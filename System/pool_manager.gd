# pool_manager.gd
extends Node
class_name Pool_Manager

# Buckets of available nodes per type (values are plain Array to avoid nested generic typing)
var pool: Dictionary[String, Array] = {}
# Registry of what to instantiate
var registry: Dictionary[String, PackedScene] = {}
# Where to park pooled nodes in the tree
var parents: Dictionary[String, Node] = {}

func register(nodetype: String, scene: PackedScene, parent: Node = null, prewarm: int = 0) -> void:
	if not pool.has(nodetype):
		pool[nodetype] = []
	registry[nodetype] = scene
	parents[nodetype] = parent if parent != null else self

	for i in prewarm:
		var n := scene.instantiate() as Node3D
		n.visible = false
		n.set_physics_process(false)
		parents[nodetype].add_child(n)
		pool[nodetype].append(n)

func acquire(nodetype: String) -> Node3D:
	if not registry.has(nodetype):
		push_error("Pool: unknown nodetype '%s'" % nodetype)
		return null
	if not pool.has(nodetype):
		pool[nodetype] = []

	var bucket: Array = pool[nodetype]
	var node: Node3D = null

	# pull from bucket or make new
	while bucket.size() > 0 and node == null:
		var candidate = bucket.pop_back()
		if is_instance_valid(candidate):
			node = candidate as Node3D
	# instantiate if needed
	if node == null:
		node = registry[nodetype].instantiate() as Node3D
		parents[nodetype].add_child(node)

	# node handles its own setup
	if "pool_setup" in node:
		node.pool_setup()

	return node

func release(nodetype: String, node: Node3D) -> void:
	if node == null or not is_instance_valid(node):
		return
	# node handles its own teardown
	if "pool_release" in node:
		node.pool_release()
	if not pool.has(nodetype):
		pool[nodetype] = []
	pool[nodetype].append(node)

func active(nodetype: String) -> int:
	if not parents.has(nodetype):
		return 0
	# Active = children parked under parent minus available in bucket
	var total := parents[nodetype].get_child_count()
	var available := pool[nodetype].size() if pool.has(nodetype) else 0
	return total - available
