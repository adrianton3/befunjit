describe 'OptimizingCompiler', ->
	Path = bef.Path
	ProgramState = bef.ProgramState
	OptimizingCompiler = bef.OptimizingCompiler

	getPath = (string) ->
		path = new Path()
		stringMode = false
		(string.split '').forEach (char) ->
			if char == '"'
				stringMode = !stringMode
				path.push 0, 0, '>', char, false
			else
				path.push 0, 0, '>', char, stringMode
		path


	getProgramState = (stack = [], input = []) ->
		programState = new ProgramState()
		programState.stack = stack
		programState.setInput input

		(spyOn programState, 'push').and.callThrough()
		(spyOn programState, 'pop').and.callThrough()
		spyOn programState, 'put'
		(spyOn programState, 'get').and.returnValue 55

		programState


	execute = (string, stack, input, pathInvalidatedAhead = false) ->
		path = getPath string
		OptimizingCompiler.compile path

		programState = getProgramState stack, input
		programState.flags.pathInvalidatedAhead = pathInvalidatedAhead
		path.body programState

		programState


	it 'compiles an empty path', ->
		programState = execute ''
		(expect programState.push.calls.count()).toEqual 0
		(expect programState.pop.calls.count()).toEqual 0
		(expect programState.stack).toEqual []

	it 'pushes data on the stack', ->
		programState = execute '123'
		(expect programState.push.calls.count()).toEqual 1
		(expect programState.pop.calls.count()).toEqual 0
		(expect programState.stack).toEqual [1, 2, 3]

	describe 'binary operators', ->
		describe '+', ->
			it 'resolves entirely at compile time', ->
				programState = execute '12+'
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 0
				(expect programState.stack).toEqual [3]

			it 'resolves partially at compile time', ->
				programState = execute '1+', [2]
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 1
				(expect programState.stack).toEqual [3]

			it 'does not resolve at compile time', ->
				programState = execute '+', [1, 2]
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 2
				(expect programState.stack).toEqual [3]

		describe '-', ->
			it 'resolves entirely at compile time', ->
				programState = execute '23-'
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 0
				(expect programState.stack).toEqual [-1]

			it 'resolves partially at compile time', ->
				programState = execute '3-', [2]
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 1
				(expect programState.stack).toEqual [-1]

			it 'does not resolve at compile time', ->
				programState = execute '-', [2, 3]
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 2
				(expect programState.stack).toEqual [-1]

		describe '*', ->
			it 'resolves entirely at compile time', ->
				programState = execute '23*'
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 0
				(expect programState.stack).toEqual [6]

			it 'resolves partially at compile time', ->
				programState = execute '3*', [2]
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 1
				(expect programState.stack).toEqual [6]

			it 'does not resolve at compile time', ->
				programState = execute '*', [2, 3]
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 2
				(expect programState.stack).toEqual [6]

		describe '/', ->
			it 'resolves entirely at compile time', ->
				programState = execute '92/'
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 0
				(expect programState.stack).toEqual [4]

			it 'resolves partially at compile time', ->
				programState = execute '2/', [9]
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 1
				(expect programState.stack).toEqual [4]

			it 'does not resolve at compile time', ->
				programState = execute '/', [9, 2]
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 2
				(expect programState.stack).toEqual [4]

		describe '`', ->
			it 'resolves entirely at compile time', ->
				programState = execute '92`'
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 0
				(expect programState.stack).toEqual [1]

			it 'resolves partially at compile time', ->
				programState = execute '2`', [9]
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 1
				(expect programState.stack).toEqual [1]

			it 'does not resolve at compile time', ->
				programState = execute '`', [9, 2]
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 2
				(expect programState.stack).toEqual [1]

	describe '!', ->
		it 'resolves at compile time', ->
			programState = execute '2!'
			(expect programState.push.calls.count()).toEqual 1
			(expect programState.pop.calls.count()).toEqual 0
			(expect programState.stack).toEqual [0]

		it 'does not resolve at compile time', ->
			programState = execute '!', [2]
			(expect programState.push.calls.count()).toEqual 1
			(expect programState.pop.calls.count()).toEqual 1
			(expect programState.stack).toEqual [0]

	describe 'literals', ->
		describe '0..9', ->
			it 'pushes one digit', ->
				programState = execute '9'
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 0
				(expect programState.stack).toEqual [9]

			it 'pushes more digits', ->
				programState = execute '1234567'
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 0
				(expect programState.stack).toEqual [1, 2, 3, 4, 5, 6, 7]


		describe 'strings', ->
			it 'pushes no character', ->
				programState = execute '""'
				(expect programState.push.calls.count()).toEqual 0
				(expect programState.pop.calls.count()).toEqual 0
				(expect programState.stack).toEqual []

			it 'pushes one character', ->
				programState = execute '"9"'
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 0
				(expect programState.stack).toEqual [57]

			it 'pushes more characters', ->
				programState = execute '"123"'
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 0
				(expect programState.stack).toEqual [49, 50, 51]


	describe 'stack operators', ->
		describe ':', ->
			it 'resolves at compile time', ->
				programState = execute '1:'
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 0
				(expect programState.stack).toEqual [1, 1]

			it 'does not resolve at compile time', ->
				programState = execute ':', [1]
				(expect programState.push.calls.count()).toEqual 0
				(expect programState.pop.calls.count()).toEqual 0
				# calls .duplicate
				(expect programState.stack).toEqual [1, 1]

		describe '\\', ->
			it 'resolves at compile time', ->
				programState = execute '12\\'
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 0
				(expect programState.stack).toEqual [2, 1]

			it 'resolves partially at compile time', ->
				programState = execute '3\\', [2]
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 1
				(expect programState.stack).toEqual [3, 2]

			it 'does not resolve at compile time', ->
				programState = execute '\\', [1, 2]
				(expect programState.push.calls.count()).toEqual 0
				(expect programState.pop.calls.count()).toEqual 0
				(expect programState.stack).toEqual [2, 1]

		describe '$', ->
			it 'resolves at compile time', ->
				programState = execute '1$'
				(expect programState.push.calls.count()).toEqual 0
				(expect programState.pop.calls.count()).toEqual 0
				(expect programState.stack).toEqual []

			it 'does not resolve at compile time', ->
				programState = execute '$', [1, 2]
				(expect programState.push.calls.count()).toEqual 0
				(expect programState.pop.calls.count()).toEqual 1
				(expect programState.stack).toEqual [1]


	describe 'output', ->
		describe '.', ->
			it 'resolves at compile time', ->
				programState = execute '1.'
				(expect programState.push.calls.count()).toEqual 0
				(expect programState.pop.calls.count()).toEqual 0
				(expect programState.stack).toEqual []
				(expect programState.outRecord).toEqual [1]

			it 'does not resolve at compile time', ->
				programState = execute '.', [1]
				(expect programState.push.calls.count()).toEqual 0
				(expect programState.pop.calls.count()).toEqual 1
				(expect programState.stack).toEqual []
				(expect programState.outRecord).toEqual [1]

		describe ',', ->
			it 'resolves at compile time', ->
				programState = execute '"1",'
				(expect programState.push.calls.count()).toEqual 0
				(expect programState.pop.calls.count()).toEqual 0
				(expect programState.stack).toEqual []
				(expect programState.outRecord).toEqual ['1']

			it 'escapes \'', ->
				programState = execute '58*1-,'
				(expect programState.push.calls.count()).toEqual 0
				(expect programState.pop.calls.count()).toEqual 0
				(expect programState.stack).toEqual []
				(expect programState.outRecord).toEqual ['\'']

			it 'escapes \\', ->
				programState = execute '2999*++,'
				(expect programState.push.calls.count()).toEqual 0
				(expect programState.pop.calls.count()).toEqual 0
				(expect programState.stack).toEqual []
				(expect programState.outRecord).toEqual ['\\']

			it 'does not resolve at compile time', ->
				programState = execute ',', [49]
				(expect programState.push.calls.count()).toEqual 0
				(expect programState.pop.calls.count()).toEqual 1
				(expect programState.stack).toEqual []
				(expect programState.outRecord).toEqual ['1']


	describe 'input', ->
		describe '&', ->
			it 'dumps the stack before adding to it', ->
				programState = execute '123&', [], [4]
				(expect programState.push.calls.count()).toEqual 2
				(expect programState.pop.calls.count()).toEqual 0
				(expect programState.stack).toEqual [1, 2, 3, 4]

			it 'does not dump an empty stack before adding to it', ->
				programState = execute '&', [], [4]
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 0
				(expect programState.stack).toEqual [4]

		describe '~', ->
			it 'dumps the stack before adding to it', ->
				programState = execute '123~', [], ['4']
				(expect programState.push.calls.count()).toEqual 2
				(expect programState.pop.calls.count()).toEqual 0
				(expect programState.stack).toEqual [1, 2, 3, 52]

			it 'does not dump an empty stack before adding to it', ->
				programState = execute '~', [], ['4']
				(expect programState.push.calls.count()).toEqual 1
				(expect programState.pop.calls.count()).toEqual 0
				(expect programState.stack).toEqual [52]

	describe 'p', ->
		it 'gets stack entries at compile time', ->
			programState = execute '123p'
			(expect programState.push.calls.count()).toEqual 0
			(expect programState.pop.calls.count()).toEqual 0
			(expect programState.put.calls.count()).toEqual 1

		it 'gets no stack entries at compile time', ->
			programState = execute 'p', [1, 2, 3]
			(expect programState.push.calls.count()).toEqual 0
			(expect programState.pop.calls.count()).toEqual 3
			(expect programState.put.calls.count()).toEqual 1

		it 'dumps the stack if path was invalidated ahead', ->
			programState = execute '123456p789', [], [], true
			(expect programState.push.calls.count()).toEqual 1
			(expect programState.pop.calls.count()).toEqual 0
			(expect programState.put.calls.count()).toEqual 1
			(expect programState.stack).toEqual [1, 2, 3]

	describe 'g', ->
		it 'gets all stack entries at compile time', ->
			programState = execute '12g'
			(expect programState.push.calls.count()).toEqual 1
			(expect programState.pop.calls.count()).toEqual 0
			(expect programState.get.calls.count()).toEqual 1
			(expect programState.stack).toEqual [55]

		it 'gets some stack entries at compile time', ->
			programState = execute '2g', [1]
			(expect programState.push.calls.count()).toEqual 1
			(expect programState.pop.calls.count()).toEqual 1
			(expect programState.get.calls.count()).toEqual 1
			(expect programState.stack).toEqual [55]

		it 'gets no stack entries at compile time', ->
			programState = execute 'g', [1, 2]
			(expect programState.push.calls.count()).toEqual 1
			(expect programState.pop.calls.count()).toEqual 2
			(expect programState.get.calls.count()).toEqual 1
			(expect programState.stack).toEqual [55]

		it 'preserves the existing stack', ->
			programState = execute '12345g'
			(expect programState.push.calls.count()).toEqual 2
			(expect programState.pop.calls.count()).toEqual 0
			(expect programState.get.calls.count()).toEqual 1
			(expect programState.stack).toEqual [1, 2, 3, 55]