extends Node3D
class_name Level

@export var play_speed: float = 2.0
@onready var play_window: PlayWindow = $PlayWindow

@onready var player: CharacterBody3D = %Player
@onready var bullets_node: Node3D = $Bullets

const BULLET_ROUND = preload("uid://dwa0qhvaty8tj")


func _ready() -> void:
	PoolManager.register("BulletRound", BULLET_ROUND, bullets_node, 1000)

func _physics_process(delta: float):
	if StateManager.is_paused:
		return
	
	# Scroll play area backward to simulate forward movement
	var current_speed = play_speed
	if Input.is_action_pressed("boost"):
		current_speed *= 1.5
	play_window.position.x += current_speed * delta
	
	# Clamp player to play area bounds
	var play_area_extents = Vector3(10, 5.5, 0.5)  # Half of BoxShape3D size (21, 12, 1)
	player.position.x = clamp(player.position.x, -play_area_extents.x, play_area_extents.x)
	player.position.y = clamp(player.position.y, -play_area_extents.y, play_area_extents.y)
