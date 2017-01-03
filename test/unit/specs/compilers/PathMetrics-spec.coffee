'use strict'


{ PathMetrics } = bef
{ getPath } = befTest


describe 'PathMetrics', ->
	describe 'getDepth', ->
		{ getDepth } = PathMetrics

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
				(expect (getDepth path).max).toBe depth
