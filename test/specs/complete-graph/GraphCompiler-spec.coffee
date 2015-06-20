describe 'GraphCompiler', ->
	GraphCompiler = bef.GraphCompiler

	describe 'compile', ->
		compile = GraphCompiler.compile

		it 'compiles a circular graph', ->
			graph =
				start: 'a'
				nodes:
					a: [{ path: 'p1', to: 'b' }]
					b: [{ path: 'p2', to: 'a' }]

			console.log compile graph

		it 'compiles the minimal chain', ->
			graph =
				start: 'a'
				nodes:
					a: [{ path: 'p11', to: 'b' }, { path: 'p12', to: 'b' }]
					b: [{ path: 'p21', to: 'a' }, { path: 'p22', to: 'a' }]

			console.log compile graph