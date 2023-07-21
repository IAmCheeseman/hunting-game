extends Node2D
class_name AnimalSpawner

const ANIMALS: Array[PackedScene] = [
	preload("res://entities/attackable/prey/bunny/bunny.tscn"),
	preload("res://entities/attackable/prey/deer/deer.tscn"),
]

var _spawn_timer := Timer.new()

func _get_camera_rect() -> Rect2:
	var size = get_viewport_rect().size
	return Rect2(GameManager.camera.global_position, size)

func _get_position() -> Vector2:
	var offset = Vector2.RIGHT.rotated(randf() * TAU) * get_viewport_rect().size * 2
	return GameManager.player.global_position + offset

func _ready() -> void:
	add_child(_spawn_timer)
	_spawn_timer.timeout.connect(_spawn_animal)
	_spawn_timer.start(2)

func _spawn_animal() -> void:
	var exclude = _get_camera_rect()
	
	var pos = _get_position()
	while exclude.has_point(pos):
		pos = _get_position()
	
	var animal: Attackable = Utils.get_random(ANIMALS).instantiate()
	animal.position = pos
	GameManager.world.add_child(animal)
