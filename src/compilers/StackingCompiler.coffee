'use strict'


{ getDepth } = bef.PathMetrics
S = bef.Symbols


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


codeMap = new Map [
	[S.BLANK, ->]


	[S.D0, digitPusher 0]
	[S.D1, digitPusher 1]
	[S.D2, digitPusher 2]
	[S.D3, digitPusher 3]
	[S.D4, digitPusher 4]
	[S.D5, digitPusher 5]
	[S.D6, digitPusher 6]
	[S.D7, digitPusher 7]
	[S.D8, digitPusher 8]
	[S.D9, digitPusher 9]


	[S.ADD, binaryOperator ((o1, o2) -> o2 + o1), '+', (o1, o2) -> "(#{o2} + #{o1})"]
	[S.SUB, binaryOperator ((o1, o2) -> o2 - o1), '-', (o1, o2) -> "(#{o2} - #{o1})"]
	[S.MUL, binaryOperator ((o1, o2) -> o2 * o1), '*', (o1, o2) -> "(#{o2} * #{o1})"]
	[S.DIV, binaryOperator ((o1, o2) -> o2 // o1), '/', (o1, o2) -> "Math.floor(#{o2} / #{o1})"]
	[S.MOD, binaryOperator ((o1, o2) -> o2 % o1), '%', (o1, o2) -> "(#{o2} % #{o1})"]


	[S.NOT, (stack) ->
		operand = stack.pop()

		stack.push if isNumber operand
			 +!operand
		else
			"(+!#{operand})"

		return
	]


	[S.GT, binaryOperator ((o1, o2) -> +(o1 < o2)), '`', (o1, o2) -> "(+(#{o1} < #{o2}))"]


	[S.UP, ->]
	[S.LEFT, ->]
	[S.DOWN, ->]
	[S.RIGHT, ->]
	[S.RAND, ->]
	[S.IFH, ->]
	[S.IFV, ->]
	[S.QUOT, ->]


	[S.DUP, (stack) ->
		top = stack.peek()
		stack.push top
		return
	]


	[S.SWAP, (stack) ->
		e1 = stack.pop()
		e2 = stack.pop()
		stack.push e1, e2
		return
	]


	[S.DROP, (stack) ->
		stack.pop()
		return
	]


	[S.OUTI, (stack) ->
		stack.out("programState.out(#{stack.pop()})")
		return
	]


	[S.OUTC, (stack) ->
		stack.out("programState.outChar(String.fromCharCode(#{stack.pop()}))")
		return
	]


	[S.JUMP, ->]


	[S.PUT, -> '']


	[S.GET, (stack) ->
		stack.push "programState.get(#{stack.pop()}, #{stack.pop()})"
		return
	]


	[S.INI, (stack) ->
		stack.push stack.next()
		return
	]


	[S.INC, (stack) ->
		stack.push stack.nextChar()
		return
	]


	[S.END, (stack) ->
		stack.exit()
		return
	]
]

makeStack = (uid, ending, options = {}) ->
	popMethod = options.popMethod ? 'pop'
	freePops = options.freePops ? Infinity
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
			if ending?.charCode in [124, 95] # |_
				if stack.length == 0
					"branchFlag = #{@pop()};"
				else if stack.length == 1
					"branchFlag = #{stack[0]};"
				else
					last = stack.pop()
					"""
						#{pushBack stack, pushCount}
						branchFlag = #{last}
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

	stack = makeStack path.id, path.ending, options

	for entry in charList
		if entry.string
			stack.push entry.charCode
		else
			codeGenerator = codeMap.get entry.charCode
			if codeGenerator?
				codeGenerator stack

	stack.stringify()


writeBack = (count, uid) ->
	temps = ("t#{uid}_#{i}" for i in [0...count])
	"stack.push(#{temps.join ', '})"


assembleTight = (path, options) ->
	{ max, sum } = getDepth path

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