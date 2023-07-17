extends "res://ui/inventory/slot.gd"

func _process(_delta: float) -> void:
	if Inventory.data.mouse_slot != null:
		icon.texture = Inventory.data.mouse_slot.texture
		visible = true
		global_position = get_global_mouse_position()
	else:
		visible = false

func _gui_input(_event: InputEvent) -> void:
	pass
