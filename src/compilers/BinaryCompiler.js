// Generated by CoffeeScript 1.11.0
(function() {
  'use strict';
  var BinaryCompiler, assemble, consumeCount, consumePair, generateCode, generateTree, getMaxDepth;

  consumePair = function(consume, delta) {
    return {
      consume: consume,
      delta: delta
    };
  };

  consumeCount = new Map([[' ', consumePair(0, 0)], ['0', consumePair(0, 1)], ['1', consumePair(0, 1)], ['2', consumePair(0, 1)], ['3', consumePair(0, 1)], ['4', consumePair(0, 1)], ['5', consumePair(0, 1)], ['6', consumePair(0, 1)], ['7', consumePair(0, 1)], ['8', consumePair(0, 1)], ['9', consumePair(0, 1)], ['+', consumePair(2, -1)], ['-', consumePair(2, -1)], ['*', consumePair(2, -1)], ['/', consumePair(2, -1)], ['%', consumePair(2, -1)], ['!', consumePair(1, 0)], ['`', consumePair(2, -1)], ['^', consumePair(0, 0)], ['<', consumePair(0, 0)], ['v', consumePair(0, 0)], ['>', consumePair(0, 0)], ['?', consumePair(0, 0)], ['_', consumePair(0, 0)], ['|', consumePair(0, 0)], ['"', consumePair(0, 0)], [':', consumePair(0, 1)], ['\\', consumePair(2, 0)], ['$', consumePair(1, -1)], ['.', consumePair(1, -1)], [',', consumePair(1, -1)], ['#', consumePair(0, 0)], ['p', consumePair(3, -3)], ['g', consumePair(2, -1)], ['&', consumePair(0, 1)], ['~', consumePair(0, 1)], ['@', consumePair(0, 0)]]);

  getMaxDepth = function(path) {
    var max;
    max = path.getAsList().reduce(function(arg, arg1) {
      var char, consume, delta, max, ref, string, sum;
      max = arg.max, sum = arg.sum;
      char = arg1.char, string = arg1.string;
      ref = string ? {
        consume: 0,
        delta: 1
      } : consumeCount.has(char) ? consumeCount.get(char) : {
        consume: 0,
        delta: 0
      }, consume = ref.consume, delta = ref.delta;
      return {
        sum: sum + delta,
        max: Math.min(max, sum - consume)
      };
    }, {
      max: 0,
      sum: 0
    }).max;
    return -max;
  };

  generateTree = function(codes, id) {
    var generate;
    generate = function(from, to) {
      var mid;
      if (from >= to) {
        return codes[from];
      } else {
        mid = Math.floor((from + to) / 2);
        return "if (length_" + id + " < " + (mid + 1) + ") {\n	" + (generate(from, mid)) + "\n} else {\n	" + (generate(mid + 1, to)) + "\n}";
      }
    };
    if (codes.length === 0) {
      return '';
    } else if (codes.length === 1) {
      return codes[0];
    } else {
      return "const length_" + id + " = programState.getLength()\nif (length_" + id + " < " + (codes.length - 1) + ") {\n	" + (generate(0, codes.length - 2)) + "\n} else {\n	" + codes[codes.length - 1] + "\n}";
    }
  };

  generateCode = function(path, maxDepth) {
    var charList, codeMap, makeStack, ref, stack;
    ref = window.bef.StackingCompiler, makeStack = ref.makeStack, codeMap = ref.codeMap;
    charList = path.getAsList();
    stack = makeStack(path.id + "_" + maxDepth, {
      popMethod: 'popUnsafe',
      freePops: maxDepth
    });
    charList.forEach(function(entry, i) {
      var codeGenerator;
      if (entry.string) {
        stack.push(entry.char.charCodeAt(0));
      } else {
        codeGenerator = codeMap[entry.char];
        if (codeGenerator != null) {
          codeGenerator(stack);
        }
      }
    });
    return stack.stringify();
  };

  assemble = function(path) {
    var codes, depth, maxDepth;
    maxDepth = getMaxDepth(path);
    codes = (function() {
      var j, ref, results;
      results = [];
      for (depth = j = 0, ref = maxDepth; 0 <= ref ? j <= ref : j >= ref; depth = 0 <= ref ? ++j : --j) {
        results.push(generateCode(path, depth));
      }
      return results;
    })();
    return generateTree(codes, path.id);
  };

  BinaryCompiler = function() {};

  Object.assign(BinaryCompiler, {
    getMaxDepth: getMaxDepth,
    generateTree: generateTree,
    assemble: assemble
  });

  if (window.bef == null) {
    window.bef = {};
  }

  window.bef.BinaryCompiler = BinaryCompiler;

}).call(this);