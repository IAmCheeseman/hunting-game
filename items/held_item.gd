extends Node2D
class_name HeldItem

const THROWN_ITEM := preload("res://entities/thrown-item/thrown_item.tscn")
const MIN_CHARGE := 0.5
const MAX_CHARGE := 1.5
const CHARGE_BONUS := 3.0

@onready var sprite := $Sprite

var item: Item

var charge: float = 0
var total_hold_time: float = 0

func _ready() -> void:
	sprite.texture = item.texture

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	rotation_degrees = snapped(rotation_degrees, 6)
	
	sprite.flip_h = get_global_mouse_position().x < global_position.x
	
	if Input.is_action_pressed("throw_item"):
		charge += delta
		total_hold_time += delta
		charge = clamp(charge, 0, MAX_CHARGE)
	
	var percentage = charge / MAX_CHARGE
	var bonus = CHARGE_BONUS * percentage
	
	if percentage >= 1:
		sprite.rotation = PI / 2 + sin(total_hold_time * 60) / 4 
	else:
		sprite.rotation = percentage * (PI / 2)
	sprite.rotation_degrees = snapped(sprite. rotation_degrees, 6)
	if not sprite.flip_h:
		sprite.rotation *= -1
	
	sprite.material.set_shader_parameter("line_thickness", percentage )
	
	if Input.is_action_just_released("throw_item"):
		if charge > MIN_CHARGE:
			var throw := THROWN_ITEM.instantiate()
			throw.item = item
			throw.global_position = global_position
			throw.damage = item.throw_damage
			throw.aerodynamicy = item.throw_aerodynamicy / bonus
			throw.velocity = global_position.direction_to(
				get_global_mouse_position()) * 150 * bonus
			GameManager.world.add_child(throw)
			Inventory.remove_hotbar_item()
			
		charge = 0
