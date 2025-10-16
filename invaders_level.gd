extends Node3D
class_name InvadersLevel

@onready var player: PlayerShip = %Player
@onready var play_window: PlayWindow = $PlayWindow
@onready var bullets_node: Node3D = $Bullets

const BULLET_ROUND = preload("uid://dwa0qhvaty8tj")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PoolManager.register("BulletRound", BULLET_ROUND, bullets_node, 1000)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
