'use strict'

codeMap =
  ' ': -> '/*   */'
  '0': -> '/* 0 */  runtime.push(0)'
  '1': -> '/* 1 */  runtime.push(1)'
  '2': -> '/* 2 */  runtime.push(2)'
  '3': -> '/* 3 */  runtime.push(3)'
  '4': -> '/* 4 */  runtime.push(4)'
  '5': -> '/* 5 */  runtime.push(5)'
  '6': -> '/* 6 */  runtime.push(6)'
  '7': -> '/* 7 */  runtime.push(7)'
  '8': -> '/* 8 */  runtime.push(8)'
  '9': -> '/* 9 */  runtime.push(9)'
  '+': -> '/* + */  runtime.push(runtime.pop() + runtime.pop())'
  '-': -> '/* - */  runtime.push(runtime.pop() - runtime.pop())'
  '*': -> '/* * */  runtime.push(runtime.pop() * runtime.pop())'
  '/': -> '/* / */  runtime.push(Math.floor(runtime.pop() / runtime.pop()))'
  '%': -> '/* % */  runtime.push(runtime.pop() % runtime.pop())'
  '!': -> '/* ! */  runtime.push(+!runtime.pop())'
  '`': -> '/* ` */  runtime.push(+(runtime.pop() > runtime.pop()))'
  '^': -> '/* ^ */'
  '<': -> '/* < */'
  'v': -> '/* v */'
  '>': -> '/* > */'
  '?': -> '/* ? */'
  '_': -> '/* _ */  return;'
  '|': -> '/* | */  return;'
  '"': -> '/* " */'
  ':': -> '/* : */  runtime.duplicate()'
  '\\': -> '/* \\ */  runtime.swap()'
  '$': -> '/* $ */  runtime.pop()'
  '.': -> '/* . */  runtime.out(runtime.pop())'
  ',': -> '/* , */  runtime.out(String.fromCharCode(runtime.pop()))'
  '#': -> '/* # */'
  'p': (x, y, dir, index) ->
    "/* p */  runtime.put(runtime.pop(), runtime.pop(), runtime.pop(), #{x}, #{y}, '#{dir}', #{index})\n" +
    "if (runtime.flags.pathInvalidatedAhead) { return; }"
  'g': -> '/* g */  runtime.push(runtime.get(runtime.pop(), runtime.pop()))'
  '&': -> '/* & */  runtime.push(runtime.next())'
  '~': -> '/* ~ */  runtime.push(runtime.nextChar())'
  '@': -> '/* @ */  return;'

BasicCompiler = ->


BasicCompiler.compile = (path) ->
  charList = path.getAsList()

  lines = charList.map (entry, i) ->
    if entry.string
      "/* '#{entry.char}' */  runtime.push(#{entry.char.charCodeAt 0})"
    else
      codeGenerator = codeMap[entry.char]
      if codeGenerator?
        codeGenerator entry.x, entry.y, entry.dir, i
      else
        "/* __ #{entry.char} */"

  code = lines.join '\n'
  compiled = new Function 'runtime', code
  path.body = compiled


window.bef ?= {}
window.bef.BasicCompiler = BasicCompiler