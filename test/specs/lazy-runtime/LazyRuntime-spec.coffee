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

			lazyRuntime = new LazyRuntime
			lazyRuntime.execute playfield, options, input

			lazyRuntime.programState


		befTest.runtimeSuite execute

		it 'loops forever (or until the too-many-jumps condition holds)', ->
			{ stack, outRecord } = execute '''
				>7v
				^.<
			''', [], jumpLimit: 3

			(expect stack).toEqual []
			(expect outRecord).toEqual [7, 7, 7]

		it 'changes direction randomly', ->
			source = [
				'?2.@.3',
				'4',
				'.',
				'@',
				'.',
				'5'
			].join '\n'

			thunk = -> execute source

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

		it 'duplicates the value on the stack', ->
			{ stack, outRecord } = execute '7:@'

			(expect stack).toEqual [7, 7]
			(expect outRecord).toEqual []

		it 'swaps the first two values on the stack', ->
			{ stack, outRecord } = execute '275\\@'

			(expect stack).toEqual [2, 5, 7]
			(expect outRecord).toEqual []

		it 'discards the first value on the stack', ->
			{ stack, outRecord } = execute '27$@'

			(expect stack).toEqual [2]
			(expect outRecord).toEqual []

		it 'can get a value from the playfield', ->
			{ stack, outRecord } = execute '20g@'

			(expect stack).toEqual ['g'.charCodeAt 0]
			(expect outRecord).toEqual []

		it 'can read an integer', ->
			{ stack, outRecord } = execute '&@', [123]

			(expect stack).toEqual [123]
			(expect outRecord).toEqual []

		it 'can read a char', ->
			{ stack, outRecord } = execute '~@', ['a']

			(expect stack).toEqual ['a'.charCodeAt 0]
			(expect outRecord).toEqual []

		describe 'strings', ->
			charCodes = (string) ->
				(string.split '').map (char) ->
					char.charCodeAt 0

			it 'pushes a string', ->
				{ stack, outRecord } = execute '12"34"56@'

				(expect stack).toEqual [1, 2, 51, 52, 5, 6]
				(expect outRecord).toEqual []

			it 'wraps around 2 times to close a string', ->
				{ stack, outRecord } = execute '12"34', [], jumpLimit: 1

				(expect stack).toEqual [1, 2, 51, 52, 49, 50, 3, 4]
				(expect outRecord).toEqual []

			it 'does not change direction while in a string', ->
				{ stack, outRecord } = execute '"V^"@'

				(expect stack).toEqual charCodes 'V^'
				(expect outRecord).toEqual []

			it 'evaluates an empty string', ->
				{ stack, outRecord } = execute '""@'

				(expect stack).toEqual []
				(expect outRecord).toEqual []

		describe 'edge cases', ->
			it 'pops 0 from an empty stack', ->
				{ stack, outRecord } = execute '.@'

				(expect stack).toEqual []
				(expect outRecord).toEqual [0]

			it 'ignores non-instructions', ->
				{ stack, outRecord } = execute 'abc@'

				(expect stack).toEqual []
				(expect outRecord).toEqual []

			it 'gets 0 if input is empty', ->
				{ stack, outRecord } = execute '&&&&&@', [1, 2, 3]

				(expect stack).toEqual [1, 2, 3, 0, 0]
				(expect outRecord).toEqual []

			it 'gets 0 when trying to access cells outside of the playfield', ->
				{ stack, outRecord } = execute '99g@'

				(expect stack).toEqual [0]
				(expect outRecord).toEqual []

			it 'does not crash when trying to write outside of the playfield', ->
				{ stack, outRecord } = execute '999p@'

				(expect stack).toEqual []
				(expect outRecord).toEqual []