extends Node
class_name GameManager

@onready var pause_menu: Control = $CanvasLayer/PauseMenu
@onready var resume_bn: Button = $CanvasLayer/PauseMenu/Panel/VBoxContainer/Resume
@onready var quit_bn: Button = $CanvasLayer/PauseMenu/Panel/VBoxContainer/Quit


var game_window: PackedScene = preload("res://game.tscn")
var current_game_window: Node = null

func _ready():
	# Setup pause menu
	pause_menu.visible = false
	resume_bn.connect("pressed", _on_resume_pressed)
	quit_bn.connect("pressed", _on_quit_to_menu_pressed)
	StateManager.connect("pause_toggled", _on_pause_toggled)
	StateManager.connect("state_changed", _on_state_changed)

func clean():
	if current_game_window:
		current_game_window.queue_free()
		current_game_window = null
	pause_menu.visible = false

func Setup():
	current_game_window = game_window.instantiate()
	add_child(current_game_window)
	StateManager.game_data.score = 0

func _input(event):
	if StateManager.get_current_state() == StateManager.State.PLAY and event.is_action_pressed("ui_cancel"):
		StateManager.toggle_pause()

func _on_pause_toggled(is_paused: bool):
	pause_menu.visible = is_paused

func _on_state_changed(new_state: StateManager.State):
	if new_state != StateManager.State.PLAY:
		clean()

func _on_resume_pressed():
	pause_menu.visible = false
	StateManager.toggle_pause()

func _on_quit_to_menu_pressed():
	StateManager.toggle_pause()
	StateManager.set_state(StateManager.State.MENU)
