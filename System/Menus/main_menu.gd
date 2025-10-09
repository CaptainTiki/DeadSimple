extends Control
@onready var menu: Control = $Menu
@onready var play_button: Button = $Menu/VBoxContainer/PlayButton
@onready var quit_button: Button = $Menu/VBoxContainer/QuitButton

func _ready():
	pass

func _on_play_pressed():
	StateManager.set_state(StateManager.State.PLAY)

func _on_quit_pressed():
	get_tree().quit()
