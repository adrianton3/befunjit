'use strict'

isNumber = (obj) ->
	typeof obj == 'number'


digitPusher = (digit) ->
	(stack) ->
		stack.push digit
		"/* #{digit} */"


binaryOperator = (operatorFunction, operatorChar, stringFunction) ->
	(stack) ->
		operand1 = if stack.length then stack.pop() else 'programState.pop()'
		operand2 = if stack.length then stack.pop() else 'programState.pop()'
		if (isNumber operand1) and (isNumber operand2)
			stack.push operatorFunction operand1, operand2
			"/* #{operatorChar} */"
		else
			"/* #{operatorChar} */  #{stringFunction operand1, operand2}"


codeMap =
	' ': -> '/*   */'


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


	'+': binaryOperator ((o1, o2) -> o1 + o2), '+', (o1, o2) -> "programState.push(#{o1} + #{o2})"
	'-': binaryOperator ((o1, o2) -> o2 - o1), '-', (o1, o2) -> "programState.push(- #{o1} + #{o2})"
	'*': binaryOperator ((o1, o2) -> o1 * o2), '*', (o1, o2) -> "programState.push(#{o1} * #{o2})"
	'/': binaryOperator ((o1, o2) -> o2 // o1), '/', (o1, o2) -> "programState.div(#{o1}, #{o2})"
	'%': binaryOperator ((o1, o2) -> o2 % o1), '%', (o1, o2) -> "programState.mod(#{o1}, #{o2})"


	'!': (stack) ->
		if stack.length
			stack.push +!stack.pop()
			'/* ! */'
		else
			'/* ! */  programState.push(+!programState.pop())'


	'`': binaryOperator ((o1, o2) -> +(o1 < o2)), '`', (o1, o2) -> "programState.push(+(#{o1} < #{o2}))"


	'^': -> '/* ^ */'
	'<': -> '/* < */'
	'v': -> '/* v */'
	'>': -> '/* > */'
	'?': -> '/* ? */  /*return;*/'
	'_': -> '/* _ */  /*return;*/'
	'|': -> '/* | */  /*return;*/'
	'"': -> '/* " */'


	':': (stack) ->
		if stack.length
			stack.push stack[stack.length - 1]
			'/* : */'
		else
			'/* : */  programState.duplicate()'


	'\\': (stack) ->
		if stack.length > 1
			e1 = stack[stack.length - 1]
			e2 = stack[stack.length - 2]
			stack[stack.length - 1] = e2
			stack[stack.length - 2] = e1
			'/* \\ */'
		else if stack.length > 0
			"/* \\ */  programState.push(#{stack.pop()}, programState.pop())"
		else
			'/* \\ */  programState.swap()'


	'$': (stack) ->
		if stack.length
			stack.pop()
			'/* $ */'
		else
			'/* $ */  programState.pop()'


	'.': (stack) ->
		if stack.length
			"/* . */  programState.out(#{stack.pop()})"
		else
			'/* . */  programState.out(programState.pop())'


	',': (stack) ->
		if stack.length > 0
			"/* , */  programState.out(String.fromCharCode(#{stack.pop()}))"
		else
			'/* , */  programState.out(String.fromCharCode(programState.pop()))'


	'#': -> '/* # */'


	'p': -> ''


	'g': (stack) ->
		operand1 = if stack.length then stack.pop() else 'programState.pop()'
		operand2 = if stack.length then stack.pop() else 'programState.pop()'
		if stack.length
			stringedStack = stack.join ', '
			stack.length = 0
			"""
				/* g */
				programState.push(#{stringedStack});
				programState.push(programState.get(#{operand1}, #{operand2}));
			"""
		else
			"""
				/* g */  programState.push(programState.get(#{operand1}, #{operand2}));
			"""


	# require special handling
	'&': -> '/* & */  programState.push(programState.next())'
	'~': -> '/* ~ */  programState.push(programState.nextChar())'


	'@': -> '/* @ */  programState.exit(); /*return;*/'


OptimizingCompiler = ->


OptimizingCompiler.assemble = (path, options = {}) ->
	charList = path.getAsList()

	stack = []
	lines = charList.map ({ char, string }) ->
		if string
			stack.push char.charCodeAt 0
			"/* '#{char}' */"
		else
			codeGenerator = codeMap[char]
			if codeGenerator?
				ret = ''
				if char == '&' or char == '~'
					# dump the stack
					if stack.length
						ret += "programState.push(#{stack.join ', '});\n"
					stack = []
				ret += codeGenerator stack
				ret
			else if ' ' <= char <= '~'
				"/* '#{char}' */"
			else
				"/* ##{char.charCodeAt 0} */"

	if path.ending?.char in ['|', '_']
		if stack.length == 0
			lines.push "branchFlag = programState.pop()"
		else if stack.length == 1
			lines.push "branchFlag = #{stack[0]}"
		else
			last = stack.pop()
			lines.push(
				"programState.push(#{stack.join ', '})"
				"branchFlag = #{last}"
			)
	else
		if stack.length > 0
			lines.push "programState.push(#{stack.join ', '})"

	lines.join '\n'


window.bef ?= {}
window.bef.OptimizingCompiler = OptimizingCompiler