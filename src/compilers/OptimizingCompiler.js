// Generated by CoffeeScript 1.8.0
(function() {
  'use strict';
  var OptimizingCompiler, binaryOperator, codeMap, digitPusher, isNumber;

  isNumber = function(obj) {
    return typeof obj === 'number';
  };

  digitPusher = function(digit) {
    return function(x, y, dir, index, stack) {
      stack.push(digit);
      return "/* " + digit + " */";
    };
  };

  binaryOperator = function(operatorFunction, operatorChar, stringFunction) {
    return function(x, y, dir, index, stack) {
      var operand1, operand2;
      operand1 = stack.length ? stack.pop() : 'programState.pop()';
      operand2 = stack.length ? stack.pop() : 'programState.pop()';
      if ((isNumber(operand1)) && (isNumber(operand2))) {
        stack.push(operatorFunction(operand1, operand2));
        return "/* " + operatorChar + " */";
      } else {
        return "/* " + operatorChar + " */  programState.push(" + (stringFunction(operand1, operand2)) + ")";
      }
    };
  };

  codeMap = {
    ' ': function() {
      return '/*   */';
    },
    '0': digitPusher(0),
    '1': digitPusher(1),
    '2': digitPusher(2),
    '3': digitPusher(3),
    '4': digitPusher(4),
    '5': digitPusher(5),
    '6': digitPusher(6),
    '7': digitPusher(7),
    '8': digitPusher(8),
    '9': digitPusher(9),
    '+': binaryOperator((function(o1, o2) {
      return o1 + o2;
    }), '+', function(o1, o2) {
      return "" + o1 + " + " + o2;
    }),
    '-': binaryOperator((function(o1, o2) {
      return o1 - o2;
    }), '-', function(o1, o2) {
      return "" + o1 + " - " + o2;
    }),
    '*': binaryOperator((function(o1, o2) {
      return o1 * o2;
    }), '*', function(o1, o2) {
      return "" + o1 + " * " + o2;
    }),
    '/': binaryOperator((function(o1, o2) {
      return Math.floor(o1 / o2);
    }), '/', function(o1, o2) {
      return "Math.floor(" + o1 + " / " + o2 + ")";
    }),
    '%': binaryOperator((function(o1, o2) {
      return o1 % o2;
    }), '%', function(o1, o2) {
      return "" + o1 + " % " + o2;
    }),
    '!': function(x, y, dir, index, stack) {
      if (stack.length) {
        stack.push(+(!stack.pop()));
        return '/* ! */';
      } else {
        return '/* ! */  programState.push(+!programState.pop())';
      }
    },
    '`': binaryOperator((function(o1, o2) {
      return +(o1 > o2);
    }), '`', function(o1, o2) {
      return "+(" + o1 + " > " + o2 + ")";
    }),
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
    ':': function(x, y, dir, index, stack) {
      if (stack.length) {
        stack.push(stack[stack.length - 1]);
        return '/* : */';
      } else {
        return '/* : */  programState.duplicate()';
      }
    },
    '\\': function(x, y, dir, index, stack) {
      var e1, e2;
      if (stack.length > 1) {
        e1 = stack[stack.length - 1];
        e2 = stack[stack.length - 2];
        stack[stack.length - 1] = e2;
        stack[stack.length - 2] = e1;
        return '/* \\ */';
      } else {
        return '/* \\ */  programState.swap()';
      }
    },
    '$': function(x, y, dir, index, stack) {
      if (stack.length) {
        stack.pop();
        return '/* $ */';
      } else {
        return '/* $ */  programState.pop()';
      }
    },
    '.': function(x, y, dir, index, stack) {
      if (stack.length) {
        return "/* . */  programState.out(" + (stack.pop()) + ")";
      } else {
        return '/* . */  programState.out(programState.pop())';
      }
    },
    ',': function(x, y, dir, index, stack) {
      var char;
      if (stack.length) {
        char = String.fromCharCode(stack.pop());
        if (char === "'") {
          char = "\\'";
        } else if (char === '\\') {
          char = '\\\\';
        }
        return "/* , */  programState.out('" + char + "')";
      } else {
        return '/* , */  programState.out(String.fromCharCode(programState.pop()))';
      }
    },
    '#': function() {
      return '/* # */';
    },
    'p': function(x, y, dir, index, stack) {
      var operand1, operand2, operand3;
      operand1 = stack.length ? stack.pop() : 'programState.pop()';
      operand2 = stack.length ? stack.pop() : 'programState.pop()';
      operand3 = stack.length ? stack.pop() : 'programState.pop()';
      return ("/* p */  programState.put(" + operand1 + ", " + operand2 + ", " + operand3 + ", " + x + ", " + y + ", '" + dir + "', " + index + ")\n") + "if (programState.flags.pathInvalidatedAhead) {" + ("" + (stack.length ? "programState.push(" + (stack.join(', ')) + ");" : '')) + " return; }";
    },
    'g': function(x, y, dir, index, stack) {
      var operand1, operand2, stringedStack;
      operand1 = stack.length ? stack.pop() : 'programState.pop()';
      operand2 = stack.length ? stack.pop() : 'programState.pop()';
      if (stack.length) {
        stringedStack = stack.join(', ');
        stack.length = 0;
        return "/* g */\nprogramState.push(" + stringedStack + ");\nprogramState.push(programState.get(" + operand1 + ", " + operand2 + "));";
      } else {
        return "/* g */  programState.push(programState.get(" + operand1 + ", " + operand2 + "));";
      }
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

  OptimizingCompiler = function() {};

  OptimizingCompiler.assemble = function(path) {
    var charList, lines, stack;
    charList = path.getAsList();
    stack = [];
    lines = charList.map(function(entry, i) {
      var codeGenerator, ret;
      if (entry.string) {
        stack.push(entry.char.charCodeAt(0));
        return "/* '" + entry.char + "' */";
      } else {
        codeGenerator = codeMap[entry.char];
        if (codeGenerator != null) {
          ret = '';
          if (entry.char === '&' || entry.char === '~') {
            if (stack.length) {
              ret += "programState.push(" + (stack.join(', ')) + ");\n";
            }
            stack = [];
          }
          ret += codeGenerator(entry.x, entry.y, entry.dir, i, stack);
          return ret;
        } else {
          return "/* __ " + entry.char + " */";
        }
      }
    });
    if (stack.length) {
      lines.push("programState.push(" + (stack.join(', ')) + ")");
    }
    return lines.join('\n');
  };

  OptimizingCompiler.compile = function(path) {
    var code, compiled;
    code = OptimizingCompiler.assemble(path);
    path.code = code;
    compiled = new Function('programState', code);
    return path.body = compiled;
  };

  if (window.bef == null) {
    window.bef = {};
  }

  window.bef.OptimizingCompiler = OptimizingCompiler;

}).call(this);
