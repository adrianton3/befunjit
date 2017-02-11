// Generated by CoffeeScript 1.12.3
(function() {
  'use strict';
  var loadProgram, prettify, ref, run, saveProgram, setupCompilers, setupEditors, setupRunButton, setupSamples;

  ref = window.viz, setupEditors = ref.setupEditors, setupSamples = ref.setupSamples, setupCompilers = ref.setupCompilers, setupRunButton = ref.setupRunButton, saveProgram = ref.saveProgram, loadProgram = ref.loadProgram;

  prettify = function(code) {
    var beautified, semicolons;
    semicolons = code.replace(/([\w)])$/gm, '$1;');
    beautified = js_beautify(semicolons);
    return beautified.replace(/;$/gm, '');
  };

  run = function(editors, compiler) {
    var playfield, prettyJs, runtime, size, stringedOutput, stringedStack;
    saveProgram(editors);
    size = {
      width: 16,
      height: 10
    };
    playfield = new bef.Playfield(editors.source.getValue(), size);
    runtime = new bef.EagerRuntime();
    runtime.execute(playfield, {
      jumpLimit: 1000,
      compiler: compiler,
      fastConditionals: true
    }, editors.input.getValue());
    prettyJs = prettify(runtime.code);
    editors.js.setValue(prettyJs, 1);
    stringedStack = runtime.programState.stack.join(' ');
    stringedOutput = runtime.programState.outRecord.join(' ');
    return editors.output.setValue("Stack: " + stringedStack + "\nOutput: " + stringedOutput, 1);
  };

  (function() {
    var compiler, editors;
    compiler = bef.StackingCompiler;
    editors = setupEditors();
    setupSamples(window.befSample, editors);
    setupCompilers(function(_compiler) {
      compiler = _compiler;
      return run(editors, compiler);
    });
    setupRunButton(function() {
      return run(editors, compiler);
    });
    loadProgram(editors);
    return run(editors, compiler);
  })();

}).call(this);
