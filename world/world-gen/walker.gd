extends RefCounted
class_name Walker

const DIRECTIONS: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT
]

var _steps: int
var _straight_steps: int
var _position: Vector2i
var _direction: Vector2i
var _area: Rect2i

var turn_chance := 0.25
var max_steps := 75
var max_straight_steps := 5

func _init(
	turn_chance_: float,
	max_steps_: int,
	max_straight_steps_: int,
	area: Rect2i
) -> void:
	turn_chance = turn_chance_
	max_steps = max_steps_
	max_straight_steps = max_straight_steps_
	_area = area
	
	_change_direction()

func walk() -> Array[Vector2i]:
	var steps: Array[Vector2i] = []
	
	for i in max_steps:
		_step()
		steps.append(_position)
	
	return steps

func _step() -> void:
	if not _area.has_point(_position + _direction) or randf() < turn_chance \
	or _straight_steps >= max_straight_steps:
		_change_direction()
	_position += _direction
	_steps += 1
	_straight_steps += 1

func _change_direction() -> void:
	var direction = Utils.get_random(DIRECTIONS)
	if _direction == direction or not _area.has_point(_position + direction):
		_change_direction()
		return
	_direction = direction
