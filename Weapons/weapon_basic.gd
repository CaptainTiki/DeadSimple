# res://weapons/weapon_basic.gd
extends Weapon

func set_trigger(pressed: bool, delta: float) -> void:
	_trigger = pressed
	_cooldown = max(0.0, _cooldown - delta)
	if _trigger and _cooldown <= 0.0:
		_cooldown = 1.0 / max(0.001, fire_rate)
		fire()  # implemented by child

func fire() -> void:
	for m in muzzles_root.get_children():
		if m is Marker3D:
			var forward: Vector3 = -(m as Marker3D).global_transform.basis.z
			_spawn_bullet(m, forward, bullet_speed)

func _spawn_bullet(from_marker: Marker3D, dir: Vector3, speed: float) -> void:
	var bullet: Node = PoolManager.acquire_bullet()
	if bullet == null:
		return
	var origin: Vector3 = from_marker.global_transform.origin
	bullet.call("fire", origin, dir.normalized() * speed)
