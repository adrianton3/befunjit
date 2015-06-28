describe 'GraphCompiler', ->
	GraphCompiler = bef.GraphCompiler

	describe 'assemble', ->
		assemble = GraphCompiler.assemble


		Runtime = (stack = []) ->
			@stack = stack
			@messages = []
			@exitRequest = false
			return

		Runtime::isAlive = ->	@stack.length > 0 and not @exitRequest
		Runtime::exit = -> @exitRequest = true
		Runtime::emit = (message) -> @messages.push message
		Runtime::pop = -> @stack.pop()


		execute = (code, stack) ->
			thunk = new Function 'runtime', code
			runtime = new Runtime stack
			thunk runtime
			runtime


		it 'assembles a tree', ->
			graph =
				start: 'a'
				nodes:
					a: [{ code: 'runtime.emit("p1")', to: 'b' }]
					b: [{ code: 'runtime.emit("p2")', to: 'c' }, { code: 'runtime.emit("p3")', to: 'd' }]

			runtime = execute (assemble graph), [true]

			expect runtime.messages
			.toEqual ['p1', 'p2']

		it 'assembles the minimal chain', ->
			graph =
				start: 'a'
				nodes:
					a: [
						{ code: 'runtime.emit("p11")', to: 'b' },
						{ code: 'runtime.emit("p12")', to: 'b' }
					]
					b: [
						{ code: 'runtime.emit("p21")', to: 'a' },
						{ code: 'runtime.emit("p22")', to: 'a' }
					]

			runtime = execute (assemble graph), [true, true]

			expect runtime.messages
			.toEqual ['p11', 'p21']