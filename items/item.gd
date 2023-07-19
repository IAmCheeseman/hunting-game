extends Resource
class_name Item

const DROPPED_ITEM := preload("res://entities/dropped-item/dropped_item.tscn")

enum Rarity {
	COMMON,
	NORMAL,
	RARE,
	SUPER_RARE,
}

@export var texture: Texture2D
@export var hold: PackedScene
@export var translation_id: String
@export var rarity: Rarity = Rarity.COMMON
@export var spawn_chance: float = 1.0
@export var tooltip: Array[TooltipData] = []

@export var durability: int = -1

@export_subgroup("Throwing", "throw")
@export var throw_aerodynamicy := 12.0 
@export var throw_damage: int = 5
@export var throw_straight: bool = false
@export var throw_straight_offset: float = 0
@export var pierces: bool = false

@export_subgroup("Melee", "melee")
@export var melee_damage: int = 5
@export var melee_cooldown: float = 0.4
@export var melee_collision: RectangleShape2D


func get_item_name() -> String:
	return "item.%s.name" % translation_id

func get_description() -> String:
	return "item.%s.desc" % translation_id

func get_rarity_string() -> String:
	match rarity:
		Rarity.COMMON:
			return "rarity.common"
		Rarity.NORMAL:
			return "rarity.normal"
		Rarity.RARE:
			return "rarity.rare"
		Rarity.SUPER_RARE:
			return "rarity.superrare"
	return "Invalid rarity"

func get_tooltip() -> String:
	var tooltip_str = "%s" % get_item_name()
	tooltip_str += "\n%s" % get_description()
	return tooltip_str

static func create_drop(item: Item) -> CharacterBody2D:
	var drop = DROPPED_ITEM.instantiate()
	drop.item = ItemState.new(item)
	return drop

static func create_drop_from(item: ItemState) -> CharacterBody2D:
	var drop = DROPPED_ITEM.instantiate()
	drop.item = item
	return drop
