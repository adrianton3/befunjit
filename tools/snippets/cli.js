(function () {
	'use strict';


	function processArguments(argv) {
		if (argv.length < 3 || argv.length > 6) {
			console.error('Use: node befunjit.node.js [--lazy] [--stacking|--optimizing|--basic] [--time] <source>');
			process.exit(1);
		}

		const options = new Set(argv.slice(2, argv.length - 1));

		return {
			sourcePath: argv[argv.length - 1],
			time: options.has('--time'),
			runtimeConstructor: options.has('--lazy') ? bef.LazyRuntime : bef.EagerRuntime,
			compiler: options.has('--stacking') ? bef.StackingCompiler
				: options.has('--optimizing') ? bef.OptimizingCompiler
				: options.has('--basic') ? bef.BasicCompiler
				: bef.BinaryCompiler
		};
	}

	function setupStdin(ready) {
		var input = '';

		process.stdin.setEncoding('utf8');

		process.stdin.on('readable', function () {
			var chunk = process.stdin.read();

			if (chunk !== null) {
				input += chunk;
			}
		});

		process.stdin.on('end', function () {
			ready(input);
		});
	}

	function run(runtimeConstructor, compiler, source, input) {
		var playfield = new bef.Playfield();
		playfield.fromString(source);

		var runtime = new runtimeConstructor;
		runtime.execute(playfield, { jumpLimit: Infinity, compiler: compiler }, input);

		return runtime.programState.outRecord.join('');
	}


	if (require.main === module) {
		var fs = require('fs');

		var args = processArguments(process.argv);

		setupStdin(function (input) {
			var source = fs.readFileSync(args.sourcePath).toString();

			var start;
			if (args.time) {
				start = process.hrtime();
			}

			var output = run(args.runtimeConstructor, args.compiler, source, input);

			if (args.time) {
				var diff = process.hrtime(start);
				process.stdout.write('execution took ' + (diff[0] * 1e9 + diff[1]) + 'ns');
			} else {
				process.stdout.write(output);
			}
		})
	} else {
		module.exports = bef;
	}
})();