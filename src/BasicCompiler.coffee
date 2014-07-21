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
  '#': -> '/* # */'
  '&': -> '/* & */  runtime.push(runtime.input.next())'
  '.': -> '/* . */  runtime.out(runtime.pop())'
  '|': -> '/* | */  return;'
  '_': -> '/* _ */  return;'
  'p': (x, y, dir, index) ->
    "/* p */  runtime.put(runtime.pop(), runtime.pop(), runtime.pop(), #{x}, #{y}, '#{dir}', #{index})\n" +
    "if (runtime.flags.pathInvalidatedAhead) { return; }"


BasicCompiler = ->


BasicCompiler.compile = (path) ->
  charList = path.getAsList()

  lines = charList.map (entry, i) ->
    codeGenerator = codeMap[entry.char]
    codeGenerator entry.x, entry.y, entry.dir, i

  code = lines.join('\n')
  compiled = new Function 'runtime', code
  path.body = compiled


window.bef ?= {}
window.bef.BasicCompiler = BasicCompiler