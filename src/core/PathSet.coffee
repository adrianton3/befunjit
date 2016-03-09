'use strict'


getHashAny = (x, y) ->
	"#{x}_#{y}"


getHashDir = (x, y, dir) ->
	"#{x}_#{y}_#{dir}"


PathSet = ->
	@map = new Map
	return


PathSet::add = (path) ->
	head = path.list[0]

	hash = if head.char in ['^', '<', 'v', '>']
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

	hash = if head.char in ['^', '<', 'v', '>']
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