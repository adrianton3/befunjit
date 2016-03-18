'use strict'

isNumber = (obj) ->
	typeof obj == 'number'


digitPusher = (digit) ->
	(x, y, dir, index, stack) ->
		stack.push digit
		"/* #{digit} */"


binaryOperator = (operatorFunction, operatorChar, stringFunction) ->
	(x, y, dir, index, stack) ->
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


	'!': (x, y, dir, index, stack) ->
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


	':': (x, y, dir, index, stack) ->
		if stack.length
			stack.push stack[stack.length - 1]
			'/* : */'
		else
			'/* : */  programState.duplicate()'


	'\\': (x, y, dir, index, stack) ->
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


	'$': (x, y, dir, index, stack) ->
		if stack.length
			stack.pop()
			'/* $ */'
		else
			'/* $ */  programState.pop()'


	'.': (x, y, dir, index, stack) ->
		if stack.length
			"/* . */  programState.out(#{stack.pop()})"
		else
			'/* . */  programState.out(programState.pop())'


	',': (x, y, dir, index, stack) ->
		if stack.length
			char = String.fromCharCode stack.pop()

			safeChar = switch char
				when "'"
					"\\'"
				when '\\'
					'\\\\'
				when '\n'
					'\\n'
				when '\r'
					'\\r'
				when '\t'
					'\\t'
				else
					char

			"/* , */  programState.out('#{safeChar}')"
		else
			'/* , */  programState.out(String.fromCharCode(programState.pop()))'


	'#': -> '/* # */'


	'p': (x, y, dir, index, stack, from, to) ->
		operand1 = if stack.length then stack.pop() else 'programState.pop()'
		operand2 = if stack.length then stack.pop() else 'programState.pop()'
		operand3 = if stack.length then stack.pop() else 'programState.pop()'
		"""
			/* p */
			programState.put(
				#{operand1},
				#{operand2},
				#{operand3},
				#{x}, #{y}, '#{dir}', #{index},
				'#{from}', '#{to}'
			);
			if (programState.flags.pathInvalidatedAhead) {
				#{if stack.length then "programState.push(#{stack.join ', '});" else ''}
				return;
			}
		"""


	'g': (x, y, dir, index, stack) ->
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


OptimizingCompiler.assemble = (path) ->
	charList = path.getAsList()

	stack = []
	lines = charList.map (entry, i) ->
		if entry.string
			stack.push entry.char.charCodeAt 0
			"/* '#{entry.char}' */"
		else
			codeGenerator = codeMap[entry.char]
			if codeGenerator?
				ret = ''
				if entry.char == '&' or entry.char == '~'
					# dump the stack
					if stack.length
						ret += "programState.push(#{stack.join ', '});\n"
					stack = []
				ret += codeGenerator entry.x, entry.y, entry.dir, i, stack, path.from, path.to
				ret
			else
				"/* __ #{entry.char} */"

	if stack.length
		lines.push "programState.push(#{stack.join ', '})"

	lines.join '\n'


OptimizingCompiler.compile = (path) ->
	code = OptimizingCompiler.assemble path
	path.code = code #storing this just for debugging
	compiled = new Function 'programState', code
	path.body = compiled


window.bef ?= {}
window.bef.OptimizingCompiler = OptimizingCompiler