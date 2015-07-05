describe 'LazyRuntime', ->
  Playfield = bef.Playfield
  LazyRuntime = bef.LazyRuntime

  getPlayfield = (string, width, height) ->
    playfield = new Playfield width, height
    playfield.fromString string, width, height
    playfield

  getInterpreter = (string, width, height) ->
    playfield = getPlayfield string, width, height
    lazyRuntime = new LazyRuntime()
    lazyRuntime.playfield = playfield
    lazyRuntime

  describe 'getPath', ->
    it 'gets a simple path until the pointer exist the playground', ->
      lazyRuntime = getInterpreter 'abc@', 4, 1

      paths = lazyRuntime._getPath 0, 0, '>'
      pathAsList = paths[0].getAsList()
      (expect pathAsList).toEqual [
        { x: 0, y: 0, dir: '>', char: 'a', string: false }
        { x: 1, y: 0, dir: '>', char: 'b', string: false }
        { x: 2, y: 0, dir: '>', char: 'c', string: false }
      ]

    it 'can get a turning path', ->
      lazyRuntime = getInterpreter '''
        abv
          c
          d
          @
      ''', 3, 4

      paths = lazyRuntime._getPath 0, 0, '>'
      pathAsList = paths[0].getAsList()
      (expect pathAsList).toEqual [
        { x: 0, y: 0, dir: '>', char: 'a', string: false }
        { x: 1, y: 0, dir: '>', char: 'b', string: false }
        { x: 2, y: 0, dir: 'v', char: 'v', string: false }
        { x: 2, y: 1, dir: 'v', char: 'c', string: false }
        { x: 2, y: 2, dir: 'v', char: 'd', string: false }
      ]

    it 'can get a circular path', ->
      lazyRuntime = getInterpreter '''
        >av
        d b
        ^c<
      ''', 3, 3

      paths = lazyRuntime._getPath 0, 0, '>'

      pathAsList = paths[0].getAsList()
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
      lazyRuntime = getInterpreter '''
        abc
      ''', 3, 1

      paths = lazyRuntime._getPath 0, 0, '>'

      pathAsList = paths[0].getAsList()
      (expect pathAsList).toEqual [
        { x: 0, y: 0, dir: '>', char: 'a', string: false }
        { x: 1, y: 0, dir: '>', char: 'b', string: false }
        { x: 2, y: 0, dir: '>', char: 'c', string: false }
      ]

    it 'can get the initial part of a circular path', ->
      lazyRuntime = getInterpreter '''
        ab>cv
          f d
          ^e<
      ''', 5, 3

      paths = lazyRuntime._getPath 0, 0, '>'

      pathAsList = paths[0].getAsList()
      (expect pathAsList).toEqual [
        { x: 0, y: 0, dir: '>', char: 'a', string: false }
        { x: 1, y: 0, dir: '>', char: 'b', string: false }
      ]

      pathAsList = paths[1].getAsList()
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
      lazyRuntime = getInterpreter '''
        a#bc@
      ''', 5, 1

      paths = lazyRuntime._getPath 0, 0, '>'

      pathAsList = paths[0].getAsList()
      (expect pathAsList).toEqual [
        { x: 0, y: 0, dir: '>', char: 'a', string: false }
        { x: 1, y: 0, dir: '>', char: '#', string: false }
        { x: 3, y: 0, dir: '>', char: 'c', string: false }
      ]

    it 'can jump repeatedly', ->
      lazyRuntime = getInterpreter '''
        a#b#cd@
      ''', 7, 1

      paths = lazyRuntime._getPath 0, 0, '>'

      pathAsList = paths[0].getAsList()
      (expect pathAsList).toEqual [
        { x: 0, y: 0, dir: '>', char: 'a', string: false }
        { x: 1, y: 0, dir: '>', char: '#', string: false }
        { x: 3, y: 0, dir: '>', char: '#', string: false }
        { x: 5, y: 0, dir: '>', char: 'd', string: false }
      ]

    it 'parses a string', ->
      lazyRuntime = getInterpreter '''
        12"34"56
      ''', 8, 1

      paths = lazyRuntime._getPath 0, 0, '>'
      pathAsList = paths[0].getAsList()
      (expect pathAsList).toEqual [
        { x: 0, y: 0, dir: '>', char: '1', string: false }
        { x: 1, y: 0, dir: '>', char: '2', string: false }
        { x: 2, y: 0, dir: '>', char: '"', string: false }
        { x: 3, y: 0, dir: '>', char: '3', string: true }
        { x: 4, y: 0, dir: '>', char: '4', string: true }
        { x: 5, y: 0, dir: '>', char: '"', string: false }
        { x: 6, y: 0, dir: '>', char: '5', string: false }
        { x: 7, y: 0, dir: '>', char: '6', string: false }
      ]

    it 'wraps around 2 times to close a string', ->
      lazyRuntime = getInterpreter '''
        12"34
      ''', 5, 1

      paths = lazyRuntime._getPath 0, 0, '>'
      pathAsList = paths[0].getAsList()
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
			lazyRuntime = getInterpreter '__'

			paths = lazyRuntime._getPath 0, 0, '>'
			pathAsList = paths[0].getAsList()
			(expect pathAsList).toEqual []


  describe 'execute', ->
    execute = (string, width, height, options, input = []) ->
      playfield = new Playfield()
      playfield.fromString string, width, height

      lazyRuntime = new LazyRuntime()
      lazyRuntime.execute playfield, options, input

      lazyRuntime

    it 'just exits', ->
      lazyRuntime = execute '''
        @
      ''', 1, 1

      (expect lazyRuntime.programState.stack).toEqual []
      (expect lazyRuntime.programState.outRecord).toEqual []
      (expect lazyRuntime.stats.compileCalls).toEqual 1

    it 'outputs a number', ->
      lazyRuntime = execute '''
        5.@
      ''', 3, 1

      (expect lazyRuntime.programState.stack).toEqual []
      (expect lazyRuntime.programState.outRecord).toEqual [5]
      (expect lazyRuntime.stats.compileCalls).toEqual 1

    it 'outputs a character', ->
      lazyRuntime = execute '''
        77*,@
      ''', 5, 1

      (expect lazyRuntime.programState.stack).toEqual []
      (expect lazyRuntime.programState.outRecord).toEqual ['1']
      (expect lazyRuntime.stats.compileCalls).toEqual 1

    it 'loops forever (or until the too-many-jumps condition holds)', ->
      lazyRuntime = execute '''
        >7v
        ^.<
      ''', 3, 2, jumpLimit: 3

      (expect lazyRuntime.programState.stack).toEqual []
      (expect lazyRuntime.programState.outRecord).toEqual [7, 7, 7]
      (expect lazyRuntime.stats.compileCalls).toEqual 1

    it 'executes a figure of 8', ->
      lazyRuntime = execute '''
          v
        @.9<
          >^
      ''', 4, 3

      (expect lazyRuntime.programState.stack).toEqual [9]
      (expect lazyRuntime.programState.outRecord).toEqual [9]
      (expect lazyRuntime.stats.compileCalls).toEqual 1

    it 'evaluates a conditional', ->
      lazyRuntime = execute '''
        0  v
        @.7_9.@
      ''', 7, 2

      (expect lazyRuntime.programState.stack).toEqual []
      (expect lazyRuntime.programState.outRecord).toEqual [9]
      (expect lazyRuntime.stats.compileCalls).toEqual 2

    it 'mutates the current path, before the current index', ->
      lazyRuntime = execute '''
        2077*p5.@
      ''', 10, 1

      (expect lazyRuntime.programState.stack).toEqual []
      (expect lazyRuntime.programState.outRecord).toEqual [5]
      (expect lazyRuntime.stats.compileCalls).toEqual 1

    it 'mutates the current path, after the current index', ->
      lazyRuntime = execute '''
        6077*p5.@
      ''', 10, 1

      (expect lazyRuntime.programState.stack).toEqual []
      (expect lazyRuntime.programState.outRecord).toEqual [1]
      (expect lazyRuntime.stats.compileCalls).toEqual 2

    it 'evaluates an addition', ->
      lazyRuntime = execute '''
        49+.@
      ''', 10, 1

      (expect lazyRuntime.programState.stack).toEqual []
      (expect lazyRuntime.programState.outRecord).toEqual [13]
      (expect lazyRuntime.stats.compileCalls).toEqual 1

    it 'evaluates a subtraction', ->
      lazyRuntime = execute '''
        49-.@
      ''', 10, 1

      (expect lazyRuntime.programState.stack).toEqual []
      (expect lazyRuntime.programState.outRecord).toEqual [5]
      (expect lazyRuntime.stats.compileCalls).toEqual 1

    it 'evaluates a multiplication', ->
      lazyRuntime = execute '''
        49*.@
      ''', 10, 1

      (expect lazyRuntime.programState.stack).toEqual []
      (expect lazyRuntime.programState.outRecord).toEqual [36]
      (expect lazyRuntime.stats.compileCalls).toEqual 1

    it 'performs integer division', ->
      lazyRuntime = execute '''
        49/.@
      ''', 10, 1

      (expect lazyRuntime.programState.stack).toEqual []
      (expect lazyRuntime.programState.outRecord).toEqual [2]
      (expect lazyRuntime.stats.compileCalls).toEqual 1

    it 'performs a modulo operation', ->
      lazyRuntime = execute '''
        49%.@
      ''', 10, 1

      (expect lazyRuntime.programState.stack).toEqual []
      (expect lazyRuntime.programState.outRecord).toEqual [1]
      (expect lazyRuntime.stats.compileCalls).toEqual 1

    it 'performs unary not', ->
      lazyRuntime = execute '''
        4!.@
      ''', 10, 1

      (expect lazyRuntime.programState.stack).toEqual []
      (expect lazyRuntime.programState.outRecord).toEqual [0]
      (expect lazyRuntime.stats.compileCalls).toEqual 1

    it 'evaluates a comparison', ->
      lazyRuntime = execute '''
        49`.@
      ''', 10, 1

      (expect lazyRuntime.programState.stack).toEqual []
      (expect lazyRuntime.programState.outRecord).toEqual [1]
      (expect lazyRuntime.stats.compileCalls).toEqual 1

    it 'changes direction randomly', ->
      source = [
        '?2.@.3',
        '4',
        '.',
        '@',
        '.',
        '5'
      ].join '\n'

      thunk = -> execute source, 6, 6

      sum = 0
      hits = []
      # run for a couple of times
      # just enough so all directions should be hit
      for i in [1..20]
        lazyRuntime = thunk()
        output = lazyRuntime.programState.outRecord[0]
        sum += output
        hits[output] = true

      expectedHits = []
      expectedHits[2] = true
      expectedHits[3] = true
      expectedHits[4] = true
      expectedHits[5] = true
      (expect hits).toEqual expectedHits

    it 'duplicates the value on the stack', ->
      lazyRuntime = execute '''
        7:@
      ''', 10, 1

      (expect lazyRuntime.programState.stack).toEqual [7, 7]
      (expect lazyRuntime.programState.outRecord).toEqual []
      (expect lazyRuntime.stats.compileCalls).toEqual 1

    it 'swaps the first two values on the stack', ->
      lazyRuntime = execute '''
        275\\@
      ''', 10, 1

      (expect lazyRuntime.programState.stack).toEqual [2, 5, 7]
      (expect lazyRuntime.programState.outRecord).toEqual []
      (expect lazyRuntime.stats.compileCalls).toEqual 1

    it 'discards the first value on the stack', ->
      lazyRuntime = execute '''
        27$@
      ''', 10, 1

      (expect lazyRuntime.programState.stack).toEqual [2]
      (expect lazyRuntime.programState.outRecord).toEqual []
      (expect lazyRuntime.stats.compileCalls).toEqual 1

    it 'can get a value from the playfield', ->
      lazyRuntime = execute '''
        20g@
      ''', 10, 1

      (expect lazyRuntime.programState.stack).toEqual ['g'.charCodeAt 0]
      (expect lazyRuntime.programState.outRecord).toEqual []
      (expect lazyRuntime.stats.compileCalls).toEqual 1

    it 'can read an integer', ->
      lazyRuntime = execute '''
        &@
      ''', 10, 1, null, [123]

      (expect lazyRuntime.programState.stack).toEqual [123]
      (expect lazyRuntime.programState.outRecord).toEqual []
      (expect lazyRuntime.stats.compileCalls).toEqual 1

    it 'can read a char', ->
      lazyRuntime = execute '''
        ~@
      ''', 10, 1, null, ['a']

      (expect lazyRuntime.programState.stack).toEqual ['a'.charCodeAt 0]
      (expect lazyRuntime.programState.outRecord).toEqual []
      (expect lazyRuntime.stats.compileCalls).toEqual 1

    describe 'strings', ->
      charCodes = (string) ->
        (string.split '').map (char) ->
          char.charCodeAt 0

      it 'pushes a string', ->
        lazyRuntime = execute '''
          12"34"56@
        ''', 10, 1

        (expect lazyRuntime.programState.stack).toEqual [1, 2, 51, 52, 5, 6]
        (expect lazyRuntime.programState.outRecord).toEqual []
        (expect lazyRuntime.stats.compileCalls).toEqual 1

      it 'wraps around 2 times to close a string', ->
        lazyRuntime = execute '''
          12"34
        ''', 5, 1, jumpLimit: 1

        (expect lazyRuntime.programState.stack).toEqual [1, 2, 51, 52, 49, 50, 3, 4]
        (expect lazyRuntime.programState.outRecord).toEqual []
        (expect lazyRuntime.stats.compileCalls).toEqual 1

      it 'does not change direction while in a string', ->
        lazyRuntime = execute '''
          "V^"@
        ''', 10, 1

        (expect lazyRuntime.programState.stack).toEqual charCodes 'V^'
        (expect lazyRuntime.programState.outRecord).toEqual []
        (expect lazyRuntime.stats.compileCalls).toEqual 1

      it 'evaluates an empty string', ->
        lazyRuntime = execute '''
          ""@
        ''', 5, 1

        (expect lazyRuntime.programState.stack).toEqual []
        (expect lazyRuntime.programState.outRecord).toEqual []
        (expect lazyRuntime.stats.compileCalls).toEqual 1

    describe 'edge cases', ->
      it 'pops 0 from an empty stack', ->
        lazyRuntime = execute '''
          .@
        ''', 5, 1

        (expect lazyRuntime.programState.stack).toEqual []
        (expect lazyRuntime.programState.outRecord).toEqual [0]
        (expect lazyRuntime.stats.compileCalls).toEqual 1

      it 'ignores non-instructions', ->
        lazyRuntime = execute '''
          abc@
        ''', 5, 1

        (expect lazyRuntime.programState.stack).toEqual []
        (expect lazyRuntime.programState.outRecord).toEqual []
        (expect lazyRuntime.stats.compileCalls).toEqual 1

      it 'gets 0 if input is empty', ->
        lazyRuntime = execute '''
          &&&&&@
        ''', 6, 1, {}, [1, 2, 3]

        (expect lazyRuntime.programState.stack).toEqual [1, 2, 3, 0, 0]
        (expect lazyRuntime.programState.outRecord).toEqual []
        (expect lazyRuntime.stats.compileCalls).toEqual 1

      it 'gets 0 when trying to access cells outside of the playfield', ->
        lazyRuntime = execute '''
          99g@
        ''', 6, 1

        (expect lazyRuntime.programState.stack).toEqual [0]
        (expect lazyRuntime.programState.outRecord).toEqual []
        (expect lazyRuntime.stats.compileCalls).toEqual 1

      it 'does not crash when trying to write outside of the playfield', ->
        lazyRuntime = execute '''
          999p@
        ''', 6, 1

        (expect lazyRuntime.programState.stack).toEqual []
        (expect lazyRuntime.programState.outRecord).toEqual []
        (expect lazyRuntime.stats.compileCalls).toEqual 1