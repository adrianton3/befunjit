'use strict'

codeMap =
  ' ': -> '/*   */'
  '0': -> '/* 0 */  programState.push(0)'
  '1': -> '/* 1 */  programState.push(1)'
  '2': -> '/* 2 */  programState.push(2)'
  '3': -> '/* 3 */  programState.push(3)'
  '4': -> '/* 4 */  programState.push(4)'
  '5': -> '/* 5 */  programState.push(5)'
  '6': -> '/* 6 */  programState.push(6)'
  '7': -> '/* 7 */  programState.push(7)'
  '8': -> '/* 8 */  programState.push(8)'
  '9': -> '/* 9 */  programState.push(9)'
  '+': -> '/* + */  programState.push(programState.pop() + programState.pop())'
  '-': -> '/* - */  programState.push(programState.pop() - programState.pop())'
  '*': -> '/* * */  programState.push(programState.pop() * programState.pop())'
  '/': -> '/* / */  programState.push(Math.floor(programState.pop() / programState.pop()))'
  '%': -> '/* % */  programState.push(programState.pop() % programState.pop())'
  '!': -> '/* ! */  programState.push(+!programState.pop())'
  '`': -> '/* ` */  programState.push(+(programState.pop() > programState.pop()))'
  '^': -> '/* ^ */'
  '<': -> '/* < */'
  'v': -> '/* v */'
  '>': -> '/* > */'
  '?': -> '/* ? */  /*return;*/'
  '_': -> '/* _ */  /*return;*/'
  '|': -> '/* | */  /*return;*/'
  '"': -> '/* " */'
  ':': -> '/* : */  programState.duplicate()'
  '\\': -> '/* \\ */  programState.swap()'
  '$': -> '/* $ */  programState.pop()'
  '.': -> '/* . */  programState.out(programState.pop())'
  ',': -> '/* , */  programState.out(String.fromCharCode(programState.pop()))'
  '#': -> '/* # */'
  'p': (x, y, dir, index) ->
    "/* p */  programState.put(programState.pop(), programState.pop(), programState.pop(), #{x}, #{y}, '#{dir}', #{index})\n" +
    "if (programState.flags.pathInvalidatedAhead) { return; }"
  'g': -> '/* g */  programState.push(programState.get(programState.pop(), programState.pop()))'
  '&': -> '/* & */  programState.push(programState.next())'
  '~': -> '/* ~ */  programState.push(programState.nextChar())'
  '@': -> '/* @ */  programState.exit(); /*return;*/'

BasicCompiler = ->


BasicCompiler.assemble = (path) ->
  charList = path.getAsList()

  lines = charList.map (entry, i) ->
    if entry.string
      "/* '#{entry.char}' */  programState.push(#{entry.char.charCodeAt 0})"
    else
      codeGenerator = codeMap[entry.char]
      if codeGenerator?
        codeGenerator entry.x, entry.y, entry.dir, i
      else
        "/* __ #{entry.char} */"

  lines.join '\n'


BasicCompiler.compile = (path) ->
  code = BasicCompiler.assemble path
  path.code = code #storing this just for debugging
  compiled = new Function 'programState', code
  path.body = compiled


window.bef ?= {}
window.bef.BasicCompiler = BasicCompiler