extends Node3D

@export var play_speed: float = 2.0

@onready var play_area: Node3D = $PlayArea
@onready var player: CharacterBody3D = $Player
@onready var camera: Camera3D = $Camera3D

func _physics_process(delta: float):
	if StateManager.is_paused():
		return
	
	# Scroll play area backward to simulate forward movement
	var current_speed = play_speed
	if Input.is_action_pressed("boost"):
		current_speed *= 1.5
	play_area.position.z -= current_speed * delta
	
	# Clamp player to screen bounds
	var viewport = get_viewport()
	var screen_size = viewport.get_visible_rect().size
	var left_edge = camera.unproject_position(Vector3(-5, 0, 0)).x  # Adjust bounds based on orthogonal size
	var right_edge = camera.unproject_position(Vector3(5, 0, 0)).x
	var bottom_edge = camera.unproject_position(Vector3(0, -3, 0)).y
	var top_edge = camera.unproject_position(Vector3(0, 3, 0)).y
	
	player.position.x = clamp(player.position.x, left_edge, right_edge)
	player.position.y = clamp(player.position.y, bottom_edge, top_edge)
