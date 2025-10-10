# res://Projectiles/Bullet.gd
extends Area3D
class_name BulletBase

@onready var play_window := get_tree().get_first_node_in_group("play_area") as PlayWindow

@export var lifetime: float = 40.0
@export var speed: float = 10.0
var velocity: Vector3 = Vector3.ZERO
var t: float = 0.0
var play: PlayWindow

func _ready() -> void:
	play = get_tree().get_first_node_in_group("play_area") as PlayWindow

func fire(origin: Vector3, vel: Vector3) -> void:
	global_transform.origin = origin
	velocity = vel
	t = 0.0
	visible = true
	monitoring = true
	set_physics_process(true)
	if play and not play.contains_point(global_transform.origin):
		_despawn()

func _physics_process(delta: float) -> void:
	t += delta
	global_translate(velocity * delta)
	if t > lifetime or (play and not play.contains_point(global_transform.origin)):
		_despawn()

func reset_for_pool() -> void:
	velocity = Vector3.ZERO
	rotation = Vector3.UP
	global_position = Vector3(-99999,-99999, -99999)

func _despawn() -> void:
	monitoring = false
	set_physics_process(false)
	visible = false
	PoolManager.release(self)
