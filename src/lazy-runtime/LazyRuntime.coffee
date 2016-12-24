'use strict'

LazyRuntime = ->
	@playfield = null
	@pathSet = null

	# used for statistics/debugging
	@stats =
		compileCalls: 0
		jumpsPerformed: 0

	return


LazyRuntime::_getPath = (x, y, dir) ->
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
				loopingPath.looping = true
				return {
					type: 'composed'
					initialPath: initialPath
					loopingPath: loopingPath
				}
			else
				path.looping = true
				return {
					type: 'looping'
					loopingPath: path
				}

		path.push pointer.x, pointer.y, pointer.dir, currentChar

		if currentChar in ['|', '_', '?', '@', 'p']
			return {
				type: 'simple'
				path: path
			}

		if currentChar == '#'
			pointer.advance()

		pointer.advance()


LazyRuntime::put = (x, y, e) ->
	return if not @playfield.isInside x, y # exit early

	paths = @playfield.getPathsThrough x, y
	paths.forEach (path) =>
		@pathSet.remove path
		@playfield.removePath path
		return

	@playfield.setAt x, y, e

	return


LazyRuntime::get = (x, y) ->
	return 0 if not @playfield.isInside x, y

	char = @playfield.getAt x, y
	char.charCodeAt 0


LazyRuntime::_registerPath = (path, compiler) ->
	@stats.compileCalls++
	code ="""
		stack = programState.stack;
		#{compiler.assemble path}
	"""
	path.code = code
	path.body = new Function 'programState', code

	if path.list.length > 0
		@pathSet.add path
		@playfield.addPath path

	return


LazyRuntime::_getCurrentPath = ({ x, y, dir }, compiler) ->
	path = @pathSet.getStartingFrom x, y, dir

	if not path?
		newPath = @_getPath x, y, dir

		path = switch newPath.type
			when 'simple'
				@_registerPath newPath.path, compiler
				newPath.path
			when 'looping'
				@_registerPath newPath.loopingPath, compiler
				newPath.loopingPath
			when 'composed'
				@_registerPath newPath.initialPath, compiler
				@_registerPath newPath.loopingPath, compiler
				newPath.initialPath

	path


LazyRuntime::_turn = (pointer, char) ->
	if char == 'p'
		e = String.fromCharCode @programState.pop()
		y = @programState.pop()
		x = @programState.pop()
		@put x, y, e
	else
		dir = switch char
			when '|'
				if @programState.pop() then '^' else 'v'
			when '_'
				if @programState.pop() then '<' else '>'
			when '?'
				'^<v>'[Math.random() * 4 | 0]

		pointer.turn dir
	
	pointer.advance()

	return


LazyRuntime::execute = (@playfield, options, input = []) ->
	options ?= {}
	options.jumpLimit ?= -1
	options.compiler ?= bef.OptimizingCompiler

	@stats.compileCalls = 0
	@stats.jumpsPerformed = 0

	@pathSet = new bef.PathSet()
	@programState = new bef.ProgramState @
	@programState.setInput input
	pointer = new bef.Pointer 0, 0, '>', @playfield.getSize()

	loop
		# artificial limit to prevent potentially non-breaking loops
		break if @stats.jumpsPerformed == options.jumpLimit

		@stats.jumpsPerformed++

		@currentPath = @_getCurrentPath pointer, options.compiler

		# executing the compiled path
		@currentPath.body @programState

		if @currentPath.list.length
			pathEndPoint = @currentPath.getEndPoint()
			pointer.set pathEndPoint.x, pathEndPoint.y, pathEndPoint.dir

			if @currentPath.looping
				pointer.advance()
				continue

		currentChar = @playfield.getAt pointer.x, pointer.y

		# program ended
		break if currentChar == '@'

		@_turn pointer, currentChar

	return


window.bef ?= {}
window.bef.LazyRuntime = LazyRuntime