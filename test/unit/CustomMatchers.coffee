'use strict'

toStartWith = (util, customEqualityTesters) ->
	compare: (actual, expected) ->
		if actual.length < expected.length
			pass: false
			message: "Expected at least #{expected.length} elements"
		else
			matching = expected.every (element, index) ->
				util.equals actual[index], element

			if matching
				pass: true
				message: "Expected #{actual} not to start with #{expected}"
			else
				pass: false
				message: "Expected #{actual} to start with #{expected}"


window.befTest ?= {}
window.befTest.CustomMatchers = { toStartWith }