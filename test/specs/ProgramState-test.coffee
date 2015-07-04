describe 'ProgramState', ->
  ProgramState = bef.ProgramState
  programState = null

  beforeEach ->
    programState = new ProgramState

  describe 'out', ->
    it 'outputs some numbers', ->
      programState.out 11
      programState.out 22
      programState.out 33
      (expect programState.outRecord).toEqual [11, 22, 33]

  describe 'next', ->
    it 'read from input', ->
      programState.setInput [11, 22, 33]
      (expect programState.next()).toEqual 11
      (expect programState.next()).toEqual 22
      (expect programState.next()).toEqual 33