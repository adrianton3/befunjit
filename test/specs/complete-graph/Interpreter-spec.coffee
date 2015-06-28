describe 'Interpreter', ->
	Playfield = bef.Playfield
	Interpreter = bef.Interpreter2

	getPlayfield = (string, width, height) ->
		lines = string.split '\n'
		width ?= Math.max (lines.map (line) -> line.length)...
		height ?= lines.length

		playfield = new Playfield width, height
		playfield.fromString string, width, height
		playfield

	getInterpreter = (string, width, height) ->
		playfield = getPlayfield string, width, height
		interpreter = new Interpreter()
		interpreter.playfield = playfield
		interpreter


	describe 'buildGraph', ->
		buildGraph = (string) ->
			interpreter = getInterpreter string
			start = new bef.Pointer 0, 0, '>', interpreter.playfield.getSize()
			interpreter.buildGraph start

		it 'builds a graph from a simple path', ->
			graph = buildGraph 'abc@'

			(expect graph['start']).toBeDefined()
			(expect graph['start'].length).toEqual 1

		it 'builds a graph from a branching path', ->
			graph = buildGraph '''
				abv
				@c_d@
			'''

			(expect graph['start']).toBeDefined()
			(expect graph['start'].length).toEqual 1
			(expect graph['start'][0].to).toEqual '2_1'

			(expect graph['2_1']).toBeDefined()
			(expect graph['2_1'].length).toEqual 2

		it 'builds a graph from a cycling path', ->
			graph = buildGraph '''
				abv
				vc_dv
				>e^g<
			'''

			(expect graph['start']).toBeDefined()
			(expect graph['start'].length).toEqual 1
			(expect graph['start'][0].to).toEqual '2_1'

			(expect graph['2_1']).toBeDefined()
			(expect graph['2_1'].length).toEqual 2
			(expect graph['2_1'][0].to).toEqual '2_1'
			(expect graph['2_1'][1].to).toEqual '2_1'

		it 'builds a graph from a doubly cycling path', ->
			graph = buildGraph 'a_b_c'

			(expect graph['start']).toBeDefined()
			(expect graph['start'].length).toEqual 1
			(expect graph['start'][0].to).toEqual '1_0'

			(expect graph['1_0']).toBeDefined()
			(expect graph['1_0'].length).toEqual 2
			(expect graph['1_0'][0].to).toEqual '3_0'
			(expect graph['1_0'][1].to).toEqual '3_0'

			(expect graph['3_0']).toBeDefined()
			(expect graph['3_0'].length).toEqual 2
			(expect graph['3_0'][0].to).toEqual '1_0'
			(expect graph['3_0'][1].to).toEqual '1_0'

		it 'handles adjacent conditionals', ->
			graph = buildGraph 'a__b'

			(expect graph['start']).toBeDefined()
			(expect graph['start'].length).toEqual 1
			(expect graph['start'][0].to).toEqual '1_0'

			(expect graph['1_0']).toBeDefined()
			(expect graph['1_0'].length).toEqual 2
			(expect graph['1_0'][0].to).toEqual '2_0'
			(expect graph['1_0'][1].to).toEqual '2_0'

			(expect graph['2_0']).toBeDefined()
			(expect graph['2_0'].length).toEqual 2
			(expect graph['2_0'][0].to).toEqual '1_0'
			(expect graph['2_0'][1].to).toEqual '1_0'

		it 'handles conditionals in the starting location', ->
			graph = buildGraph '_ab'

			(expect graph['start']).toBeDefined()
			(expect graph['start'].length).toEqual 1
			(expect graph['start'][0].to).toEqual '0_0'

			(expect graph['0_0']).toBeDefined()
			(expect graph['0_0'].length).toEqual 2
			(expect graph['0_0'][0].to).toEqual '0_0'
			(expect graph['0_0'][1].to).toEqual '0_0'


	describe 'compile', ->
		Runtime = bef.Runtime
		Runtime::isAlive = ->	not @exitRequest

		compile = (string) ->
			interpreter = getInterpreter string
			start = new bef.Pointer 0, 0, '>', interpreter.playfield.getSize()
			graph = interpreter.buildGraph start
			interpreter.compile graph, { compiler: bef.BasicCompiler }

		execute = (string, stack) ->
			thunk = compile string
			runtime = new Runtime stack
			thunk runtime
			runtime

		it 'adds 2 numbers', ->
			{ stack, outRecord } = execute '37+@'

			(expect stack).toEqual [10]
			(expect outRecord).toEqual []

		it 'performs arithmetic operations', ->
			{ stack, outRecord } = execute '2357*+-@'

			(expect stack).toEqual [5 * 7 + 3 - 2]
			(expect outRecord).toEqual []