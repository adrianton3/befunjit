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
	['_', consumePair 1, -1]
	['|', consumePair 1, -1]
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
	{ max, sum } = path.getAsList().reduce ({ max, sum }, { char, string }) ->
		{ consume, delta } = if string
			{ consume: 0, delta: 1 }
		else if consumeCount.has char
			consumeCount.get char
		else
			{ consume: 0, delta: 0 }

		sum: sum + delta
		max: Math.min max, sum - consume
	, { max: 0, sum: 0 }

	{ max: -max, sum }


isNumber = (obj) ->
	typeof obj == 'number'


digitPusher = (digit) ->
	(stack) ->
		stack.push digit
		return


binaryOperator = (operatorFunction, operatorChar, stringFunction) ->
	(stack) ->
		operand1 = stack.pop()
		operand2 = stack.pop()

		fun = if (isNumber operand1) and (isNumber operand2)
			operatorFunction
		else
			stringFunction

		stack.push fun operand1, operand2

		return


codeMap =
	' ': ->


	'0': digitPusher 0
	'1': digitPusher 1
	'2': digitPusher 2
	'3': digitPusher 3
	'4': digitPusher 4
	'5': digitPusher 5
	'6': digitPusher 6
	'7': digitPusher 7
	'8': digitPusher 8
	'9': digitPusher 9


	'+': binaryOperator ((o1, o2) -> o2 + o1), '+', (o1, o2) -> "(#{o2} + #{o1})"
	'-': binaryOperator ((o1, o2) -> o2 - o1), '-', (o1, o2) -> "(#{o2} - #{o1})"
	'*': binaryOperator ((o1, o2) -> o2 * o1), '*', (o1, o2) -> "(#{o2} * #{o1})"
	'/': binaryOperator ((o1, o2) -> o2 // o1), '/', (o1, o2) -> "Math.floor(#{o2} / #{o1})"
	'%': binaryOperator ((o1, o2) -> o2 % o1), '%', (o1, o2) -> "(#{o2} % #{o1})"


	'!': (stack) ->
		operand = stack.pop()

		stack.push if isNumber operand
			 +!operand
		else
			"(+!#{operand})"

		return


	'`': binaryOperator ((o1, o2) -> +(o1 < o2)), '`', (o1, o2) -> "(+(#{o1} < #{o2}))"


	'^': ->
	'<': ->
	'v': ->
	'>': ->
	'?': ->
	'_': ->
	'|': ->
	'"': ->


	':': (stack) ->
		top = stack.peek()
		stack.push top
		return


	'\\': (stack) ->
		e1 = stack.pop()
		e2 = stack.pop()
		stack.push e1, e2
		return


	'$': (stack) ->
		stack.pop()
		return


	'.': (stack) ->
		stack.out("programState.out(#{stack.pop()})")
		return


	',': (stack) ->
		stack.out("programState.out(String.fromCharCode(#{stack.pop()}))")
		return


	'#': ->


	'p': -> ''


	'g': (stack) ->
		stack.push "programState.get(#{stack.pop()}, #{stack.pop()})"
		return


	'&': (stack) ->
		stack.push stack.next()
		return


	'~': (stack) ->
		stack.push stack.nextChar()
		return


	'@': (stack) ->
		stack.exit()
		return


makeStack = (uid, options = {}) ->
	popMethod = options.popMethod ? 'pop'
	freePops = options.freePops ? Infinity
	fastConditionals = options.fastConditionals ? false
	popCount = options.popCount ? 0
	pushCount = options.pushCount ? 0

	stack = []
	declarations = []
	reads = []
	writes = []
	exitRequest = false

	stackObj = {}

	stackObj.push = ->
		Array::push.apply stack, arguments
		return

	stackObj.pop = ->
		if stack.length > 0
			stack.pop()
		else if freePops <= 0
			0
		else
			freePops--
			name = "p#{uid}_#{declarations.length}"
			# use const once node supports it
			declarations.push(
				if popCount > 0
					"var #{name} = t#{uid}_#{popCount - 1}"
				else
					"var #{name} = programState.#{popMethod}()"
			)
			popCount = Math.max 0, popCount - 1
			name

	stackObj.peek = ->
		if stack.length > 0
			stack[stack.length - 1]
		else
			name = "p#{uid}_#{declarations.length}"
			# use const once node supports it
			declarations.push(
				if popCount > 0
					"var #{name} = t#{uid}_#{popCount - 1}"
				else
					"var #{name} = programState.peek()"
			)
			name

	makeNext = (methodName) ->
		->
			name = "r#{uid}_#{reads.length}"
			# use const once node supports it
			reads.push "var #{name} = programState.#{methodName}()"
			name

	stackObj.next = makeNext 'next'
	stackObj.nextChar = makeNext 'nextChar'

	stackObj.out = (entry) ->
		writes.push entry
		return

	pushBack = (stack, pushCount) ->
		copies = ("t#{uid}_#{i} = #{stack[i]}" for i in [0...pushCount])
		if pushCount < stack.length
			pushes = stack.slice pushCount
			"""
				#{copies.join '\n'}
				stack.push(#{pushes.join ', '})
			"""
		else
			copies.join '\n'

	stackObj.stringify = ->
		stackChunk =
			if fastConditionals
				if stack.length == 0
					'branchFlag = programState.pop();'
				else if stack.length == 1
					"branchFlag = #{stack[0]};"
				else
					branchChunk = "branchFlag = #{stack.pop()};"
					"""
						#{pushBack stack, pushCount}
						#{branchChunk}
					"""
			else
				if stack.length == 0
					''
				else
					pushBack stack, pushCount

		"""
			#{declarations.join '\n'}
			#{reads.join '\n'}
			#{stackChunk}
			#{writes.join '\n'}
			#{if exitRequest then 'programState.exit()' else ''}
		"""

	stackObj.exit = ->
		exitRequest = true

	stackObj


assemble = (path, options) ->
	charList = path.getAsList()

	stack = makeStack path.id, options

	charList.forEach (entry) ->
		if entry.string
			stack.push entry.char.charCodeAt 0
		else
			codeGenerator = codeMap[entry.char]
			if codeGenerator?
				codeGenerator stack
		return

	stack.stringify()


writeBack = (count, uid) ->
	temps = ("t#{uid}_#{i}" for i in [0...count])
	"stack.push(#{temps.join ', '})"


assembleTight = (path, options) ->
	{ max, sum } = getMaxDepth path

	tempCount = Math.min max, max + sum

	if tempCount <= 0
		assemble path, options
	else
		pushCount = tempCount
		popCount = tempCount

		pre: assemble path, Object.assign { pushCount }, options
		body: assemble path, Object.assign { popCount, pushCount }, options
		post: writeBack tempCount, path.id


StackingCompiler = ->
Object.assign(StackingCompiler, {
	codeMap
	makeStack
	assemble
	assembleTight
})


window.bef ?= {}
window.bef.StackingCompiler = StackingCompiler