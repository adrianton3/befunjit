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

	source = editors.source.getValue()

	size = { width: 16, height: 10 }

	original = new bef.Playfield source, size

	playfield = new bef.Playfield source, size

	lazyRuntime = new bef.LazyRuntime()
	lazyRuntime.execute(
		playfield
		{ jumpLimit: 1000, compiler }
		editors.input.getValue()
	)

	stringedStack = lazyRuntime.programState.stack.join ' '
	stringedOutput = lazyRuntime.programState.outRecord.join ''

	editors.output.setValue "Stack: #{stringedStack}\nOutput: #{stringedOutput}", 1

	grid?.destroy()
	grid = new viz.Grid(
		original
		playfield
		lazyRuntime.pathSet
		document.getElementById 'can'
	)
	grid.setListener (path) ->
		code = path?.code ? ''
		editors.js.setValue code, -1
		return


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