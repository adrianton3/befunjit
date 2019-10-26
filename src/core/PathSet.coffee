'use strict'


S = bef.Symbols


getHashAny = (x, y) ->
	"#{x}_#{y}"


getHashDir = (x, y, dir) ->
	"#{x}_#{y}_#{dir}"


PathSet = ->
	@map = new Map
	return


PathSet::add = (path) ->
	head = path.list[0]

	hash = if head.charCode in [S.UP, S.LEFT, S.DOWN, S.RIGHT]
		getHashAny head.x, head.y
	else
		getHashDir head.x, head.y, head.dir

	@map.set hash, path
	@


PathSet::getStartingFrom = (x, y, dir) ->
	hashDir = getHashDir x, y, dir

	if @map.has hashDir
		@map.get hashDir
	else
		hashAny = getHashAny x, y
		@map.get hashAny


PathSet::remove = (path) ->
	head = path.list[0]

	hash = if head.charCode in [S.UP, S.LEFT, S.DOWN, S.RIGHT]
		getHashAny head.x, head.y
	else
		getHashDir head.x, head.y, head.dir

	@map.delete hash
	@


PathSet::clear = ->
	@map.clear()
	@


window.bef ?= {}
window.bef.PathSet = PathSet