# res://weapons/weapon_basic.gd
extends Weapon

@export var bullet_type : String = "BulletRound"
@export var bullet_spread_angle : float = 5.0
@export var bullet_count : int = 100

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
	
	var rad_angle : float = deg_to_rad(bullet_spread_angle)
	var angle : float = -rad_angle * bullet_count * 0.5
	
	for i in bullet_count:
		var b : BulletBase = PoolManager.acquire("BulletRound") as BulletBase
		b._pool_setup()
		var origin: Vector3 = from_marker.global_transform.origin
		b.call("fire", origin, dir.rotated(Vector3(0,0,1),angle) * speed)
		angle += rad_angle
