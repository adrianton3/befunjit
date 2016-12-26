describe 'PathSet', ->
	Path = bef.Path
	PathSet = bef.PathSet

	describe 'add', ->
		it 'adds a path', ->
			path = new Path [ x: 11, y: 22, dir: '^' ]
			pathSet = new PathSet()
			pathSet.add path

			retrievedPath = pathSet.getStartingFrom 11, 22, '^'
			(expect retrievedPath).toEqual path

	describe 'remove', ->
		it 'removes a path', ->
			path1 = new Path [ x: 11, y: 22, dir: '^' ]
			path2 = new Path [ x: 33, y: 44, dir: '<' ]

			pathSet = new PathSet()

			pathSet.add path1
			pathSet.add path2

			pathSet.remove path2

			(expect pathSet.getStartingFrom 11, 22, '^').toEqual path1
			(expect pathSet.getStartingFrom 33, 44, '<').toBeUndefined()