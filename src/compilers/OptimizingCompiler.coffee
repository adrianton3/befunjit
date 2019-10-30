'use strict'


S = bef.Symbols


isNumber = (obj) ->
	typeof obj == 'number'


digitPusher = (digit) ->
	(stack) ->
		stack.push digit
		"/* #{digit} */"


binaryOperator = (operatorFunction, operatorChar, stringFunction) ->
	(stack) ->
		operand1 = if stack.length > 0 then stack.pop() else 'programState.pop()'
		operand2 = if stack.length > 0 then stack.pop() else 'programState.pop()'
		if (isNumber operand1) and (isNumber operand2)
			stack.push operatorFunction operand1, operand2
			"/* #{operatorChar} */"
		else
			"/* #{operatorChar} */  #{stringFunction operand1, operand2}"


codeMap = new Map [
	[S.BLANK, -> '/*   */']


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


	[S.ADD, binaryOperator ((o1, o2) -> o1 + o2), '+', (o1, o2) -> "programState.push(#{o1} + #{o2})"]
	[S.SUB, binaryOperator ((o1, o2) -> o2 - o1), '-', (o1, o2) -> "programState.push(- #{o1} + #{o2})"]
	[S.MUL, binaryOperator ((o1, o2) -> o1 * o2), '*', (o1, o2) -> "programState.push(#{o1} * #{o2})"]
	[S.DIV, binaryOperator ((o1, o2) -> o2 // o1), '/', (o1, o2) -> "programState.div(#{o1}, #{o2})"]
	[S.MOD, binaryOperator ((o1, o2) -> o2 % o1), '%', (o1, o2) -> "programState.mod(#{o1}, #{o2})"]


	[S.NOT, (stack) ->
		if stack.length
			stack.push +!stack.pop()
			'/* ! */'
		else
			'/* ! */  programState.push(+!programState.pop())'
	]


	[S.GT, binaryOperator ((o1, o2) -> +(o1 < o2)), '`', (o1, o2) -> "programState.push(+(#{o1} < #{o2}))"]


	[S.UP, -> '/* ^ */']
	[S.LEFT, -> '/* < */']
	[S.DOWN, -> '/* v */']
	[S.RIGHT, -> '/* > */']
	[S.RAND, -> '/* ? */']
	[S.IFH, -> '/* _ */']
	[S.IFV, -> '/* | */']
	[S.QUOT, -> '/* " */']


	[S.DUP, (stack) ->
		if stack.length
			stack.push stack[stack.length - 1]
			'/* : */'
		else
			'/* : */  programState.duplicate()'
	]


	[S.SWAP, (stack) ->
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
	]


	[S.DROP, (stack) ->
		if stack.length > 0
			stack.pop()
			'/* $ */'
		else
			'/* $ */  programState.pop()'
	]


	[S.OUTI, (stack) ->
		if stack.length > 0
			"/* . */  programState.out(#{stack.pop()})"
		else
			'/* . */  programState.out(programState.pop())'
	]


	[S.OUTC, (stack) ->
		if stack.length > 0
			"/* , */  programState.outChar(String.fromCharCode(#{stack.pop()}))"
		else
			'/* , */  programState.outChar(String.fromCharCode(programState.pop()))'
	]


	[S.JUMP, -> '/* # */']


	[S.PUT, -> '']


	[S.GET, (stack) ->
		operand1 = if stack.length > 0 then stack.pop() else 'programState.pop()'
		operand2 = if stack.length > 0 then stack.pop() else 'programState.pop()'
		if stack.length > 0
			stringedStack = stack.join ', '
			stack.length = 0
			"""
				/* g */
				programState.push(#{stringedStack})
				programState.push(programState.get(#{operand1}, #{operand2}))
			"""
		else
			"""
				/* g */  programState.push(programState.get(#{operand1}, #{operand2}))
			"""
	]


	# require special handling
	[S.INI, -> '/* & */  programState.push(programState.next())']
	[S.INC, -> '/* ~ */  programState.push(programState.nextChar())']


	[S.END, -> '/* @ */  programState.exit()']
]


OptimizingCompiler = ->


OptimizingCompiler.assemble = (path, options = {}) ->
	charList = path.getAsList()

	stack = []
	lines = charList.map ({ charCode, string }) ->
		if string
			stack.push charCode
			"/* '#{String.fromCharCode charCode}' */"
		else
			if codeMap.has charCode
				codeGenerator = codeMap.get charCode
				ret = ''
				if charCode == S.INI or charCode == S.INC
					# dump the stack
					if stack.length
						ret += "programState.push(#{stack.join ', '});\n"
					stack = []
				ret += codeGenerator stack
				ret
			else if 32 <= charCode <= 126
				"/* '#{String.fromCharCode charCode}' */"
			else
				"/* ##{charCode} */"

	if path.ending?.charCode in [S.IFV, S.IFH]
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