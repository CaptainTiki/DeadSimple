extends Node3D
class_name InvadersLevel

@onready var player: PlayerShip = %Player
@onready var play_window: PlayWindow = $PlayWindow
@onready var bullets_node: Node3D = $Bullets
@onready var formation: FormationController = $FormationController

const BULLET_ROUND = preload("uid://dwa0qhvaty8tj")

var score: int = 0
var level_time: float = 0.0

func _ready() -> void:
	PoolManager.register("BulletRound", BULLET_ROUND, bullets_node, 1000)
	player.configure_roll_profile(0)
	formation.wave_docked.connect(_on_wave_docked)
	formation.setup_formation()
	formation.start_wave()

func _physics_process(_delta: float) -> void:
	var play_area_extents: Vector3 = Vector3(10, 5.5, 0.5)
	player.position.x = clamp(player.position.x, -play_area_extents.x, play_area_extents.x)
	player.position.y = clamp(player.position.y, -play_area_extents.y, play_area_extents.y)

func _on_wave_docked() -> void:
	pass  # Ready to play; add gameplay logic here if needed
