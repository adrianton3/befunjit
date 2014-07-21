'use strict'

idCounter = 0


getId = ->
  idCounter++


getHash = (x, y, dir) ->
  "#{x}_#{y}_#{dir}"


Path = (list = []) ->
  @id = getId()
  @entries = {}
  @list = []

  list.forEach (entry) =>
    @push entry.x, entry.y, entry.dir, entry.char

  return


Path::push = (x, y, dir, char) ->
  hash = getHash x, y, dir

  @entries[hash] =
    char: char
    index: @list.length

  @list.push
    x: x
    y: y
    dir: dir
    char: char


Path::prefix = (length) ->
  prefixList = @list.slice 0, length
  new Path prefixList


Path::suffix = (length) ->
  suffixList = @list.slice length
  new Path suffixList


Path::has = (x, y, dir) ->
  hash = getHash x, y, dir
  @entries[hash]?


Path::getEntryAt = (x, y, dir) ->
  hash = getHash x, y, dir
  @entries[hash]


Path::getAsList = ->
  @list.slice 0


Path::getEndPoint = ->
  lastEntry = @list[@list.length - 1]

  x: lastEntry.x
  y: lastEntry.y
  dir: lastEntry.dir


window.bef ?= {}
window.bef.Path = Path