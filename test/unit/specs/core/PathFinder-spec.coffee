'use strict'


{ PathFinder, Playfield, Pointer } = bef
S = bef.Symbols


describe 'PathFinder', ->
	describe 'getPath', ->
		findPath = (source, x = 0, y = 0, dir = S.RIGHT) ->
			playfield = new Playfield source
			space = {
				width: playfield.width
				height: playfield.height
			}

			start = new Pointer x, y, dir, space

			PathFinder.findPath playfield, start


		it 'gets a simple path until the pointer encounters @', ->
			{ path } = findPath '123@'

			pathAsList = path.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: S.RIGHT, charCode: S.D1, string: false }
				{ x: 1, y: 0, dir: S.RIGHT, charCode: S.D2, string: false }
				{ x: 2, y: 0, dir: S.RIGHT, charCode: S.D3, string: false }
				{ x: 3, y: 0, dir: S.RIGHT, charCode: S.END, string: false }
			]

		it 'can get a turning path', ->
			{ path } = findPath '''
					12v
					..3
					..4
					..@
				'''

			pathAsList = path.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: S.RIGHT, charCode: S.D1, string: false }
				{ x: 1, y: 0, dir: S.RIGHT, charCode: S.D2, string: false }
				{ x: 2, y: 0, dir: S.DOWN, charCode: S.DOWN, string: false }
				{ x: 2, y: 1, dir: S.DOWN, charCode: S.D3, string: false }
				{ x: 2, y: 2, dir: S.DOWN, charCode: S.D4, string: false }
				{ x: 2, y: 3, dir: S.DOWN, charCode: S.END, string: false }
			]

		it 'can get a circular path', ->
			{ loopingPath } = findPath '''
					>1v
					4 2
					^3<
				'''

			pathAsList = loopingPath.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: S.RIGHT, charCode: S.RIGHT, string: false }
				{ x: 1, y: 0, dir: S.RIGHT, charCode: S.D1, string: false }
				{ x: 2, y: 0, dir: S.DOWN, charCode: S.DOWN, string: false }
				{ x: 2, y: 1, dir: S.DOWN, charCode: S.D2, string: false }
				{ x: 2, y: 2, dir: S.LEFT, charCode: S.LEFT, string: false }
				{ x: 1, y: 2, dir: S.LEFT, charCode: S.D3, string: false }
				{ x: 0, y: 2, dir: S.UP, charCode: S.UP, string: false }
				{ x: 0, y: 1, dir: S.UP, charCode: S.D4, string: false }
			]

		it 'can get a circular path by wrapping around', ->
			{ loopingPath } = findPath '123'

			pathAsList = loopingPath.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: S.RIGHT, charCode: S.D1, string: false }
				{ x: 1, y: 0, dir: S.RIGHT, charCode: S.D2, string: false }
				{ x: 2, y: 0, dir: S.RIGHT, charCode: S.D3, string: false }
			]

		it 'can get a path composed of an initial part and a circular part', ->
			{ initialPath, loopingPath } = findPath '''
					12>3v
					..6 4
					..^5<
				'''

			pathAsList = initialPath.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: S.RIGHT, charCode: S.D1, string: false }
				{ x: 1, y: 0, dir: S.RIGHT, charCode: S.D2, string: false }
			]

			pathAsList = loopingPath.getAsList()
			(expect pathAsList).toEqual [
				{ x: 2, y: 0, dir: S.RIGHT, charCode: S.RIGHT, string: false }
				{ x: 3, y: 0, dir: S.RIGHT, charCode: S.D3, string: false }
				{ x: 4, y: 0, dir: S.DOWN, charCode: S.DOWN, string: false }
				{ x: 4, y: 1, dir: S.DOWN, charCode: S.D4, string: false }
				{ x: 4, y: 2, dir: S.LEFT, charCode: S.LEFT, string: false }
				{ x: 3, y: 2, dir: S.LEFT, charCode: S.D5, string: false }
				{ x: 2, y: 2, dir: S.UP, charCode: S.UP, string: false }
				{ x: 2, y: 1, dir: S.UP, charCode: S.D6, string: false }
			]

		it 'can jump over a cell', ->
			{ path } = findPath '1#23@'

			pathAsList = path.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: S.RIGHT, charCode: S.D1, string: false }
				{ x: 1, y: 0, dir: S.RIGHT, charCode: S.JUMP, string: false }
				{ x: 3, y: 0, dir: S.RIGHT, charCode: S.D3, string: false }
				{ x: 4, y: 0, dir: S.RIGHT, charCode: S.END, string: false }
			]

		it 'can jump repeatedly', ->
			{ path } = findPath '1#2#34@'

			pathAsList = path.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: S.RIGHT, charCode: S.D1, string: false }
				{ x: 1, y: 0, dir: S.RIGHT, charCode: S.JUMP, string: false }
				{ x: 3, y: 0, dir: S.RIGHT, charCode: S.JUMP, string: false }
				{ x: 5, y: 0, dir: S.RIGHT, charCode: S.D4, string: false }
				{ x: 6, y: 0, dir: S.RIGHT, charCode: S.END, string: false }
			]

		it 'parses a string', ->
			{ path } = findPath '12"34"56@'

			pathAsList = path.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: S.RIGHT, charCode: S.D1, string: false }
				{ x: 1, y: 0, dir: S.RIGHT, charCode: S.D2, string: false }
				{ x: 2, y: 0, dir: S.RIGHT, charCode: S.QUOT, string: false }
				{ x: 3, y: 0, dir: S.RIGHT, charCode: S.D3, string: true }
				{ x: 4, y: 0, dir: S.RIGHT, charCode: S.D4, string: true }
				{ x: 5, y: 0, dir: S.RIGHT, charCode: S.QUOT, string: false }
				{ x: 6, y: 0, dir: S.RIGHT, charCode: S.D5, string: false }
				{ x: 7, y: 0, dir: S.RIGHT, charCode: S.D6, string: false }
				{ x: 8, y: 0, dir: S.RIGHT, charCode: S.END, string: false }
			]

		it 'wraps around 2 times to close a string', ->
			{ loopingPath } = findPath '12"34'

			pathAsList = loopingPath.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: S.RIGHT, charCode: S.D1, string: false }
				{ x: 1, y: 0, dir: S.RIGHT, charCode: S.D2, string: false }

				{ x: 2, y: 0, dir: S.RIGHT, charCode: S.QUOT, string: false }

				{ x: 3, y: 0, dir: S.RIGHT, charCode: S.D3, string: true }
				{ x: 4, y: 0, dir: S.RIGHT, charCode: S.D4, string: true }
				{ x: 0, y: 0, dir: S.RIGHT, charCode: S.D1, string: true }
				{ x: 1, y: 0, dir: S.RIGHT, charCode: S.D2, string: true }

				{ x: 2, y: 0, dir: S.RIGHT, charCode: S.QUOT, string: false }

				{ x: 3, y: 0, dir: S.RIGHT, charCode: S.D3, string: false }
				{ x: 4, y: 0, dir: S.RIGHT, charCode: S.D4, string: false }
			]

		it 'gets an empty path', ->
			{ path } = findPath '__'

			pathAsList = path.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: S.RIGHT, charCode: S.IFH, string: false }
			]

		it 'can handle jumps on path endings', ->
			path = findPath '1_2#3_4', 2, 0

			pathAsList = path.path.getAsList()
			(expect pathAsList).toEqual [
				{ x: 2, y: 0, dir: S.RIGHT, charCode: S.D2, string: false }
				{ x: 3, y: 0, dir: S.RIGHT, charCode: S.JUMP, string: false }
				{ x: 5, y: 0, dir: S.RIGHT, charCode: S.IFH, string: false }
			]