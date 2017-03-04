'use strict'

const fs = require('fs')
const path = require('path')

const { execSync } = require('child_process')

function generateProduct (arrays) {
	const solutions = []

	function recurse (partial, k) {
		if (k >= arrays.length) {
			solutions.push(partial)
		} else {
			const array = arrays[k]

			array.forEach((entry) => {
				recurse([...partial, entry], k + 1)
			})
		}
	}

	recurse([], 0)

	return solutions
}

function extractTime (buffer) {
	const string = buffer.toString()
	const extract = string.match(/\d+/)[0]
	return extract / 1e6
}

function execAverage (command, count) {
	let sum = 0

	for (let i = 0; i < count; i++) {
		const buffer = execSync(command)
		sum += extractTime(buffer)
	}

	return sum / count
}

const compilers = [
	//'--basic',
	//'--optimizing',
	'--stacking',
	'--binary'
]

const runtimes = [
	//'--lazy',
	'--eager'
]

const scripts = [
	'count-up.bef',
	'count-up-extra.bef',
	'count-down.bef',
	'count-up-put-get.bef',
	'count-up-mutate.bef',
].map((name) => path.join(__dirname, 'scripts', name))

const runs = 10

const argSet = generateProduct([compilers, runtimes, scripts])

const results = argSet.map((args) => {
	const befunjit = path.join(__dirname, '..', '..', 'build/befunjit.node.js')
	const command = `node ${befunjit} --no-input --time ${args.join(' ')}`

	console.log(
		'Executing',
		...args.slice(0, -1),
		path.parse(args[args.length - 1]).base
	)

	const time = execAverage(command, runs)

	console.log('done in ', time, 'ms', '\n')

	return { args, time }
})

fs.writeFileSync(
	path.join(__dirname, 'results.json'),
	JSON.stringify(results)
)