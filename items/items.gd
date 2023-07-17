extends RefCounted
class_name Items

static func get_random() -> Item:
	var keys := ITEMS.keys()
	var item: Item = ITEMS[keys[int(randf() * keys.size())]]
	if randf() < item.spawn_chance:
		return item
	return get_random()

const ITEMS = {
	"rock": preload("res://items/rock/rock.tres"),
	"stick": preload("res://items/stick/stick.tres"),
}
