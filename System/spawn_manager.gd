# res://scripts/spawn/SpawnManager.gd
extends Node3D
class_name SpawnManager

@export var sequence: SpawnSequence                 # your .tres with entries
@export var play_on_ready := true
@export var loop_sequence := false

@onready var _enemies_root: Node3D = $"../../Enemies"

signal spawned(instance: Node, entry: SpawnEntry)

var _spawners: Dictionary = {}  # name:StringName -> Node3D (e.g., Marker3D/Spawner)
var _running := false

func _ready() -> void:
	# Cache enemies root
	if _enemies_root == null:
		push_warning("SpawnManager: enemies_root_path not set or missing.")

	# Cache spawners by name (you’ve placed them manually in the scene)
	for child in get_children():
		# Accept either your Spawner.gd or raw Marker3D
		if child is Node3D:
			_spawners[child.name] = child

	if play_on_ready:
		start_spawning()

func start_spawning() -> void:
	if _running:
		return
	if not sequence:
		push_warning("SpawnManager: No sequence assigned.")
		return
	_running = true
	# fire-and-forget
	_run_loop()

func stop_spawning() -> void:
	_running = false

func _run_loop() -> void:
	# Coroutine wrapper so we can loop if requested
	spawn_entries()

func _on_sequence_finished() -> void:
	_running = loop_sequence
	if _running:
		_run_loop()

func _spawn(entry: SpawnEntry) -> void:
	if not entry.scene:
		return
	var spawner: Node3D = _spawners.get(entry.spawner_name, null)
	if spawner == null:
		push_warning("Spawner '%s' not found." % entry.spawner_name)
		return

	var inst := entry.scene.instantiate()
	inst.global_position = spawner.global_position

	# Simple entry styles / behaviors (optional hooks)
	match entry.entry_style:
		SpawnEntry.EntryStyle.SLIDE_ONLY:
			if "set_initial_velocity" in inst:
				inst.set_initial_velocity(Vector3(-entry.speed, 0, 0))
			elif "velocity" in inst:
				inst.velocity.x = -entry.speed
		SpawnEntry.EntryStyle.SLIDE_PAUSE:
			if "velocity" in inst:
				inst.velocity = Vector3.ZERO

	match entry.behavior:
		SpawnEntry.Behavior.RAM_PLAYER:
			if "set_behavior" in inst:
				inst.set_behavior("ram_player")
			elif "behavior" in inst:
				inst.behavior = "ram_player"

	if _enemies_root:
		_enemies_root.add_child(inst)
	else:
		add_child(inst)

	emit_signal("spawned", inst, entry)

func spawn_entries() -> void:
	# NOTE: no @func — just a normal function. 'await' works in Godot 4.
	for e in sequence.entries:
		if not _running:
			break
		await get_tree().create_timer(maxf(e.delay_s, 0.0)).timeout
		if not _running:
			break
		_spawn(e)
	_on_sequence_finished()
