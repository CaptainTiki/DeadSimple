extends Area3D
class_name PathingEnemy

@export var speed: float = 1
@export var damage: float = 20.0
@export var pause_delay: float = 0.0
var play_speed: float = 2.0  # Match Level.play_speed
var state: String = "pause"
var pause_timer: float = 0.0
var show_path_in_game: bool = false

func _ready():
	pause_timer = pause_delay
	var level = get_tree().current_scene
	if level is Level:
		play_speed = level.play_speed
	if get_parent() and get_parent() is PathFollow3D:
		get_parent().visible = show_path_in_game  # Show path if toggled
		print("Parent PathFollow3D: ", get_parent().progress)

func _physics_process(delta: float):
	if StateManager.is_paused:
		return
	
	if state == "pause":
		pause_timer -= delta
		if pause_timer <= 0:
			state = "path"
			print("Switched to path state")
	else:  # "path"
		if get_parent() is PathFollow3D:
			get_parent().progress += speed * delta
			print("Progress: ", get_parent().progress, " Position: ", global_position)
		#if global_position.x < -2.0:
			#queue_free()

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

func _input(event):
	if event.is_action_pressed("ui_accept"):  # Toggle path with Enter key
		show_path_in_game = !show_path_in_game
		if get_parent() and get_parent() is PathFollow3D and get_parent().get_parent() is Path3D:
			get_parent().get_parent().visible = show_path_in_game
