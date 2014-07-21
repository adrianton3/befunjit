'use strict'

Runtime = (@interpreter) ->
  @stack = []
  @flags =
    pathInvalidatedAhead: false
  @inputPointer = 0
  @inputList = []
  @outRecord = []
  return


Runtime::push = (e) ->
  @stack.push e


Runtime::pop = ->
  @stack.pop()


Runtime::out = (e) ->
  @outRecord.push e


Runtime::setInput = (values) ->
  @inputList = values.slice 0
  @inputPointer = 0


Runtime::next = ->
  ret = @inputList[@inputPointer]
  if @inputPointer < @inputList.length
    @inputPointer++
  ret


Runtime::put = (e, y, x, currentX, currentY, currentDir, index) ->
  @interpreter.put x, y, (String.fromCharCode e), currentX, currentY, currentDir, index


window.bef ?= {}
window.bef.Runtime = Runtime