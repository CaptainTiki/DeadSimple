# res://weapons/weapon.gd
extends Node3D
class_name Weapon

@export var fire_rate: float = 8.0        # shots per second
@export var bullet_speed: float = 80.0    # units/sec (tune to your scale)
@export var pool_autoload_name: StringName = "BulletPool" # or "Pools" if yours differs

@onready var muzzles_root: Node3D = $Muzzles
var _cooldown: float = 0.0
var _trigger: bool = false

func set_trigger(pressed: bool, delta: float) -> void:
	_trigger = pressed
	_cooldown = max(0.0, _cooldown - delta)
	if _trigger and _cooldown <= 0.0:
		_cooldown = 1.0 / max(0.001, fire_rate)
		fire()  # implemented by child

func fire() -> void:
	pass

func _spawn_bullet(_from_marker: Marker3D, _dir: Vector3, _speed: float) -> void:
	pass
