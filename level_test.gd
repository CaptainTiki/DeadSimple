extends Node3D
class_name Level

@export var play_speed: float = 2.0
@onready var play_area: Node3D = $PlayArea

@onready var player: CharacterBody3D = %Player

func _physics_process(delta: float):
	if StateManager.is_paused:
		return
	
	# Scroll play area backward to simulate forward movement
	var current_speed = play_speed
	if Input.is_action_pressed("boost"):
		current_speed *= 1.5
	play_area.position.x += current_speed * delta
	
	# Clamp player to play area bounds
	var play_area_extents = Vector3(10, 5.5, 0.5)  # Half of BoxShape3D size (21, 12, 1)
	player.position.x = clamp(player.position.x, -play_area_extents.x, play_area_extents.x)
	player.position.y = clamp(player.position.y, -play_area_extents.y, play_area_extents.y)
