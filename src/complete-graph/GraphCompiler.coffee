'use strict'

List = bef.List

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


compile = (graph) ->
	indegree = computeIndegree graph.nodes

	df = (node, stack) ->
		if (stack.find node)?
			"break _#{node};"
		else
			neighbours = graph.nodes[node]

			switch neighbours.length
				when 2
					newStack = stack.con node
					branch1 = df neighbours[0].to, newStack
					branch2 = df neighbours[1].to, newStack

					"""
						while (runtime.isAlive()) _#{node}: {
							if (runtime.pop()) {
								#{neighbours[0].path};
								#{branch1}
							} else {
								#{neighbours[1].path};
								#{branch2}
							}
						}
					"""
				when 1
					newStack = stack.con node
					branch = df neighbours[0].to, newStack

					"""
						while (runtime.isAlive()) _#{node}: {
							#{neighbours[0].path};
							#{branch}
						}
					"""
				when 0
					'runtime.exit(); return;'

	df graph.start, List.EMPTY


GraphCompiler =
	compile: compile


window.bef ?= {}
window.bef.GraphCompiler = GraphCompiler