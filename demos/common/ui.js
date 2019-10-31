// Generated by CoffeeScript 1.12.7
(function() {
  'use strict';
  var loadProgram, saveProgram, setupCompilers, setupEditors, setupRunButton, setupSamples;

  setupEditors = function() {
    var input, js, output, source;
    source = ace.edit('source-editor');
    source.setTheme('ace/theme/monokai');
    source.setFontSize(14);
    input = ace.edit('input-editor');
    input.setTheme('ace/theme/monokai');
    input.getSession().setUseWrapMode(true);
    input.setFontSize(14);
    output = ace.edit('output-editor');
    output.setTheme('ace/theme/monokai');
    output.getSession().setUseWrapMode(true);
    output.setReadOnly(true);
    output.setFontSize(14);
    js = ace.edit('js-editor');
    js.setTheme('ace/theme/monokai');
    js.getSession().setMode('ace/mode/javascript');
    js.getSession().setUseWrapMode(true);
    js.setReadOnly(true);
    js.setFontSize(14);
    return {
      source: source,
      input: input,
      output: output,
      js: js
    };
  };

  setupSamples = function(samples, arg) {
    var input, select, source;
    source = arg.source, input = arg.input;
    select = document.getElementById('sample');
    (Object.keys(samples)).forEach(function(sampleName) {
      var option;
      option = document.createElement('option');
      option.textContent = sampleName;
      select.appendChild(option);
    });
    return select.addEventListener('change', function() {
      var sample;
      sample = samples[this.value];
      source.setValue(sample.code, 1);
      input.setValue(sample.input, 1);
    });
  };

  setupCompilers = function(onChange) {
    var select;
    select = document.getElementById('compiler');
    ['StackingCompiler', 'BinaryCompiler', 'OptimizingCompiler', 'BasicCompiler'].forEach(function(sampleName) {
      var option;
      option = document.createElement('option');
      option.textContent = sampleName;
      select.appendChild(option);
    });
    return select.addEventListener('change', function() {
      onChange(bef[this.value]);
    });
  };

  setupRunButton = function(run) {
    return (document.getElementById('run')).addEventListener('click', run);
  };

  saveProgram = function(arg) {
    var input, source;
    source = arg.source, input = arg.input;
    if (localStorage['dev'] != null) {
      localStorage['last-run-source'] = source.getValue();
      return localStorage['last-run-input'] = input.getValue();
    }
  };

  loadProgram = function(arg) {
    var input, source;
    source = arg.source, input = arg.input;
    if ((localStorage['dev'] != null) && (localStorage['last-run-source'] != null)) {
      source.setValue(localStorage['last-run-source'], 1);
      return input.setValue(localStorage['last-run-input'], 1);
    }
  };

  if (window.viz == null) {
    window.viz = {};
  }

  Object.assign(window.viz, {
    setupEditors: setupEditors,
    setupSamples: setupSamples,
    setupCompilers: setupCompilers,
    setupRunButton: setupRunButton,
    saveProgram: saveProgram,
    loadProgram: loadProgram
  });

}).call(this);
