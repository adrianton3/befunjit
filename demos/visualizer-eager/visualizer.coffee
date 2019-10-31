'use strict'

{
	setupEditors
	setupSamples
	setupCompilers
	setupRunButton
	saveProgram
	loadProgram
} = window.viz


prettify = (code) ->
	# workarounds until js_beautify gets fixed
	# https://github.com/beautify-web/js-beautify/issues/815
	semicolons = code.replace /([\w)])$/gm, '$1;'
	beautified = js_beautify semicolons
	beautified.replace /;$/gm, ''


run = (editors, compiler) ->
	saveProgram editors

	playfield = new bef.Playfield editors.source.getValue(), { size: 'standard' }

	runtime = new bef.EagerRuntime()
	runtime.execute(
		playfield
		{ jumpLimit: 1000, compiler, fastConditionals: true }
		editors.input.getValue()
	)

	prettyJs = prettify runtime.code

	editors.js.setValue prettyJs, 1

	stringedStack = do ->
		{ stack } = runtime.programState
		if stack.length > 512
			"""
				#{(stack.slice 0, 256).join ' '}
				...
				#{(stack.slice -256).join ' '}
			"""
		else
			stack.join ' '

	stringedOutput = runtime.programState.outRecord.join ''

	editors.output.setValue "Stack: #{stringedStack}\nOutput: #{stringedOutput}", 1


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