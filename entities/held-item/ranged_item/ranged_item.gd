extends HeldItem
class_name RangedItem

@export var ammo: Array[Item] = []
@export var projectile_speed := 600.0

var charge_timer := 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	super._process(delta)
	
	if Input.is_action_pressed("item_active"):
		charge_timer += delta
	
	if charge == 0:
		var percentage = charge_timer / item.item.melee_cooldown
		sprite.frame = clamp(percentage * (sprite.hframes - 1), 0, 2)
	else:
		sprite.frame = 0
	
	if Input.is_action_just_released("item_active"):
		var charged_up = charge_timer > item.item.melee_cooldown
		charge_timer = 0
		if charged_up and not GameManager.is_gui_open:
			var selected_projectile := ammo[0]
			var i = 1
			while Inventory.count_item(selected_projectile) == 0:
				selected_projectile = ammo[i]
				i += 1
				if i >= ammo.size():
					return
			
			var throw := THROWN_ITEM.instantiate()
			throw.item = Inventory.remove_items(selected_projectile, 1)
			throw.global_position = global_position
			throw.damage = selected_projectile.throw_damage + item.item.melee_damage
			throw.aerodynamicy = selected_projectile.throw_aerodynamicy / item.item.throw_aerodynamicy
			throw.velocity = global_position.direction_to(
				get_global_mouse_position()) * projectile_speed
			GameManager.world.add_child(throw)
