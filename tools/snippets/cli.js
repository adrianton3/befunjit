(function () {
	'use strict'

	function processArguments (argv) {
		if (argv.length < 3 || argv.length > 7) {
			console.error([
				'Use: node befunjit.node.js [--lazy]',
				' [--stacking|--optimizing|--basic]',
				' [--time] [--no-input]',
				' <source>'
			].join('\n'))

			process.exit(1)
		}

		const options = new Set(argv.slice(2, argv.length - 1))

		return {
			sourcePath: argv[argv.length - 1],
			noInput: options.has('--no-input'),
			time: options.has('--time'),
			runtimeConstructor: options.has('--lazy') ? bef.LazyRuntime : bef.EagerRuntime,
			compiler: options.has('--stacking') ? bef.StackingCompiler
				: options.has('--optimizing') ? bef.OptimizingCompiler
				: options.has('--basic') ? bef.BasicCompiler
				: bef.BinaryCompiler
		}
	}

	function setupStdin (ready) {
		let input = ''

		process.stdin.setEncoding('utf8')

		process.stdin.on('readable', () => {
			const chunk = process.stdin.read()

			if (chunk !== null) {
				input += chunk
			}
		})

		process.stdin.on('end', () => {
			ready(input)
		})
	}

	function run (runtimeConstructor, compiler, source, input) {
		const playfield = new bef.Playfield()
		playfield.fromString(source)

		const runtime = new runtimeConstructor
		runtime.execute(
			playfield,
			{ compiler, jumpLimit: Infinity },
			input
		)

		return runtime.programState.outRecord.join('')
	}

	if (require.main === module) {
		const fs = require('fs')

		const args = processArguments(process.argv)

		const launch = function (input) {
			const source = fs.readFileSync(args.sourcePath).toString()

			let start
			if (args.time) {
				start = process.hrtime()
			}

			const output = run(args.runtimeConstructor, args.compiler, source, input)

			if (args.time) {
				const diff = process.hrtime(start)
				process.stdout.write(`execution took ${diff[0] * 1e9 + diff[1]}ns`)
			} else {
				process.stdout.write(output)
			}
		}

		if (args.noInput) {
			launch('')
		} else {
			setupStdin(launch)
		}
	} else {
		module.exports = bef
	}
})()