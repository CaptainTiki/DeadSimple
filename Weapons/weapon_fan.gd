# res://weapons/weapon_fan.gd
extends Weapon

@export var fan_count: int = 5
@export var fan_spread_deg: float = 40.0    # total arc
@export var extra_rate_scale: float = 2.0   # crank ROF

func set_trigger(pressed: bool, delta: float) -> void:
	# faster than normal to stress the pool
	_trigger = pressed
	_cooldown = max(0.0, _cooldown - delta * extra_rate_scale)
	if _trigger and _cooldown <= 0.0:
		_cooldown = 1.0 / max(0.001, fire_rate * extra_rate_scale)
		fire()

func fire() -> void:
	for m in muzzles_root.get_children():
		if m is Marker3D:
			var muzzle: Marker3D = m
			var base_forward: Vector3 = -muzzle.global_transform.basis.z
			# Build a fan by rotating around the up axis
			var up: Vector3 = muzzle.global_transform.basis.x
			var rays : int = max(1, fan_count)
			var half_spread_rad := deg_to_rad(fan_spread_deg) * 0.5
			for i in rays:
				var t := 0.0 if rays == 1 else float(i) / float(rays - 1)
				var angle : float = lerp(-half_spread_rad, half_spread_rad, t)
				var rotated: Vector3 = base_forward.rotated(up, angle).normalized()
				_spawn_bullet(muzzle, rotated, bullet_speed)

func _spawn_bullet(from_marker: Marker3D, dir: Vector3, speed: float) -> void:
	var bullet: Node = PoolManager.acquire_bullet()
	if bullet == null:
		return
	# Forward in Godot 3D is usually -Z; use marker’s basis for direction
	var origin: Vector3 = from_marker.global_transform.origin
	bullet.call("fire", origin, dir.normalized() * speed)
