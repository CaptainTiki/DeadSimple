extends Node3D
class_name FormationController

@export_category("Setup")
@export var rows: int = 5
@export var cols: int = 7
@export var spacing_xy: Vector2 = Vector2(2.0, 1.25)
@export var top_margin: float = 1.0
@export var offscreen_y: float = 12.0
@export var offscreen_x: float = 12.0
@export var per_invader_delay: float = 0.05
@export var per_column_delay: float = 0.1
@export var dock_time: float = 0.55
@export var camera_path: NodePath

@export_category("Movement")
@export var move_step_x: float = 0.25
@export var step_down_distance: float = 0.5
@export var start_interval: float = 1.0
@export var speedup_factor: float = 0.9
@export var min_interval: float = 0.15
@export var x_margin: float = 0.5

signal wave_spawned
signal wave_docked

var invaders: Array[Invader] = []
var total_count: int = 0
var docked_count: int = 0
var _wave_docked_fired: bool = false
var direction: int = 1
var move_timer: float = 0.0
var move_interval: float
var _marching: bool = false
var invader_scene: PackedScene = preload("res://Invaders/invader.tscn")
var camera: Camera3D
var play_bounds: Dictionary

func _ready() -> void:
	camera = get_node_or_null(camera_path)
	if not camera:
		camera = get_viewport().get_camera_3d()
	assert(camera, "FormationController needs a valid Camera3D.")
	play_bounds = _get_play_bounds_world()
	move_interval = start_interval

func _process(delta: float) -> void:
	if not _marching:
		return
	move_timer += delta
	if move_timer >= move_interval:
		move_timer -= move_interval
		_step_formation()

func _step_formation() -> void:
	if _will_hit_edge():
		position.y -= step_down_distance
		direction *= -1
		move_interval = max(move_interval * speedup_factor, min_interval)
	else:
		position.x += move_step_x * direction

func _will_hit_edge() -> bool:
	var aabb: AABB = _get_formation_aabb()
	var left_edge: float = play_bounds.min_x + x_margin
	var right_edge: float = play_bounds.max_x - x_margin
	var next_left: float = global_position.x + aabb.position.x + (direction * move_step_x)
	var next_right: float = next_left + aabb.size.x
	return next_left < left_edge or next_right > right_edge

func _get_formation_aabb() -> AABB:
	var minv: Vector3 = Vector3.INF
	var maxv: Vector3 = -Vector3.INF
	for invader in invaders:
		if not is_instance_valid(invader):
			continue
		minv = minv.min(invader.position)
		maxv = maxv.max(invader.position)
	return AABB(minv, maxv - minv)

func setup_formation() -> void:
	clear_existing()
	var half_w: float = (cols - 1) * spacing_xy.x * 0.5
	var top_row_world_y: float = play_bounds.max_y - top_margin
	var top_row_local_y: float = top_row_world_y - global_position.y
	global_position.x = (play_bounds.min_x + play_bounds.max_x) * 0.5
	global_position.y = 0.0
	global_position.z = 0.0
	total_count = rows * cols
	invaders.resize(total_count)
	for c in range(cols):
		for r in range(rows):
			var idx: int = r * cols + c
			var invader: Invader = invader_scene.instantiate()
			add_child(invader)
			var local_x: float = c * spacing_xy.x - half_w
			var local_y: float = top_row_local_y - r * spacing_xy.y
			var slot: Vector3 = Vector3(local_x, local_y, 0.0)
			invader.set_slot_info(slot)
			invader.place_offscreen(offscreen_x, offscreen_y)
			invader.docked.connect(_on_invader_docked)
			invader.died.connect(_on_invader_died)
			invaders[idx] = invader
	emit_signal("wave_spawned")

func start_wave() -> void:
	_dock_columns_bottom_to_top()

func clear_existing() -> void:
	for child in get_children():
		child.queue_free()
	invaders.clear()
	docked_count = 0
	_wave_docked_fired = false

func _on_invader_docked(_invader: Node) -> void:
	docked_count += 1
	if docked_count >= total_count and not _wave_docked_fired:
		_wave_docked_fired = true
		emit_signal("wave_docked")
		_marching = true

func _on_invader_died(invader: Invader) -> void:
	invaders.erase(invader)
	total_count = invaders.size()

func _dock_columns_bottom_to_top() -> void:
	for c in range(cols):
		for r in range(rows - 1, -1, -1):
			var idx: int = r * cols + c
			if idx < invaders.size() and is_instance_valid(invaders[idx]):
				invaders[idx].start_docking(dock_time, 0.0)
			await get_tree().create_timer(per_invader_delay).timeout
		await get_tree().create_timer(per_column_delay).timeout

func _get_play_bounds_world() -> Dictionary:
	var vp: Viewport = get_viewport()
	var size: Vector2 = vp.get_visible_rect().size
	var corners: Array[Vector3] = [
		_screen_to_z0(Vector2(0, 0), camera),
		_screen_to_z0(Vector2(size.x, 0), camera),
		_screen_to_z0(Vector2(0, size.y), camera),
		_screen_to_z0(Vector2(size.x, size.y), camera)
	]
	var min_x: float = INF
	var max_x: float = -INF
	var min_y: float = INF
	var max_y: float = -INF
	for v in corners:
		min_x = min(min_x, v.x)
		max_x = max(max_x, v.x)
		min_y = min(min_y, v.y)
		max_y = max(max_y, v.y)
	return { "min_x": min_x, "max_x": max_x, "min_y": min_y, "max_y": max_y }

func _screen_to_z0(screen_pos: Vector2, cam: Camera3D) -> Vector3:
	var origin: Vector3 = cam.project_ray_origin(screen_pos)
	var dir: Vector3 = cam.project_ray_normal(screen_pos)
	var denom: float = dir.z
	if abs(denom) < 1e-6:
		return Vector3(origin.x, origin.y, 0.0)
	var t: float = -origin.z / denom
	return origin + dir * t
