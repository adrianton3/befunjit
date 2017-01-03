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


		makeEdge = (code, to) ->
			assemble: ->
				"""
					#{code}
					branchFlag = programState.pop()
				"""
			to: to


		beforeEach ->
			jasmine.addMatchers befTest.CustomMatchers


		it 'assembles a tree', ->
			graph =
				start: 'a'
				nodes:
					a: [
						(makeEdge 'programState.emit("p1")', 'b')
					]
					b: [
						(makeEdge 'programState.emit("p2")', 'c')
						(makeEdge 'programState.emit("p3")', 'd')
					]

			programState = execute (assemble graph), [true]

			expect programState.messages
			.toEqual ['p1', 'p2']

		it 'assembles the minimal chain', ->
			graph =
				start: 's'
				nodes:
					s: [
						(makeEdge 'programState.emit("s")', 'a')
					]
					a: [
						(makeEdge 'programState.emit("p11")', 'b')
						(makeEdge 'programState.emit("p12")', 'b')
					]
					b: [
						(makeEdge 'programState.emit("p21")', 'a')
						(makeEdge 'programState.emit("p22")', 'a')
					]

			programState = execute (assemble graph), [true, true, true]

			expect programState.messages
			.toEqual ['s', 'p11', 'p21']

		it 'assembles a cycle', ->
			graph =
				start: 's'
				nodes:
					s: [
						(makeEdge 'programState.emit("s")', 'a')
					]
					a: [
						(makeEdge 'programState.emit("p1")', 'a')
						(makeEdge 'programState.emit("p2")', 'a')
					]

			programState = execute (assemble graph), [true, true, false, true]

			expect programState.messages
			.toStartWith ['s', 'p1', 'p2', 'p1', 'p1']