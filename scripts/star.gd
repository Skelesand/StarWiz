extends Area2D
class_name Star

signal clicked(star)

# Unique identifier for the star
var id: int = -1
# Whether this star has been used in a constellation
var used_in_constellation: bool = false

func _ready():
	input_pickable = true

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("clicked", self)
