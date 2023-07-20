extends CharacterBody2D

const SPARKS := preload("res://effects/sparks/sparks.tscn")

@onready var sprite := $Sprite
@onready var raycast := $RayCast2D
@onready var hitbox := $Hitbox

var aerodynamicy: float 
var damage: float
var ranged_damage := 0.0

var item: ItemState

func _ready() -> void:
	hitbox.damage = damage + ranged_damage
	sprite.texture = item.item.texture
	sprite.position.y = -8
	GameManager.camera.shake(1, 2, 4, 0.05, 0.1, true)

func _process(delta: float) -> void:
	if item.item.throw_straight:
		sprite.rotation = velocity.angle() + deg_to_rad(item.item.throw_straight_offset)
	else:
		sprite.rotation += delta * TAU * 5 # rotate 5 times per second
	sprite.position.y = lerpf(sprite.position.y, 0, aerodynamicy * delta)
	
	if sprite.position.y > -1:
		_drop(velocity / 2)
	
	raycast.target_position = velocity.normalized() * 8
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var normal: Vector2 = raycast.get_collision_normal()
		velocity = velocity.bounce(normal)
		GameManager.camera.shake(2, 2, 4, 0.05, 0.2, true)
		if item.take_damage(2):
			# This item should break
			spark()
			queue_free()
	
	move_and_slide()

func _on_hit(area) -> void:
	if item.take_damage(2):
		# This item should break
		spark()
		queue_free()
		return
	if not item.item.pierces:
		_drop(Vector2.ZERO)

func _drop(vel: Vector2) -> void:
	var drop = Item.create_drop_from(item)
	drop.global_position = global_position
	drop.velocity = vel
	GameManager.world.call_deferred("add_child", drop)
	queue_free()

func spark() -> void:
	var sparks := SPARKS.instantiate()
	sparks.global_position = global_position
	GameManager.world.add_child(sparks)
