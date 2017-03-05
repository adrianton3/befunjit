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

function execStats (command, count) {
	const times = []

	for (let i = 0; i < count; i++) {
		const buffer = execSync(command)
		times.push(extractTime(buffer))
	}

	const sum = times.reduce(
		(sum, time) => sum + time,
		0
	)

	const mean = sum / count

	const squareSum = times.reduce(
		(sum, time) => sum + (time - mean) ** 2,
		0
	)

	return {
		mean,
		deviation: Math.sqrt(squareSum / (count - 1))
	}
}

const compilers = [
	//'--basic',
	//'--optimizing',
	'--stacking',
	// '--binary'
]

const runtimes = [
	'--lazy',
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

	const stats = execStats(command, runs)

	console.log('done in ', stats, 'ms', '\n')

	return { args, stats }
})

fs.writeFileSync(
	path.join(__dirname, 'results.json'),
	JSON.stringify({
		runs,
		results
	})
)