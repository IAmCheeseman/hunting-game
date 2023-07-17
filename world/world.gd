extends Node2D

@onready var world_generator: WorldGenerator = $WorldGenerator

var previous_chunk: Rect2

func _ready() -> void:
	randomize()
	GameManager.world_seed = randi()
	
	GameManager.world = self
	previous_chunk = WorldGenerator.get_gen_rect(self)
	world_generator.generate()

func _process(_delta: float) -> void:
	var current_chunk = WorldGenerator.get_gen_rect(self)
	if previous_chunk != current_chunk:
		world_generator.generate()
		previous_chunk = current_chunk
	
	if Input.is_key_pressed(KEY_R):
		DroppedItem.items = []
		get_tree().reload_current_scene()
