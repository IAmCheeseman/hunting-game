extends Control

@onready var icon: TextureRect = %Icon

var item: Item

func _ready() -> void:
	if item == null:
		icon.texture = null
		return
	icon.texture = item.texture

func _process(delta: float) -> void:
	if get_index() == Inventory.data.current_slot:
		scale = scale.move_toward(Vector2.ONE * 1.4, 12 * delta)
	else:
		scale = scale.move_toward(Vector2.ONE, 12 * delta)
