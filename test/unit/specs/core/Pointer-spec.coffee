describe 'Pointer', ->
	Pointer = bef.Pointer

	describe 'advance', ->
		it 'advances one cell', ->
			pointer = new Pointer 11, 22, ('<'.charCodeAt 0), { width: 100, height: 100 }
			pointer.advance()
			(expect pointer).toEqual new Pointer 10, 22, ('<'.charCodeAt 0), { width: 100, height: 100 }

	describe 'turn', ->
		it 'turns down', ->
			pointer = new Pointer 11, 22, ('<'.charCodeAt 0), { width: 100, height: 100 }
			pointer.turn ('v'.charCodeAt 0)
			pointer.advance()
			(expect pointer).toEqual new Pointer 11, 23, ('v'.charCodeAt 0), { width: 100, height: 100 }

	describe 'set', ->
		it 'sets the position and direction', ->
			pointer = new Pointer 11, 22, ('<'.charCodeAt 0), { width: 100, height: 100 }
			pointer.set 33, 44, ('v'.charCodeAt 0)
			pointer.advance()
			(expect pointer).toEqual new Pointer 33, 45, ('v'.charCodeAt 0), { width: 100, height: 100 }
