extends Node
class_name StarManager
var MIN_DISTANCE = 15 # minimum distance between stars

var stars = []

func generate_stars(count: int, parent: Node, controller):
	var min_distance = MIN_DISTANCE 

	for i in count:
		var star = preload("res://scenes/star.tscn").instantiate()
		var position = Vector2.ZERO
		var attempts = 0
		while true:
			position = Vector2(
				randf_range(100, 1180),
				randf_range(100, 620)
			)
			var too_close = false
			for other in stars:
				if position.distance_to(other.position) < min_distance:
					too_close = true
					break
			attempts += 1
			if not too_close or attempts > 50:  # safety break to avoid infinite loops
				break

		star.position = position
		star.clicked.connect(controller.on_star_clicked)
		star.id = i
		star.used_in_constellation = false

		stars.append(star)
		parent.add_child(star)

func get_star_degree(star, connection_manager):
	var count = 0
	for other in stars:
		if other != star and connection_manager.are_connected(star, other):
			count += 1
	return count
