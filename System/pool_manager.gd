# res://System/pool_Manager.gd
extends Node

var _bullet_pool : Array[BulletBase] = []             # Array of bullet nodes (inactive)
var _scene: PackedScene     # Bullet scene to instance
var _parent: Node           # Where bullets live in the tree
var _max_size: int = 0      # 0 = unlimited

func setup_bullets(scene: PackedScene, parent: Node, initial: int, max_size: int = 0) -> void:
	_scene = scene
	_parent = parent
	_max_size = max_size
	_bullet_pool.clear()
	for i in range(initial):
		var b := _scene.instantiate()
		_prep_for_pool(b)
		_bullet_pool.append(b)

func acquire_bullet() -> Node:
	if _bullet_pool.size() > 0:
		return _bullet_pool.pop_back()
	if _max_size == 0 or _active_count() < _max_size:
		var b := _scene.instantiate()
		_prep_for_pool(b)
		return b
	return null  # at cap → caller should skip this frame

func release(node: Node) -> void:
	if node == null:
		return
	if node.has_method("reset_for_pool"):
		node.call("reset_for_pool")
	if node is CanvasItem:
		(node as CanvasItem).visible = false
	if node.has_method("set_physics_process"):
		node.set_physics_process(false)
	if node.has_method("set_monitoring"):
		node.set_deferred("monitoring", false)
	_bullet_pool.append(node)

func _prep_for_pool(n: Node) -> void:
	if n is CanvasItem:
		(n as CanvasItem).visible = false
	if n.has_method("set_physics_process"):
		n.set_physics_process(false)
	_parent.add_child(n)
	if n.has_method("reset_for_pool"):
		n.call("reset_for_pool")

func _active_count() -> int:
	var count := 0
	for c in _parent.get_children():
		if c is CanvasItem and (c as CanvasItem).visible:
			count += 1
	return count
