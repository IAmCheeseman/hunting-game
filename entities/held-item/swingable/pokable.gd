extends Swingable
class_name Pokeable

func charge_animation() -> void:
	sprite.offset.y = 0

func swing_animation(delta: float) -> void:
	var poke := 1.0 if swing_dir -1 else -0.4
	var poke_dist: float = sprite.texture.get_width() * 0.8
	
	sprite.position.x = lerp(sprite.position.x, poke_dist * poke, 16 * delta)
	if sprite.position.x > poke_dist - 1:
		swing_dir = 1
	
	sprite.rotation_degrees = -item.item.throw_straight_offset
	sprite.offset.y = sprite.texture.get_height() / 2
	if not sprite.flip_v:
		sprite.offset.y *= -1
	
	_snap_rotation()

#	sprite.flip_h = false
