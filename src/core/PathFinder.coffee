'use strict'


S = bef.Symbols


findPath = (playfield, start) ->
	path = new bef.Path()
	pointer = start.clone()

	loop
		charCode = playfield.getAt pointer.x, pointer.y

		# processing string
		if charCode == S.QUOT
			path.push pointer.x, pointer.y, pointer.dir, charCode

			loop
				pointer.advance()
				charCode = playfield.getAt pointer.x, pointer.y

				if charCode == S.QUOT
					path.push pointer.x, pointer.y, pointer.dir, charCode
					break

				path.push pointer.x, pointer.y, pointer.dir, charCode, true

			pointer.advance()
			continue

		pointer.turn charCode

		if path.hasNonString pointer.x, pointer.y, pointer.dir
			splitPosition = (path.getEntryAt pointer.x, pointer.y, pointer.dir).index

			if splitPosition > 0
				initialPath = path.prefix splitPosition
				loopingPath = path.suffix splitPosition
				loopingPath.looping = true
				return {
					type: 'composed'
					initialPath: initialPath
					loopingPath: loopingPath
				}

			else
				path.looping = true
				return {
					type: 'looping'
					loopingPath: path
				}

		path.push pointer.x, pointer.y, pointer.dir, charCode

		if charCode in [S.IFV, S.IFH, S.RAND, S.END, S.PUT]
			path.ending = {
				x: pointer.x
				y: pointer.y
				dir: pointer.dir
				charCode: charCode
			}

			return {
				type: 'simple'
				path: path
			}

		if charCode == S.JUMP
			pointer.advance()

		pointer.advance()


PathFinder = ->
Object.assign(PathFinder, {
	findPath
})


window.bef ?= {}
window.bef.PathFinder = PathFinder