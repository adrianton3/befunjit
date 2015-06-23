describe 'GraphCompiler', ->
	GraphCompiler = bef.GraphCompiler

	describe 'compile', ->
		compile = GraphCompiler.compile


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
			thunk = new Function 'runtime', """
				#{code}
				return runtime;
			"""
			runtime = new Runtime stack
			thunk runtime
			runtime


		it 'compiles a circular graph', ->
			graph =
				start: 'a'
				nodes:
					a: [{ path: 'runtime.emit("p1")', to: 'b' }]
					b: [{ path: 'runtime.emit("p2")', to: 'c' }]
					c: [{ path: 'return;', to: 'a' }]

			runtime = execute (compile graph), [true, false]

			expect runtime.messages
			.toEqual ['p1', 'p2']

		it 'compiles the minimal chain', ->
			graph =
				start: 'a'
				nodes:
					a: [
						{ path: 'runtime.emit("p11")', to: 'b' },
						{ path: 'runtime.emit("p12")', to: 'b' }
					]
					b: [
						{ path: 'runtime.emit("p21")', to: 'a' },
						{ path: 'runtime.emit("p22")', to: 'a' }
					]

			runtime = execute (compile graph), [true, true]

			expect runtime.messages
			.toEqual ['p11', 'p21']