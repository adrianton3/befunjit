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

	describe 'swap', ->
		it 'swaps the first 2 entries of a stack', ->
			programState.push 11, 22, 33, 44
			programState.swap()
			(expect programState.stack).toEqual [11, 22, 44, 33]

		it 'pushes a 0 when the stack has 1 element', ->
			programState.push 11
			programState.swap()
			(expect programState.stack).toEqual [11, 0]

		it 'pushes 2 zeros when the stack is empty', ->
			programState.swap()
			(expect programState.stack).toEqual [0, 0]

	describe 'duplicate', ->
		it 'duplicates the last entry of a stack', ->
			programState.push 11, 22, 33, 44
			programState.duplicate()
			(expect programState.stack).toEqual [11, 22, 33, 44, 44]

		it 'duplicates the last entry of a one-element stack', ->
			programState.push 11
			programState.duplicate()
			(expect programState.stack).toEqual [11, 11]

		it 'does nothing to an empty stack', ->
			programState.duplicate()
			(expect programState.stack).toEqual []