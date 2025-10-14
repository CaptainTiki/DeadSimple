extends Area3D
class_name Enemy

@export var speed: float = 1.0
@export var damage: float = 20.0
@export var pause_delay: float = 0.0
var play_speed: float = 2.0  #we should get this from play_area - or spawner?
var state: String = "pause"
var pause_timer: float = 0.0

func _ready():
	pause_timer = pause_delay

func _physics_process(delta: float):
	if StateManager.is_paused:
		return
	
	if state == "pause":
		pause_timer -= delta
		position.x -= play_speed * delta  # Counter scroll
		if pause_timer <= 0:
			state = "move"
	else:  # "move"
		position.x -= speed * delta
		if position.x < -2.0:
			queue_free()

func _on_area_entered(area: Area3D):
	if area.is_in_group("bullet"):
		StateManager.game_data.score += 150
		StateManager.game_manager.update_hud()
		queue_free()
		area.queue_free()
	if area.is_in_group("playership"):
		if area.owner is PlayerShip:
			area.owner.take_damage(damage)
			StateManager.game_data.score += 200
			StateManager.game_manager.update_hud()
			queue_free()
