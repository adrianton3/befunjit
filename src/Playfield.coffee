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


Playfield::fromString = (string, width, height) ->
  @width = width if width?
  @height = height if height?

  @field = []
  lines = string.split '\n'
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


Playfield::getSize = ->
  width: @width
  height: @height


window.bef ?= {}
window.bef.Playfield = Playfield