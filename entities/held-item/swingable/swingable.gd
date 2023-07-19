extends HeldItem
class_name Swingable

@export var swing_angle := 80.0

var swing_dir := 1
var swing_rot := deg_to_rad(swing_angle)
var swing_flip := false

func _process(delta: float) -> void:
	super._process(delta)
	
	if charge == 0:
		swing_animation(delta)
	else:
		charge_animation()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("item_active"):
		swing_dir *= -1
		swing_flip = not swing_flip

func charge_animation() -> void:
	pass

func swing_animation(delta: float) -> void:
	swing_rot = lerp_angle(swing_rot, swing_dir * deg_to_rad(swing_angle), 26 * delta)
	sprite.rotation += swing_rot
	
	_snap_rotation()
	
	if sprite.flip_v:
		sprite.flip_v = not swing_flip
	else:
		sprite.flip_v = swing_flip
