extends Node
class_name PatternMatcher

func _build_pattern_neighbors(node_count, pattern_edges):
	var neighbors = []
	for i in range(node_count):
		neighbors.append([])
	for edge in pattern_edges:
		var u = edge[0]
		var v = edge[1]
		neighbors[u].append(v)
		neighbors[v].append(u)
	return neighbors

func _order_pattern_nodes_by_degree(pattern_neighbors):
	var order = []
	for i in range(pattern_neighbors.size()):
		var deg = pattern_neighbors[i].size()
		var inserted = false
		for j in range(order.size()):
			var other = order[j]
			var other_deg = pattern_neighbors[other].size()
			if deg > other_deg or (deg == other_deg and i < other):
				order.insert(j, i)
				inserted = true
				break
		if not inserted:
			order.append(i)
	return order

func _pattern_node_consistent(pattern_index, candidate, assignment, pattern_neighbors, connection_manager):
	for neighbor_index in pattern_neighbors[pattern_index]:
		var assigned = assignment[neighbor_index]
		if assigned != null and not connection_manager.are_connected(candidate, assigned):
			return false
	return true

func _copy_assignment(assignment):
	var copy = []
	for s in assignment:
		copy.append(s)
	return copy

func _assign_next(order, depth, pattern_neighbors, assignment, used_ids, matches, seen_signatures, stars, star_manager, connection_manager):
	if depth >= order.size():
		var signature_ids = []
		for s in assignment:
			signature_ids.append(s.id)
		signature_ids.sort()
		var signature = ""
		for id in signature_ids:
			signature += str(id) + ":"
		if seen_signatures.has(signature):
			return
		seen_signatures[signature] = true
		matches.append(_copy_assignment(assignment))
		return

	var pattern_index = order[depth]
	if assignment[pattern_index] != null:
		_assign_next(order, depth + 1, pattern_neighbors, assignment, used_ids, matches, seen_signatures, stars, star_manager, connection_manager)
		return

	for star in stars:
		# Skip stars already used in a constellation
		if star.used_in_constellation:
			continue

		if used_ids.has(star.id):
			continue
		if star_manager.get_star_degree(star, connection_manager) < pattern_neighbors[pattern_index].size():
			continue
		if not _pattern_node_consistent(pattern_index, star, assignment, pattern_neighbors, connection_manager):
			continue

		assignment[pattern_index] = star
		used_ids[star.id] = true
		_assign_next(order, depth + 1, pattern_neighbors, assignment, used_ids, matches, seen_signatures, stars, star_manager, connection_manager)
		assignment[pattern_index] = null
		used_ids.erase(star.id)

func find_matches_from_edge(a, b, pattern_edges, node_count, stars, star_manager, connection_manager):
	var matches = []
	var pattern_neighbors = _build_pattern_neighbors(node_count, pattern_edges)
	var order = _order_pattern_nodes_by_degree(pattern_neighbors)
	var assignment = []
	for i in range(node_count):
		assignment.append(null)
	var used_ids = {}
	var seen_signatures = {}

	# DOUBLE ITERATION OVER ALL EDGES AND DIRECTIONS (like original)
	for edge in pattern_edges:
		var u = edge[0]
		var v = edge[1]
		for dir in [[u, v], [v, u]]:
			assignment[dir[0]] = a
			assignment[dir[1]] = b
			used_ids[a.id] = true
			used_ids[b.id] = true

			_assign_next(order, 0, pattern_neighbors, assignment, used_ids, matches, seen_signatures, stars, star_manager, connection_manager)

			assignment[dir[0]] = null
			assignment[dir[1]] = null
			used_ids.erase(a.id)
			used_ids.erase(b.id)

	return matches
