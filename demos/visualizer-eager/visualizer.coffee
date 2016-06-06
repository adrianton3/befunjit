'use strict'

{
	setupEditors
	setupSamples
	setupCompilers
	setupRunButton
	saveProgram
	loadProgram
} = window.viz


run = (editors, compiler) ->
	saveProgram editors

	playfield = new bef.Playfield()
	playfield.fromString editors.source.getValue(), 16, 10

	runtime = new bef.EagerRuntime()
	runtime.execute(
		playfield
		{ jumpLimit: 1000, compiler }
		editors.input.getValue()
	)

	rawJs = runtime.code
	prettyJs = js_beautify rawJs

	editors.js.setValue prettyJs, 1

	stringedStack = runtime.programState.stack.join ' '
	stringedOutput = runtime.programState.outRecord.join ' '

	editors.output.setValue "Stack: #{stringedStack}\nOutput: #{stringedOutput}", 1


do ->
	compiler = bef.BinaryCompiler

	editors = setupEditors()

	setupSamples window.befSample, editors

	setupCompilers (_compiler) ->
		compiler = _compiler
		run editors, compiler

	setupRunButton ->
		run editors, compiler

	loadProgram editors

	run editors, compiler