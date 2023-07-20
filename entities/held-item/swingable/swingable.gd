extends HeldItem
class_name Swingable

const SPARKS := preload("res://effects/sparks/sparks.tscn")

@onready var hitbox := $Hitbox
@onready var collision := $Hitbox/CollisionShape2D
@onready var hit_timer := $Hit
@onready var cooldown_timer := $Cooldown

@export var swing_angle := 80.0

var swing_dir := 1
var swing_rot := deg_to_rad(swing_angle)
var swing_flip := false

func _ready() -> void:
	super._ready()
	var shape = item.item.melee_collision
	collision.shape = shape
	hitbox.position.x = shape.extents.x
	hitbox.damage = item.item.melee_damage
	cooldown_timer.wait_time = item.item.melee_cooldown

func _process(delta: float) -> void:
	super._process(delta)
	
	if charge == 0:
		swing_animation(delta)
	else:
		charge_animation()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("item_active") and cooldown_timer.is_stopped():
		collision.disabled = false
		hit_timer.start()
		cooldown_timer.start()
		
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


func _on_hit_timeout() -> void:
	collision.disabled = true

func _on_hit(area) -> void:
	if item.take_damage(1):
		Inventory.remove_item_state(item)
		var sparks := SPARKS.instantiate()
		sparks.global_position = global_position
		GameManager.world.add_child(sparks)
