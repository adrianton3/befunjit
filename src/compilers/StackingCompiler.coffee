'use strict'


isNumber = (obj) ->
	typeof obj == 'number'


digitPusher = (digit) ->
	(x, y, dir, index, stack) ->
		stack.push digit
		return


binaryOperator = (operatorFunction, operatorChar, stringFunction) ->
	(x, y, dir, index, stack) ->
		operand1 = stack.popish()
		operand2 = stack.popish()

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


	'+': binaryOperator ((o1, o2) -> o1 + o2), '+', (o1, o2) -> "(#{o1} + #{o2})"
	'-': binaryOperator ((o1, o2) -> o2 - o1), '-', (o1, o2) -> "(-#{o1} + #{o2})"
	'*': binaryOperator ((o1, o2) -> o1 * o2), '*', (o1, o2) -> "(#{o1} * #{o2})"
	'/': binaryOperator ((o1, o2) -> o2 // o1), '/', (o1, o2) -> "Math.floor(#{o2} / #{o1})"
	'%': binaryOperator ((o1, o2) -> o2 % o1), '%', (o1, o2) -> "(#{o2} % #{o1})"


	'!': (x, y, dir, index, stack) ->
		stack.push "(+!#{stack.popish()})"
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


	':': (x, y, dir, index, stack) ->
		top = stack.peek()
		stack.push top
		return


	'\\': (x, y, dir, index, stack) ->
		e1 = stack.popish()
		e2 = stack.popish()
		stack.push e1, e2
		return


	'$': (x, y, dir, index, stack) ->
		stack.popish()
		return


	'.': (x, y, dir, index, stack) ->
		stack.out("programState.out(#{stack.popish()})")
		return


	',': (x, y, dir, index, stack) ->
		stack.out("programState.out(String.fromCharCode(#{stack.popish()}))")
		return


	'#': ->


	'p': (x, y, dir, index, stack, from, to) ->
		stack.dump()
		stack.int """
			programState.put(
				#{stack.popish()},
				#{stack.popish()},
				#{stack.popish()},
				#{x}, #{y}, '#{dir}', #{index},
				'#{from}', '#{to}'
			)
			if (programState.flags.pathInvalidatedAhead) {
				return
			}
		"""
		return


	'g': (x, y, dir, index, stack) ->
		stack.push "programState.get(#{stack.popish()}, #{stack.popish()})"
		return


	'&': (x, y, dir, index, stack) ->
		stack.push stack.next()
		return


	'~': (x, y, dir, index, stack) ->
		stack.push stack.nextChar()
		return


	'@': (x, y, dir, index, stack) ->
		stack.exit()
		return


StackingCompiler = ->


makeStack = (uid) ->
	stack = []
	pre = []
	read = []
	int = []
	post = []
	exit = false

	stackish = {}

	stackish.push = ->
		Array::push.apply stack, arguments
		return

	stackish.popish = ->
		if stack.length > 0
			stack.pop()
		else
			name = "p#{uid}_#{pre.length}"
			# use const once node supports it
			pre.push "var #{name} = programState.pop()"
			name

	stackish.peek = ->
		if stack.length
			stack[stack.length - 1]
		else
			name = "p#{uid}_#{pre.length}"
			# use const once node supports it
			pre.push "var #{name} = programState.peek()"
			name

	makeNext = (methodName) ->
		->
			name = "r#{uid}_#{read.length}"
			# use const once node supports it
			read.push "var #{name} = programState.#{methodName}()"
			name

	stackish.next = makeNext 'next'
	stackish.nextChar = makeNext 'nextChar'

	stackish.out = (entry) ->
		post.push entry
		return

	stackish.dump = ->
		int.push """
			#{pre.join '\n'}
			#{read.join '\n'}
			programState.push(#{stack.join ', '})
			#{post.join '\n'}
		"""

		stack = []
		pre = []
		read = []
		post = []

		return

	stackish.int = (entry) ->
		int.push entry
		return

	stackish.stringify = ->
		"""
			#{int.join '\n'}
			#{if exit then 'programState.exit()' else ''}
		"""


	stackish.exit = ->
		exit = true

	stackish


StackingCompiler.assemble = (path) ->
	charList = path.getAsList()

	stack = makeStack path.id

	charList.forEach (entry, i) ->
		if entry.string
			stack.push entry.char.charCodeAt 0
		else
			codeGenerator = codeMap[entry.char]
			if codeGenerator?
				codeGenerator entry.x, entry.y, entry.dir, i, stack, path.from, path.to
		return

	stack.dump()
	stack.stringify()


StackingCompiler.compile = (path) ->
	code = StackingCompiler.assemble path
	path.code = code #storing this just for debugging
	compiled = new Function 'programState', code
	path.body = compiled


window.bef ?= {}
window.bef.StackingCompiler = StackingCompiler