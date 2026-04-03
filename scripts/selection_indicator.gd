extends Node2D

var target_star : Node2D = null
var radius : float = 150
var color : Color = Color(0, 0.8, 1, 0.3)  # semi-transparent cyan

func _process(_delta):
	if target_star != null:
		global_position = target_star.global_position
	queue_redraw()  # <-- Godot 4 replacement for update()

func _draw():
	if target_star == null:
		return
	draw_circle(Vector2.ZERO, radius, color)
