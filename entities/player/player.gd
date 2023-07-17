extends Entity
class_name Player

const DEFAULT_HOLD := preload("res://items/held_item.tscn")
const INVENTORY := preload("res://entities/player/inventory.tres")
const MAX_STAMINA := 100.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var stamina_bar := $Stamina
@onready var stamina_regen_timer := $StaminaRegen

@export var run_speed := 220.0
@export var tired_speed := 90.0
@export var stamina_regen_rate := 10.0
@export var run_stamina := 20.0

var shadow: Sprite2D
var held_item: HeldItem

var stamina := MAX_STAMINA
var out_of_energy := false

func _ready() -> void:
	GameManager.player = self
	INVENTORY.connect("hotbar_item_changed", _on_items_changed)
	INVENTORY.connect("items_changed", _on_items_changed)
	shadow = SpriteShadow.create(self, sprite)

func take_stamina(amount: float) -> void:
	stamina = clamp(stamina - amount, 0, MAX_STAMINA)
	stamina_regen_timer.start()
	if stamina <= 1:
		out_of_energy = true

func can_use_stamina(amount: float) -> bool:
	return stamina - amount > 0 and not out_of_energy

func is_tired() -> bool:
	return out_of_energy

func get_input_dir() -> Vector2:
	var input_dir = Input.get_vector("left", "right", "up", "down")
	input_dir = input_dir.normalized()
	return input_dir

func animate() -> void:
	var input_dir = get_input_dir()
	
	sprite.scale.x = -1 if get_local_mouse_position().x < 0 else 1
	sprite.rotation = velocity.x / 360 
	
	if input_dir.is_zero_approx():
		animation_player.play("idle")
	else:
		animation_player.play("walk", -1, 0.2 + velocity.length() / speed * 1.5)
	
	SpriteShadow.update(shadow)

func _default_process(delta: float) -> void:
	var input_dir = get_input_dir()
	var accel_delta = accel if velocity.dot(input_dir) > 0 else frict
	
	var used_speed = speed
	var run_stamina_usage = run_stamina * delta
	if Input.is_action_pressed("run") and can_use_stamina(run_stamina_usage) \
	and input_dir != Vector2.ZERO:
		take_stamina(run_stamina_usage)
		used_speed = run_speed
	if is_tired():
		used_speed = tired_speed
	
	velocity = velocity.move_toward(input_dir * used_speed, accel_delta * delta)
	move_and_slide()
	
	animate()
	
	stamina_bar.modulate = Color(
		0.2, 1, 0,
		lerp(stamina_bar.modulate.a, 0.0, 5 * delta) 
	)
	
	if stamina_regen_timer.is_stopped():
		var regen = stamina_regen_rate
		if out_of_energy:
			stamina_bar.modulate = Color.ORANGE_RED
			regen /= 2
		stamina = clamp(stamina + regen * delta, 0, MAX_STAMINA)
		if stamina == MAX_STAMINA:
			out_of_energy = false
	
	if stamina != MAX_STAMINA:
		stamina_bar.modulate.a = 1
	
	stamina_bar.value = stamina

func _update_held_item() -> void:
	var item = Inventory.get_selected_hotbar_item()
	
	if held_item != null:
		held_item.queue_free()
	if item == null:
		return
	
	if item.hold:
		held_item = item.hold.instantiate()
	else:
		held_item = DEFAULT_HOLD.instantiate()
	
	held_item.item = item
	held_item.position = Vector2(0, -4)
	add_child(held_item)

func _on_items_changed(_item: Item) -> void:
	_update_held_item()
