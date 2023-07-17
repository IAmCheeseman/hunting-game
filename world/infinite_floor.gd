extends TextureRect

func _process(_delta: float) -> void:
	var rect = WorldGenerator.get_view_rect(self)
	size = rect.size.floor()
	position = rect.position.floor()
