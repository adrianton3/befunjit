// Generated by CoffeeScript 1.11.0
(function() {
  'use strict';
  var OptimizingCompiler, binaryOperator, codeMap, digitPusher, isNumber;

  isNumber = function(obj) {
    return typeof obj === 'number';
  };

  digitPusher = function(digit) {
    return function(stack) {
      stack.push(digit);
      return "/* " + digit + " */";
    };
  };

  binaryOperator = function(operatorFunction, operatorChar, stringFunction) {
    return function(stack) {
      var operand1, operand2;
      operand1 = stack.length ? stack.pop() : 'programState.pop()';
      operand2 = stack.length ? stack.pop() : 'programState.pop()';
      if ((isNumber(operand1)) && (isNumber(operand2))) {
        stack.push(operatorFunction(operand1, operand2));
        return "/* " + operatorChar + " */";
      } else {
        return "/* " + operatorChar + " */  " + (stringFunction(operand1, operand2));
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
      return "programState.push(" + o1 + " + " + o2 + ")";
    }),
    '-': binaryOperator((function(o1, o2) {
      return o2 - o1;
    }), '-', function(o1, o2) {
      return "programState.push(- " + o1 + " + " + o2 + ")";
    }),
    '*': binaryOperator((function(o1, o2) {
      return o1 * o2;
    }), '*', function(o1, o2) {
      return "programState.push(" + o1 + " * " + o2 + ")";
    }),
    '/': binaryOperator((function(o1, o2) {
      return Math.floor(o2 / o1);
    }), '/', function(o1, o2) {
      return "programState.div(" + o1 + ", " + o2 + ")";
    }),
    '%': binaryOperator((function(o1, o2) {
      return o2 % o1;
    }), '%', function(o1, o2) {
      return "programState.mod(" + o1 + ", " + o2 + ")";
    }),
    '!': function(stack) {
      if (stack.length) {
        stack.push(+(!stack.pop()));
        return '/* ! */';
      } else {
        return '/* ! */  programState.push(+!programState.pop())';
      }
    },
    '`': binaryOperator((function(o1, o2) {
      return +(o1 < o2);
    }), '`', function(o1, o2) {
      return "programState.push(+(" + o1 + " < " + o2 + "))";
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
    ':': function(stack) {
      if (stack.length) {
        stack.push(stack[stack.length - 1]);
        return '/* : */';
      } else {
        return '/* : */  programState.duplicate()';
      }
    },
    '\\': function(stack) {
      var e1, e2;
      if (stack.length > 1) {
        e1 = stack[stack.length - 1];
        e2 = stack[stack.length - 2];
        stack[stack.length - 1] = e2;
        stack[stack.length - 2] = e1;
        return '/* \\ */';
      } else if (stack.length > 0) {
        return "/* \\ */  programState.push(" + (stack.pop()) + ", programState.pop())";
      } else {
        return '/* \\ */  programState.swap()';
      }
    },
    '$': function(stack) {
      if (stack.length) {
        stack.pop();
        return '/* $ */';
      } else {
        return '/* $ */  programState.pop()';
      }
    },
    '.': function(stack) {
      if (stack.length) {
        return "/* . */  programState.out(" + (stack.pop()) + ")";
      } else {
        return '/* . */  programState.out(programState.pop())';
      }
    },
    ',': function(stack) {
      if (stack.length > 0) {
        return "/* , */  programState.out(String.fromCharCode(" + (stack.pop()) + "))";
      } else {
        return '/* , */  programState.out(String.fromCharCode(programState.pop()))';
      }
    },
    '#': function() {
      return '/* # */';
    },
    'p': function() {
      return '';
    },
    'g': function(stack) {
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

  OptimizingCompiler.assemble = function(path, options) {
    var charList, fastConditionals, last, lines, ref, stack;
    if (options == null) {
      options = {};
    }
    fastConditionals = (ref = options.fastConditionals) != null ? ref : false;
    charList = path.getAsList();
    stack = [];
    lines = charList.map(function(arg) {
      var char, codeGenerator, ret, string;
      char = arg.char, string = arg.string;
      if (string) {
        stack.push(char.charCodeAt(0));
        return "/* '" + char + "' */";
      } else {
        codeGenerator = codeMap[char];
        if (codeGenerator != null) {
          ret = '';
          if (char === '&' || char === '~') {
            if (stack.length) {
              ret += "programState.push(" + (stack.join(', ')) + ");\n";
            }
            stack = [];
          }
          ret += codeGenerator(stack);
          return ret;
        } else if ((' ' <= char && char <= '~')) {
          return "/* '" + char + "' */";
        } else {
          return "/* #" + (char.charCodeAt(0)) + " */";
        }
      }
    });
    if (fastConditionals) {
      if (stack.length === 0) {
        lines.push("branchFlag = programState.pop()");
      } else if (stack.length === 1) {
        lines.push("branchFlag = " + stack[0]);
      } else {
        last = stack.pop();
        lines.push("programState.push(" + (stack.join(', ')) + ")", "branchFlag = " + last);
      }
    } else {
      if (stack.length > 0) {
        lines.push("programState.push(" + (stack.join(', ')) + ")");
      }
    }
    return lines.join('\n');
  };

  if (window.bef == null) {
    window.bef = {};
  }

  window.bef.OptimizingCompiler = OptimizingCompiler;

}).call(this);
