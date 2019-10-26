'use strict'


S = bef.Symbols


idCounter = 0


getId = ->
	idCounter++


getHash = (x, y, dir, string) ->
	"#{x}_#{y}_#{dir}#{if string then '_s' else ''}"


Path = (list = []) ->
	@id = getId()
	@entries = {}
	@list = []
	@looping = false

	for entry in list
		@push entry.x, entry.y, entry.dir, entry.charCode, entry.string

	return


Path::push = (x, y, dir, charCode, string = false) ->
	hash = getHash x, y, dir, string

	@entries[hash] =
		charCode: charCode
		index: @list.length
		string: string

	@list.push
		x: x
		y: y
		dir: dir
		charCode: charCode
		string: string


Path::prefix = (length) ->
	prefixList = @list.slice 0, length
	new Path prefixList


Path::suffix = (length) ->
	suffixList = @list.slice length
	new Path suffixList


Path::has = (x, y, dir) ->
	hash1 = getHash x, y, dir
	hash2 = getHash x, y, dir, true
	@entries[hash1]? or @entries[hash2]?


Path::hasNonString = (x, y, dir) ->
	hash = getHash x, y, dir
	@entries[hash]?


Path::getEntryAt = (x, y, dir) ->
	hash = getHash x, y, dir
	@entries[hash]


Path::getLastEntryThrough = (x, y) ->
	possibleEntries = [
		getHash x, y, S.UP
		getHash x, y, S.LEFT
		getHash x, y, S.DOWN
		getHash x, y, S.RIGHT

		getHash x, y, S.UP, true
		getHash x, y, S.LEFT, true
		getHash x, y, S.DOWN, true
		getHash x, y, S.RIGHT, true
	]

	max = -1
	lastEntry = null
	for hash in possibleEntries
		entry = @entries[hash]
		if entry?.index > max
			max = entry.index
			lastEntry = entry

	lastEntry


Path::getAsList = ->
	@list.slice 0


Path::getEndPoint = ->
	lastEntry = @list[@list.length - 1]

	x: lastEntry.x
	y: lastEntry.y
	dir: lastEntry.dir


window.bef ?= {}
window.bef.Path = Path