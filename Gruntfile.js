module.exports = function (grunt) {
	'use strict';

	grunt.initConfig({
		coffee: {
			all: {
				files: {
					'build/befunjit.browser.js': ['src/**/*.coffee']
				}
			}
		},
		concat: {
			all: {
				src: [
					'tools/snippets/header.js',
					'build/befunjit.browser.js',
					'tools/snippets/cli.js',
					'tools/snippets/footer.js'
				],
				dest: 'build/befunjit.node.js'
			}
		}
	});

	grunt.loadNpmTasks('grunt-contrib-coffee');
	grunt.loadNpmTasks('grunt-contrib-concat');

	grunt.registerTask('default', [
		'coffee',
		'concat'
	]);
};