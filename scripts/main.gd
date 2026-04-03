extends Node2D

@onready var star_field = $StarField
@onready var draw_layer = $DrawLayer
@onready var selection_indicator = $SelectionIndicator

@onready var star_manager = StarManager.new()
@onready var connection_manager = ConnectionManager.new()
@onready var matcher = PatternMatcher.new()

@onready var dragon = Dragon.new()
@onready var chalice = Chalice.new()

var selected_star = null

func _ready():
	add_child(star_manager)
	add_child(connection_manager)
	add_child(matcher)

	connection_manager.setup(draw_layer)
	connection_manager.connection_created.connect(_on_connection_created)

	star_manager.generate_stars(50, star_field, self)

func on_star_clicked(star):
	if selected_star == null:
		# No star selected yet — select this one
		selected_star = star
		$SelectionIndicator.target_star = star
		return
	
	# Clicking the same star deselects it
	if selected_star == star:
		selected_star = null
		$SelectionIndicator.target_star = null
		return
	
	# Enforce circular selection area
	var distance = selected_star.global_position.distance_to(star.global_position)
	if distance > $SelectionIndicator.radius:
		print("Star is too far! Must select within the circle.")
		return  # reject selection
	
	# Otherwise, valid selection — create connection
	connection_manager.try_create_connection(selected_star, star)
	selected_star = null
	$SelectionIndicator.target_star = null

func _on_connection_created(a, b):
	# DRAGON
	var dragons = dragon.find_from_edge(a, b, matcher, star_manager, connection_manager)
	for d in dragons:
		dragon.color(d, connection_manager)

	# CHALICE
	var chalices = chalice.find_from_edge(a, b, matcher, star_manager, connection_manager)
	for c in chalices:
		chalice.color(c, connection_manager)
