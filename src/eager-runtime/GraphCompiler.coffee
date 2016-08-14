'use strict'

List = bef.List

# obsolete?
computeIndegree = (nodes) ->
	(Object.keys nodes).reduce (indegree, nodeName) ->
		nodes[nodeName].forEach (edge) ->
			to = edge.to
			if indegree.has to
				indegree.set to, (indegree.get to) + 1
			else
				indegree.set to, 1
		indegree
	, new Map


assemble = (graph, options) ->
	fastConditionals = options?.fastConditionals
	cycledNodes = new Set

	wrapIfLooping = (node, code) ->
		if cycledNodes.has node
			"""
				while (programState.isAlive()) _#{node}: {
					#{code}
				}
			"""
		else
			code


	df = (node, stack) ->
		# for debugging only
		return '' unless graph.nodes[node]?

		if (stack.find node)?
			cycledNodes.add node
			"break _#{node};"
		else
			neighbours = graph.nodes[node]

			# all nodes of a befunge program have 2 outgoing edges
			# except the initial node
			newStack = stack.con node

			switch neighbours.length
				when 4
					# only '?'
					branch0 = df neighbours[0].to, newStack
					branch1 = df neighbours[1].to, newStack
					branch2 = df neighbours[2].to, newStack
					branch3 = df neighbours[3].to, newStack

					randomCode = """
						#{if fastConditionals then 'programState.push(branchFlag);' else ''}
						var choice = programState.randInt(4);
						switch (choice) {
							case 0:
								#{neighbours[0].code}
								#{branch0}
								break;
							case 1:
								#{neighbours[1].code}
								#{branch1}
								break;
							case 2:
								#{neighbours[2].code}
								#{branch2}
								break;
							case 3:
								#{neighbours[3].code}
								#{branch3}
								break;
						}
					"""

					wrapIfLooping node, randomCode

				when 2
					conditionalChunk = if fastConditionals then 'branchFlag' else 'programState.pop()'

					if node == neighbours[0].to
						branch1 = df neighbours[1].to, newStack

						selectCode = """
							while (#{conditionalChunk}) {
								#{neighbours[0].code}
							}
							#{neighbours[1].code}
							#{branch1}
						"""
					else if node == neighbours[1].to
						branch0 = df neighbours[0].to, newStack

						selectCode = """
							while (!#{conditionalChunk}) {
								#{neighbours[1].code}
							}
							#{neighbours[0].code}
							#{branch0}
						"""
					else
						branch0 = df neighbours[0].to, newStack
						branch1 = df neighbours[1].to, newStack

						selectCode = """
							if (#{conditionalChunk}) {
								#{neighbours[0].code}
								#{branch0}
							} else {
								#{neighbours[1].code}
								#{branch1}
							}
						"""

					wrapIfLooping node, selectCode

				when 1
					branch = df neighbours[0].to, newStack

					edgeCode = """
						#{if fastConditionals then 'var branchFlag = 0' else ''}
						#{neighbours[0].code}
						#{branch}
					"""

					# this might not be necessary if only
					# the starting node can have a single neighbour
					wrapIfLooping node, edgeCode

				when 0
					'return;'

	df graph.start, List.EMPTY


GraphCompiler =
	assemble: assemble


window.bef ?= {}
window.bef.GraphCompiler = GraphCompiler