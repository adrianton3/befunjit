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
        return [initialPath, loopingPath]
      else
        return [path]

    if currentChar == '|' or currentChar == '_' or currentChar == '?' or currentChar == '@'
      return [path]

    path.push pointer.x, pointer.y, pointer.dir, currentChar

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
		newPaths = @_getPath pointer.x, pointer.y, pointer.dir

		if newPaths.length == 2
			# cyclic path
			graph[hash].push { path: newPaths, to: null }
		else
			# simple path
			newPath = newPaths[0]

			destination = if newPath.getAsList().length > 0
				pathEndPoint = newPath.getEndPoint()
				getPointer pathEndPoint, @playfield.getSize(), pathEndPoint.dir
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
			if edge.paths?
				initial = assemble edge.paths[0]
				cycle = assemble edge.paths[1]
				edge.code = """
					#{initial}
					while (runtime.isAlive()) {
						#{cycle}
					}
				"""
			else if edge.path?
				edge.code = assemble edge.path

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