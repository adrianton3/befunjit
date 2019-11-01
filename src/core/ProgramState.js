// Generated by CoffeeScript 1.12.7
(function() {
  'use strict';
  var ProgramState;

  ProgramState = function(interpreter) {
    this.interpreter = interpreter;
    this.stack = [];
    this.flags = {
      pathInvalidatedAhead: false
    };
    this.inputPointer = 0;
    this.inputList = [];
    this.outRecord = [];
    this.checks = 0;
    this.maxChecks = 2e308;
  };

  ProgramState.prototype.getLength = function() {
    return this.stack.length;
  };

  ProgramState.prototype.push = function() {
    this.stack.push.apply(this.stack, arguments);
  };

  ProgramState.prototype.pop = function() {
    if (this.stack.length < 1) {
      return 0;
    }
    return this.stack.pop();
  };

  ProgramState.prototype.popUnsafe = function() {
    return this.stack.pop();
  };

  ProgramState.prototype.peek = function() {
    if (this.stack.length < 1) {
      return 0;
    }
    return this.stack[this.stack.length - 1];
  };

  ProgramState.prototype.out = function(value) {
    this.outRecord.push(value, ' ');
  };

  ProgramState.prototype.outChar = function(char) {
    this.outRecord.push(char);
  };

  ProgramState.prototype.setInput = function(values) {
    this.inputList = values.slice(0);
    this.inputPointer = 0;
  };

  ProgramState.prototype.next = function() {
    var ret;
    if (this.inputPointer < this.inputList.length) {
      ret = parseInt(this.inputList[this.inputPointer], 10);
      this.inputPointer++;
      return ret;
    } else {
      return 0;
    }
  };

  ProgramState.prototype.nextChar = function() {
    var ret;
    if (this.inputPointer < this.inputList.length) {
      ret = this.inputList[this.inputPointer].charCodeAt(0);
      this.inputPointer++;
      return ret;
    } else {
      return 0;
    }
  };

  ProgramState.prototype.put = function(y, x, v, currentX, currentY, currentDir, index, from, to) {
    this.interpreter.put(x, y, v, currentX, currentY, currentDir, index, from, to);
  };

  ProgramState.prototype.get = function(y, x) {
    return this.interpreter.get(x, y);
  };

  ProgramState.prototype.div = function(a, b) {
    this.push((b / a) | 0);
  };

  ProgramState.prototype.mod = function(a, b) {
    this.push(b % a);
  };

  ProgramState.prototype.duplicate = function() {
    this.stack.push(this.peek());
  };

  ProgramState.prototype.swap = function() {
    var e1, e2;
    if (this.stack.length >= 2) {
      e1 = this.stack[this.stack.length - 1];
      e2 = this.stack[this.stack.length - 2];
      this.stack[this.stack.length - 1] = e2;
      this.stack[this.stack.length - 2] = e1;
    } else if (this.stack.length === 1) {
      this.stack.push(0);
    } else {
      this.stack.push(0, 0);
    }
  };

  ProgramState.prototype.randInt = function(max) {
    return Math.floor(Math.random() * max);
  };

  ProgramState.prototype.exit = function() {
    this.flags.exitRequest = true;
  };

  ProgramState.prototype.isAlive = function() {
    if (this.flags.exitRequest) {
      return false;
    }
    this.checks++;
    return this.checks < this.maxChecks;
  };

  if (window.bef == null) {
    window.bef = {};
  }

  window.bef.ProgramState = ProgramState;

}).call(this);
