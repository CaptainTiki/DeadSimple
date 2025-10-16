extends Node
class_name InvadersManager

#Menus
@onready var pause_menu: Control = %PauseMenu
@onready var score_sheet: Control = %ScoreSheet
@onready var hud: Control = %HUD

#ShipStatsPanel
@onready var health_container: PanelContainer = $CanvasLayer/HUD/Health
@onready var heart_1: TextureRect = $CanvasLayer/HUD/Health/MarginContainer/HBoxContainer/Heart1
@onready var heart_2: TextureRect = $CanvasLayer/HUD/Health/MarginContainer/HBoxContainer/Heart2
@onready var heart_3: TextureRect = $CanvasLayer/HUD/Health/MarginContainer/HBoxContainer/Heart3
@onready var heart_4: TextureRect = $CanvasLayer/HUD/Health/MarginContainer/HBoxContainer/Heart4
@onready var heart_5: TextureRect = $CanvasLayer/HUD/Health/MarginContainer/HBoxContainer/Heart5

#ScorePanel
@onready var time_label: Label = %TimeLabel
@onready var score_label: Label = %ScoreLabel

#DebugPanel
@onready var debug_screen: Control = $CanvasLayer/DebugScreen
@onready var bullet_count_lable: Label = $CanvasLayer/DebugScreen/PanelContainer/VBoxContainer/HBoxContainer/BulletCountLabel

var player_instance: PlayerShip = null

var level: PackedScene = preload("res://Invaders/invaders_level.tscn")
var current_level: InvadersLevel = null

func _ready():
	# Setup pause menu
	pause_menu.visible = false
	score_sheet.visible = false
	hud.visible = false

	StateManager.connect("pause_toggled", _on_pause_toggled)
	StateManager.connect("state_changed", _on_state_changed)

func clean():
	pause_menu.visible = false
	score_sheet.visible = false
	hud.visible = false

func Setup():
	hud.visible = true
	current_level = level.instantiate() as InvadersLevel
	add_child(current_level)
	current_level.score = 0
	player_instance = current_level.player
	setup_hud()

func _process(delta: float):
	if StateManager.current_state == StateManager.State.SCHMUP and not StateManager.is_paused:
		time_label.text = "Time: %.1fs" % current_level.level_time  # Update time separately
		_run_debug(delta)

func setup_hud()-> void:
	pass

func update_hud():
	score_label.text = "Score: %d" % current_level.score

func _input(event):
	if StateManager.get_current_state() == StateManager.State.INVADERS and event.is_action_pressed("ui_cancel"):
		StateManager.toggle_pause()

func pop_ScoreSheet() -> void:
	score_sheet.visible = true
	update_hud()

func _on_pause_toggled(is_paused: bool):
	pause_menu.visible = is_paused

func _on_state_changed(new_state: StateManager.State):
	if new_state != StateManager.State.INVADERS:
		clean()

func _on_resume_pressed():
	pause_menu.visible = false
	StateManager.toggle_pause()

func _on_quit_to_menu_pressed():
	StateManager.unpause() #force unpause - no matter what state. 
	StateManager.set_state(StateManager.State.MENU)


######DEBUG######
func _run_debug(_delta: float) -> void:
	pass
