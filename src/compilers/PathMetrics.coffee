'use strict'


consumePair = (consume, delta) ->
	{ consume, delta }


consumeCount = new Map [
	[' ', consumePair 0, 0]

	['0', consumePair 0, 1]
	['1', consumePair 0, 1]
	['2', consumePair 0, 1]
	['3', consumePair 0, 1]
	['4', consumePair 0, 1]
	['5', consumePair 0, 1]
	['6', consumePair 0, 1]
	['7', consumePair 0, 1]
	['8', consumePair 0, 1]
	['9', consumePair 0, 1]

	['+', consumePair 2, -1]
	['-', consumePair 2, -1]
	['*', consumePair 2, -1]
	['/', consumePair 2, -1]
	['%', consumePair 2, -1]

	['!', consumePair 1, 0]
	['`', consumePair 2, -1]

	['^', consumePair 0, 0]
	['<', consumePair 0, 0]
	['v', consumePair 0, 0]
	['>', consumePair 0, 0]
	['?', consumePair 0, 0]
	['_', consumePair 1, -1]
	['|', consumePair 1, -1]
	['"', consumePair 0, 0]

	[':', consumePair 0, 1]
	['\\', consumePair 2, 0]
	['$', consumePair 1, -1]

	['.', consumePair 1, -1]
	[',', consumePair 1, -1]
	['#', consumePair 0, 0]
	['p', consumePair 3, -3]
	['g', consumePair 2, -1]
	['&', consumePair 0, 1]
	['~', consumePair 0, 1]
	['@', consumePair 0, 0]
]


getDepth = (path) ->
	{ max, sum } = path.getAsList().reduce ({ max, sum }, { char, string }) ->
		{ consume, delta } = if string
			{ consume: 0, delta: 1 }
		else if consumeCount.has char
			consumeCount.get char
		else
			{ consume: 0, delta: 0 }

		sum: sum + delta
		max: Math.min max, sum - consume
	, { max: 0, sum: 0 }

	{ max: -max, sum }


PathMetrics = ->
Object.assign(PathMetrics, {
	getDepth
})


window.bef ?= {}
window.bef.PathMetrics = PathMetrics