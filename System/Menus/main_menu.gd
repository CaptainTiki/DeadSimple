extends Control
@onready var menu: Control = $Menu
@onready var play_button: Button = $Menu/HBoxContainer/PanelContainer/VBoxContainer/PlayButton
@onready var invaders: Button = $Menu/HBoxContainer/PanelContainer/VBoxContainer/Invaders
@onready var quit_button: Button = $Menu/HBoxContainer/PanelContainer/VBoxContainer/QuitButton

func _ready():
	pass

func _on_play_pressed():
	StateManager.set_state(StateManager.State.SCHMUP)

func _on_invaders_pressed() -> void:
	StateManager.set_state(StateManager.State.INVADERS)

func _on_quit_pressed():
	get_tree().quit()
