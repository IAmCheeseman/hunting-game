extends CanvasGroup
class_name SpriteShadow

const SHADOW_MATERIAL := preload("res://effects/shadow.tres")

static var current: CanvasGroup
static var shadow_length := 0.5

func _ready() -> void:
	current = self
	z_index = -1
#	self_modulate = Color("#00000050")
#	self_modulate = Color("#5ac54f")

static func create(tracker: Node2D, sprite: Sprite2D) -> Sprite2D:
	assert(current != null, "No sprite shadow in scene.")
	
	var shadow := sprite.duplicate()
	shadow.material = null
	shadow.set_meta("sprite", sprite)
	shadow.set_meta("tracker", tracker)
	current.add_child(shadow)
	update(shadow)
	return shadow 

static func update(shadow: Sprite2D) -> void:
	var sprite := shadow.get_meta("sprite") as Sprite2D
	var tracker := shadow.get_meta("tracker") as Node2D
	shadow.scale = sprite.scale * Vector2(1, -shadow_length)
	shadow.rotation = -sprite.rotation
	shadow.global_position = tracker.global_position + sprite.position * Vector2(1, -2)
	shadow.frame = sprite.frame
