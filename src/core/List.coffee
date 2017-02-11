'use strict'


EMPTY =
	find: -> null
	con: (value) -> new List value, EMPTY


List = (@value, @next = EMPTY) ->
	return

List::find = (value) ->
	if @value == value
		@
	else
		@next.find value

List::con = (value) ->
	new List value, @



List.EMPTY = EMPTY


window.bef ?= {}
window.bef.List = List