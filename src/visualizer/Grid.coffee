'use strict'

Grid = (@playfield, @pathSet, @canvas) ->
  @cellSize = 36
  @COLORS =
    BACKGROUND: '#272822'
    PATHBACKGROUND: '#49483E'
    GRID: '#EDF'
    PATHINDICATOR: 'rgb(24, 155, 230)'
    FONT: '#EDF'

  @canvas.width = @playfield.width * @cellSize
  @canvas.height = @playfield.height * @cellSize

  @con2d = @canvas.getContext '2d'
  @con2d.textAlign = 'center'
  @con2d.textBaseline = 'middle'
  @con2d.font = '20px Consolas, monospace'
  @con2d.strokeStyle = '#FFF'
  @con2d.lineWidth = 0.8

  @onChange = null
  @mouseState =
    x: -1
    y: -1

  @_setupMouseListener()

  @hitRegions = []
  @_setupHitRegions()
  @arrowImages = getArrowImages @cellSize / 3, @COLORS
  @draw()
  return


getArrowImage = (size, angle, COLORS) ->
  canvas = document.createElement 'canvas'
  canvas.width = size
  canvas.height = size
  con2d = canvas.getContext '2d'
  con2d.strokeStyle = COLORS.PATHINDICATOR
  con2d.lineWidth = 2

  con2d.translate size / 2, size / 2
  con2d.rotate angle

  con2d.beginPath()
  con2d.moveTo -size / 2 - 1, size / 2 - 4
  con2d.lineTo  0, -size / 2 + 3
  con2d.lineTo  size / 2 + 1, size / 2 - 4
  con2d.stroke()
  canvas

getArrowImages = (size, COLORS) ->
  '^': getArrowImage size, 0, COLORS
  '<': getArrowImage size, -Math.PI / 2, COLORS
  'v': getArrowImage size, Math.PI, COLORS
  '>': getArrowImage size, Math.PI / 2, COLORS


directions = [
  { char: '<', offset: { x: 0, y: 1 } }
  { char: '^', offset: { x: 1, y: 0 } }
  { char: 'v', offset: { x: 1, y: 2 } }
  { char: '>', offset: { x: 2, y: 1 } }
]

Grid::_setupHitRegions = ->
  getCellRegion = ((x, y, offX, offY, dir) ->
    x: x
    y: y
    dir: dir
    start:
      x: x * @cellSize + @cellSize / 3 * offX
      y: y * @cellSize + @cellSize / 3 * offY
    end:
      x: x * @cellSize + @cellSize / 3 * (offX + 1)
      y: y * @cellSize + @cellSize / 3 * (offY + 1)
    size:
      width: @cellSize / 3
      height: @cellSize / 3
  ).bind @

  for i in [0...@playfield.width]
    for j in [0...@playfield.height]
      for dir in directions
        if @pathSet.has i, j, dir.char
          offset = dir.offset
          @hitRegions.push getCellRegion i, j, offset.x, offset.y, dir.char

  return


Grid::_getRegion = (x, y) ->
  for region in @hitRegions
    if region.start.x <= x <= region.end.x and region.start.y <= y <= region.end.y
      return region
  return null

# throttle this
mouseMove = (e) ->
  @mouseState.x = e.offsetX ? e.layerX
  @mouseState.y = e.offsetY ? e.layerY
  newRegion = @_getRegion @mouseState.x, @mouseState.y
  if newRegion != @currentRegion
    @currentRegion = newRegion
    if @currentRegion?
      @highlightedPath = @pathSet.getStartingFrom @currentRegion.x, @currentRegion.y, @currentRegion.dir
    else
      @highlightedPath = null
    @draw()

    @onChange? @highlightedPath


Grid::_setupMouseListener = ->
  @_mouseMove = mouseMove.bind @
  @canvas.addEventListener 'mousemove', @_mouseMove
  return


Grid::draw = ->
  #background
  @con2d.fillStyle = @COLORS.BACKGROUND
  @con2d.fillRect 0, 0, @canvas.width, @canvas.height

  #active path
  @con2d.fillStyle = @COLORS.PATHBACKGROUND
  @highlightedPath?.list.forEach (entry) =>
    @con2d.fillRect entry.x * @cellSize, entry.y * @cellSize, @cellSize, @cellSize

  #chars
  @con2d.fillStyle = @COLORS.FONT
  for i in [0...@playfield.width]
    for j in [0...@playfield.height]
      @con2d.fillText(
        (@playfield.getAt i, j),
        i * @cellSize + @cellSize / 2,
        j * @cellSize + @cellSize / 2
      )

  #path indicators
    for hitRegion in @hitRegions
      @con2d.drawImage @arrowImages[hitRegion.dir], hitRegion.start.x, hitRegion.start.y

  #grid
  @con2d.strokeStyle = @COLORS.GRID
  @con2d.beginPath()
  for i in [1...@playfield.width]
    @con2d.moveTo i * @cellSize, 0
    @con2d.lineTo i * @cellSize, @canvas.height

  for i in [1...@playfield.height]
    @con2d.moveTo 0, i * @cellSize
    @con2d.lineTo @canvas.width, i * @cellSize
  @con2d.stroke()

  return


Grid::setListener = (@onChange) ->
  return


Grid:: destroy = ->
  @canvas.removeEventListener 'mousemove', @_mouseMove


window.viz ?= {}
window.viz.Grid = Grid