describe 'Path', ->
	Path = bef.Path

	describe 'push', ->
		it 'pushes some entries', ->
			path = new Path()
			path.push 10, 20, 3, 'z'
			path.push 1, 2, 0, 't'
			(expect path.getAsList()).toEqual [
				{ x: 10, y: 20, dir: 3, char: 'z', string: false }
				{ x: 1, y: 2, dir: 0, char: 't', string: false }
			]


	describe 'prefix', ->
		it 'gets the prefix of length 0', ->
			path = new Path()
			path.push 11, 20, 3, 'a'
			path.push 12, 20, 3, 'b'
			path.push 13, 20, 3, 'c'

			prefixPath = path.prefix 0
			(expect prefixPath.getAsList()).toEqual []

		it 'gets the prefix of an arbitrary length', ->
			path = new Path()
			path.push 11, 20, 3, 'a'
			path.push 12, 20, 3, 'b'
			path.push 13, 20, 3, 'c'

			prefixPath = path.prefix 2
			(expect prefixPath.getAsList()).toEqual [
				{ x: 11, y: 20, dir: 3, char: 'a', string: false }
				{ x: 12, y: 20, dir: 3, char: 'b', string: false }
			]

		it 'gets the prefix of the same length as the source path', ->
			path = new Path()
			path.push 11, 20, 3, 'a'
			path.push 12, 20, 3, 'b'
			path.push 13, 20, 3, 'c'

			prefixPath = path.prefix 3
			(expect prefixPath.getAsList()).toEqual [
				{ x: 11, y: 20, dir: 3, char: 'a', string: false }
				{ x: 12, y: 20, dir: 3, char: 'b', string: false }
				{ x: 13, y: 20, dir: 3, char: 'c', string: false }
			]

	describe 'suffix', ->
		it 'gets the suffix of length 0', ->
			path = new Path()
			path.push 11, 20, 3, 'a'
			path.push 12, 20, 3, 'b'
			path.push 13, 20, 3, 'c'

			suffixPath = path.suffix 0
			(expect suffixPath.getAsList()).toEqual [
				{ x: 11, y: 20, dir: 3, char: 'a', string: false }
				{ x: 12, y: 20, dir: 3, char: 'b', string: false }
				{ x: 13, y: 20, dir: 3, char: 'c', string: false }
			]

		it 'gets the suffix of an arbitrary length', ->
			path = new Path()
			path.push 11, 20, 3, 'a'
			path.push 12, 20, 3, 'b'
			path.push 13, 20, 3, 'c'

			suffixPath = path.suffix 2
			(expect suffixPath.getAsList()).toEqual [
				{ x: 13, y: 20, dir: 3, char: 'c', string: false }
			]

		it 'gets the suffix of the same length as the source path', ->
			path = new Path()
			path.push 11, 20, 3, 'a'
			path.push 12, 20, 3, 'b'
			path.push 13, 20, 3, 'c'

			suffixPath = path.suffix 3
			(expect suffixPath.getAsList()).toEqual []