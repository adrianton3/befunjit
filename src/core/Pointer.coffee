'use strict'

dirTable =
  '^': { x:  0, y: -1 }
  '<': { x: -1, y:  0 }
  'v': { x:  0, y:  1 }
  '>': { x:  1, y:  0 }


Pointer = (@x, @y, @dir, @space) ->
  @_updateDir(@dir)
  return


Pointer::_updateDir = (@dir) ->
  @ax = dirTable[@dir].x
  @ay = dirTable[@dir].y


Pointer::turn = (dir) ->
  if dirTable[dir]? and (dir != @dir)
    @_updateDir dir
  @


Pointer::advance = ->
  @x = (@x + @ax + @space.width) % @space.width
  @y = (@y + @ay + @space.height) % @space.height

  @


Pointer::set = (@x, @y, @dir) ->
  @_updateDir dir
  @


window.bef ?= {}
window.bef.Pointer = Pointer