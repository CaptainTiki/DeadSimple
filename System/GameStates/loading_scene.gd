extends CanvasLayer
var target_state: int

func start(new_state: int):
	target_state = new_state
	$AnimationPlayer.play("fade_in") # Fade to black
	await $AnimationPlayer.animation_finished
	# Unload old, load new
	var new_state_node = GameManager.state_nodes[target_state].instantiate()
	GameManager.current_state_node = new_state_node
	GameManager.current_state = target_state
	get_tree().root.add_child(new_state_node)
	$AnimationPlayer.play("fade_out") # Fade to scene
	await $AnimationPlayer.animation_finished
	queue_free() # Remove loading screen
