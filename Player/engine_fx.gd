# EngineFX.gd (attach to EngineFX)
extends Node3D

# Profiles: 0=Invaders (UP boosts), 1=Schmup (RIGHT boosts)
@export_enum("Invaders","Schmup") var thrust_profile := 0

# Tuning ranges
@export_category("GPU Particle Settings")
@export var base_vel := Vector2(5.0, 7.0)     # min/max at idle
@export var boost_vel := Vector2(12.0, 16.0)  # min/max at full thrust
@export var base_scale := Vector2(0.6, 1.0)
@export var boost_scale := Vector2(1.6, 2.2)
@export var base_amount := 120
@export var boost_amount := 200
@export var smooth := 10.0                    # higher = snappier

@export_category("Light Glow")
@export var glow_base : float = 0.35        # idle brightness
@export var wobble_scale : float = 0.10
@export var thrust_multiplier : float = 1.4 # how much brighter at full thrust (1.0 = none)
@export var max_energy : float = 2.0

@onready var _flame: GPUParticles3D = $FlameCore
@onready var _sparks: GPUParticles3D = $ExhaustSparks
@onready var thrust_glow: OmniLight3D = $ThrustGlow

#particles
var _flame_pm: ParticleProcessMaterial
var _sparks_pm: ParticleProcessMaterial
var _thrust := 0.0
var _time := 0.0

func _ready() -> void:
	_setup_engineFX.call_deferred()

func _setup_engineFX() -> void:
	_flame_pm = _flame.process_material as ParticleProcessMaterial
	_sparks_pm = _sparks.process_material as ParticleProcessMaterial
	_flame.emitting = true
	_sparks.emitting = true

func set_profile_invaders():
	thrust_profile = 0
func set_profile_schmup():
	thrust_profile = 1

# Call this from Player each frame with your move_input (Vector2)
func update_thrust(move_input: Vector2, delta: float) -> void:
	# Map input → [0..1] thrust per profile
	var raw := 0.0
	if thrust_profile == 0:
		# Invaders: UP grows, DOWN shrinks
		raw = move_input.y    # if your UP is negative, flip: raw = -move_input.y
	else:
		# Schmup: RIGHT grows, LEFT shrinks
		raw = move_input.x
	# Convert -1..1 → 0..1
	var target : float = clamp((raw * 0.5) + 0.5, 0.0, 1.0)

	# Smooth
	var t := 1.0 - pow(0.001, delta * smooth)
	_thrust = lerp(_thrust, target, t)
	
	# Idle flicker
	_time += delta
	var wobble : float = 0.06 * sin(_time * 16.7) + 0.04 * sin(_time * 9.3)
	var amt : int = int(roundi(lerp(base_amount, boost_amount, clamp(_thrust + wobble, 0.0, 1.0))))

	# Apply to FlameCore
	_flame_pm.initial_velocity_min = lerp(base_vel.x,   boost_vel.x,   _thrust)
	_flame_pm.initial_velocity_max = lerp(base_vel.y,   boost_vel.y,   _thrust)
	_flame_pm.scale_min            = lerp(base_scale.x, boost_scale.x, _thrust)
	_flame_pm.scale_max            = lerp(base_scale.y, boost_scale.y, _thrust)
	_flame.amount = amt

	# Apply to Sparks (lighter response)
	_sparks_pm.initial_velocity_min = lerp(base_vel.x+2.0, boost_vel.x+3.0, _thrust)
	_sparks_pm.initial_velocity_max = lerp(base_vel.y+4.0, boost_vel.y+5.0, _thrust)
	_sparks.amount = int(roundi(lerp(20.0, 60.0, _thrust)))
	
	#adjust light flare
	var flicker : float = wobble * wobble_scale
	var thrust_gain : float = lerp(1.0, thrust_multiplier, _thrust)
	var energy : float = (glow_base + flicker) * thrust_gain
	thrust_glow.light_energy = clamp(energy, 0.0, max_energy)
	
