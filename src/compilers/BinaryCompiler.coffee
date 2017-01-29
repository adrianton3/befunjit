'use strict'


generateTree = (codes, id) ->
	generate = (from, to) ->
		if from >= to
			codes[from]
		else
			mid = (from + to) // 2
			"""
				if (length_#{id} < #{mid + 1}) {
					#{generate from, mid}
				} else {
					#{generate mid + 1, to}
				}
			"""

	if codes.length == 0
		''
	else if codes.length == 1
		codes[0]
	else
		"""
			const length_#{id} = programState.getLength()
			if (length_#{id} < #{codes.length - 1}) {
				#{generate 0, codes.length - 2}
			} else {
				#{codes[codes.length - 1]}
			}
		"""


generateCode = (path, maxDepth, options) ->
	{ makeStack, codeMap } = window.bef.StackingCompiler

	charList = path.getAsList()

	stack = makeStack(
		"#{path.id}_#{maxDepth}"
		path.ending
		Object.assign { popMethod: 'popUnsafe', freePops: maxDepth }, options
	)

	charList.forEach (entry, i) ->
		if entry.string
			stack.push entry.char.charCodeAt 0
		else
			codeGenerator = codeMap[entry.char]
			if codeGenerator?
				codeGenerator stack
		return

	stack.stringify()


assemble = (path, options = {}) ->
	{ max } = bef.PathMetrics.getDepth path
	codes = ((generateCode path, depth, options) for depth in [0..max])
	generateTree codes, path.id


BinaryCompiler = ->
Object.assign(BinaryCompiler, {
	generateTree
	assemble
})

window.bef ?= {}
window.bef.BinaryCompiler = BinaryCompiler