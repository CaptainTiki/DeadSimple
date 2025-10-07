extends Node
enum State {TITLE, MENU, GAMEPLAY, PAUSED, END, LOADING}
var current_state: State = State.TITLE
var state_nodes: Dictionary = {} # Map State to Node
var current_state_node: Node

var title_screen : Node = preload("res://System/GameStates/TitleScreen.tscn").instantiate()
var menu_screen : Node = preload("res://System/GameStates/MenuScene.tscn").instantiate()
var loading_screen : Node = preload("res://System/GameStates/LoadingScene.tscn").instantiate()


func _ready():
	# Load state scenes or nodes (preload or instance later)
	state_nodes[State.TITLE] = title_screen
	state_nodes[State.MENU] = menu_screen
	# ... other states
	switch_state(State.TITLE)

func switch_state(new_state: State):
	if current_state == State.LOADING: return # Prevent mid-load switches
	if current_state_node:
		current_state_node.queue_free() # Unload old state
	current_state = State.LOADING
	var loading = loading_screen
	add_child(loading)
	loading.start(new_state) # Pass target state to loading
