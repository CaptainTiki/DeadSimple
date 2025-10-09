# res://Projectiles/Bullet.gd
extends Area3D
class_name Bullet

@export var speed: float = 10.0
var vel := Vector3.ZERO

func reset_for_pool() -> void:
	vel = Vector3.ZERO
	rotation = Vector3.UP
	global_position = Vector3(-99999,-99999, -99999)

func fire(origin: Vector3, velocity: Vector3) -> void:
	global_position = origin
	vel = velocity
	visible = true
	set_physics_process(true)
	if has_method("set_monitoring"):
		set("monitoring", true)

func _physics_process(dt: float) -> void:
	global_position += vel * dt
	# simple offscreen cull with a gutter
	var cam := get_viewport().get_camera_2d()
	if cam:
		var dx : float = abs(global_position.x - cam.global_position.x)
		var dy : float = abs(global_position.y - cam.global_position.y)
		if dx > 1200.0 or dy > 800.0:
			_despawn()

func _on_body_entered(_b: Node) -> void:
	_despawn()

func _on_area_entered(area: Area3D) -> void:
	print("bullet entered: ", area.name)
	if area.is_in_group("destruction_area"):
		_despawn()

func _despawn() -> void:
	PoolManager.release(self)
