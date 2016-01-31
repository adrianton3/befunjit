'use strict'


DEFAULT =
	WIDTH: 80
	HEIGHT: 25


Playfield = (@width = DEFAULT.WIDTH, @height = DEFAULT.HEIGHT) ->
	@field = []
	@pathPlane = []
	return


Playfield::_initPathPlane = (width = DEFAULT.WIDTH, height = DEFAULT.HEIGHT) ->
	@pathPlane = []

	for i in [1..height]
		line = []

		for j in [1..width]
			line.push {}

		@pathPlane.push line

	return


Playfield::fromString = (string, width, height) ->
	lines = string.split '\n'

	[@width, @height] = if width? and height?
		[width, height]
	else
		[
			Math.max (lines.map (line) -> line.length)...
			lines.length
		]

	@field = []
	lines.forEach (line) =>
		chars = line.split ''

		for i in [chars.length...@width]
			chars.push ' '

		@field.push chars

	for i in [lines.length...@height]
		line = []

		for j in [0...@width]
			line.push ' '

		@field.push line

	@_initPathPlane width, height

	@


Playfield::getAt = (x, y) ->
	@field[y][x]


Playfield::setAt = (x, y, char) ->
	@field[y][x] = char
	@


Playfield::addPath = (path) ->
	path.list.forEach (entry) =>
		@setAt entry.x, entry.y, entry.char
		@pathPlane[entry.y][entry.x][path.id] = path
	@


Playfield::isInside = (x, y) ->
	0 <= x < @width and 0 <= y < @height


Playfield::getPathsThrough = (x, y) ->
	cell = @pathPlane[y][x]
	keys = Object.keys cell
	paths = []
	keys.forEach (key) -> paths.push cell[key]
	paths


Playfield::removePath = (path) ->
	path.list.forEach (entry) =>
		cell = @pathPlane[entry.y][entry.x]
		delete cell[path.id]
		return

	return


Playfield::getSize = ->
	width: @width
	height: @height


Playfield::clearPaths = ->
	for i in [0...@height]
		for j in [0...@width]
			@pathPlane[i][j] = {}

	return


window.bef ?= {}
window.bef.Playfield = Playfield