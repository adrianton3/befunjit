'use strict'


{ findPath } = bef.PathFinder


EagerRuntime = ->
	@playfield = null
	@pathSet = null

	# used for statistics/debugging
	@stats =
		compileCalls: 0
		jumpsPerformed: 0

	return


canReach = (graph, start, targets) ->
	visited = new Set

	traverse = (start) ->
		return true if targets.has start
		return false if visited.has start
		visited.add start
		graph[start].some ({ to }) -> traverse to

	traverse start


EagerRuntime::put = (x, y, e, currentX, currentY, currentDir, from, to) ->
	# exit early if the coordinates are not valid
	return if not @playfield.isInside x, y

	# erase all paths that pass through the coordinates
	paths = @playfield.getPathsThrough x, y
	for path in paths
		@pathSet.remove path
		@playfield.removePath path

	# write to the cell
	@playfield.setAt x, y, e

	# figure out if the current path is invalidated
	if paths.length > 0
		# check if the affected edges are reachable
		targets = paths.reduce (targets, path) ->
			targets.add path.from
			targets
		, new Set

		if canReach @graph, to, targets
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
		newPath = findPath @playfield, pointer

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
	for nodeName in Object.keys graph
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

			return

	# generate code for the whole graph
	@code = bef.GraphCompiler.assemble(
		{ start: 'start', nodes: graph }
		options
	)

	new Function 'programState', @code


registerGraph = (graph, playfield, pathSet) ->
	playfield.clearPaths()
	pathSet.clear()

	for nodeName in Object.keys graph
		edges = graph[nodeName]
		for { path } in edges
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