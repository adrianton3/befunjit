'use strict'


{ findPath } = bef.PathFinder
S = bef.Symbols


LazyRuntime = ->
	@playfield = null
	@pathSet = null

	# used for statistics/debugging
	@stats =
		compileCalls: 0
		jumpsPerformed: 0

	return


LazyRuntime::put = (y, x, v) ->
	return if not @playfield.isInside x, y

	paths = @playfield.getPathsThrough x, y
	for path in paths
		@pathSet.remove path
		@playfield.removePath path

	@playfield.setAt x, y, v

	return


LazyRuntime::get = (x, y) ->
	if @playfield.isInside x, y
		@playfield.getAt x, y
	else
		0


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


LazyRuntime::_getCurrentPath = (start, compiler) ->
	path = @pathSet.getStartingFrom start.x, start.y, start.dir

	return path if path?

	{ type } = newPath = findPath @playfield, start

	if type == 'simple'
		newPath.path.ending = null
		@_registerPath newPath.path, compiler
		newPath.path
	else if type == 'looping'
		newPath.loopingPath.ending = null
		@_registerPath newPath.loopingPath, compiler
		newPath.loopingPath
	else if type == 'composed'
		newPath.initialPath.ending = null
		newPath.loopingPath.ending = null
		@_registerPath newPath.initialPath, compiler
		@_registerPath newPath.loopingPath, compiler
		newPath.initialPath


LazyRuntime::_turn = (pointer, charCode) ->
	dir =
		if charCode == S.IFV
			if @programState.pop() != 0 then S.UP else S.DOWN
		else if charCode == S.IFH
			if @programState.pop() != 0 then S.LEFT else S.RIGHT
		else if charCode == S.RAND
			[S.UP, S.LEFT, S.DOWN, S.RIGHT][Math.random() * 4 | 0]

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
	pointer = new bef.Pointer 0, 0, S.RIGHT, @playfield.getSize()

	loop
		# artificial limit to prevent potentially non-breaking loops
		break if @stats.jumpsPerformed == options.jumpLimit

		@stats.jumpsPerformed++

		currentPath = @_getCurrentPath pointer, options.compiler

		# executing the compiled path
		currentPath.body @programState

		if currentPath.list.length > 0
			pathEndPoint = currentPath.getEndPoint()
			pointer.set pathEndPoint.x, pathEndPoint.y, pathEndPoint.dir

			if currentPath.looping
				pointer.advance()
				continue

		charCode = @playfield.getAt pointer.x, pointer.y

		# program ended
		break if charCode == S.END

		if charCode == S.PUT
			@put @programState.pop(), @programState.pop(), @programState.pop()
			pointer.advance()
		else
			@_turn pointer, charCode

	return


window.bef ?= {}
window.bef.LazyRuntime = LazyRuntime