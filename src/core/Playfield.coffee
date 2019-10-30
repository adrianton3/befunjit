'use strict'


S = bef.Symbols


Playfield = (string, options) ->
	lines = string.split '\n'

	{ @width, @height } = initSize lines, options
	@field = initField lines, @width, @height
	@pathPlane = initPathPlane @width, @height

	return


initSize = (lines, options) ->
	width = Math.max (lines.map (line) -> line.length)...
	height = lines.length

	if options?.size == 'standard'
		{
			width: 80
			height: 25
		}
	else if options?.size == 'double'
		{
			width: width * 2
			height: height * 2
		}
	else
		{
			width
			height
		}


initField = (lines, width, height) ->
	field = []

	i = 0
	iLimit = Math.min lines.length, height
	while i < iLimit
		line = lines[i]
		chars = Array.from line, (char) -> char.charCodeAt 0
		chars.splice width, chars.length

		for j in [chars.length...width]
			chars.push S.BLANK

		field.push chars
		i++

	i = lines.length
	iLimit = height
	while i < iLimit
		line = []

		for j in [0...width]
			line.push S.BLANK

		field.push line
		i++

	field


initPathPlane = (width, height) ->
	pathPlane = []

	for i in [1..height]
		line = []

		for j in [1..width]
			line.push new Map

		pathPlane.push line

	pathPlane


Playfield::getAt = (x, y) ->
	@field[y][x]


Playfield::setAt = (x, y, value) ->
	@field[y][x] = value
	@


Playfield::addPath = (path) ->
	for entry in path.list
		cell = @pathPlane[entry.y][entry.x]
		cell.set path.id, path

	@


Playfield::isInside = (x, y) ->
	0 <= x < @width and 0 <= y < @height


Playfield::getPathsThrough = (x, y) ->
	Array.from @pathPlane[y][x].values()


Playfield::removePath = (path) ->
	for entry in path.list
		cell = @pathPlane[entry.y][entry.x]
		cell.delete path.id

	return


Playfield::getSize = ->
	width: @width
	height: @height


Playfield::clearPaths = ->
	for i in [0...@height]
		for j in [0...@width]
			@pathPlane[i][j] = new Map

	return


window.bef ?= {}
window.bef.Playfield = Playfield