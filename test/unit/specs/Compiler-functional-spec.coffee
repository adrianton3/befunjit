'use strict'


{ Path, ProgramState } = bef
S = bef.Symbols


generalSpecs = [{
	text: 'just exits'
	code: '@'
	outRecord: []
}, {
	text: 'outputs a number'
	code: '5.@'
	outRecord: [5, ' ']
}, {
	text: 'outputs a character'
	code: '77*,@'
	outRecord: ['1']
}, {
	text: 'evaluates an addition'
	code: '49+.@'
	outRecord: [13, ' ']
}, {
	text: 'evaluates a subtraction'
	code: '49-.@'
	outRecord: [-5, ' ']
}, {
	text: 'evaluates a multiplication'
	code: '49*.@'
	outRecord: [36, ' ']
}, {
	text: 'performs integer division'
	code: '94/.@'
	outRecord: [2, ' ']
}, {
	text: 'performs a modulo operation'
	code: '94%.@'
	outRecord: [1, ' ']
}, {
	text: 'performs unary not'
	code: '4!.@'
	outRecord: [0, ' ']
}, {
	text: 'evaluates a comparison'
	code: '94`.@'
	outRecord: [1, ' ']
}, {
	text: 'duplicates the value on the stack'
	code: '7:..@'
	outRecord: [7, ' ', 7, ' ']
}, {
	text: 'swaps the first two values on the stack'
	code: '275\\...@'
	outRecord: [7, ' ', 5, ' ', 2, ' ']
}, {
	text: 'discards the first value on the stack'
	code: '27$.@'
	outRecord: [2, ' ']
}, {
	text: 'can get a value from the playfield'
	code: '20g.@'
	outRecord: [55, ' '] # there is no playfield!
}, {
	text: 'can read an integer'
	code: '&.@'
	input: [123]
	outRecord: [123, ' ']
}, {
	text: 'can read a char'
	code: '~.@'
	input: ['a']
	outRecord: [('a'.charCodeAt 0), ' ']
}]


stringSpecs = [{
	text: 'pushes a string'
	code: '12"34"56......@'
	outRecord: [6, ' ', 5, ' ', 52, ' ', 51, ' ', 2, ' ', 1, ' ']
}, {
	text: 'does not change direction while in a string'
	code: '"v^"..@'
	outRecord: [S.UP, ' ', S.DOWN, ' ']
}, {
	text: 'evaluates an empty string'
	code: '"".@'
	outRecord: [0, ' ']
}]


edgeCasesSpecs = [{
	text: 'pops 0 from an empty stack'
	code: '.@'
	outRecord: [0, ' ']
}, {
	text: 'ignores non-instructions'
	code: 'abc@'
	outRecord: []
}, {
	text: 'gets 0 if input is empty'
	code: '&&&&&.....@'
	input: [1, 2, 3]
	outRecord: [0, ' ', 0, ' ', 3, ' ', 2, ' ', 1, ' ']
}]


getPath = (string) ->
	path = new Path()
	stringMode = false

	(string.split '').forEach (char) ->
		charCode = char.charCodeAt 0

		if charCode == S.QUOT
			stringMode = !stringMode
			path.push 0, 0, S.RIGHT, charCode, false
		else
			path.push 0, 0, S.RIGHT, charCode, stringMode
		return

	path


getProgramState = (input = []) ->
	programState = new ProgramState()
	programState.setInput input

	programState.put = ->
	programState.get = -> 55

	programState


compile = (compiler, path) ->
	code ="""
			stack = programState.stack;
			#{compiler.assemble path}
		"""
	path.code = code
	path.body = new Function 'programState', code


makeExecute = (compiler) ->
	(code, input) ->
		path = getPath code
		compile compiler, path

		programState = getProgramState input
		path.body programState

		programState


runSuite = (specs, execute) ->
	specs.forEach (spec) ->
		it spec.text, ->
			{ code, input, pathInvalidatedAhead } = spec
			{ outRecord } = execute code, input, pathInvalidatedAhead

			(expect outRecord).toEqual spec.outRecord


window.befTest ?= {}
window.befTest.makeExecute = makeExecute
window.befTest.runSuite = runSuite
window.befTest.getPath = getPath

window.befTest.compilerSpecs =
	general: generalSpecs
	string: stringSpecs
	edgeCases: edgeCasesSpecs