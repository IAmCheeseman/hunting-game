extends "res://ui/inventory/slot.gd"

func _process(_delta: float) -> void:
	var mouse_slot := Inventory.data.mouse_slot
	if mouse_slot != null:
		icon.texture = mouse_slot.item.texture
		visible = true
		global_position = get_global_mouse_position()
		
		progress.visible = mouse_slot.item.durability != -1
		progress.value = float(mouse_slot.uses_left) / float(mouse_slot.item.durability)
	else:
		visible = false

func _gui_input(_event: InputEvent) -> void:
	pass
