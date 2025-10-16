extends Control

func _input(event):
	# Transition to main menu on any key press or mouse click
	if event is InputEventKey and event.pressed or event is InputEventMouseButton and event.pressed:
		StateManager.set_state(StateManager.State.MENU)
		await get_tree().process_frame  # let StateManager add the menu manager
		queue_free()
