'use strict'

getHash = (x, y, dir) ->
  "#{x}_#{y}_#{dir}"


PathSet = ->
  @set = {}
  return


PathSet::add = (path) ->
  hash = getHash path.list[0].x, path.list[0].y, path.list[0].dir
  @set[hash] = path
  @


PathSet::getStartingFrom = (x, y, dir) ->
  hash = getHash x, y, dir
  @set[hash]


PathSet::remove = (path) ->
  hash = getHash path.list[0].x, path.list[0].y, path.list[0].dir
  delete @set[hash]
  @


window.bef ?= {}
window.bef.PathSet = PathSet