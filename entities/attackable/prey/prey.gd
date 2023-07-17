extends Attackable
class_name Prey


func _on_damage_manager_dead() -> void:
	queue_free()
