(function () {
	'use strict';

	var fs = require('fs');

	if (process.argv.length < 2) {
		console.error('Must supply source');
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

	function run(source, input) {
		var playfield = new bef.Playfield();
		playfield.fromString(source);

		var runtime = new bef.LazyRuntime();
		runtime.execute(playfield, { jumpLimit: 100 }, input);

		return runtime.programState.outRecord.join('');
	}

	setupStdin(function (input) {
		var sourcePath = process.argv[2];
		var source = fs.readFileSync(sourcePath).toString();

		var output = run(source, input);

		process.stdout.write(output);
	})
})();