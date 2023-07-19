extends Resource
class_name Inventory

## Holds and manages items in an inventory.

const SLOT_COUNT := 12 ## The amount of slots in the inventory.
const HOTBAR_END := 4 ## The ending index of the hotbar

enum Result {
	OK, ## Action executed successfully.
	NO_ITEM, ## There is none of the specified item.
	NO_SPACE, ## There is no space in the inventory.
	SLOT_TAKEN, ## Slot cannot be overridden.
	INVALID_TYPE, ## Slot is already filled with another type.
	MOUSE_SLOT_FULL, ## Cannot override mouse slot.
	NO_HELD_ITEM, ## You are not holding an item.
	BAD_ITEM, ## Item data is incorrect.
}

## Emitted when items are changed
signal items_changed(item: ItemState)
## Emitted when an item is added
signal added_item(item: ItemState)
## Emitted when an item is removed
signal removed_item(item: ItemState)
## Emitted when the current slot changes
signal hotbar_item_changed(item: ItemState)

static var data: Inventory ## The current player's inventory.
var mouse_slot: ItemState ## The mouse slot.
var current_slot := 0 ## The current hotbar slot.
var _mouse_index := 0
var _items: Array[ItemState] = []

func _init() -> void:
	data = self
	Inventory.clear()

# Returns an item slot with the specified item
# if there is viable no slot, then it returns null.
func _get_open_slot() -> int:
	var index := 0
	for i in _items:
		if i == null:
			return index
		index += 1
	return -1

## Adds one instance of item to the inventory.
static func add_item(item: ItemState) -> Result:
	var slot := data._get_open_slot()
	if slot == -1:
		return Result.NO_SPACE
	data._items[slot] = item
	data.emit_signal("items_changed", item)
	data.emit_signal("added_item", item)
	return Result.OK

## Gets the amount of this item in your inventory.
static func count_item(item: Item) -> int:
	var count := 0
	for i in data._items:
		if i == null:
			continue
		if i.item == item:
			count += 1
	return count

## Removes a specified amount of items from the inventory.
static func remove_items(item: Item, count: int = 1) -> Result:
	for i in count:
		var index = -1
		for j in data._items:
			index += 1
			if j == null:
				continue
			if j.item == item:
				data._items[index] = null
				data.emit_signal("items_changed", j)
				data.emit_signal("removed_item", j)
				break
	
	return Result.OK

## Picks up the specified slot and puts it in the mouse slot.
static func move_to_mouse_slot(index: int) -> Result:
	if data._items[index] == null:
		return Result.NO_ITEM
	if data.mouse_slot != null:
		return Result.MOUSE_SLOT_FULL
	
	var slot = data._items[index]
	data.mouse_slot = slot
	data._mouse_index = index
	data._items[index] = null
	
	data.emit_signal("items_changed", slot)
	data.emit_signal("removed_item", slot)
	
	return Result.OK

## Drops the mouse slot into the specified slot.
static func drop_mouse_slot(index: int) -> Result:
	# Swap items
	var item = data._items[index]
	data._items[index] = data.mouse_slot
	data.mouse_slot = item
	
	data.emit_signal("items_changed", data._items[index])
	data.emit_signal("added_item", data._items[index])
	if data.mouse_slot != null:
		data.emit_signal("removed_item", data.mouse_slot)
	
	return Result.OK

## Drops the currently selected hotbar item.
static func drop_selected_item() -> void:
	var selected := get_selected_hotbar_item()
	if selected == null:
		return
	
	var item = Item.create_drop_from(selected)
	item.global_position = GameManager.player.global_position
	item.velocity = GameManager.player.global_position.direction_to(
		GameManager.player.get_global_mouse_position()) * 100
	GameManager.world.add_child(item)
	
	data._items[data.current_slot] = null
	data.emit_signal("items_changed", item.item)
	data.emit_signal("removed_item", item.item)

## Clears the invetory
static func clear() -> void:
	data._items.clear()
	for i in SLOT_COUNT:
		data._items.append(null)

## Moves the hotbar slot by the amount specified.
static func move_hotbar_slot(by: int) -> void:
	data.current_slot = wrapi(
			data.current_slot + by, 0, Inventory.HOTBAR_END)
	data.emit_signal("hotbar_item_changed", data._items[data.current_slot])

## Sets the hotbar slot to the specified slot instantly.
static func set_hotbar_slot(to: int) -> void:
	data.current_slot = wrapi(to, 0, Inventory.HOTBAR_END)
	data.emit_signal("hotbar_item_changed", data._items[data.current_slot])

## Removes the currently selected hotbar item.
static func remove_hotbar_item() -> void:
	var item := data._items[data.current_slot]
	data._items[data.current_slot] = null
	data.emit_signal("items_changed", item)
	data.emit_signal("removed_item", item)

## Returns the item you are currently holding.
static func get_selected_hotbar_item() -> ItemState:
	return data._items[data.current_slot]

## Returns a copy of the inventory.
static func get_inventory_snapshot() -> Array[ItemState]:
	return data._items.duplicate()
