extends Control

const HOTBAR_TEXTURE := preload("res://ui/inventory/hotbar_slot.png")

@onready var background: TextureRect = $Background
@onready var icon: TextureRect = %Icon

var item: ItemState
var mouse_hovering := false

signal hover_updated(slot: Control)

func _ready() -> void:
	if item == null:
		icon.texture = null
		return
	icon.texture = item.item.texture

func _process(delta: float) -> void:
	if get_index() < Inventory.HOTBAR_END:
		background.texture = HOTBAR_TEXTURE
	
	var target_scale = Vector2.ONE
	if mouse_hovering and not Input.is_action_pressed("move_item"):
		target_scale = Vector2.ONE * 1.4
	
	scale = scale.move_toward(target_scale, 12 * delta)	

func _on_mouse_entered() -> void:
	mouse_hovering = true
	emit_signal("hover_updated", self)

func _on_mouse_exited() -> void:
	mouse_hovering = false
	emit_signal("hover_updated", self)
