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


	describe 'getPath', ->
		it 'can handle jumps on path endings', ->
			interpreter = getInterpreter 'a_b#c_d'

			path = interpreter._getPath 2, 0, '>'
			pathAsList = path.path.getAsList()
			(expect pathAsList).toEqual [
				{ x: 2, y: 0, dir: '>', char: 'b', string: false }
				{ x: 3, y: 0, dir: '>', char: '#', string: false }
				{ x: 5, y: 0, dir: '>', char: '_', string: false }
			]

	describe 'buildGraph', ->
		buildGraph = (string) ->
			interpreter = getInterpreter string
			start = new bef.Pointer 0, 0, '>', interpreter.playfield.getSize()
			interpreter.buildGraph start

		it 'builds a graph from a simple path', ->
			graph = buildGraph 'abc@'

			(expect Object.keys graph).toEqual ['start', '3_0']

			(expect graph['start']).toBeDefined()
			(expect graph['start'].length).toEqual 1

		it 'builds a graph from a branching path', ->
			graph = buildGraph '''
				abv
				@c_d@
			'''

			(expect Object.keys graph).toEqual ['start', '2_1', '0_1', '4_1']

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

			(expect Object.keys graph).toEqual ['start', '2_1']

			(expect graph['start']).toBeDefined()
			(expect graph['start'].length).toEqual 1
			(expect graph['start'][0].to).toEqual '2_1'

			(expect graph['2_1']).toBeDefined()
			(expect graph['2_1'].length).toEqual 2
			(expect graph['2_1'][0].to).toEqual '2_1'
			(expect graph['2_1'][1].to).toEqual '2_1'

		it 'builds a graph from a doubly cycling path', ->
			graph = buildGraph 'a_b_c'

			(expect Object.keys graph).toEqual ['start', '1_0', '3_0']

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

			(expect Object.keys graph).toEqual ['start', '1_0', '2_0']

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

			(expect Object.keys graph).toEqual ['start', '0_0']

			(expect graph['start']).toBeDefined()
			(expect graph['start'].length).toEqual 1
			(expect graph['start'][0].to).toEqual '0_0'

			(expect graph['0_0']).toBeDefined()
			(expect graph['0_0'].length).toEqual 2
			(expect graph['0_0'][0].to).toEqual '0_0'
			(expect graph['0_0'][1].to).toEqual '0_0'

		it 'handles skip instructions', ->
			graph = buildGraph ' _ # _'

			(expect Object.keys graph).toEqual ['start', '1_0', '5_0']

			(expect graph['start']).toBeDefined()
			(expect graph['start'].length).toEqual 1
			(expect graph['start'][0].to).toEqual '1_0'

			(expect graph['1_0']).toBeDefined()
			(expect graph['1_0'].length).toEqual 2
			(expect graph['1_0'][0].to).toEqual '5_0'
			(expect graph['1_0'][1].to).toEqual '5_0'

			(expect graph['5_0']).toBeDefined()
			(expect graph['5_0'].length).toEqual 2
			(expect graph['5_0'][0].to).toEqual '1_0'
			(expect graph['5_0'][1].to).toEqual '1_0'


	describe 'compile', ->
		Runtime = bef.Runtime
		Runtime::isAlive = ->
			return false if @exitRequest
			if @maxChecks?
				@checks ?= 0
				@checks++
				@checks < @maxChecks
			else
				true

		compile = (string) ->
			interpreter = getInterpreter string
			start = new bef.Pointer 0, 0, '>', interpreter.playfield.getSize()
			graph = interpreter.buildGraph start
			interpreter.compile graph, { compiler: bef.BasicCompiler }

		execute = (string, stack = [], maxChecks = 100) ->
			thunk = compile string
			runtime = new Runtime null # interpreter
			runtime.stack = stack
			runtime.maxChecks = maxChecks
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

		it 'branches to the left', ->
			{ stack, outRecord } = execute '''
				1 v
				@2_3@
			'''

			(expect stack).toEqual [2]
			(expect outRecord).toEqual []

		it 'branches to the right', ->
			{ stack, outRecord } = execute '''
				0 v
				@2_3@
			'''

			(expect stack).toEqual [3]
			(expect outRecord).toEqual []

		it 'executes a looping path indefinitely', ->
			{ stack, outRecord } = execute '''
				>.v
				^ <
			''', [11, 22, 33, 44, 55, 66, 77, 88, 99, 110], 6

			(expect stack).toEqual [11, 22, 33, 44, 55]
			(expect outRecord).toEqual [110, 99, 88, 77, 66]

		it 'executes a composed path indefinitely', ->
			{ stack, outRecord } = execute '''
				>>.v
				 ^ <
			''', [11, 22, 33, 44, 55, 66, 77, 88, 99, 110], 6

			(expect stack).toEqual [11, 22, 33, 44, 55]
			(expect outRecord).toEqual [110, 99, 88, 77, 66]

		it 'ping-pongs between 2 nodes indefinitely', ->
			{ stack, outRecord } = execute '0_._', [1, 11, 0, 22, 1, 33, 0, 44], 4

			(expect stack).toEqual []
			(expect outRecord).toEqual [44, 33, 22, 11, 0] # 0 ?

		it 'changes direction randomly', ->
			source = '''
				?2.@.3
				4
				.
				@
				.
				5
			'''

			thunk = execute.bind null, source

			sum = 0
			hits = []
			# run for a couple of times
			# just enough so all directions should be hit
			for i in [1..20]
				runtime = thunk()
				output = runtime.outRecord[0]
				sum += output
				hits[output] = true

			expectedHits = []
			expectedHits[2] = true
			expectedHits[3] = true
			expectedHits[4] = true
			expectedHits[5] = true
			(expect hits).toEqual expectedHits