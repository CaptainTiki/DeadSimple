extends CharacterBody3D

@export var move_speed: float = 5.0

func _physics_process(delta: float):
	if StateManager.is_paused:
		return
	
	# 2D movement input (Z locked)
	var input_dir = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_down", "move_up")  # Invert if up should be positive Y
	).normalized()
	
	var boost_multiplier = 1.5 if Input.is_action_pressed("boost") else 1.0
	
	velocity.x = input_dir.x * move_speed * boost_multiplier
	velocity.y = input_dir.y * move_speed * boost_multiplier
	velocity.z = 0  # Locked Z
	
	move_and_slide()
	
	# Stub for fire and dodge
	if Input.is_action_just_pressed("fire"):
		print("Fire!")  # Instance bullet later
	if Input.is_action_just_pressed("dodge"):
		print("Dodge!")  # Quick burst later
