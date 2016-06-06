'use strict'

setupEditors = ->
	source = ace.edit 'source-editor'
	source.setTheme 'ace/theme/monokai'
	source.setFontSize 14

	input = ace.edit 'input-editor'
	input.setTheme 'ace/theme/monokai'
	input.getSession().setUseWrapMode true
	input.setFontSize 14

	output = ace.edit 'output-editor'
	output.setTheme 'ace/theme/monokai'
	output.getSession().setUseWrapMode true
	output.setReadOnly true
	output.setFontSize 14

	js = ace.edit 'js-editor'
	js.setTheme 'ace/theme/monokai'
	js.getSession().setMode 'ace/mode/javascript'
	js.getSession().setUseWrapMode true
	js.setReadOnly true
	js.setFontSize 14

	{
		source
		input
		output
		js
	}


setupSamples = (samples, { source, input }) ->
	select = document.getElementById 'sample'

	(Object.keys samples).forEach (sampleName) ->
		option = document.createElement 'option'
		option.textContent = sampleName
		select.appendChild option
		return

	select.addEventListener 'change', ->
		sample = samples[@value]
		source.setValue sample.code, 1
		input.setValue sample.input, 1
		return


setupCompilers = (onChange) ->
	select = document.getElementById 'compiler'

	[
		'BinaryCompiler'
		'StackingCompiler'
		'OptimizingCompiler'
		'BasicCompiler'
	].forEach (sampleName) ->
		option = document.createElement 'option'
		option.textContent = sampleName
		select.appendChild option
		return

	select.addEventListener 'change', ->
		onChange bef[@value]
		return


setupRunButton = (run) ->
	(document.getElementById 'run').addEventListener 'click', run


saveProgram = ({ source, input }) ->
	if localStorage['dev']?
		localStorage['last-run-source'] = source.getValue()
		localStorage['last-run-input'] = input.getValue()


loadProgram = ({ source, input }) ->
	if localStorage['dev']? and localStorage['last-run-source']?
		source.setValue localStorage['last-run-source'], 1
		input.setValue localStorage['last-run-input'], 1


window.viz ?= {}
Object.assign(window.viz, {
	setupEditors
	setupSamples
	setupCompilers
	setupRunButton
	saveProgram
	loadProgram
})