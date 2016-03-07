'use strict'

getHash = (x, y, dir) ->
	"#{x}_#{y}_#{dir}"


PathSet = ->
	@map = new Map
	return


PathSet::add = (path) ->
	head = path.list[0]
	hash = getHash head.x, head.y, head.dir
	@map.set hash, path
	@


PathSet::has = (x, y, dir) ->
	hash = getHash x, y, dir
	@map.has hash


PathSet::getStartingFrom = (x, y, dir) ->
	hash = getHash x, y, dir
	@map.get hash


PathSet::remove = (path) ->
	head = path.list[0]
	hash = getHash head.x, head.y, head.dir
	@map.delete hash
	@


PathSet::clear = ->
	@map.clear()
	@


window.bef ?= {}
window.bef.PathSet = PathSet