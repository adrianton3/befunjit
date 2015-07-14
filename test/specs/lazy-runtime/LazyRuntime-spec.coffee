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
		it 'gets a simple path until the pointer exist the playground', ->
			lazyRuntime = getInterpreter 'abc@'

			paths = lazyRuntime._getPath 0, 0, '>'
			pathAsList = paths[0].getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: '>', char: 'a', string: false }
				{ x: 1, y: 0, dir: '>', char: 'b', string: false }
				{ x: 2, y: 0, dir: '>', char: 'c', string: false }
			]

		it 'can get a turning path', ->
			lazyRuntime = getInterpreter '''
				abv
				..c
				..d
				..@
			'''

			paths = lazyRuntime._getPath 0, 0, '>'
			pathAsList = paths[0].getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: '>', char: 'a', string: false }
				{ x: 1, y: 0, dir: '>', char: 'b', string: false }
				{ x: 2, y: 0, dir: 'v', char: 'v', string: false }
				{ x: 2, y: 1, dir: 'v', char: 'c', string: false }
				{ x: 2, y: 2, dir: 'v', char: 'd', string: false }
			]

		it 'can get a circular path', ->
			lazyRuntime = getInterpreter '''
				>av
				d b
				^c<
			'''

			paths = lazyRuntime._getPath 0, 0, '>'

			pathAsList = paths[0].getAsList()
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

			paths = lazyRuntime._getPath 0, 0, '>'

			pathAsList = paths[0].getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: '>', char: 'a', string: false }
				{ x: 1, y: 0, dir: '>', char: 'b', string: false }
				{ x: 2, y: 0, dir: '>', char: 'c', string: false }
			]

		it 'can get the initial part of a circular path', ->
			lazyRuntime = getInterpreter '''
				ab>cv
				..f d
				..^e<
			'''

			paths = lazyRuntime._getPath 0, 0, '>'

			pathAsList = paths[0].getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: '>', char: 'a', string: false }
				{ x: 1, y: 0, dir: '>', char: 'b', string: false }
			]

			pathAsList = paths[1].getAsList()
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

			paths = lazyRuntime._getPath 0, 0, '>'

			pathAsList = paths[0].getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: '>', char: 'a', string: false }
				{ x: 1, y: 0, dir: '>', char: '#', string: false }
				{ x: 3, y: 0, dir: '>', char: 'c', string: false }
			]

		it 'can jump repeatedly', ->
			lazyRuntime = getInterpreter 'a#b#cd@'

			paths = lazyRuntime._getPath 0, 0, '>'

			pathAsList = paths[0].getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: '>', char: 'a', string: false }
				{ x: 1, y: 0, dir: '>', char: '#', string: false }
				{ x: 3, y: 0, dir: '>', char: '#', string: false }
				{ x: 5, y: 0, dir: '>', char: 'd', string: false }
			]

		it 'parses a string', ->
			lazyRuntime = getInterpreter '12"34"56'

			paths = lazyRuntime._getPath 0, 0, '>'
			pathAsList = paths[0].getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: '>', char: '1', string: false }
				{ x: 1, y: 0, dir: '>', char: '2', string: false }
				{ x: 2, y: 0, dir: '>', char: '"', string: false }
				{ x: 3, y: 0, dir: '>', char: '3', string: true }
				{ x: 4, y: 0, dir: '>', char: '4', string: true }
				{ x: 5, y: 0, dir: '>', char: '"', string: false }
				{ x: 6, y: 0, dir: '>', char: '5', string: false }
				{ x: 7, y: 0, dir: '>', char: '6', string: false }
			]

		it 'wraps around 2 times to close a string', ->
			lazyRuntime = getInterpreter '12"34'

			paths = lazyRuntime._getPath 0, 0, '>'
			pathAsList = paths[0].getAsList()
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

			paths = lazyRuntime._getPath 0, 0, '>'
			pathAsList = paths[0].getAsList()
			(expect pathAsList).toEqual []


	describe 'execute', ->
		execute = (string, input = [], options = {}) ->
			playfield = new Playfield
			playfield.fromString string

			options.jumpLimit ?= 100

			lazyRuntime = new LazyRuntime
			lazyRuntime.execute playfield, options, input

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


		describe 'strings', ->
			befTest.runtimeSuite befTest.specs.string, execute

			it 'wraps around 2 times to close a string', ->
				{ stack, outRecord } = execute '12"34', [], jumpLimit: 1

				(expect stack).toEqual [1, 2, 51, 52, 49, 50, 3, 4]
				(expect outRecord).toEqual []


		describe 'edge cases', ->
			befTest.runtimeSuite befTest.specs.edgeCases, execute