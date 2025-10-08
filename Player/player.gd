extends CharacterBody3D

@export var move_speed: float = 5.0
@export var fire_rate: float = 0.2  # Seconds between shots

var bullet_scene = preload("res://Projectiles/bullet.tscn")
var time_since_last_shot: float = 0.0

func _physics_process(delta: float):
	if StateManager.is_paused:
		return
	
	# 2D movement input (Z locked)
	var input_dir = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_down", "move_up")  # Invert if up should be positive Y
	).normalized()
	
	velocity.x = input_dir.x * move_speed
	velocity.y = input_dir.y * move_speed
	velocity.z = 0  # Locked Z
	
	move_and_slide()
	
	# Handle firing
	time_since_last_shot += delta
	if Input.is_action_pressed("fire") and time_since_last_shot >= fire_rate:
		fire_bullet()
		time_since_last_shot = 0.0
	
	if Input.is_action_just_pressed("dodge"):
		print("Dodge!")  # Quick burst later

func fire_bullet():
	var bullet = bullet_scene.instantiate()
	# Add bullet to the play area (parent) to match coordinate space
	get_parent().add_child(bullet)
	# Position bullet slightly in front of player (negative Z)
	bullet.position = position + Vector3(1, 0, 0)
