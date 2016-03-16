describe 'EagerRuntime', ->
	Playfield = bef.Playfield
	EagerRuntime = bef.EagerRuntime

	getPlayfield = (string, width, height) ->
		playfield = new Playfield width, height
		playfield.fromString string, width, height
		playfield

	getInterpreter = (string, width, height) ->
		playfield = getPlayfield string, width, height
		eagerRuntime = new EagerRuntime()
		eagerRuntime.playfield = playfield
		eagerRuntime


	describe 'getPath', ->
		it 'can handle jumps on path endings', ->
			eagerRuntime = getInterpreter 'a_b#c_d'

			path = eagerRuntime._getPath 2, 0, '>'
			pathAsList = path.path.getAsList()
			(expect pathAsList).toEqual [
				{ x: 2, y: 0, dir: '>', char: 'b', string: false }
				{ x: 3, y: 0, dir: '>', char: '#', string: false }
				{ x: 5, y: 0, dir: '>', char: '_', string: false }
			]

	describe 'buildGraph', ->
		buildGraph = (string) ->
			eagerRuntime = getInterpreter string
			start = new bef.Pointer 0, 0, '>', eagerRuntime.playfield.getSize()
			eagerRuntime.buildGraph start

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
		compile = (string) ->
			eagerRuntime = getInterpreter string
			start = new bef.Pointer 0, 0, '>', eagerRuntime.playfield.getSize()
			graph = eagerRuntime.buildGraph start
			eagerRuntime.compile graph, { compiler: bef.OptimizingCompiler }

		execute = (string, stack = [], maxChecks = 100) ->
			thunk = compile string
			programState = new bef.ProgramState null # eagerRuntime
			programState.stack = stack
			programState.maxChecks = maxChecks
			thunk programState
			programState

		it 'adds 2 numbers', ->
			{ stack, outRecord } = execute '37+@'

			(expect stack).toEqual [10]
			(expect outRecord).toEqual []

		it 'performs arithmetic operations', ->
			{ stack, outRecord } = execute '2357*+-@'

			(expect stack).toEqual [2 - (5 * 7 + 3)]
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
				programState = thunk()
				output = programState.outRecord[0]
				sum += output
				hits[output] = true

			expectedHits = []
			expectedHits[2] = true
			expectedHits[3] = true
			expectedHits[4] = true
			expectedHits[5] = true
			(expect hits).toEqual expectedHits

	describe 'execute', ->
		execute = (string, input = []) ->
			playfield = new Playfield
			playfield.fromString string

			options =
				jumpLimit: 10
				compiler: bef.OptimizingCompiler

			eagerRuntime = new EagerRuntime
			eagerRuntime.execute playfield, options, input

			eagerRuntime.programState.stats = eagerRuntime.stats
			eagerRuntime.programState


		befTest.runtimeSuite befTest.specs.general, execute

		it 'can get a value from the playfield', ->
			{ stack, outRecord } = execute '20g@'

			(expect stack).toEqual ['g'.charCodeAt 0]
			(expect outRecord).toEqual []

		it 'can get a value from the playfield after it was altered', ->
			{ stack, outRecord, stats } = execute '6077*p560g@'

			(expect stack).toEqual [1, 49]
			(expect outRecord).toEqual []
			(expect stats.compileCalls).toEqual 2

		it 'does not recompile if altered cell is not on any path', ->
			{ stack, outRecord, stats } = execute '''
					6177*p@
					>>>>>>>
				'''

			(expect stack).toEqual []
			(expect outRecord).toEqual []
			(expect stats.compileCalls).toEqual 1

		it 'does not recompile if altered cell is not on a reachable path', ->
			{ stack, outRecord, stats } = execute '''
					v>1234....@
					>|
					>>6077*p9.@
				'''

			(expect stack).toEqual []
			(expect outRecord).toEqual [9]
			(expect stats.compileCalls).toEqual 1

		it 'recompiles if altered cell is on a reachable path', ->
			{ stack, outRecord, stats } = execute '''
					2177*p0v
					@.8    _9.@
				'''

			(expect stack).toEqual []
			(expect outRecord).toEqual [9]
			(expect stats.compileCalls).toEqual 2

		describe 'strings', ->
			befTest.runtimeSuite befTest.specs.string, execute

		describe 'edge cases', ->
			befTest.runtimeSuite befTest.specs.edgeCases, execute