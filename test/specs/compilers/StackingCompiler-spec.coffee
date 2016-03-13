'use strict'

{ StackingCompiler } = bef

describe 'StackingCompiler', ->
	{ runSuite, compilerSpecs } = befTest
	execute = befTest.makeExecute StackingCompiler

	describe 'general', ->
		runSuite compilerSpecs.general, execute

	describe 'string', ->
		runSuite compilerSpecs.string, execute

	describe 'edgeCases', ->
		runSuite compilerSpecs.edgeCases, execute