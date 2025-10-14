extends CharacterBody3D
class_name PlayerShip

@export var move_speed: float = 5.0
@export var fire_rate: float = 0.2  # Seconds between shots
@export var max_shields: float = 100.0  # Max shields
@export var max_health: float = 30.0  # Max hits
@export var shield_recharge_rate: float = 5.0  # Shields per second
@export var shield_recharge_delay: float = 2.0  # Seconds before recharge starts

@onready var muzzle: Node3D = $Muzzle
@onready var weapons_root: Node3D = $Weapons

var trigger_held: bool = false

var bullet_scene = preload("res://Projectiles/bullet_round.tscn")
var time_since_last_shot: float = 0.0
var current_shields: float = 100.0
var current_health: float = 30.0
var no_hit_timer: float = 0.0
var flash_tween: Tween

var fire_cooldown: float = 0.0             # time left until next shot

signal damage_taken

func _ready():
	pass

func _physics_process(delta: float):
	if StateManager.is_paused:
		return
	
	# 2D movement input (Z locked)
	var input_dir = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_down", "move_up")  # Invert if up should be positive Y
	).normalized()
	
	velocity.x = input_dir.x * move_speed
	velocity.y = input_dir.y * move_speed
	velocity.z = 0  # Locked Z
	
	move_and_slide()
	
	trigger_held = Input.is_action_pressed("fire")
	# notify children (fast: no signals needed)
	for weapon in weapons_root.get_children():
		if weapon.has_method("set_trigger"):
			weapon.set_trigger(trigger_held, delta)
	
	if Input.is_action_just_pressed("dodge"):
		print("Dodge!")  # Quick burst later
	
	# Shield recharge logic
	if no_hit_timer > 0:
		no_hit_timer -= delta
		if no_hit_timer <= 0 and current_shields < max_shields:
			current_shields += shield_recharge_rate * delta
			current_shields = min(current_shields, max_shields)

func fire_bullet() -> void:
	print("player.gd - fire bullet")
	# Get an inactive bullet from the BulletPool
	var new_bullet: Node = PoolManager.acquire_bullet()
	if new_bullet == null:
		# Pool empty or capped → skip this frame
		print("player.gd - skipped")
		return

	# Define the bullet’s direction
	var direction: Vector3 = Vector3.RIGHT

	# Rotate the bullet sprite to match its direction
	#TODO: rotate the bullet to face the direction of travel
	
	# Call the bullet’s fire() method to activate it
	new_bullet.call(
		"fire",
		muzzle.global_position,        # start position
		direction * new_bullet.speed       # velocity vector
	)

func _on_body_entered(body: Node3D):
	if body.is_in_group("enemy"):
		take_damage(20.0) #TODO: this is arbitrary damage - need to export to variables
		body.queue_free()  #TODO: make this deal collision damage - not just destroy

func _on_area_entered(area: Node3D):
	if area.is_in_group("rock"):
		take_damage(20.0) #TODO: this is arbitrary damage - need to export to variables
		area.queue_free()  #TODO: make this deal collision damage - not just destroy

func take_damage(damage: float):
	# Reset no-hit timer
	no_hit_timer = shield_recharge_delay
	
	# Apply damage to shields first
	current_shields -= damage
	if current_shields < 0:
		current_health += current_shields #sheilds should be negative - so this will subtract
		current_shields = 0
	
	# Clamp health
	current_health = max(0, current_health)
	
	# Visual feedback: Flash red
	if flash_tween:
		flash_tween.kill()
	flash_tween = create_tween()
	var material = $CSGCombiner3D/CSGBox3D.material as StandardMaterial3D
	flash_tween.tween_property(material, "albedo_color", Color.RED, 0.1)
	flash_tween.tween_property(material, "albedo_color", Color(0.545, 0.545, 0.545, 1), 0.1)
	
	emit_signal("damage_taken")  # Notify for HUD update
	
	# Check for game over
	if current_health <= 0:
		kill_player()

func kill_player() -> void:
	set_process(false)
	set_physics_process(false)
	StateManager.game_manager.pop_ScoreSheet()
