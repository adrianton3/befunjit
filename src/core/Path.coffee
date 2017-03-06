'use strict'

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

	list.forEach (entry) ->
		@push entry.x, entry.y, entry.dir, entry.char, entry.string
		return
	, @

	return


Path::push = (x, y, dir, char, string = false) ->
	hash = getHash x, y, dir, string

	@entries[hash] =
		char: char
		index: @list.length
		string: string

	@list.push
		x: x
		y: y
		dir: dir
		char: char
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
		getHash x, y, '^'
		getHash x, y, '<'
		getHash x, y, 'V'
		getHash x, y, '>'

		getHash x, y, '^', true
		getHash x, y, '<', true
		getHash x, y, 'V', true
		getHash x, y, '>', true
	]

	max = -1
	lastEntry = null
	possibleEntries.forEach (hash) ->
		entry = @entries[hash]
		if entry?.index > max
			max = entry.index
			lastEntry = entry
		return
	, @

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