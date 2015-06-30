'use strict'

Interpreter = ->
	@playfield = null
	@pathSet = null

	# used for statistics/debugging
	@stats =
		compileCalls: 0
		jumpsPerformed: 0

	return


Interpreter::_getPath = (x, y, dir) ->
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

		if currentChar in ['|', '_', '?', '@']
			return {
				type: 'simple'
				path: path
			}

		if currentChar == '#'
			pointer.advance()

		pointer.advance()


Interpreter::put = (x, y, e, currentX, currentY, currentDir, currentIndex) ->
	return if not @playfield.isInside x, y # exit early

	paths = @playfield.getPathsThrough x, y
	paths.forEach (path) =>
		@pathSet.remove path
		@playfield.removePath path
	@playfield.setAt x, y, e

	lastEntry = @currentPath.getLastEntryThrough x, y
	if lastEntry?.index > currentIndex
		@runtime.flags.pathInvalidatedAhead = true
		@runtime.flags.exitPoint =
			x: currentX
			y: currentY
			dir: currentDir


Interpreter::get = (x, y) ->
	return 0 if not @playfield.isInside x, y

	char = @playfield.getAt x, y
	char.charCodeAt 0


getHash = (pointer) ->
	"#{pointer.x}_#{pointer.y}"


getPointer = (point, space, dir) ->
	pointer = new bef.Pointer point.x, point.y, dir, space
	pointer.advance()


Interpreter::buildGraph = (start) ->
	graph = {}

	dispatch = (hash, destination) =>
		currentChar = @playfield.getAt destination.x, destination.y
		partial = getPointer.bind null, destination, @playfield.getSize()
		if currentChar == '_'
			buildEdge hash, partial '<'
			buildEdge hash, partial '>'
		else if currentChar == '|'
			buildEdge hash, partial '^'
			buildEdge hash, partial 'v'
		else if currentChar == '?'
			buildEdge hash, partial '^'
			buildEdge hash, partial 'v'
			buildEdge hash, partial '<'
			buildEdge hash, partial '>'
		else if currentChar == '@'
			console.log 'exit'
		else
			console.log "unknown char #{currentChar}"
		return


	buildEdge = (hash, pointer) =>
		# seek out a path
		newPath = @_getPath pointer.x, pointer.y, pointer.dir

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


Interpreter::compile = (graph, options) ->
	assemble = options.compiler.assemble

	# generate code for all paths
	(Object.keys graph).forEach (nodeName) ->
		edges = graph[nodeName]
		edges.forEach (edge) ->
			{ path, path: { type }} = edge
			edge.code = switch type
				when 'composed'
					"""
						#{assemble path.initialPath}
						while (runtime.isAlive()) {
							#{assemble path.loopingPath}
						}
					"""
				when 'looping'
					"""
						while (runtime.isAlive()) {
							#{assemble path.loopingPath}
						}
					"""
				when 'simple'
					assemble path.path

	# generate code for the whole graph
	code = bef.GraphCompiler.assemble
		start: 'start'
		nodes: graph

	new Function 'runtime', code


Interpreter::execute = (@playfield, options, input = []) ->
	options ?= {}
	options.jumpLimit ?= -1
	options.compiler ?= bef.OptimizinsCompiler

	@stats.compileCalls = 0
	@stats.jumpsPerformed = 0

	@pathSet = new bef.PathSet()
	@runtime = new bef.Runtime @
	@runtime.setInput input

	start = new bef.Pointer 0, 0, '>', @playfield.getSize()

	# loop
	graph = @buildGraph start
	program = @compile graph

	program @runtime
	# if path invalidated ahead
	# start = exit point
	# else break

	return


window.bef ?= {}
window.bef.Interpreter2 = Interpreter