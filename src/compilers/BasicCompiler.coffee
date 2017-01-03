'use strict'

codeMap =
	' ': '/*   */'
	'0': '/* 0 */  programState.push(0)'
	'1': '/* 1 */  programState.push(1)'
	'2': '/* 2 */  programState.push(2)'
	'3': '/* 3 */  programState.push(3)'
	'4': '/* 4 */  programState.push(4)'
	'5': '/* 5 */  programState.push(5)'
	'6': '/* 6 */  programState.push(6)'
	'7': '/* 7 */  programState.push(7)'
	'8': '/* 8 */  programState.push(8)'
	'9': '/* 9 */  programState.push(9)'
	'+': '/* + */  programState.push(programState.pop() + programState.pop())'
	'-': '/* - */  programState.push(-programState.pop() + programState.pop())'
	'*': '/* * */  programState.push(programState.pop() * programState.pop())'
	'/': '/* / */  programState.div(programState.pop(), programState.pop())'
	'%': '/* % */  programState.mod(programState.pop(), programState.pop())'
	'!': '/* ! */  programState.push(+!programState.pop())'
	'`': '/* ` */  programState.push(+(programState.pop() < programState.pop()))'
	'^': '/* ^ */'
	'<': '/* < */'
	'v': '/* v */'
	'>': '/* > */'
	'?': '/* ? */  /*return;*/'
	'_': '/* _ */  /*return;*/'
	'|': '/* | */  /*return;*/'
	'"': '/* " */'
	':': '/* : */  programState.duplicate()'
	'\\': '/* \\ */  programState.swap()'
	'$': '/* $ */  programState.pop()'
	'.': '/* . */  programState.out(programState.pop())'
	',': '/* , */  programState.out(String.fromCharCode(programState.pop()))'
	'#': '/* # */'
	'p': '/* p */  /*return;*/'
	'g': '/* g */  programState.push(programState.get(programState.pop(), programState.pop()))'
	'&': '/* & */  programState.push(programState.next())'
	'~': '/* ~ */  programState.push(programState.nextChar())'
	'@': '/* @ */  programState.exit() /*return;*/'


BasicCompiler = ->


BasicCompiler.assemble = (path, options = {}) ->
	charList = path.getAsList()

	lines = charList.map ({ char, string }) ->
		if string
			"/* '#{char}' */  programState.push(#{char.charCodeAt 0})"
		else if codeMap[char]?
			codeMap[char]
		else if ' ' <= char <= '~'
			"/* '#{char}' */"
		else
			"/* ##{char.charCodeAt 0} */"

	if path.ending?.char in ['|', '_']
		"""
			#{lines.join '\n'}
			branchFlag = programState.pop()
		"""
	else
		lines.join '\n'


window.bef ?= {}
window.bef.BasicCompiler = BasicCompiler