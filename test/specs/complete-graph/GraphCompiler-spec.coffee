describe 'GraphCompiler', ->
	GraphCompiler = bef.GraphCompiler

	describe 'assemble', ->
		assemble = GraphCompiler.assemble


		ProgramState = (stack = []) ->
			@stack = stack
			@messages = []
			@exitRequest = false
			return

		ProgramState::isAlive = ->	@stack.length > 0 and not @exitRequest
		ProgramState::exit = -> @exitRequest = true
		ProgramState::emit = (message) -> @messages.push message
		ProgramState::pop = -> @stack.pop()


		execute = (code, stack) ->
			thunk = new Function 'programState', code
			programState = new ProgramState stack
			thunk programState
			programState


		it 'assembles a tree', ->
			graph =
				start: 'a'
				nodes:
					a: [{ code: 'programState.emit("p1")', to: 'b' }]
					b: [{ code: 'programState.emit("p2")', to: 'c' }, { code: 'programState.emit("p3")', to: 'd' }]

			programState = execute (assemble graph), [true]

			expect programState.messages
			.toEqual ['p1', 'p2']

		it 'assembles the minimal chain', ->
			graph =
				start: 'a'
				nodes:
					a: [
						{ code: 'programState.emit("p11")', to: 'b' },
						{ code: 'programState.emit("p12")', to: 'b' }
					]
					b: [
						{ code: 'programState.emit("p21")', to: 'a' },
						{ code: 'programState.emit("p22")', to: 'a' }
					]

			programState = execute (assemble graph), [true, true]

			expect programState.messages
			.toEqual ['p11', 'p21']

		it 'assembles a cycle', ->
			graph =
				start: 'a'
				nodes:
					a: [
						{ code: 'programState.emit("p1")', to: 'a' },
						{ code: 'programState.emit("p2")', to: 'a' }
					]

			programState = execute (assemble graph), [true, true, false, true]

			expect programState.messages
			.toEqual ['p1', 'p2', 'p1', 'p1']