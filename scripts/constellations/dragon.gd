extends Node
class_name Dragon

# Find all dragon patterns that include the edge a-b
func find_from_edge(a, b, matcher, star_manager, connection_manager):
	var pattern_edges = [
		[0,1],[1,4],[1,5],[1,6],[1,7],
		[1,2],[2,3],[4,5],[6,7]
	]

	var matches = matcher.find_matches_from_edge(
		a, b, pattern_edges, 8,
		star_manager.stars,
		star_manager,
		connection_manager
	)

	var dragons = []
	for m in matches:
		# Skip any match where one of the stars is already used in another constellation
		var skip = false
		for star in m:
			if "used_in_constellation" in star and star.used_in_constellation:
				skip = true
				break
		if skip:
			continue
		
		dragons.append({
			"a": m[0], "b": m[1], "c": m[2], "d": m[3],
			"t1a": m[4], "t1b": m[5],
			"t2a": m[6], "t2b": m[7]
		})
	return dragons

# Color the matched dragon and mark stars as used
func color(dragon_data, connection_manager):
	var keys = [
		connection_manager.get_connection_key(dragon_data["a"].id, dragon_data["b"].id),
		connection_manager.get_connection_key(dragon_data["b"].id, dragon_data["c"].id),
		connection_manager.get_connection_key(dragon_data["c"].id, dragon_data["d"].id),
		connection_manager.get_connection_key(dragon_data["b"].id, dragon_data["t1a"].id),
		connection_manager.get_connection_key(dragon_data["b"].id, dragon_data["t1b"].id),
		connection_manager.get_connection_key(dragon_data["t1a"].id, dragon_data["t1b"].id),
		connection_manager.get_connection_key(dragon_data["b"].id, dragon_data["t2a"].id),
		connection_manager.get_connection_key(dragon_data["b"].id, dragon_data["t2b"].id),
		connection_manager.get_connection_key(dragon_data["t2a"].id, dragon_data["t2b"].id)
	]

	for k in keys:
		if connection_manager.connections.has(k):
			connection_manager.connections[k].default_color = Color.RED

	for star in dragon_data.values():
		star.self_modulate = Color.RED
		star.used_in_constellation = true
