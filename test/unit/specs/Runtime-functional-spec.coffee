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
	text: 'executes a figure of 8'
	code: '''
			>>v
			@.9<
			..>^
		'''
	outRecord: [9]
}, {
	text: 'evaluates a conditional'
	code: '''
			0  v
			@.7_9.@
		'''
	outRecord: [9]
}, {
	text: 'mutates the current path, before the current index'
	code: '2077*p5.@'
	outRecord: [5]
}, {
	text: 'mutates the current path, after the current index'
	code: '77*60p5.@'
	outRecord: [1]
}, {
	text: 'mutates the current path twice, after the current index'
	code: '''
			>77*23pv
			v      <
			>96*23pv
			@.9 _1 <
		'''
	outRecord: [6]
}, {
	text: 'mutates a conditional'
	code: '''
			v>>>>>>>8v
			>77*71p| >.@
			>>>>>>>>9^
		'''
	outRecord: [1]
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
	outRecord: ['g'.charCodeAt 0]
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


charCodes = (string) ->
	(string.split '').map (char) ->
		char.charCodeAt 0

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
}, {
	text: 'gets 0 when trying to access cells outside of the playfield'
	code: '99g.@'
	outRecord: [0]
}, {
	text: 'does not crash when trying to write outside of the playfield'
	code: '999p@'
	outRecord: []
}]


run = (specs, execute) ->
	specs.forEach (spec) ->
		it spec.text, ->
			{ outRecord } = execute spec.code, spec.input

			(expect outRecord).toEqual spec.outRecord


window.befTest ?= {}
window.befTest.runtimeSuite = run

window.befTest.specs =
	general: generalSpecs
	string: stringSpecs
	edgeCases: edgeCasesSpecs