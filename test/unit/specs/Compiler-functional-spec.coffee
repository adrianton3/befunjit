'use strict'


{ Path, ProgramState } = bef


charCodes = (string) ->
	(string.split '').map (char) ->
		char.charCodeAt 0


generalSpecs = [{
	text: 'just exits'
	code: '@'
	outRecord: []
}, {
	text: 'outputs a number'
	code: '5.@'
	outRecord: [5]
}, {
	text: 'outputs a character'
	code: '77*,@'
	outRecord: ['1']
}, {
	text: 'evaluates an addition'
	code: '49+.@'
	outRecord: [13]
}, {
	text: 'evaluates a subtraction'
	code: '49-.@'
	outRecord: [-5]
}, {
	text: 'evaluates a multiplication'
	code: '49*.@'
	outRecord: [36]
}, {
	text: 'performs integer division'
	code: '94/.@'
	outRecord: [2]
}, {
	text: 'performs a modulo operation'
	code: '94%.@'
	outRecord: [1]
}, {
	text: 'performs unary not'
	code: '4!.@'
	outRecord: [0]
}, {
	text: 'evaluates a comparison'
	code: '94`.@'
	outRecord: [1]
}, {
	text: 'duplicates the value on the stack'
	code: '7:..@'
	outRecord: [7, 7]
}, {
	text: 'swaps the first two values on the stack'
	code: '275\\...@'
	outRecord: [7, 5, 2]
}, {
	text: 'discards the first value on the stack'
	code: '27$.@'
	outRecord: [2]
}, {
	text: 'can get a value from the playfield'
	code: '20g.@'
	outRecord: [55] # there is no playfield!
}, {
	text: 'can read an integer'
	code: '&.@'
	input: [123]
	outRecord: [123]
}, {
	text: 'can read a char'
	code: '~.@'
	input: ['a']
	outRecord: ['a'.charCodeAt 0]
}]


stringSpecs = [{
	text: 'pushes a string'
	code: '12"34"56......@'
	outRecord: [1, 2, 51, 52, 5, 6].reverse()
}, {
	text: 'does not change direction while in a string'
	code: '"V^"..@'
	outRecord: charCodes '^V'
}, {
	text: 'evaluates an empty string'
	code: '"".@'
	outRecord: [0]
}]


edgeCasesSpecs = [{
	text: 'pops 0 from an empty stack'
	code: '.@'
	outRecord: [0]
}, {
	text: 'ignores non-instructions'
	code: 'abc@'
	outRecord: []
}, {
	text: 'gets 0 if input is empty'
	code: '&&&&&.....@'
	input: [1, 2, 3]
	outRecord: [0, 0, 3, 2, 1]
}]


getPath = (string) ->
	path = new Path()
	stringMode = false
	(string.split '').forEach (char) ->
		if char == '"'
			stringMode = !stringMode
			path.push 0, 0, '>', char, false
		else
			path.push 0, 0, '>', char, stringMode
		return
	path


getProgramState = (input = [], pathInvalidatedAhead) ->
	programState = new ProgramState()
	programState.setInput input
	programState.flags.pathInvalidatedAhead = pathInvalidatedAhead

	programState.put = ->
	programState.get = -> 55

	programState


makeExecute = (compiler, options = {}) ->
	(code, input, pathInvalidatedAhead = false) ->
		path = getPath code
		compiler.compile path, options

		programState = getProgramState input, pathInvalidatedAhead
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