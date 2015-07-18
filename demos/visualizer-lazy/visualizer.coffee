'use strict'

sourceEditor = null
inputEditor = null
outputEditor = null
jsEditor = null

grid = null


setupEditors = ->
  sourceEditor = ace.edit 'source-editor'
  sourceEditor.setTheme 'ace/theme/monokai'
  sourceEditor.setFontSize 14

  inputEditor = ace.edit 'input-editor'
  inputEditor.setTheme 'ace/theme/monokai'
  inputEditor.getSession().setUseWrapMode true
  inputEditor.setFontSize 14

  outputEditor = ace.edit 'output-editor'
  outputEditor.setTheme 'ace/theme/monokai'
  outputEditor.getSession().setUseWrapMode true
  outputEditor.setReadOnly true
  outputEditor.setFontSize 14

  jsEditor = ace.edit 'js-editor'
  jsEditor.setTheme 'ace/theme/monokai'
  jsEditor.getSession().setMode 'ace/mode/javascript'
  jsEditor.getSession().setUseWrapMode true
  jsEditor.setReadOnly true
  jsEditor.setFontSize 14


run = ->
  playfield = new bef.Playfield()
  playfield.fromString sourceEditor.getValue(), 16, 10

  lazyRuntime = new bef.LazyRuntime()
  lazyRuntime.execute playfield, jumpLimit: 1000, inputEditor.getValue()

  stringedStack = lazyRuntime.programState.stack.join ' '
  stringedOutput = lazyRuntime.programState.outRecord.join ' '

  outputEditor.setValue "Stack: #{stringedStack}\nOutput: #{stringedOutput}", 1

  grid?.destroy()
  grid = new viz.Grid playfield, lazyRuntime.pathSet, document.getElementById 'can'
  grid.setListener (path) ->
    jsEditor.setValue path?.code ? ''


setupRunButton = ->
  (document.getElementById 'run').addEventListener 'click', run


setupEditors()
setupRunButton()
run()