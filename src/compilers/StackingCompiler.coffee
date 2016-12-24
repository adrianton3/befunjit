'use strict'


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
			declarations.push "var #{name} = programState.#{popMethod}()"
			name

	stackObj.peek = ->
		if stack.length > 0
			stack[stack.length - 1]
		else
			name = "p#{uid}_#{declarations.length}"
			# use const once node supports it
			declarations.push "var #{name} = programState.peek()"
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
						stack.push(#{stack.join ', '});
						#{branchChunk}
					"""
			else
				if stack.length == 0
					''
				else
					"stack.push(#{stack.join ', '});"

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


StackingCompiler = ->
Object.assign(StackingCompiler, {
	codeMap
	makeStack
	assemble
})


window.bef ?= {}
window.bef.StackingCompiler = StackingCompiler