extends Area2D

@onready var rc := $RayCast
@export var check_sight := true

signal found_player(player: CharacterBody2D)

func is_player(body: Node2D) -> bool:
	if body.is_in_group("player"):
		rc.target_position = to_local(body.global_position)
		rc.force_raycast_update()
		if rc.is_colliding() and check_sight:
			return false
		return true
	return false

func get_player() -> CharacterBody2D:
	for b in get_overlapping_bodies():
		if is_player(b):
			return b
	return null

func _on_body_entered(body: Node2D) -> void:
	if is_player(body):
		emit_signal("found_player", body as CharacterBody2D)
