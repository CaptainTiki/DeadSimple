extends Control

func _input(event):
	# Transition to main menu on any key press or mouse click
	if event is InputEventKey and event.pressed or event is InputEventMouseButton and event.pressed:
		# Ensure MenuManager is initialized and push MainMenu
		if StateManager.menu_manager:
			StateManager.menu_manager.open_main_menu()
			# Free TitleScreen (main scene)
			queue_free()
