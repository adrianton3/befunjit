'use strict'


{ PathFinder, Playfield, Pointer } = bef


describe 'PathFinder', ->
	describe 'getPath', ->
		findPath = (source, x = 0, y = 0, dir = '>') ->
			playfield = new Playfield
			playfield.fromString source
			space = {
				width: playfield.width
				height: playfield.height
			}

			start = new Pointer x, y, dir, space

			PathFinder.findPath playfield, start


		it 'gets a simple path until the pointer encounters @', ->
			{ path } = findPath 'abc@'

			pathAsList = path.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: '>', char: 'a', string: false }
				{ x: 1, y: 0, dir: '>', char: 'b', string: false }
				{ x: 2, y: 0, dir: '>', char: 'c', string: false }
				{ x: 3, y: 0, dir: '>', char: '@', string: false }
			]

		it 'can get a turning path', ->
			{ path } = findPath '''
					abv
					..c
					..d
					..@
				'''

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
			{ loopingPath } = findPath '''
					>av
					d b
					^c<
				'''

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
			{ loopingPath } = findPath 'abc'

			pathAsList = loopingPath.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: '>', char: 'a', string: false }
				{ x: 1, y: 0, dir: '>', char: 'b', string: false }
				{ x: 2, y: 0, dir: '>', char: 'c', string: false }
			]

		it 'can get a path composed of an initial part and a circular part', ->
			{ initialPath, loopingPath } = findPath '''
					ab>cv
					..f d
					..^e<
				'''

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
			{ path } = findPath 'a#bc@'

			pathAsList = path.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: '>', char: 'a', string: false }
				{ x: 1, y: 0, dir: '>', char: '#', string: false }
				{ x: 3, y: 0, dir: '>', char: 'c', string: false }
				{ x: 4, y: 0, dir: '>', char: '@', string: false }
			]

		it 'can jump repeatedly', ->
			{ path } = findPath 'a#b#cd@'

			pathAsList = path.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: '>', char: 'a', string: false }
				{ x: 1, y: 0, dir: '>', char: '#', string: false }
				{ x: 3, y: 0, dir: '>', char: '#', string: false }
				{ x: 5, y: 0, dir: '>', char: 'd', string: false }
				{ x: 6, y: 0, dir: '>', char: '@', string: false }
			]

		it 'parses a string', ->
			{ path } = findPath '12"34"56@'

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
			{ loopingPath } = findPath '12"34'

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
			{ path } = findPath '__'

			pathAsList = path.getAsList()
			(expect pathAsList).toEqual [
				{ x: 0, y: 0, dir: '>', char: '_', string: false }
			]

		it 'can handle jumps on path endings', ->
			path = findPath 'a_b#c_d', 2, 0, '>'

			pathAsList = path.path.getAsList()
			(expect pathAsList).toEqual [
				{ x: 2, y: 0, dir: '>', char: 'b', string: false }
				{ x: 3, y: 0, dir: '>', char: '#', string: false }
				{ x: 5, y: 0, dir: '>', char: '_', string: false }
			]