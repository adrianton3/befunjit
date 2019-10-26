'use strict'

S = bef.Symbols

codeMap = new Map [
	[S.BLANK, '/*   */']
	[S.D0, '/* 0 */  programState.push(0)']
	[S.D1, '/* 1 */  programState.push(1)']
	[S.D2, '/* 2 */  programState.push(2)']
	[S.D3, '/* 3 */  programState.push(3)']
	[S.D4, '/* 4 */  programState.push(4)']
	[S.D5, '/* 5 */  programState.push(5)']
	[S.D6, '/* 6 */  programState.push(6)']
	[S.D7, '/* 7 */  programState.push(7)']
	[S.D8, '/* 8 */  programState.push(8)']
	[S.D9, '/* 9 */  programState.push(9)']
	[S.ADD, '/* + */  programState.push(programState.pop() + programState.pop())']
	[S.SUB, '/* - */  programState.push(-programState.pop() + programState.pop())']
	[S.MUL, '/* * */  programState.push(programState.pop() * programState.pop())']
	[S.DIV, '/* / */  programState.div(programState.pop(), programState.pop())']
	[S.MOD, '/* % */  programState.mod(programState.pop(), programState.pop())']
	[S.NOT, '/* ! */  programState.push(+!programState.pop())']
	[S.GT, '/* ` */  programState.push(+(programState.pop() < programState.pop()))']
	[S.UP, '/* ^ */']
	[S.LEFT, '/* < */']
	[S.DOWN, '/* v */']
	[S.RIGHT, '/* > */']
	[S.RAND, '/* ? */  /* return */']
	[S.IFH, '/* _ */  /* return */']
	[S.IFV, '/* | */  /* return */']
	[S.QUOT, '/* " */']
	[S.DUP, '/* : */  programState.duplicate()']
	[S.SWAP, '/* \\ */  programState.swap()']
	[S.DROP, '/* $ */  programState.pop()']
	[S.OUTI, '/* . */  programState.out(programState.pop())']
	[S.OUTC, '/* , */  programState.out(String.fromCharCode(programState.pop()))']
	[S.JUMP, '/* # */']
	[S.PUT, '/* p */  /* return */']
	[S.GET, '/* g */  programState.push(programState.get(programState.pop(), programState.pop()))']
	[S.INI, '/* & */  programState.push(programState.next())']
	[S.INC, '/* ~ */  programState.push(programState.nextChar())']
	[S.END, '/* @ */  programState.exit() /* return */']
]


BasicCompiler = ->


BasicCompiler.assemble = (path, options = {}) ->
	charList = path.getAsList()

	lines = charList.map ({ charCode, string }) ->
		if string
			"/* '#{String.fromCharCode charCode}' */  programState.push(#{charCode})"
		else if codeMap.has charCode
			codeMap.get charCode
		else if 32 <= charCode <= 126
			"/* '#{String.fromCharCode charCode}' */"
		else
			"/* ##{charCode} */"

	if path.ending?.charCode in [S.IFV, S.IFH]
		"""
			#{lines.join '\n'}
			branchFlag = programState.pop()
		"""
	else
		lines.join '\n'


window.bef ?= {}
window.bef.BasicCompiler = BasicCompiler