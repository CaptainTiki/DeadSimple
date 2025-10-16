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
const INVADERS_SCENE  := preload("res://Invaders/invaders_manager.tscn")

func _ready() -> void:
	set_state(State.TITLE)

func set_state(new_state: State) -> void:
	if new_state == current_state:
		return

	# Clean up old manager
	if current_manager and is_instance_valid(current_manager):
		current_manager.queue_free()
		current_manager = null

	# Pick next scene
	var next_scene: PackedScene = null
	match new_state:
		State.TITLE:    next_scene = TITLE_SCENE
		State.MENU:     next_scene = MENU_SCENE
		State.SCHMUP:   next_scene = SCHMUP_SCENE
		State.INVADERS: next_scene = INVADERS_SCENE

	current_state = new_state

	if next_scene:
		var instance := next_scene.instantiate()
		current_manager = instance
		# Defer adding AND setup into one coroutine
		call_deferred("_add_and_setup_manager", instance)
	else:
		emit_signal("state_changed", current_state)

func _add_and_setup_manager(instance: Node) -> void:
	print("add and setup manager")
	# If we switched states again before this ran, bail.
	if not is_instance_valid(instance) or instance != current_manager:
		return
	add_child(instance)
	# Wait until it's actually in the tree and its _ready() finished.
	if not instance.is_node_ready():
		await instance.ready
	# If we switched again during the await, bail.
	if not is_instance_valid(instance) or instance != current_manager:
		return
	# Call Setup only if it exists
	if instance.has_method("Setup"):
		instance.Setup()

	emit_signal("state_changed", current_state)

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
