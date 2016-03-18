'use strict'


{
	Path
	ProgramState
	BasicCompiler
	OptimizingCompiler
	StackingCompiler
} = bef


generateCommand = do ->
	commands = '0123456789+-*/%!`:\\$.,pg' # ~&

	->
		commands[Math.floor Math.random() * commands.length]


generateCode = (length) ->
	(
		generateCommand() for i in [0...length]
	).join('')


getPath = (string) ->
	path = new Path()
	stringMode = false
	(string.split '').forEach (char) ->
		if char == '"'
			stringMode = !stringMode
			path.push 0, 0, '>', char, false
		else
			path.push 0, 0, '>', char, stringMode
		return
	path


getProgramState = (input = [], pathInvalidatedAhead) ->
	programState = new ProgramState()
	programState.setInput input
	programState.flags.pathInvalidatedAhead = pathInvalidatedAhead

	programState.put = ->
	programState.get = -> 55

	programState


makeExecute = (compiler) ->
	(code, input, pathInvalidatedAhead) ->
		path = getPath code
		compiler.compile path

		programState = getProgramState input, pathInvalidatedAhead
		path.body programState

		programState


arraysEqual = (a, b) ->
	return false if a.length != b.length

	for i in [0...a.length]
		return false unless Object.is a[i], b[i]

	true


runSpec = (spec, executeList) ->
	{ code, input, pathInvalidatedAhead } = spec

	execute = executeList[0]
	firstResult = execute code, input, pathInvalidatedAhead

	(executeList.slice 1).forEach (execute, index) ->
		result = execute code, input, pathInvalidatedAhead

		if not arraysEqual firstResult.outRecord, result.outRecord
			throw new Error """
				outRecords do not match
				#{index}
				#{code}
				#{firstResult.outRecord} #{result.outRecord}"
			"""

		if not arraysEqual firstResult.stack, result.stack
			throw new Error """
				stacks do not match
				#{index}
				#{code}
				#{firstResult.stack} #{result.stack}"
			"""

		return
	return


runAll = (count) ->
	executeList = [
		BasicCompiler
		OptimizingCompiler
		StackingCompiler
	].map makeExecute

	for i in [0...count]
		spec = {
			code: generateCode 15
			input: []
			pathInvalidatedAhead: Math.random() < 0.5
		}

		runSpec spec, executeList
		console.log spec.code

	return


runAll 100