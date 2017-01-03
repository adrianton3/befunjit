'use strict'


{ BinaryCompiler } = bef
{ runSuite, compilerSpecs, makeExecute } = befTest


describe 'BinaryCompiler', ->
	execute = makeExecute BinaryCompiler

	describe 'general', ->
		runSuite compilerSpecs.general, execute

	describe 'string', ->
		runSuite compilerSpecs.string, execute

	describe 'edgeCases', ->
		runSuite compilerSpecs.edgeCases, execute