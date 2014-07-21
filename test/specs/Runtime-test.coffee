describe 'Runtime', ->
  Runtime = bef.Runtime
  runtime = null

  beforeEach ->
    runtime = new Runtime

  describe 'out', ->
    it 'outputs some numbers', ->
      runtime.out 11
      runtime.out 22
      runtime.out 33
      (expect runtime.outRecord).toEqual [11, 22, 33]

  describe 'next', ->
    it 'read from input', ->
      runtime.setInput [11, 22, 33]
      (expect runtime.next()).toEqual 11
      (expect runtime.next()).toEqual 22
      (expect runtime.next()).toEqual 33