@tool
extends Area3D

@export_enum("Dumb", "Pathing") var enemy_type: String = "Dumb":
	set(value):
		enemy_type = value
		if Engine.is_editor_hint() and is_node_ready():
			generate_path()
@export_category("All Enemies")
@export var enemy_scene: PackedScene
@export var pathing_enemy_scene: PackedScene
@export var pause_delay: float = 0.0
@export_category("Pathing Only")
@export var curve_factor: float = 0.0:  # -5 to 5
	set(value):
		curve_factor = value
		if Engine.is_editor_hint() and is_node_ready():
			generate_path()
@export var show_path: bool = false:
	set(value):
		show_path = value
		if Engine.is_editor_hint() and is_node_ready():
			generate_path()
@export var path_length: float = 20.0:  # Adjustable path length
	set(value):
		path_length = value
		if Engine.is_editor_hint() and is_node_ready():
			generate_path()
@export var show_path_in_game: bool = false  # New for runtime display
@export var spawned: bool = false

@onready var path: Path3D = $Path3D

func _enter_tree():
	if not Engine.is_editor_hint() and enemy_type == "Pathing":
		generate_path()  # Generate curve only for Pathing at runtime

func _ready():
	if Engine.is_editor_hint():
		generate_path()
	else:
		visible = true
		path.visible = show_path_in_game  # Show path in game if toggled

func generate_path():
	if not is_node_ready():
		return
	path.curve = Curve3D.new()
	if enemy_type == "Pathing":
		var length = path_length
		var points = 20
		for i in range(points + 1):
			var t = float(i) / points
			var x = -t * length
			var y = sin(t * PI * 2) * curve_factor if abs(curve_factor) > 0.01 else 0.0
			path.curve.add_point(Vector3(x, y, 0))
		path.visible = (show_path and Engine.is_editor_hint()) or show_path_in_game
		print("Spawner curve points: ", path.curve.get_point_count())
	else:
		path.visible = false

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint() and spawned:
		queue_free()

func _on_area_entered(area: Area3D):
	if area.is_in_group("activation_area") and not spawned:
		print("Spawner curve points before spawn: ", path.curve.get_point_count())
		if enemy_type == "Pathing":
			spawn_pathing_enemy()
		else:
			spawn_enemy()
		spawned = true
		visible = false

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	get_parent().add_child(enemy)
	enemy.position = position
	enemy.pause_delay = pause_delay

func spawn_pathing_enemy():
	var path_node = Path3D.new()
	path_node.global_position = global_position
	path_node.curve = path.curve.duplicate()
	var path_follow = PathFollow3D.new()
	path_follow.rotation_mode = PathFollow3D.ROTATION_NONE
	path_follow.loop = true
	path_follow.progress = 0.0
	path_node.add_child(path_follow)
	get_parent().add_child(path_node)  # Add Path3D to scene
	path_node.position = position
	var enemy = pathing_enemy_scene.instantiate()
	get_parent().add_child(enemy)  # Add enemy to scene first
	enemy.reparent(path_follow)  # Now reparent
	enemy.pause_delay = pause_delay
	enemy.show_path_in_game = show_path_in_game
	print("Enemy initial position: ", enemy.global_position)
