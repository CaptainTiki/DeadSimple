extends Node

enum State { TITLE, MENU, SCHMUP, INVADERS }

signal state_changed(new_state: State)
signal pause_toggled(is_paused: bool)

var current_state: State = State.MENU
var is_paused := false
var current_manager: Node = null

# Keep these as PackedScenes (no .instantiate() here)
const TITLE_SCENE     := preload("res://System/Menus/TitleScreen.tscn")
const MENU_SCENE      := preload("res://System/menu_manager.tscn")
const SCHMUP_SCENE    := preload("res://System/schmup_manager.tscn")
const INVADERS_SCENE  := preload("res://System/invaders_manager.tscn")

func _ready() -> void:
	set_state(State.TITLE)

func set_state(new_state: State) -> void:
	if new_state == current_state:
		return

	# Unpause when switching modes to avoid sticky pause states
	get_tree().paused = false
	is_paused = false
	emit_signal("pause_toggled", is_paused)

	# Remove previous manager cleanly
	if current_manager and is_instance_valid(current_manager):
		current_manager.queue_free()
		current_manager = null

	# Instantiate only the target manager
	var next_scene: PackedScene = null
	match new_state:
		State.MENU:     next_scene = MENU_SCENE
		State.SCHMUP:   next_scene = SCHMUP_SCENE
		State.INVADERS: next_scene = INVADERS_SCENE

	if next_scene:
		current_manager = next_scene.instantiate()
		# Add after current frame to avoid “modified while iterating” issues
		call_deferred("_add_manager_deferred", current_manager)

	current_state = new_state
	if current_manager:
		current_manager.Setup()
	emit_signal("state_changed", current_state)

func _add_manager_deferred(node: Node) -> void:
	add_child(node)

func toggle_pause():
	if current_state == State.MENU:
		return
	is_paused = !is_paused
	get_tree().paused = is_paused
	emit_signal("pause_toggled", is_paused)

func unpause():
	is_paused = false
	get_tree().paused = false
	emit_signal("pause_toggled", is_paused)

func get_current_state() -> State:
	return current_state
