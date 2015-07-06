'use strict'

ProgramState = (@interpreter) ->
	@stack = []
	@flags =
		pathInvalidatedAhead: false
	@inputPointer = 0
	@inputList = []
	@outRecord = []
	return


ProgramState::push = ->
	@stack.push.apply @stack, arguments


ProgramState::pop = ->
	return 0 if @stack.length < 1
	@stack.pop()


ProgramState::out = (e) ->
	@outRecord.push e


ProgramState::setInput = (values) ->
	@inputList = values.slice 0
	@inputPointer = 0


ProgramState::next = ->
	ret = @inputList[@inputPointer]
	if @inputPointer < @inputList.length
		@inputPointer++
		ret
	else
		0


ProgramState::nextChar = ->
	ret = @inputList[@inputPointer].charCodeAt 0
	if @inputPointer < @inputList.length
		@inputPointer++
		ret
	else
		0


ProgramState::put = (e, y, x, currentX, currentY, currentDir, index) ->
	@interpreter.put x, y, (String.fromCharCode e), currentX, currentY, currentDir, index


ProgramState::get = (y, x) ->
	@interpreter.get x, y


ProgramState::duplicate = ->
	e = @stack[@stack.length - 1]
	@stack.push e


ProgramState::swap = ->
	return if @stack.length < 2
	e1 = @stack[@stack.length - 1]
	e2 = @stack[@stack.length - 2]
	@stack[@stack.length - 1] = e2
	@stack[@stack.length - 2] = e1
	return


ProgramState::randInt = (max) ->
	Math.floor Math.random() * max


ProgramState::exit = ->
	@flags.exitRequest = true


window.bef ?= {}
window.bef.ProgramState = ProgramState