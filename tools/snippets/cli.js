(function () {
	'use strict';


	function processArguments(argv) {
		if (argv.length < 3 || argv.length > 5) {
			console.error('Use: node befunjit.node.js [--lazy] [--time] <source>');
			process.exit(1);
		}

		if (argv.length === 3) {
			return {
				runtimeConstructor: bef.EagerRuntime,
				sourcePath: argv[2],
				time: false
			}
		} else if (argv.length === 4) {
			return {
				runtimeConstructor: argv[2] === '--lazy' ? bef.LazyRuntime : bef.EagerRuntime,
				sourcePath: argv[3],
				time: argv[2] === '--time'
			}
		} else {
			return {
				runtimeConstructor: (argv[2] === '--lazy') || (argv[3] === '--lazy') ?
					bef.LazyRuntime :
					bef.EagerRuntime,
				sourcePath: argv[4],
				time: (argv[2] === '--time') || (argv[3] === '--time')
			}
		}
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

	function run(runtimeConstructor, source, input) {
		var playfield = new bef.Playfield();
		playfield.fromString(source);

		var runtime = new runtimeConstructor;
		//runtime.execute(playfield, { jumpLimit: Infinity, compiler: bef.BasicCompiler }, input);
		//runtime.execute(playfield, { jumpLimit: Infinity, compiler: bef.OptimizingCompiler }, input);
		//runtime.execute(playfield, { jumpLimit: Infinity, compiler: bef.StackingCompiler }, input);
		runtime.execute(playfield, { jumpLimit: Infinity, compiler: bef.BinaryCompiler }, input);

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

			var output = run(args.runtimeConstructor, source, input);

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