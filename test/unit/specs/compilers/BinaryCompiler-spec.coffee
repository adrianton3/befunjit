'use strict'

{ BinaryCompiler } = bef
{ runSuite, compilerSpecs, makeExecute, getPath } = befTest

describe 'BinaryCompiler', ->
	execute = makeExecute BinaryCompiler

	describe 'getMaxDepth', ->
		{ getMaxDepth } = BinaryCompiler

		[
			['', 0]
			['1', 0]
			['123', 0]
			['+', 2]
			['+++', 4]
			['1+', 1]
			['1++', 2]
			['1+2+', 1]
			['123++', 0]
			['\\', 2]
			['"asd"', 0]
			['"asd"+++', 1]
		].forEach ([code, depth]) ->
			it code, ->
				path = getPath code
				(expect getMaxDepth path).toBe depth


	describe 'general', ->
		runSuite compilerSpecs.general, execute

	describe 'string', ->
		runSuite compilerSpecs.string, execute

	describe 'edgeCases', ->
		runSuite compilerSpecs.edgeCases, execute