extends Area3D

@export var health: int = 2
var asteroid_scene = preload("res://Objects/Obstacles/Rock.tscn")
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
	
	# Apply rotation
	rotate_x(angular_velocity.x * delta)
	rotate_y(angular_velocity.y * delta)
	rotate_z(angular_velocity.z * delta)

func _on_area_entered(area: Area3D):
	if area.is_in_group("player_bullet"):
		health -= 1
		if area is Bullet:
			area._despawn()
		if health <= 0:
			spawn_small_asteroids()
			StateManager.game_data.score += 200  # Increment score for large rock
			StateManager.game_manager.update_hud()  # Update HUD
			queue_free()

func spawn_small_asteroids():
	var num = randi_range(2, 3)
	for i in num:
		var small = asteroid_scene.instantiate()
		get_parent().add_child(small)
		small.position = position
		var random_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		small.velocity = Vector3(random_dir.x, random_dir.y, 0) * randf_range(3.0, 6.0)
