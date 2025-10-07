extends CanvasLayer
signal transition_to(state) # Emitted when state wants to change

func _ready():
	$Panel/StartButton.pressed.connect(_on_start_pressed)

func _process(delta):
	# Update title-specific logic, e.g., animate logo
	pass

func _on_start_pressed():
	emit_signal("transition_to", GameManager.State.GAMEPLAY)
