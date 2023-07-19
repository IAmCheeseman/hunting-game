extends CharacterBody2D

@onready var sprite := $Sprite2D
@onready var raycast := $RayCast2D

var shadow: Sprite2D
var copy_sprite: Sprite2D
var frame: int

func _ready() -> void:
	sprite.texture = copy_sprite.texture
	sprite.hframes = copy_sprite.hframes
	sprite.frame = frame
	sprite.offset.y = -sprite.texture.get_height() / 2
	
	shadow = SpriteShadow.create(self, sprite)

func _process(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
	raycast.target_position = velocity.normalized() * 16
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var normal: Vector2 = raycast.get_collision_normal()
		velocity = velocity.bounce(normal)
	move_and_slide()
	
	SpriteShadow.update(shadow)
