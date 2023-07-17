extends Node2D
class_name Prop

@onready var sprite := $Sprite
@onready var drop_positions := $PropPositions

@export var item: Item
@export var spawn_min := 1
@export var spawn_max := 2

var world_generator: WorldGenerator

var shadow: Sprite2D
var excluded := []
var picked_up_items: Array = []

func _ready() -> void:
	shadow = SpriteShadow.create(self, sprite)
	picked_up_items = world_generator.get_state(self, 0, [])
	
	if item == null:
		return
	
	for i in randi_range(spawn_min, spawn_max):
		var drop = Item.create_drop(item)
		drop.position = get_drop_position().position
		drop.picked_up.connect(_on_item_picked_up.bind(i))
		add_child(drop)
		if i in picked_up_items:
			drop.queue_free()
			continue
	
	excluded.clear()
	drop_positions.queue_free()

func _process(_delta: float) -> void:
	SpriteShadow.update(shadow)

func _exit_tree() -> void:
	shadow.queue_free()

func _on_item_picked_up(_item: CharacterBody2D, index: int) -> void:
	picked_up_items.append(index)
	world_generator.register_state(self, 0, picked_up_items)

func get_drop_position():
	var drop_position = drop_positions.get_child(randi() % drop_positions.get_child_count())
	if drop_position in excluded:
		return get_drop_position()
	excluded.append(drop_position)
	return drop_position
