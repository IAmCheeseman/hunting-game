extends Control

@onready var icon: TextureRect = %Icon
@onready var progress: ProgressBar = %Progress

var item: ItemState

func _ready() -> void:
	if item == null:
		icon.texture = null
		return
	icon.texture = item.item.texture

func _process(delta: float) -> void:
	progress.visible = false
	if item:
		progress.visible = item.item.durability != -1
		progress.value = float(item.uses_left) / float(item.item.durability)
	
	if get_index() == Inventory.data.current_slot:
		scale = scale.move_toward(Vector2.ONE * 1.4, 12 * delta)
	else:
		scale = scale.move_toward(Vector2.ONE, 12 * delta)
