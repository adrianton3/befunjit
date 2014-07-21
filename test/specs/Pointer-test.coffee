describe 'Pointer', ->
  Pointer = bef.Pointer

  describe 'advance', ->
    it 'advances one cell', ->
      pointer = new Pointer 11, 22, '<'
      pointer.advance()
      (expect pointer).toEqual new Pointer 10, 22, '<'

  describe 'turn', ->
    it 'turns down', ->
      pointer = new Pointer 11, 22, '<'
      pointer.turn 'v'
      pointer.advance()
      (expect pointer).toEqual new Pointer 11, 23, 'v'

  describe 'set', ->
    it 'sets the position and direction', ->
      pointer = new Pointer 11, 22, '<'
      pointer.set 33, 44, 'v'
      pointer.advance()
      (expect pointer).toEqual new Pointer 33, 45, 'v'