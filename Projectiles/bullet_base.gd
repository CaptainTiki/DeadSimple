# res://Projectiles/Bullet.gd
extends Area3D
class_name BulletBase

@onready var play_window := get_tree().get_first_node_in_group("play_area") as PlayWindow

@export var lifetime: float = 10.0
@export var speed: float = 4.0
var velocity: Vector3 = Vector3.ZERO
var t: float = 0.0
var play: PlayWindow

func _ready() -> void:
	play = get_tree().get_first_node_in_group("play_area") as PlayWindow

func fire(origin: Vector3, vel: Vector3) -> void:
	_pool_setup()
	global_transform.origin = origin
	velocity = vel
	if play and not play.contains_point(global_transform.origin):
		despawn()

func _physics_process(delta: float) -> void:
	t += delta
	global_translate(velocity * delta)
	if t > lifetime or (play and not play.contains_point(global_transform.origin)):
		despawn()

##public function to release object
func despawn() -> void:
	_pool_release()

##function to setup after objectpool retrieval
func _pool_setup() -> void:
	visible = true
	monitorable= true
	t = 0.0
	set_physics_process(true)

##function to shut down node - prep for objectpool storage
func _pool_release() -> void:
	# clean & park
	set_physics_process(false)
	visible = false
	monitorable= false
	velocity = Vector3.ZERO
	rotation = Vector3.UP
	global_position = Vector3(-99999,-99999, -99999)
