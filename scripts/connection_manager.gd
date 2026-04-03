extends Node
class_name ConnectionManager

signal connection_created(a, b)

var connections = {}
var draw_layer

func setup(layer):
	draw_layer = layer

func get_connection_key(id1, id2):
	var min_id = min(id1, id2)
	var max_id = max(id1, id2)
	return str(min_id) + "-" + str(max_id)

func try_create_connection(a, b):
	var key = get_connection_key(a.id, b.id)
	
	if connections.has(key):
		return
	
	var line = draw_line_between(a.position, b.position)
	connections[key] = line
	
	connection_created.emit(a, b)

func draw_line_between(p1: Vector2, p2: Vector2):
	var line = Line2D.new()
	line.points = [p1, p2]
	line.width = 2
	line.default_color = Color.WHITE
	draw_layer.add_child(line)
	return line

func are_connected(a, b):
	var key = get_connection_key(a.id, b.id)
	return connections.has(key)
