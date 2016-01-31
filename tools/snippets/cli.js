(function () {
	'use strict';


	function processArguments(argv) {
		if (argv.length < 3 || argv.length > 4) {
			console.error('Use: node befunjit.node.js [--lazy] <source>');
			process.exit(1);
		}

		if (argv.length === 3) {
			return {
				runtimeConstructor: bef.EagerRuntime,
				sourcePath: argv[2]
			}
		} else {
			return {
				runtimeConstructor: argv[2] === '--lazy' ? bef.LazyRuntime : bef.EagerRuntime,
				sourcePath: argv[3]
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
		runtime.execute(playfield, { jumpLimit: 1000 }, input);

		return runtime.programState.outRecord.join('');
	}


	if (require.main === module) {
		var fs = require('fs');

		var args = processArguments(process.argv);

		setupStdin(function (input) {
			var source = fs.readFileSync(args.sourcePath).toString();

			var output = run(args.runtimeConstructor, source, input);

			process.stdout.write(output);
		})
	} else {
		module.exports = bef;
	}
})();