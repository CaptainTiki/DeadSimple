extends Node

enum State { MENU, PLAY }

signal state_changed(new_state: State)
signal pause_toggled(is_paused: bool)

var current_state: State = State.MENU
var is_paused: bool = false
var game_data: Dictionary = {"score": 0}

@onready var menu_manager: MenuManager = preload("res://System/menu_manager.tscn").instantiate()
@onready var game_manager: GameManager = preload("res://System/game_manager.tscn").instantiate()

func _ready():
	# Load managers as persistent children
	add_child(menu_manager)
	add_child(game_manager)

func set_state(new_state: State):
	if current_state == new_state:
		return
	
	current_state = new_state
	
	# Clean both managers
	menu_manager.clean()
	game_manager.clean()
	
	# Setup the active manager
	if new_state == State.MENU:
		menu_manager.Setup()
		menu_manager.open_main_menu()
	elif new_state == State.PLAY:
		is_paused = false
		get_tree().paused = false
		game_manager.Setup()
	
	emit_signal("state_changed", new_state)

func toggle_pause():
	if current_state != State.PLAY:
		return
	is_paused = !is_paused
	get_tree().paused = is_paused
	emit_signal("pause_toggled", is_paused)

func unpause():
	is_paused = false
	get_tree().paused = is_paused
	emit_signal("pause_toggled", is_paused)

func get_current_state() -> State:
	return current_state
