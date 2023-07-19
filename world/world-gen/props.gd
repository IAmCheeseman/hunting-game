extends RefCounted
class_name Props

const COST_PER_CHUNK := 10

class PropData:
	var scene: PackedScene
	var chance: float
	var cost: int
	var get_count: Callable
	
	func _init(scene_: PackedScene, chance_: float, cost_: int, amount: Callable) -> void:
		self.scene = scene_
		self.chance = clamp(chance_, 0, 1)
		self.get_count = amount
		self.cost = cost_

#TODO)) Implement prop weighting
static func get_random() -> PropData:
	return Props.PROPS[randf() * Props.PROPS.size()]

static var PROPS: Array[PropData] = [
	PropData.new(
		preload("res://world/props/tree/tree.tscn"),
		0.5,
		5,
		func(x): return ceil(x * 3)
	),
	PropData.new(
		preload("res://world/props/rock/rock.tscn"),
		0.5,
		7,
		func(x): return ceil(x * 2)
	),
	PropData.new(
		preload("res://world/props/grass/grass.tscn"),
		0.5,
		5,
		func(x): return ceil(x * 12)
	)
]
