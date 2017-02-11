describe 'LazyRuntime', ->
	{ Playfield, LazyRuntime } = bef


	describe 'execute', ->
		execute = (string, input = [], options = {}) ->
			playfield = new Playfield string

			options.jumpLimit ?= 100

			lazyRuntime = new LazyRuntime
			lazyRuntime.execute playfield, options, input

			lazyRuntime.programState.stats = lazyRuntime.stats
			lazyRuntime.programState


		beforeEach ->
			jasmine.addMatchers befTest.CustomMatchers


		befTest.runtimeSuite befTest.specs.general, execute

		it 'loops forever (or until the too-many-jumps condition holds)', ->
			{ stack, outRecord } = execute '''
				>7v
				^.<
			'''

			(expect stack).toEqual []
			(expect outRecord).toStartWith [7, 7, 7]

		it 'does not recompile paths when conditional immediately leads to change of direction', ->
			{ stats, stack, outRecord } = execute '''
				4v -1<
				>>:.:|
				>>>>>@
			'''

			(expect stack).toEqual [0]
			(expect outRecord).toEqual [4, 3, 2, 1, 0]
			(expect stats.compileCalls).toEqual 3

		it 'changes direction randomly', ->
			thunk = execute.bind null, '''
				?2.@.3
				4
				.
				@
				.
				5
			'''

			sum = 0
			hits = []
			# run for a couple of times
			# just enough so all directions should be hit
			for i in [1..40]
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


		describe 'strings', ->
			befTest.runtimeSuite befTest.specs.string, execute

			it 'wraps around 2 times to close a string', ->
				{ stack, outRecord } = execute '12"34', [], jumpLimit: 1

				(expect stack).toEqual [1, 2, 51, 52, 49, 50, 3, 4]
				(expect outRecord).toEqual []


		describe 'edge cases', ->
			befTest.runtimeSuite befTest.specs.edgeCases, execute