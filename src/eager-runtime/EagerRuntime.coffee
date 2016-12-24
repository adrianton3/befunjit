'use strict'

EagerRuntime = ->
	@playfield = null
	@pathSet = null

	# used for statistics/debugging
	@stats =
		compileCalls: 0
		jumpsPerformed: 0

	return


EagerRuntime::_getPath = (x, y, dir) ->
	path = new bef.Path()
	pointer = new bef.Pointer x, y, dir, @playfield.getSize()

	loop
		currentChar = @playfield.getAt pointer.x, pointer.y

		# processing string
		if currentChar == '"'
			path.push pointer.x, pointer.y, pointer.dir, currentChar
			loop
				pointer.advance()
				currentChar = @playfield.getAt pointer.x, pointer.y
				if currentChar == '"'
					path.push pointer.x, pointer.y, pointer.dir, currentChar
					break
				path.push pointer.x, pointer.y, pointer.dir, currentChar, true
			pointer.advance()
			continue

		pointer.turn currentChar

		if path.hasNonString pointer.x, pointer.y, pointer.dir
			splitPosition = (path.getEntryAt pointer.x, pointer.y, pointer.dir).index
			if splitPosition > 0
				initialPath = path.prefix splitPosition
				loopingPath = path.suffix splitPosition
				return {
					type: 'composed'
					initialPath: initialPath
					loopingPath: loopingPath
				}
			else
				return {
					type: 'looping'
					loopingPath: path
				}

		path.push pointer.x, pointer.y, pointer.dir, currentChar

		if currentChar in ['|', '_', '?', '@', 'p']
			path.ending = {
				x: pointer.x
				y: pointer.y
				dir: pointer.dir
				char: currentChar
			}
			return {
				type: 'simple'
				path: path
			}

		if currentChar == '#'
			pointer.advance()

		pointer.advance()


canReach = do ->
	visited = new Set

	(graph, start, targets) ->
		traverse = (start) ->
			return true if targets.has start
			return false if visited.has start
			visited.add start
			graph[start].some ({ to }) -> traverse to

		traverse start


getPath = (graph, from, to) ->
	for edge in graph[from]
		if edge.to == to
			return edge
	return


EagerRuntime::put = (x, y, e, currentX, currentY, currentDir, from, to) ->
	# exit early if the coordinates are not valid
	return if not @playfield.isInside x, y

	# erase all paths that pass through the coordinates
	paths = @playfield.getPathsThrough x, y
	paths.forEach (path) =>
		@pathSet.remove path
		@playfield.removePath path
		return

	# write to the cell
	@playfield.setAt x, y, e

	# figure out if the current path is invalidated
	if paths.length > 0
		# check if the affected edges are reachable
		targets = paths.reduce (targets, path) ->
			targets.add path.from
		, new Set

		# check if current edge is affected
		{ path: currentPath } = getPath @graph, from, to
		lastEntry = switch currentPath.type
			when 'simple'
				currentPath.path.getLastEntryThrough x, y
			when 'looping'
				currentPath.loopingPath.getLastEntryThrough x, y
			when 'composed'
				(currentPath.initialPath.getLastEntryThrough x, y) ?
					(currentPath.loopingPath.getLastEntryThrough x, y)

		if lastEntry? or (canReach @graph, to, targets)
			@programState.flags.pathInvalidatedAhead = true
			@programState.flags.exitPoint =
				x: currentX
				y: currentY
				dir: currentDir

	return


EagerRuntime::get = (x, y) ->
	return 0 if not @playfield.isInside x, y

	char = @playfield.getAt x, y
	char.charCodeAt 0


getHash = (pointer) ->
	"#{pointer.x}_#{pointer.y}"


getPointer = (point, space, dir) ->
	pointer = new bef.Pointer point.x, point.y, dir, space
	pointer.advance()


