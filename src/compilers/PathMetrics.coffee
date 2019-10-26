'use strict'


S = bef.Symbols


consumePair = (consume, delta) ->
	{ consume, delta }


consumeCount = new Map [
	[S.BLANK, consumePair 0, 0]

	[S.D0, consumePair 0, 1]
	[S.D1, consumePair 0, 1]
	[S.D2, consumePair 0, 1]
	[S.D3, consumePair 0, 1]
	[S.D4, consumePair 0, 1]
	[S.D5, consumePair 0, 1]
	[S.D6, consumePair 0, 1]
	[S.D7, consumePair 0, 1]
	[S.D8, consumePair 0, 1]
	[S.D9, consumePair 0, 1]

	[S.ADD, consumePair 2, -1]
	[S.SUB, consumePair 2, -1]
	[S.MUL, consumePair 2, -1]
	[S.DIV, consumePair 2, -1]
	[S.MOD, consumePair 2, -1]

	[S.NOT, consumePair 1, 0]
	[S.GT, consumePair 2, -1]

	[S.UP, consumePair 0, 0]
	[S.LEFT, consumePair 0, 0]
	[S.DOWN, consumePair 0, 0]
	[S.RIGHT, consumePair 0, 0]
	[S.RAND, consumePair 0, 0]
	[S.IFH, consumePair 1, -1]
	[S.IFV, consumePair 1, -1]
	[S.QUOT, consumePair 0, 0]

	[S.DUP, consumePair 0, 1]
	[S.SWAP, consumePair 2, 0]
	[S.DROP, consumePair 1, -1]

	[S.OUTI, consumePair 1, -1]
	[S.OUTC, consumePair 1, -1]
	[S.JUMP, consumePair 0, 0]
	[S.PUT, consumePair 3, -3]
	[S.GET, consumePair 2, -1]
	[S.INI, consumePair 0, 1]
	[S.INC, consumePair 0, 1]
	[S.END, consumePair 0, 0]
]


getDepth = (path) ->
	{ max, sum } = path.getAsList().reduce ({ max, sum }, { charCode, string }) ->
		{ consume, delta } = if string
			{ consume: 0, delta: 1 }
		else if consumeCount.has charCode
			consumeCount.get charCode
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