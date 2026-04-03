extends Node
class_name Chalice

func _get_distance(a, b):
	return a.position.distance_to(b.position)

func _check_dist(m):
	if _get_distance(m[0], m[6]) <= _get_distance(m[1], m[3]):
		return false
	if _get_distance(m[2], m[4]) <= _get_distance(m[1], m[3]):
		return false
	if _get_distance(m[2], m[5]) <= _get_distance(m[2], m[4]):
		return false
	if _get_distance(m[0], m[7]) <= _get_distance(m[0], m[6]):
		return false
	return true

# Find challices using edge a-b
func find_from_edge(a, b, matcher, star_manager, connection_manager):
	var pattern_edges = [
		[0,1],[1,2],[1,3],[3,6],
		[6,7],[3,4],[4,5]
	]

	var matches = matcher.find_matches_from_edge(
		a, b, pattern_edges, 8,
		star_manager.stars,
		star_manager,
		connection_manager
	)

	var result = []
	for m in matches:
		# Skip any match where one of the stars is already used
		var skip = false
		for star in m:
			if star.used_in_constellation:
				skip = true
				break
		if skip:
			continue

		if _check_dist(m):
			result.append({
				"n0": m[0], "n1": m[1], "n2": m[2], "n3": m[3],
				"n4": m[4], "n5": m[5], "n6": m[6], "n7": m[7]
			})
	return result

# Color a chalice and mark stars as used
func color(c, connection_manager):
	var keys = [
		connection_manager.get_connection_key(c["n0"].id, c["n1"].id),
		connection_manager.get_connection_key(c["n1"].id, c["n2"].id),
		connection_manager.get_connection_key(c["n1"].id, c["n3"].id),
		connection_manager.get_connection_key(c["n3"].id, c["n6"].id),
		connection_manager.get_connection_key(c["n6"].id, c["n7"].id),
		connection_manager.get_connection_key(c["n3"].id, c["n4"].id),
		connection_manager.get_connection_key(c["n4"].id, c["n5"].id)
	]

	for k in keys:
		if connection_manager.connections.has(k):
			connection_manager.connections[k].default_color = Color8(128, 0, 128)

	for s in c.values():
		s.self_modulate = Color8(128, 0, 128)
		s.used_in_constellation = true  # <-- mark as used
