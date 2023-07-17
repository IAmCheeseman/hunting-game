extends VBoxContainer

const SLOT := preload("res://ui/hotbar/hotbar_slot.tscn")

@onready var items := $Items
@onready var item_name := $ItemName

func _ready() -> void:
	Inventory.data.connect("items_changed", _on_items_changed)
	Inventory.data.connect("items_changed", _on_hotbar_slot_changed)
	Inventory.data.connect("hotbar_item_changed", _on_hotbar_slot_changed)
	_on_items_changed(null)

func _on_items_changed(_item: Item) -> void:
	Utils.free_children(items)
	
	var inventory = Inventory.get_inventory_snapshot()
	for i in Inventory.HOTBAR_END:
		var slot := SLOT.instantiate()
		slot.item = inventory[i]
		items.add_child(slot)

func _on_hotbar_slot_changed(_item: Item) -> void:
	var item := Inventory.get_selected_hotbar_item()
	if item != null:
		item_name.text = item.get_item_name()
	else:
		item_name.text = ""

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("scroll_up"):
		Inventory.move_hotbar_slot(1)
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("scroll_down"):
		Inventory.move_hotbar_slot(-1)
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("drop_item"):
		Inventory.drop_selected_item()
	
	for i in 4:
		if event.is_action_pressed("slot_%d" % (i + 1)):
			Inventory.set_hotbar_slot(i)
			get_viewport().set_input_as_handled()
			break
