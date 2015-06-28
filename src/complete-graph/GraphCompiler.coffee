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


assemble = (graph) ->
	cycledNodes = new Set

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
				when 2
					branch1 = df neighbours[0].to, newStack
					branch2 = df neighbours[1].to, newStack

					selectCode = """
						if (runtime.pop()) {
							#{neighbours[0].code}
							#{branch1}
						} else {
							#{neighbours[1].code}
							#{branch2}
						}
					"""

					if cycledNodes.has node
						"""
							while (runtime.isAlive()) _#{node}: {
								#{selectCode}
							}
						"""
					else
						selectCode
				when 1
					branch = df neighbours[0].to, newStack

					edgeCode = """
						#{neighbours[0].code}
						#{branch}
					"""

					if cycledNodes.has node
						"""
							while (runtime.isAlive()) _#{node}: {
								#{edgeCode}
							}
						"""
					else
						edgeCode

	df graph.start, List.EMPTY


GraphCompiler =
	assemble: assemble


window.bef ?= {}
window.bef.GraphCompiler = GraphCompiler