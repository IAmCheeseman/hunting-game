extends CharacterBody2D

@onready var sprite := $Sprite
@onready var raycast := $RayCast2D
@onready var hitbox := $Hitbox

var aerodynamicy: float 
var damage: float

var item: Item
var shadow: Sprite2D

func _ready() -> void:
	hitbox.damage = damage
	sprite.texture = item.texture
	sprite.position.y = -8
	shadow = SpriteShadow.create(self, sprite)


func _process(delta: float) -> void:
	sprite.rotation += delta * TAU * 5 # rotate 5 times per second
	sprite.position.y = lerpf(sprite.position.y, 0, aerodynamicy * delta)
	
	if sprite.position.y > -1:
		var drop = Item.create_drop(item)
		drop.global_position = global_position
		drop.velocity = velocity / 2
		GameManager.world.add_child(drop)
		queue_free()
	
	raycast.target_position = velocity.normalized() * 8
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var normal: Vector2 = raycast.get_collision_normal()
		velocity = velocity.bounce(normal)
	
	move_and_slide()
	
	SpriteShadow.update(shadow)


func _exit_tree() -> void:
	shadow.queue_free()
