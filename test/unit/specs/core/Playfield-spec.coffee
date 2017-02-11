describe 'Playfield', ->
	Playfield = bef.Playfield
	Path = bef.Path

	samplePlayefield = """
		a  s d
		d sa

		dd hh
	"""

	playfield = null

	beforeEach ->
		playfield = new Playfield samplePlayefield

	describe 'constructor', ->
		it 'creates a playfield from a stringed field', ->
			(expect playfield.field).toEqual [
				('a  s d'.split '')
				('d sa  '.split '')
				('      '.split '')
				('dd hh '.split '')
			]

		it 'pads a playfield with spaces', ->
			playfield = new Playfield samplePlayefield, { width: 8, height: 5 }
			(expect playfield.field).toEqual [
				('a  s d  '.split '')
				('d sa    '.split '')
				('        '.split '')
				('dd hh   '.split '')
				('        '.split '')
			]

		it 'trims cells that are outside', ->
			playfield = new Playfield samplePlayefield, { width: 4, height: 2 }
			(expect playfield.field).toEqual [
				('a  s'.split '')
				('d sa'.split '')
			]


	describe 'getAt', ->
		it 'gets the char at a position', ->
			(expect playfield.getAt 0, 0).toEqual 'a'
			(expect playfield.getAt 2, 1).toEqual 's'
			(expect playfield.getAt 2, 3).toEqual ' '


	describe 'setAt', ->
		it 'sets a char at a position', ->
			expect playfield.setAt 2, 1, 'z'
			(expect playfield.getAt 2, 1).toEqual 'z'


	describe 'addPath', ->
		it 'adds a path', ->
			# chars don't matter
			path = new Path [
				{ x: 1, y: 1, dir: '>', char: 'a' }
				{ x: 1, y: 2, dir: 'v', char: 'b' }
			]

			playfield.addPath path

			(expect playfield.getPathsThrough 0, 0).toEqual []
			(expect playfield.getPathsThrough 1, 1).toEqual [path]
			(expect playfield.getPathsThrough 1, 2).toEqual [path]
			(expect playfield.getPathsThrough 2, 1).toEqual []

		it 'adds multiple paths', ->
			path1 = new Path [
				{ x: 1, y: 1, dir: '>', char: 'a' }
				{ x: 1, y: 2, dir: 'v', char: 'b' }
			]

			path2 = new Path [
				{ x: 2, y: 2, dir: '>', char: 'a' }
				{ x: 2, y: 1, dir: 'v', char: 'b' }
				{ x: 1, y: 1, dir: '<', char: 'c' }
			]

			playfield.addPath path1
			playfield.addPath path2

			(expect playfield.getPathsThrough 1, 1).toEqual [path1, path2]
			(expect playfield.getPathsThrough 1, 2).toEqual [path1]
			(expect playfield.getPathsThrough 2, 1).toEqual [path2]
			(expect playfield.getPathsThrough 2, 2).toEqual [path2]


	describe 'removePath', ->
		it 'removed a path', ->
			path1 = new Path [
				{ x: 1, y: 1, dir: '>', char: 'a' }
				{ x: 1, y: 2, dir: 'v', char: 'b' }
			]

			path2 = new Path [
				{ x: 2, y: 2, dir: '>', char: 'a' }
				{ x: 2, y: 1, dir: 'v', char: 'b' }
				{ x: 1, y: 1, dir: '<', char: 'c' }
			]

			playfield.addPath path1
			playfield.addPath path2
			playfield.removePath path1

			(expect playfield.getPathsThrough 1, 1).toEqual [path2]
			(expect playfield.getPathsThrough 1, 2).toEqual []
			(expect playfield.getPathsThrough 2, 1).toEqual [path2]
			(expect playfield.getPathsThrough 2, 2).toEqual [path2]