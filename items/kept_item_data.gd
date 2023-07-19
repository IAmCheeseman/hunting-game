extends RefCounted
class_name ItemState

## The item it's representing
var item: Item

## The amount of uses left on this item
var uses_left: int

func _init(item_: Item) -> void:
	item = item_
	uses_left = item.durability

## Takes a point off the durability, returns true if the item broke.
func take_damage() -> bool:
	uses_left -= 1
	if uses_left <= 0 and item.durability > 0:
		Utils.create_new_dialog("Your %s broke!" % tr(item.get_item_name()).to_lower())
		return true
	return false
