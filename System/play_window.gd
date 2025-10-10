# res://system/PlayWindow.gd
extends Node3D
class_name PlayWindow

@export var gutter: float = -0.25              # extra margin around the screen
@export var depth: float = 2.0              # how thick the box is in front/back
@export var reference_distance: float = 13.5 # optional: distance from camera to player plane

@onready var camera_3d: Camera3D = $Camera3D


var half_extents: Vector3                   # final half-size of the play box

func _ready() -> void:
	if camera_3d == null:
		push_warning("PlayWindow: camera not found — defaulting to 8x5 box")
		half_extents = Vector3(8, 5, depth * 0.5)
	else:
		# Figure out screen half-width/height at the plane where the player sits.
		# Perspective: width = 2 * z * tan(FOV/2), Orthographic: height = cam.size
		var aspect := float(camera_3d.get_viewport().size.x) / float(camera_3d.get_viewport().size.y)
		if camera_3d.projection == Camera3D.PROJECTION_PERSPECTIVE:
			# Either use reference_distance (player depth) or something in front of camera
			var z_dist := reference_distance
			if z_dist == 0.0:
				# default to distance from camera to this node’s position
				z_dist = abs(global_position.z - camera_3d.global_position.z)
			var half_h := z_dist * tan(deg_to_rad(camera_3d.fov * 0.5))
			var half_w := half_h * aspect
			half_extents = Vector3(half_w + gutter, half_h + gutter, depth * 0.5)
		else:
			var half_h := camera_3d .size * 0.5
			var half_w := half_h * aspect
			half_extents = Vector3(half_w + gutter, half_h + gutter, depth * 0.5)

	add_to_group("play_window")

# The bullet calls this each frame to check if it’s inside
func contains_point(point_world: Vector3) -> bool:
	var center := global_transform.origin
	var d := point_world - center
	return (abs(d.x) <= half_extents.x
		 and abs(d.y) <= half_extents.y
		 and abs(d.z) <= half_extents.z)
