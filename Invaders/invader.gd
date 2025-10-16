extends Node3D
class_name Invader

@export var max_hp: int = 1
@export var score_value: int = 100
@export var collision_damage: int = 1

signal docked(invader: Node)
signal died(invader: Node)

enum State { DOCKING, DOCKED, DIVING, RETURNING, DEAD }
var state: int = State.DOCKING
var hp: int
var slot_local_offset: Vector3 = Vector3.ZERO

func _ready() -> void:
	hp = max_hp

func set_slot_info(slot_offset: Vector3) -> void:
	slot_local_offset = slot_offset

func place_offscreen(x_offset: float, y_offset: float) -> void:
	position = slot_local_offset + Vector3(x_offset, y_offset, 0)
	state = State.DOCKING

func start_docking(dock_time: float = 0.6, delay: float = 0.0) -> void:
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", slot_local_offset, dock_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished
	state = State.DOCKED
	emit_signal("docked", self)

func apply_damage(amount: int) -> void:
	if state == State.DEAD:
		return
	hp -= amount
	if hp <= 0:
		state = State.DEAD
		emit_signal("died", self)
		queue_free()

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("player_bullet"):
		StateManager.current_manager.current_level.score += score_value
		StateManager.current_manager.update_hud()
		apply_damage(1)
		area.despawn()
	elif area.is_in_group("playership") and area.owner is PlayerShip:
		if not area.owner.is_invulnerable:
			area.owner.take_damage(collision_damage)
			StateManager.current_manager.current_level.score += score_value
			StateManager.current_manager.update_hud()
			apply_damage(1)
