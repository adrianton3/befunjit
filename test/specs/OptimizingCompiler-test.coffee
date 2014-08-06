describe 'OptimizingCompiler', ->
  Path = bef.Path
  Runtime = bef.Runtime
  OptimizinsCompiler = bef.OptimizinsCompiler

  getPath = (string) ->
    path = new Path()
    stringMode = false
    (string.split '').forEach (char) ->
      if char == '"'
        stringMode = !stringMode
        path.push 0, 0, '>', char, false
      else
        path.push 0, 0, '>', char, stringMode
    path


  getRuntime = (stack = [], input = []) ->
    runtime = new Runtime()
    runtime.stack = stack
    runtime.setInput input

    (spyOn runtime, 'push').and.callThrough()
    (spyOn runtime, 'pop').and.callThrough()
    spyOn runtime, 'put'
    (spyOn runtime, 'get').and.returnValue 55

    runtime


  execute = (string, stack, input, pathInvalidatedAhead = false) ->
    path = getPath string
    OptimizinsCompiler.compile path

    runtime = getRuntime stack, input
    runtime.flags.pathInvalidatedAhead = pathInvalidatedAhead
    path.body runtime

    runtime


  it 'compiles an empty path', ->
    runtime = execute ''
    (expect runtime.push.calls.count()).toEqual 0
    (expect runtime.pop.calls.count()).toEqual 0
    (expect runtime.stack).toEqual []


  describe 'binary operators', ->
    describe '+', ->
      it 'resolves entirely at compile time', ->
        runtime = execute '12+'
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 0
        (expect runtime.stack).toEqual [3]

      it 'resolves partially at compile time', ->
        runtime = execute '1+', [2]
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 1
        (expect runtime.stack).toEqual [3]

      it 'does not resolve at compile time', ->
        runtime = execute '+', [1, 2]
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 2
        (expect runtime.stack).toEqual [3]

    describe '-', ->
      it 'resolves entirely at compile time', ->
        runtime = execute '23-'
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 0
        (expect runtime.stack).toEqual [1]

      it 'resolves partially at compile time', ->
        runtime = execute '3-', [2]
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 1
        (expect runtime.stack).toEqual [1]

      it 'does not resolve at compile time', ->
        runtime = execute '-', [2, 3]
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 2
        (expect runtime.stack).toEqual [1]

    describe '*', ->
      it 'resolves entirely at compile time', ->
        runtime = execute '23*'
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 0
        (expect runtime.stack).toEqual [6]

      it 'resolves partially at compile time', ->
        runtime = execute '3*', [2]
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 1
        (expect runtime.stack).toEqual [6]

      it 'does not resolve at compile time', ->
        runtime = execute '*', [2, 3]
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 2
        (expect runtime.stack).toEqual [6]

    describe '/', ->
      it 'resolves entirely at compile time', ->
        runtime = execute '29/'
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 0
        (expect runtime.stack).toEqual [4]

      it 'resolves partially at compile time', ->
        runtime = execute '9/', [2]
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 1
        (expect runtime.stack).toEqual [4]

      it 'does not resolve at compile time', ->
        runtime = execute '/', [2, 9]
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 2
        (expect runtime.stack).toEqual [4]

    describe '`', ->
      it 'resolves entirely at compile time', ->
        runtime = execute '29`'
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 0
        (expect runtime.stack).toEqual [1]

      it 'resolves partially at compile time', ->
        runtime = execute '9`', [2]
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 1
        (expect runtime.stack).toEqual [1]

      it 'does not resolve at compile time', ->
        runtime = execute '`', [2, 9]
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 2
        (expect runtime.stack).toEqual [1]

  describe '!', ->
    it 'resolves at compile time', ->
      runtime = execute '2!'
      (expect runtime.push.calls.count()).toEqual 1
      (expect runtime.pop.calls.count()).toEqual 0
      (expect runtime.stack).toEqual [0]

    it 'does not resolve at compile time', ->
      runtime = execute '!', [2]
      (expect runtime.push.calls.count()).toEqual 1
      (expect runtime.pop.calls.count()).toEqual 1
      (expect runtime.stack).toEqual [0]

  describe 'literals', ->
    describe '0..9', ->
      it 'pushes one digit', ->
        runtime = execute '9'
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 0
        (expect runtime.stack).toEqual [9]

      it 'pushes more digits', ->
        runtime = execute '1234567'
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 0
        (expect runtime.stack).toEqual [1, 2, 3, 4, 5, 6, 7]


    describe 'strings', ->
      it 'pushes no character', ->
        runtime = execute '""'
        (expect runtime.push.calls.count()).toEqual 0
        (expect runtime.pop.calls.count()).toEqual 0
        (expect runtime.stack).toEqual []

      it 'pushes one character', ->
        runtime = execute '"9"'
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 0
        (expect runtime.stack).toEqual [57]

      it 'pushes more characters', ->
        runtime = execute '"123"'
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 0
        (expect runtime.stack).toEqual [49, 50, 51]


  describe 'stack operators', ->
    describe ':', ->
      it 'resolves at compile time', ->
        runtime = execute '1:'
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 0
        (expect runtime.stack).toEqual [1, 1]

      it 'does not resolve at compile time', ->
        runtime = execute ':', [1]
        (expect runtime.push.calls.count()).toEqual 0
        (expect runtime.pop.calls.count()).toEqual 0
        # calls .duplicate
        (expect runtime.stack).toEqual [1, 1]

    describe '\\', ->
      it 'resolves at compile time', ->
        runtime = execute '12\\'
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 0
        (expect runtime.stack).toEqual [2, 1]

      it 'does not resolve at compile time', ->
        runtime = execute '\\', [1, 2]
        (expect runtime.push.calls.count()).toEqual 0
        (expect runtime.pop.calls.count()).toEqual 0
        (expect runtime.stack).toEqual [2, 1]

    describe '$', ->
      it 'resolves at compile time', ->
        runtime = execute '1$\\'
        (expect runtime.push.calls.count()).toEqual 0
        (expect runtime.pop.calls.count()).toEqual 0
        (expect runtime.stack).toEqual []

      it 'does not resolve at compile time', ->
        runtime = execute '$', [1, 2]
        (expect runtime.push.calls.count()).toEqual 0
        (expect runtime.pop.calls.count()).toEqual 1
        (expect runtime.stack).toEqual [1]


  describe 'output', ->
    describe '.', ->
      it 'resolves at compile time', ->
        runtime = execute '1.'
        (expect runtime.push.calls.count()).toEqual 0
        (expect runtime.pop.calls.count()).toEqual 0
        (expect runtime.stack).toEqual []
        (expect runtime.outRecord).toEqual [1]

      it 'does not resolve at compile time', ->
        runtime = execute '.', [1]
        (expect runtime.push.calls.count()).toEqual 0
        (expect runtime.pop.calls.count()).toEqual 1
        (expect runtime.stack).toEqual []
        (expect runtime.outRecord).toEqual [1]

    describe ',', ->
      it 'resolves at compile time', ->
        runtime = execute '"1",'
        (expect runtime.push.calls.count()).toEqual 0
        (expect runtime.pop.calls.count()).toEqual 0
        (expect runtime.stack).toEqual []
        (expect runtime.outRecord).toEqual ['1']

      it 'escapes \'', ->
        runtime = execute '158*-,'
        (expect runtime.push.calls.count()).toEqual 0
        (expect runtime.pop.calls.count()).toEqual 0
        (expect runtime.stack).toEqual []
        (expect runtime.outRecord).toEqual ['\'']

      it 'escapes \\', ->
        runtime = execute '2999*++,'
        (expect runtime.push.calls.count()).toEqual 0
        (expect runtime.pop.calls.count()).toEqual 0
        (expect runtime.stack).toEqual []
        (expect runtime.outRecord).toEqual ['\\']

      it 'does not resolve at compile time', ->
        runtime = execute ',', [49]
        (expect runtime.push.calls.count()).toEqual 0
        (expect runtime.pop.calls.count()).toEqual 1
        (expect runtime.stack).toEqual []
        (expect runtime.outRecord).toEqual ['1']


  describe 'input', ->
    describe '&', ->
      it 'dumps the stack before adding to it', ->
        runtime = execute '123&', [], [4]
        (expect runtime.push.calls.count()).toEqual 2
        (expect runtime.pop.calls.count()).toEqual 0
        (expect runtime.stack).toEqual [1, 2, 3, 4]

      it 'does not dump an empty stack before adding to it', ->
        runtime = execute '&', [], [4]
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 0
        (expect runtime.stack).toEqual [4]

    describe '~', ->
      it 'dumps the stack before adding to it', ->
        runtime = execute '123~', [], ['4']
        (expect runtime.push.calls.count()).toEqual 2
        (expect runtime.pop.calls.count()).toEqual 0
        (expect runtime.stack).toEqual [1, 2, 3, 52]

      it 'does not dump an empty stack before adding to it', ->
        runtime = execute '~', [], ['4']
        (expect runtime.push.calls.count()).toEqual 1
        (expect runtime.pop.calls.count()).toEqual 0
        (expect runtime.stack).toEqual [52]

  describe 'p', ->
    it 'gets stack entries at compile time', ->
      runtime = execute '123p'
      (expect runtime.push.calls.count()).toEqual 0
      (expect runtime.pop.calls.count()).toEqual 0
      (expect runtime.put.calls.count()).toEqual 1

    it 'gets no stack entries at compile time', ->
      runtime = execute 'p', [1, 2, 3]
      (expect runtime.push.calls.count()).toEqual 0
      (expect runtime.pop.calls.count()).toEqual 3
      (expect runtime.put.calls.count()).toEqual 1

    it 'dumps the stack if path was invalidated ahead', ->
      runtime = execute '123456p789', [], [], true
      (expect runtime.push.calls.count()).toEqual 1
      (expect runtime.pop.calls.count()).toEqual 0
      (expect runtime.put.calls.count()).toEqual 1
      (expect runtime.stack).toEqual [1, 2, 3]

  describe 'g', ->
    it 'gets all stack entries at compile time', ->
      runtime = execute '12g'
      (expect runtime.push.calls.count()).toEqual 1
      (expect runtime.pop.calls.count()).toEqual 0
      (expect runtime.get.calls.count()).toEqual 1
      (expect runtime.stack).toEqual [55]

    it 'gets some stack entries at compile time', ->
      runtime = execute '2g', [1]
      (expect runtime.push.calls.count()).toEqual 1
      (expect runtime.pop.calls.count()).toEqual 1
      (expect runtime.get.calls.count()).toEqual 1
      (expect runtime.stack).toEqual [55]

    it 'gets some stack entries at compile time', ->
      runtime = execute 'g', [1, 2]
      (expect runtime.push.calls.count()).toEqual 1
      (expect runtime.pop.calls.count()).toEqual 2
      (expect runtime.get.calls.count()).toEqual 1
      (expect runtime.stack).toEqual [55]