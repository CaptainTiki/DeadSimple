extends Node
class_name GameManager

#Menus
@onready var pause_menu: Control = %PauseMenu
@onready var score_sheet: Control = %ScoreSheet
@onready var hud: Control = %HUD

#ShipStatsPanel
@onready var health_bar: ProgressBar = %HealthBar
@onready var shields_bar: ProgressBar = %ShieldsBar
@onready var power_bar: ProgressBar = %PowerBar

#ScorePanel
@onready var time_label: Label = %TimeLabel
@onready var score_label: Label = %ScoreLabel

#DebugPanel
@onready var debug_screen: Control = $CanvasLayer/DebugScreen
@onready var bullet_count_lable: Label = $CanvasLayer/DebugScreen/PanelContainer/VBoxContainer/HBoxContainer/BulletCountLabel

var level: PackedScene = preload("res://level_test.tscn") #TODO: need to setup way to pass which level to load here
var current_level: Level = null
var level_time: float = 0.0
var player_instance: PlayerShip = null

func _ready():
	# Setup pause menu
	pause_menu.visible = false
	score_sheet.visible = false
	hud.visible = false
	health_bar.max_value = 3.0
	health_bar.value = 3.0
	shields_bar.max_value = 100.0
	shields_bar.value = 100.0
	power_bar.max_value = 100.0
	power_bar.value = 0.0  # Not implemented yet
	StateManager.connect("pause_toggled", _on_pause_toggled)
	StateManager.connect("state_changed", _on_state_changed)

func clean():
	if current_level:
		current_level.queue_free()
		current_level = null
	pause_menu.visible = false
	score_sheet.visible = false
	hud.visible = false
	level_time = 0.0
	player_instance = null

func Setup():
	hud.visible = true
	current_level = level.instantiate() as Level
	add_child(current_level)
	StateManager.game_data.score = 0
	player_instance = current_level.player
	setup_hud()

func _process(delta: float):
	if StateManager.current_state == StateManager.State.PLAY and not StateManager.is_paused:
		level_time += delta
		time_label.text = "Time: %.1fs" % level_time  # Update time separately
		_run_debug(delta)

func setup_hud()-> void:
	if player_instance:
		health_bar.value = player_instance.max_health
		health_bar.max_value = player_instance.max_health
		shields_bar.value = player_instance.max_shields
		shields_bar.max_value = player_instance.max_shields
		player_instance.damage_taken.connect(update_hud)  # Connect signal for damage updates
		update_hud()

func update_hud():
	if player_instance:
		health_bar.value = player_instance.current_health
		shields_bar.value = player_instance.current_shields
		power_bar.value = 0.0  # Placeholder until power implemented
	score_label.text = "Score: %d" % StateManager.game_data.score

func _input(event):
	if StateManager.get_current_state() == StateManager.State.PLAY and event.is_action_pressed("ui_cancel"):
		StateManager.toggle_pause()

func pop_ScoreSheet() -> void:
	score_sheet.visible = true
	update_hud()  # Final update on death

func _on_pause_toggled(is_paused: bool):
	pause_menu.visible = is_paused

func _on_state_changed(new_state: StateManager.State):
	if new_state != StateManager.State.PLAY:
		clean()

func _on_resume_pressed():
	pause_menu.visible = false
	StateManager.toggle_pause()

func _on_quit_to_menu_pressed():
	StateManager.unpause() #force unpause - no matter what state. 
	StateManager.set_state(StateManager.State.MENU)


######DEBUG######
func _run_debug(_delta: float) -> void:
	var active := 0
	for b in current_level.bullets_node.get_children():
		if b.visible:
			active += 1
	bullet_count_lable.text = str(active)
