extends Area3D

@export var friction: float = 5.0
var velocity: Vector3 = Vector3.ZERO
var angular_velocity: Vector3

func _ready():
	# Set random angular velocity for each axis (radians per second)
	angular_velocity = Vector3(
		randf_range(0.1, 0.3) * (1 if randi() % 2 == 0 else -1),
		randf_range(0.1, 0.3) * (1 if randi() % 2 == 0 else -1),
		randf_range(0.1, 0.3) * (1 if randi() % 2 == 0 else -1)
	)

func _physics_process(delta: float):
	if StateManager.is_paused:
		return
	
	# Apply sliding velocity
	if velocity != Vector3.ZERO:
		position += velocity * delta
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
	
	# Apply rotation
	rotate_x(angular_velocity.x * delta)
	rotate_y(angular_velocity.y * delta)
	rotate_z(angular_velocity.z * delta)

func _on_area_entered(area: Area3D):
	if area.is_in_group("player_bullet"):
		StateManager.current_manager.current_level.score += 100  # Increment score
		StateManager.current_manager.update_hud()  # Update HUD
		queue_free()
		if area is BulletBase:
			area.despawn()
