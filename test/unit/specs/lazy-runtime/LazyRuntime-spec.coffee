describe 'LazyRuntime', ->
	Playfield = bef.Playfield
	LazyRuntime = bef.LazyRuntime

	getPlayfield = (string, width, height) ->
		playfield = new Playfield width, height
		playfield.fromString string, width, height
		playfield

	getInterpreter = (string, width, height) ->
		playfield = getPlayfield string, width, height
		lazyRuntime = new LazyRuntime()
		lazyRuntime.playfield = playfield
		lazyRuntime

	describe 'getPath', ->
		it 'gets a simple path until the pointer encounters @', ->
			lazyRuntime = getInterpreter 'abc@'

			{ path } = lazyRuntime._getPath 0, 0, '>'
			pathAsList = path.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: '>', char: 'a', string: false }
				{ x: 1, y: 0, dir: '>', char: 'b', string: false }
				{ x: 2, y: 0, dir: '>', char: 'c', string: false }
				{ x: 3, y: 0, dir: '>', char: '@', string: false }
			]

		it 'can get a turning path', ->
			lazyRuntime = getInterpreter '''
				abv
				..c
				..d
				..@
			'''

			{ path } = lazyRuntime._getPath 0, 0, '>'
			pathAsList = path.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: '>', char: 'a', string: false }
				{ x: 1, y: 0, dir: '>', char: 'b', string: false }
				{ x: 2, y: 0, dir: 'v', char: 'v', string: false }
				{ x: 2, y: 1, dir: 'v', char: 'c', string: false }
				{ x: 2, y: 2, dir: 'v', char: 'd', string: false }
				{ x: 2, y: 3, dir: 'v', char: '@', string: false }
			]

		it 'can get a circular path', ->
			lazyRuntime = getInterpreter '''
				>av
				d b
				^c<
			'''

			{ loopingPath } = lazyRuntime._getPath 0, 0, '>'

			pathAsList = loopingPath.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: '>', char: '>', string: false }
				{ x: 1, y: 0, dir: '>', char: 'a', string: false }
				{ x: 2, y: 0, dir: 'v', char: 'v', string: false }
				{ x: 2, y: 1, dir: 'v', char: 'b', string: false }
				{ x: 2, y: 2, dir: '<', char: '<', string: false }
				{ x: 1, y: 2, dir: '<', char: 'c', string: false }
				{ x: 0, y: 2, dir: '^', char: '^', string: false }
				{ x: 0, y: 1, dir: '^', char: 'd', string: false }
			]

		it 'can get a circular path by wrapping around', ->
			lazyRuntime = getInterpreter 'abc'

			{ loopingPath } = lazyRuntime._getPath 0, 0, '>'

			pathAsList = loopingPath.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: '>', char: 'a', string: false }
				{ x: 1, y: 0, dir: '>', char: 'b', string: false }
				{ x: 2, y: 0, dir: '>', char: 'c', string: false }
			]

		it 'can get a path composed of an initial part and a circular part', ->
			lazyRuntime = getInterpreter '''
				ab>cv
				..f d
				..^e<
			'''

			{ initialPath, loopingPath } = lazyRuntime._getPath 0, 0, '>'

			pathAsList = initialPath.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: '>', char: 'a', string: false }
				{ x: 1, y: 0, dir: '>', char: 'b', string: false }
			]

			pathAsList = loopingPath.getAsList()
			(expect pathAsList).toEqual [
				{ x: 2, y: 0, dir: '>', char: '>', string: false }
				{ x: 3, y: 0, dir: '>', char: 'c', string: false }
				{ x: 4, y: 0, dir: 'v', char: 'v', string: false }
				{ x: 4, y: 1, dir: 'v', char: 'd', string: false }
				{ x: 4, y: 2, dir: '<', char: '<', string: false }
				{ x: 3, y: 2, dir: '<', char: 'e', string: false }
				{ x: 2, y: 2, dir: '^', char: '^', string: false }
				{ x: 2, y: 1, dir: '^', char: 'f', string: false }
			]

		it 'can jump over a cell', ->
			lazyRuntime = getInterpreter 'a#bc@'

			{ path } = lazyRuntime._getPath 0, 0, '>'

			pathAsList = path.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: '>', char: 'a', string: false }
				{ x: 1, y: 0, dir: '>', char: '#', string: false }
				{ x: 3, y: 0, dir: '>', char: 'c', string: false }
				{ x: 4, y: 0, dir: '>', char: '@', string: false }
			]

		it 'can jump repeatedly', ->
			lazyRuntime = getInterpreter 'a#b#cd@'

			{ path } = lazyRuntime._getPath 0, 0, '>'

			pathAsList = path.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: '>', char: 'a', string: false }
				{ x: 1, y: 0, dir: '>', char: '#', string: false }
				{ x: 3, y: 0, dir: '>', char: '#', string: false }
				{ x: 5, y: 0, dir: '>', char: 'd', string: false }
				{ x: 6, y: 0, dir: '>', char: '@', string: false }
			]

		it 'parses a string', ->
			lazyRuntime = getInterpreter '12"34"56@'

			{ path } = lazyRuntime._getPath 0, 0, '>'
			pathAsList = path.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: '>', char: '1', string: false }
				{ x: 1, y: 0, dir: '>', char: '2', string: false }
				{ x: 2, y: 0, dir: '>', char: '"', string: false }
				{ x: 3, y: 0, dir: '>', char: '3', string: true }
				{ x: 4, y: 0, dir: '>', char: '4', string: true }
				{ x: 5, y: 0, dir: '>', char: '"', string: false }
				{ x: 6, y: 0, dir: '>', char: '5', string: false }
				{ x: 7, y: 0, dir: '>', char: '6', string: false }
				{ x: 8, y: 0, dir: '>', char: '@', string: false }
			]

		it 'wraps around 2 times to close a string', ->
			lazyRuntime = getInterpreter '12"34'

			{ loopingPath } = lazyRuntime._getPath 0, 0, '>'
			pathAsList = loopingPath.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: '>', char: '1', string: false }
				{ x: 1, y: 0, dir: '>', char: '2', string: false }

				{ x: 2, y: 0, dir: '>', char: '"', string: false }

				{ x: 3, y: 0, dir: '>', char: '3', string: true }
				{ x: 4, y: 0, dir: '>', char: '4', string: true }
				{ x: 0, y: 0, dir: '>', char: '1', string: true }
				{ x: 1, y: 0, dir: '>', char: '2', string: true }

				{ x: 2, y: 0, dir: '>', char: '"', string: false }

				{ x: 3, y: 0, dir: '>', char: '3', string: false }
				{ x: 4, y: 0, dir: '>', char: '4', string: false }
			]

		it 'gets an empty path', ->
			lazyRuntime = getInterpreter '__'

			{ path } = lazyRuntime._getPath 0, 0, '>'
			pathAsList = path.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: '>', char: '_', string: false }
			]


	describe 'execute', ->
		execute = (string, input = [], options = {}) ->
			playfield = new Playfield
			playfield.fromString string

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