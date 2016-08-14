// Generated by CoffeeScript 1.10.0
(function() {
  'use strict';
  var BasicCompiler, codeMap;

  codeMap = {
    ' ': function() {
      return '/*   */';
    },
    '0': function() {
      return '/* 0 */  programState.push(0)';
    },
    '1': function() {
      return '/* 1 */  programState.push(1)';
    },
    '2': function() {
      return '/* 2 */  programState.push(2)';
    },
    '3': function() {
      return '/* 3 */  programState.push(3)';
    },
    '4': function() {
      return '/* 4 */  programState.push(4)';
    },
    '5': function() {
      return '/* 5 */  programState.push(5)';
    },
    '6': function() {
      return '/* 6 */  programState.push(6)';
    },
    '7': function() {
      return '/* 7 */  programState.push(7)';
    },
    '8': function() {
      return '/* 8 */  programState.push(8)';
    },
    '9': function() {
      return '/* 9 */  programState.push(9)';
    },
    '+': function() {
      return '/* + */  programState.push(programState.pop() + programState.pop())';
    },
    '-': function() {
      return '/* - */  programState.push(-programState.pop() + programState.pop())';
    },
    '*': function() {
      return '/* * */  programState.push(programState.pop() * programState.pop())';
    },
    '/': function() {
      return '/* / */  programState.div(programState.pop(), programState.pop())';
    },
    '%': function() {
      return '/* % */  programState.mod(programState.pop(), programState.pop())';
    },
    '!': function() {
      return '/* ! */  programState.push(+!programState.pop())';
    },
    '`': function() {
      return '/* ` */  programState.push(+(programState.pop() < programState.pop()))';
    },
    '^': function() {
      return '/* ^ */';
    },
    '<': function() {
      return '/* < */';
    },
    'v': function() {
      return '/* v */';
    },
    '>': function() {
      return '/* > */';
    },
    '?': function() {
      return '/* ? */  /*return;*/';
    },
    '_': function() {
      return '/* _ */  /*return;*/';
    },
    '|': function() {
      return '/* | */  /*return;*/';
    },
    '"': function() {
      return '/* " */';
    },
    ':': function() {
      return '/* : */  programState.duplicate()';
    },
    '\\': function() {
      return '/* \\ */  programState.swap()';
    },
    '$': function() {
      return '/* $ */  programState.pop()';
    },
    '.': function() {
      return '/* . */  programState.out(programState.pop())';
    },
    ',': function() {
      return '/* , */  programState.out(String.fromCharCode(programState.pop()))';
    },
    '#': function() {
      return '/* # */';
    },
    'p': function(x, y, dir, index, stack, from, to) {
      return "/* p */\nprogramState.put(\n	programState.pop(),\n	programState.pop(),\n	programState.pop(),\n	" + x + ", " + y + ", '" + dir + "', " + index + ",\n	'" + from + "', '" + to + "'\n)\n    	if (programState.flags.pathInvalidatedAhead) { return; }";
    },
    'g': function() {
      return '/* g */  programState.push(programState.get(programState.pop(), programState.pop()))';
    },
    '&': function() {
      return '/* & */  programState.push(programState.next())';
    },
    '~': function() {
      return '/* ~ */  programState.push(programState.nextChar())';
    },
    '@': function() {
      return '/* @ */  programState.exit(); /*return;*/';
    }
  };

  BasicCompiler = function() {};

  BasicCompiler.assemble = function(path) {
    var charList, lines;
    charList = path.getAsList();
    lines = charList.map(function(entry, i) {
      var codeGenerator;
      if (entry.string) {
        return "/* '" + entry.char + "' */  programState.push(" + (entry.char.charCodeAt(0)) + ")";
      } else {
        codeGenerator = codeMap[entry.char];
        if (codeGenerator != null) {
          return codeGenerator(entry.x, entry.y, entry.dir, i, null, path.from, path.to);
        } else {
          return "/* __ " + entry.char + " */";
        }
      }
    });
    return lines.join('\n');
  };

  BasicCompiler.compile = function(path) {
    var code, compiled;
    code = BasicCompiler.assemble(path);
    path.code = code;
    compiled = new Function('programState', code);
    return path.body = compiled;
  };

  if (window.bef == null) {
    window.bef = {};
  }

  window.bef.BasicCompiler = BasicCompiler;

}).call(this);
