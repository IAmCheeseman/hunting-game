extends Node2D
class_name HeldItem

const THROWN_ITEM := preload("res://entities/thrown-item/thrown_item.tscn")
const MIN_CHARGE := 0.5
const MAX_CHARGE := 1.5
const CHARGE_BONUS := 3.0

@onready var sprite := $Sprite

var item: ItemState

var charge: float = 0
var total_hold_time: float = 0

func _ready() -> void:
	sprite.texture = item.item.texture

func _snap_rotation() -> void:
	sprite.flip_v = get_global_mouse_position().x < global_position.x
	if not sprite.flip_v:
		sprite.rotation *= -1
	if item.item.throw_straight and charge != 0:
		sprite.flip_v = not sprite.flip_v

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
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
	
	sprite.material.set_shader_parameter("line_thickness", percentage )
	
	if Input.is_action_just_released("throw_item"):
		if charge > MIN_CHARGE:
			var throw := THROWN_ITEM.instantiate()
			throw.item = item
			throw.global_position = global_position
			throw.damage = item.item.throw_damage
			throw.aerodynamicy = item.item.throw_aerodynamicy / bonus
			throw.velocity = global_position.direction_to(
				get_global_mouse_position()) * 150 * bonus
			GameManager.world.add_child(throw)
			Inventory.remove_hotbar_item()
			
		charge = 0
	
	_snap_rotation()
