extends CharacterBody3D
class_name PlayerShip

@export var move_speed: float = 5.0
@export var roll_duration: float = 0.5
@export var roll_cooldown: float = 2.0
@export var fire_rate: float = 0.2
@export var max_shields: float = 100.0  # Max shields
@export var max_health: float = 30.0  # Max hits
@export var shield_recharge_rate: float = 5.0  # Shields per second
@export var shield_recharge_delay: float = 2.0  # Seconds before recharge starts
@export var max_invul_time: float = 1.0

@onready var muzzle: Node3D = $Muzzle
@onready var weapons_root: Node3D = $Weapons
@onready var visual_pivot: Node3D = $VisualPivot
@onready var engine_fx: Node3D = $VisualPivot/EngineFX
@onready var hit_box: Area3D = $HitBox
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

var trigger_held: bool = false

var bullet_scene = preload("res://Projectiles/bullet_round.tscn")
var time_since_last_shot: float = 0.0
var current_shields: float = 100.0
var current_health: float = 30.0
var no_hit_timer: float = 0.0
var flash_tween: Tween
var is_invulnerable: bool = false
var invul_countdown: float = 0

var is_rolling: bool = false
var roll_timer: float = 0.0

var fire_cooldown: float = 0.0             # time left until next shot

##Visual Roll Settings
var roll_profile := 0
var max_roll_deg := 18.0
var roll_smooth := 12.0   # higher = snappier
var roll_input_axis := 0
var roll_axis := 2  
var roll_sign := 1.0 

signal damage_taken

func _ready():
	pass


func _physics_process(delta: float):
	if StateManager.is_paused:
		return
	
	if is_invulnerable:
		invul_countdown -= delta
		if invul_countdown <= 0:
			is_invulnerable = false
			_stop_invulnerable()
	
	# 2D movement input (Z locked)
	var input_dir = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_down", "move_up")  # Invert if up should be positive Y
	).normalized()
	
	velocity.x = input_dir.x * move_speed
	velocity.y = input_dir.y * move_speed
	velocity.z = 0  # Locked Z
	
	if is_rolling:
		roll_timer -= delta
		if roll_timer <= 0:
			is_rolling = false
	else:
		roll_timer -= delta
		if Input.is_action_just_pressed("dodge") and roll_timer <= 0:
			start_roll()
	
	_update_visual_roll(delta, input_dir)
	engine_fx.update_thrust(input_dir, delta)
	move_and_slide()
	
	trigger_held = Input.is_action_pressed("fire")
	# notify children (fast: no signals needed)
	for weapon in weapons_root.get_children():
		if weapon.has_method("set_trigger"):
			weapon.set_trigger(trigger_held, delta)
	
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

func start_roll() -> void:
	is_rolling = true
	roll_timer = roll_cooldown
	# Add invincibility
	is_invulnerable = true
	var tween = create_tween()
	tween.tween_property(self, "rotation", Vector3(rotation.x, rotation.y +2 * PI, rotation.z), roll_duration).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(_end_roll)

func _end_roll() -> void:
	is_invulnerable = false
	is_rolling = false

func _on_area_entered(area: Node3D):
	if area.is_in_group("enemy_bullet"):
		take_damage(20.0) #TODO: this is arbitrary damage - need to export to variables
		area.despawn() #TODO: make this deal collision damage - not just destroy

func take_damage(damage: float):
	if is_invulnerable:
		return
	# Reset no-hit timer
	no_hit_timer = shield_recharge_delay
	
	# Apply damage to shields first
	current_shields -= damage
	if current_shields < 0:
		current_health += current_shields #sheilds should be negative - so this will subtract
		current_shields = 0
		
	# Clamp health
	current_health = max(0, current_health)
	
	set_invulnerable()
	
	# Check for game over
	if current_health <= 0:
		kill_player()

func set_invulnerable() -> void:
	is_invulnerable = true
	invul_countdown = max_invul_time
	if flash_tween:
		flash_tween.kill()
	flash_tween = create_tween().set_loops()
	flash_tween.tween_property(visual_pivot, "visible", false, 0.1)
	flash_tween.tween_property(visual_pivot, "visible", true, 0.1)

func _stop_invulnerable() -> void:
	is_invulnerable = false
	if flash_tween:
		flash_tween.kill()
	visual_pivot.visible = true

func kill_player() -> void:
	set_process(false)
	set_physics_process(false)
	StateManager.game_manager.pop_ScoreSheet()

func configure_roll_profile(profile: int) -> void:
	roll_profile = profile
	match roll_profile:
		0: # Invaders: player at bottom, moving left/right; bank left/right
			roll_input_axis = 0          # Horizontal input drives roll
			roll_axis = 0                # roll around Z looks screen-aligned
			max_roll_deg = 30.0
			roll_sign = 1.0             # left tilt feels nicer with negative
		1: # Schmup: facing right; bank up/down when moving vertically
			roll_input_axis = 1          # Vertical input drives roll
			roll_axis = 0                # still around Z for screen bank
			max_roll_deg = 30.0
			roll_sign = -1.0
		_: # Custom: keep whatever is exported in the inspector
			pass
	pass

func _update_visual_roll(delta: float, move_input: Vector2) -> void:
	if visual_pivot == null:
		return

	var axis_value := 0.0
	axis_value = move_input.x if (roll_input_axis == 0) else move_input.y
	axis_value = clamp(axis_value, -1.0, 1.0)

	# Target angle in radians
	var target_rad := deg_to_rad(max_roll_deg) * axis_value * roll_sign

	# Smooth toward target (critically-damped-ish)
	var t := 1.0 - pow(0.001, delta * roll_smooth)

	match roll_axis:
		0: # X
			visual_pivot.rotation.x = lerp(visual_pivot.rotation.x, target_rad, t)
		1: # Y
			visual_pivot.rotation.y = lerp(visual_pivot.rotation.y, target_rad, t)
		2: # Z
			visual_pivot.rotation.z = lerp(visual_pivot.rotation.z, target_rad, t)
