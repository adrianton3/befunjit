'use strict'


S = bef.Symbols


colors =
	background: 'hsl(70, 8%, 15%)'
	grid: 'hsl(270, 100%, 93%)'
	path:
		arrow: 'hsl(202, 81%, 50%)'
		background: 'hsl(55, 8%, 26%)'
	text: 'hsl(270, 100%, 93%)'
	altered: 'hsl(0, 54%, 28%)'


fonts =
	normal: '20px Consolas, monospace'
	small: '14px Consolas, monospace'


Grid = (@original, @playfield, @pathSet, @canvas) ->
	@cellSize = 36

	@canvas.width = @playfield.width * @cellSize
	@canvas.height = @playfield.height * @cellSize

	@con2d = @canvas.getContext '2d'
	@con2d.textAlign = 'center'
	@con2d.textBaseline = 'middle'
	@con2d.strokeStyle = '#FFF'
	@con2d.lineWidth = 0.8

	@onChange = null
	@mouseState =
		x: -1
		y: -1

	@_setupMouseListener()

	@hitRegions = []
	@_setupHitRegions()
	@arrowImages = getArrowImages @cellSize / 3
	@draw()
	return


getArrowImage = (size, angle) ->
	canvas = document.createElement 'canvas'
	canvas.width = size
	canvas.height = size
	con2d = canvas.getContext '2d'
	con2d.strokeStyle = colors.path.arrow
	con2d.lineWidth = 2

	con2d.translate size / 2, size / 2
	con2d.rotate angle

	con2d.beginPath()
	con2d.moveTo -size / 2 - 1, size / 2 - 4
	con2d.lineTo  0, -size / 2 + 3
	con2d.lineTo  size / 2 + 1, size / 2 - 4
	con2d.stroke()
	canvas


getArrowImages = (size) ->
	images = {}
	
	images[S.UP] = getArrowImage size, 0
	images[S.LEFT] = getArrowImage size, -Math.PI / 2
	images[S.DOWN] = getArrowImage size, Math.PI
	images[S.RIGHT] = getArrowImage size, Math.PI / 2

	images


directions = [
	{ charCode: S.LEFT,  offset: { x: 0, y: 1 } }
	{ charCode: S.UP,    offset: { x: 1, y: 0 } }
	{ charCode: S.DOWN,  offset: { x: 1, y: 2 } }
	{ charCode: S.RIGHT, offset: { x: 2, y: 1 } }
]


directionsIndexed = directions.reduce (ret, { charCode, offset }) ->
		ret.set charCode, offset
		ret
	, new Map


Grid::_setupHitRegions = ->
	getCellRegion = (x, y, offX, offY, dir) =>
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

	for i in [0...@playfield.width]
		for j in [0...@playfield.height]
			charCode = @playfield.getAt i, j

			if charCode in [S.UP, S.LEFT, S.DOWN, S.RIGHT] and (@pathSet.getStartingFrom i, j, '')?
				offset = directionsIndexed.get charCode
				@hitRegions.push getCellRegion i, j, offset.x, offset.y, charCode
			else
				for dir in directions
					if (@pathSet.getStartingFrom i, j, dir.charCode)?
						offset = dir.offset
						@hitRegions.push getCellRegion i, j, offset.x, offset.y, dir.charCode

	return


Grid::_getRegion = (x, y) ->
	for region in @hitRegions
		if region.start.x <= x <= region.end.x and region.start.y <= y <= region.end.y
			return region
	null

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
	for i in [0...@playfield.width]
		for j in [0...@playfield.height]
			charOriginal = @original.getAt i, j
			charNow = @playfield.getAt i, j
			@con2d.fillStyle = if charNow == charOriginal
					colors.background
				else
					colors.altered

			@con2d.fillRect(
				i * @cellSize
				j * @cellSize
				@cellSize
				@cellSize
			)

	#active path
	@con2d.fillStyle = colors.path.background
	@highlightedPath?.list.forEach (entry) =>
		@con2d.fillRect entry.x * @cellSize, entry.y * @cellSize, @cellSize, @cellSize

	#chars
	@con2d.fillStyle = colors.text
	for i in [0...@playfield.width]
		for j in [0...@playfield.height]
			charCode = @playfield.getAt i, j

			if charCode > 0
				charPretty = if 32 <= charCode <= 126
					@con2d.font = fonts.normal
					String.fromCharCode charCode
				else
					@con2d.font = fonts.small
					"##{charCode}"

				@con2d.fillText(
					charPretty
					i * @cellSize + @cellSize / 2
					j * @cellSize + @cellSize / 2
				)

	#path indicators
		for hitRegion in @hitRegions
			@con2d.drawImage @arrowImages[hitRegion.dir], hitRegion.start.x, hitRegion.start.y

	#grid
	@con2d.save()
	@con2d.translate 0.5, 0.5

	@con2d.strokeStyle = colors.grid
	@con2d.beginPath()
	for i in [1...@playfield.width]
		@con2d.moveTo i * @cellSize, 0
		@con2d.lineTo i * @cellSize, @canvas.height

	for i in [1...@playfield.height]
		@con2d.moveTo 0, i * @cellSize
		@con2d.lineTo @canvas.width, i * @cellSize
	@con2d.stroke()

	@con2d.restore()

	return


Grid::setListener = (@onChange) ->
	return


Grid:: destroy = ->
	@canvas.removeEventListener 'mousemove', @_mouseMove


window.viz ?= {}
window.viz.Grid = Grid