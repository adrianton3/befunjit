'use strict'

ProgramState = (@interpreter) ->
	@stack = []
	@flags =
		pathInvalidatedAhead: false
	@inputPointer = 0
	@inputList = []
	@outRecord = []

	@checks = 0
	@maxChecks = Infinity
	return


ProgramState::push = ->
	@stack.push.apply @stack, arguments
	return


ProgramState::pop = ->
	return 0 if @stack.length < 1
	@stack.pop()


ProgramState::peek = ->
	return 0 if @stack.length < 1
	@stack[@stack.length - 1]


ProgramState::out = (e) ->
	@outRecord.push e


ProgramState::setInput = (values) ->
	@inputList = values.slice 0
	@inputPointer = 0


ProgramState::next = ->
	if @inputPointer < @inputList.length
		ret = parseInt @inputList[@inputPointer], 10
		@inputPointer++
		ret
	else
		0


ProgramState::nextChar = ->
	if @inputPointer < @inputList.length
		ret = @inputList[@inputPointer].charCodeAt 0
		@inputPointer++
		ret
	else
		0


ProgramState::put = (e, y, x, currentX, currentY, currentDir, index, from, to) ->
	@interpreter.put x, y, (String.fromCharCode e), currentX, currentY, currentDir, index, from, to


ProgramState::get = (y, x) ->
	@interpreter.get x, y


ProgramState::div = (a, b) ->
	@push b // a
	return


ProgramState::mod = (a, b) ->
	@push b % a
	return


ProgramState::duplicate = ->
	return if @stack.length < 1
	e = @stack[@stack.length - 1]
	@stack.push e
	return


ProgramState::swap = ->
	if @stack.length >= 2
		e1 = @stack[@stack.length - 1]
		e2 = @stack[@stack.length - 2]
		@stack[@stack.length - 1] = e2
		@stack[@stack.length - 2] = e1
	else if @stack.length == 1
		@stack.push 0
	else
		@stack.push 0, 0
	return


ProgramState::randInt = (max) ->
	Math.floor Math.random() * max


ProgramState::exit = ->
	@flags.exitRequest = true


ProgramState::isAlive = ->
	return false if @flags.exitRequest
	@checks++
	@checks < @maxChecks


window.bef ?= {}
window.bef.ProgramState = ProgramState