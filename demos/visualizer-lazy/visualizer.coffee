'use strict'

{
	setupEditors
	setupSamples
	setupCompilers
	setupRunButton
	saveProgram
	loadProgram
} = window.viz


grid = null


run = (editors, compiler) ->
	saveProgram editors

	playfield = new bef.Playfield()
	playfield.fromString editors.source.getValue(), 16, 10

	lazyRuntime = new bef.LazyRuntime()
	lazyRuntime.execute(
		playfield
		{ jumpLimit: 1000, compiler }
		editors.input.getValue()
	)

	stringedStack = lazyRuntime.programState.stack.join ' '
	stringedOutput = lazyRuntime.programState.outRecord.join ' '

	editors.output.setValue "Stack: #{stringedStack}\nOutput: #{stringedOutput}", 1

	grid?.destroy()
	grid = new viz.Grid playfield, lazyRuntime.pathSet, document.getElementById 'can'
	grid.setListener (path) ->
		editors.js.setValue path?.code ? ''


do ->
	compiler = bef.StackingCompiler

	editors = setupEditors()

	setupSamples window.befSample, editors

	setupCompilers (_compiler) ->
		compiler = _compiler
		run editors, compiler

	setupRunButton ->
		run editors, compiler

	loadProgram editors

	run editors, compiler