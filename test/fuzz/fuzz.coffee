'use strict'


{
	Path
	ProgramState
	BasicCompiler
	OptimizingCompiler
	StackingCompiler
	BinaryCompiler
} = bef


generateCommand = do ->
	commands = '0123456789+-*/%!`:\\$.,g' # ~&

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


getProgramState = (input = []) ->
	programState = new ProgramState()
	programState.setInput input

	programState.put = ->
	programState.get = -> 55

	programState


compile = (compiler, path) ->
	code ="""
			stack = programState.stack;
			#{compiler.assemble path}
		"""
	path.code = code
	path.body = new Function 'programState', code


makeExecute = (compiler) ->
	(code, input) ->
		path = getPath code
		compile compiler, path

		programState = getProgramState input
		path.body programState

		programState


arraysEqual = (a, b) ->
	return false if a.length != b.length

	a.every (elementA, i) ->
		elementB = b[i]
		elementA == elementB or ((isNaN elementA) and (isNaN elementB))


runSpec = ({ code, input }, executeList) ->
	execute = executeList[0]
	firstResult = execute code, input

	(executeList.slice 1).forEach (execute, index) ->
		result = execute code, input

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


randInt = (min, max) ->
	min + Math.floor Math.random() * (max - min + 1)


runAll = (count) ->
	executeList = [
		BasicCompiler
		OptimizingCompiler
		StackingCompiler
		BinaryCompiler
	].map makeExecute

	for i in [0...count]
		spec = {
			code: generateCode randInt 1, 20
			input: []
		}

		console.log 'running', spec.code
		runSpec spec, executeList

	return


runAll 100