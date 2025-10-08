extends Area3D

@export var speed: float = 20.0
@export var lifetime: float = 0.75

var time_alive: float = 0.0

func _physics_process(delta: float):
	if StateManager.is_paused:
		return
	
	# Move bullet forward (negative Z in local space, as play area moves positive X)
	position.x += speed * delta
	
	# Despawn after lifetime
	time_alive += delta
	if time_alive > lifetime:
		queue_free()
