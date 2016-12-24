'use strict'

consumePair = (consume, delta) ->
	{ consume, delta }


consumeCount = new Map [
	[' ', consumePair 0, 0]

	['0', consumePair 0, 1]
	['1', consumePair 0, 1]
	['2', consumePair 0, 1]
	['3', consumePair 0, 1]
	['4', consumePair 0, 1]
	['5', consumePair 0, 1]
	['6', consumePair 0, 1]
	['7', consumePair 0, 1]
	['8', consumePair 0, 1]
	['9', consumePair 0, 1]

	['+', consumePair 2, -1]
	['-', consumePair 2, -1]
	['*', consumePair 2, -1]
	['/', consumePair 2, -1]
	['%', consumePair 2, -1]

	['!', consumePair 1, 0]
	['`', consumePair 2, -1]

	['^', consumePair 0, 0]
	['<', consumePair 0, 0]
	['v', consumePair 0, 0]
	['>', consumePair 0, 0]
	['?', consumePair 0, 0]
	['_', consumePair 0, 0]
	['|', consumePair 0, 0]
	['"', consumePair 0, 0]

	[':', consumePair 0, 1]
	['\\', consumePair 2, 0]
	['$', consumePair 1, -1]

	['.', consumePair 1, -1]
	[',', consumePair 1, -1]
	['#', consumePair 0, 0]
	['p', consumePair 3, -3]
	['g', consumePair 2, -1]
	['&', consumePair 0, 1]
	['~', consumePair 0, 1]
	['@', consumePair 0, 0]
]


getMaxDepth = (path) ->
	{ max } = path.getAsList().reduce ({ max, sum }, { char, string }) ->
		{ consume, delta } = if string
			{ consume: 0, delta: 1 }
		else if consumeCount.has char
			consumeCount.get char
		else
			{ consume: 0, delta: 0 }

		sum: sum + delta
		max: Math.min max, sum - consume
	, { max: 0, sum: 0 }

	-max


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


generateCode = (path, maxDepth) ->
	{ makeStack, codeMap } = window.bef.StackingCompiler

	charList = path.getAsList()

	stack = makeStack(
		"#{path.id}_#{maxDepth}"
		{ popMethod: 'popUnsafe', freePops: maxDepth }
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


assemble = (path) ->
	maxDepth = getMaxDepth path
	codes = ((generateCode path, depth) for depth in [0..maxDepth])
	generateTree codes, path.id


BinaryCompiler = ->
Object.assign(BinaryCompiler, {
	getMaxDepth
	generateTree
	assemble
})

window.bef ?= {}
window.bef.BinaryCompiler = BinaryCompiler