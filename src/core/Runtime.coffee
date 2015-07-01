'use strict'

Runtime = (@interpreter) ->
  @stack = []
  @flags =
    pathInvalidatedAhead: false
  @inputPointer = 0
  @inputList = []
  @outRecord = []
  return


Runtime::push = ->
  @stack.push.apply @stack, arguments


Runtime::pop = ->
  return 0 if @stack.length < 1
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
  else
    0


Runtime::nextChar = ->
  ret = @inputList[@inputPointer].charCodeAt 0
  if @inputPointer < @inputList.length
    @inputPointer++
    ret
  else
    0


Runtime::put = (e, y, x, currentX, currentY, currentDir, index) ->
  @interpreter.put x, y, (String.fromCharCode e), currentX, currentY, currentDir, index


Runtime::get = (y, x) ->
  @interpreter.get x, y


Runtime::duplicate = ->
  e = @stack[@stack.length - 1]
  @stack.push e


Runtime::swap = ->
  e1 = @stack[@stack.length - 1]
  e2 = @stack[@stack.length - 2]
  @stack[@stack.length - 1] = e2
  @stack[@stack.length - 2] = e1


Runtime::randInt = (max) ->
	Math.floor Math.random() * max


window.bef ?= {}
window.bef.Runtime = Runtime