EagerRuntime::buildGraph = (start) ->
	graph = {}

	dispatch = (hash, destination) =>
		currentChar = @playfield.getAt destination.x, destination.y
		partial = getPointer.bind null, destination, @playfield.getSize()

		switch currentChar
			when '_'
				buildEdge hash, partial '<'
				buildEdge hash, partial '>'
			when '|'
				buildEdge hash, partial '^'
				buildEdge hash, partial 'v'
			when '?'
				buildEdge hash, partial '^'
				buildEdge hash, partial 'v'
				buildEdge hash, partial '<'
				buildEdge hash, partial '>'
			when 'p'
				buildEdge hash, partial destination.dir

		return


	buildEdge = (hash, pointer) =>
		# seek out a path
		newPath = @_getPath pointer.x, pointer.y, pointer.dir

		# remember where this path comes from and where it leads to
		newPath.path?.from = hash
		newPath.initialPath?.from = hash
		newPath.loopingPath?.from = hash

		# only simple paths lead somewhere
		newPath.path?.to = getHash newPath.path.getEndPoint()

		if newPath.type != 'simple'
			# cyclic path
			graph[hash].push { path: newPath, to: null }
		else
			# simple path
			destination = if newPath.path.getAsList().length > 0
				newPath.path.getEndPoint()
			else
				pointer

			newHash = getHash destination
			graph[hash].push { path: newPath, to: newHash }
			return if graph[newHash]?
			graph[newHash] = []
			dispatch newHash, destination
		return


	hash = 'start'
	graph[hash] = []
	buildEdge hash, start
	graph


EagerRuntime::compile = (graph, options) ->
	{ assemble, assembleTight } = options.compiler

	# generate code for all paths
	(Object.keys graph).forEach (nodeName) ->
		edges = graph[nodeName]
		edges.forEach (edge) ->
			{ path, path: { type }} = edge

			switch type
				when 'composed'
					edge.assemble = -> """
						#{assemble path.initialPath, options}
						while (programState.isAlive()) {
							#{assemble path.loopingPath, options}
						}
					"""
				when 'looping'
					edge.assemble = -> """
						while (programState.isAlive()) {
							#{assemble path.loopingPath, options}
						}
					"""
				when 'simple'
					edge.assemble = ->
						assemble path.path, options

					if assembleTight?
						edge.assembleTight = ->
							assembleTight path.path, options

	# generate code for the whole graph
	@code = bef.GraphCompiler.assemble(
		{ start: 'start', nodes: graph }
		options
	)

	new Function 'programState', @code


registerGraph = (graph, playfield, pathSet) ->
	playfield.clearPaths()
	pathSet.clear()
	(Object.keys graph).forEach (node) ->
		edges = graph[node]
		edges.forEach ({ path }) ->
			if path.type == 'simple'
				pathSet.add path.path
				playfield.addPath path.path
			else if path.type == 'looping'
				pathSet.add path.loopingPath
				playfield.addPath path.loopingPath
			else if path.type == 'composed'
				pathSet.add path.loopingPath
				pathSet.add path.initialPath
				playfield.addPath path.loopingPath
				playfield.addPath path.initialPath
			return
		return
	return


EagerRuntime::execute = (@playfield, options, input = []) ->
	options ?= {}
	options.jumpLimit ?= -1
	options.compiler ?= bef.OptimizingCompiler
	options.fastConditionals ?= false

	@stats.compileCalls = 0
	@stats.jumpsPerformed = 0

	@pathSet = new bef.PathSet()
	@programState = new bef.ProgramState @
	@programState.setInput input
	@programState.maxChecks = options.jumpLimit

	start = new bef.Pointer 0, 0, '>', @playfield.getSize()

	loop
		@stats.compileCalls++
		@graph = @buildGraph start
		registerGraph @graph, @playfield, @pathSet
		program = @compile @graph, options

		program @programState

		if @programState.flags.pathInvalidatedAhead
			@programState.flags.pathInvalidatedAhead = false
			{ x, y, dir } = @programState.flags.exitPoint
			start.set x, y, dir
			start.advance()

		if @programState.flags.exitRequest
			break

		@stats.jumpsPerformed++
		if @stats.jumpsPerformed > options.jumpLimit
			break

	return


window.bef ?= {}
window.bef.EagerRuntime = EagerRuntime