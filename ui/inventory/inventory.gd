extends Control

const SLOT := preload("res://ui/inventory/slot.tscn")

@onready var items: GridContainer = %Items
@onready var tooltip: Control = %Tooltip

var open := false
var selected := -1

func _ready() -> void:
	Inventory.data.connect("items_changed", _on_items_changed)
	_on_items_changed(null)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory") and \
	(not GameManager.is_gui_open or open):
		open = not open
		GameManager.is_gui_open = open
	
	if open:
		scale = scale.move_toward(Vector2.ONE, 12 * delta)
	else:
		scale = scale.move_toward(Vector2.ZERO, 24 * delta)

func _on_items_changed(_item: Item) -> void:
	Utils.free_children(items)
	
	for i in Inventory.get_inventory_snapshot():
		var slot := SLOT.instantiate()
		slot.item = i
		slot.connect("hover_updated", _on_slot_hover_update)
		items.add_child(slot)

func _on_slot_hover_update(slot: Control) -> void:
	selected = slot.get_index()
	tooltip.set_item(slot.item)
	if not slot.mouse_hovering:
		selected = -1
		tooltip.set_item(null)

func _unhandled_input(event: InputEvent) -> void: 
	if event.is_action_pressed("move_item"):
		if Inventory.data.mouse_slot == null:
			Inventory.move_to_mouse_slot(selected)
			get_viewport().set_input_as_handled()
		elif selected == -1:
			var item = Item.create_drop(Inventory.data.mouse_slot)
			item.global_position = GameManager.player.global_position
			item.velocity = GameManager.player.global_position.direction_to(
				GameManager.player.get_global_mouse_position()) * 100
			GameManager.world.add_child(item)
			Inventory.data.mouse_slot = null
		else: 
			Inventory.drop_mouse_slot(selected)
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("drop_item") and Inventory.data.mouse_slot != null:
		var item = Item.create_drop(Inventory.data.mouse_slot)
		item.global_position = GameManager.player.global_position
		item.velocity = GameManager.player.global_position.direction_to(
			GameManager.player.get_global_mouse_position()) * 100
		GameManager.world.add_child(item)
		Inventory.data.mouse_slot = null
