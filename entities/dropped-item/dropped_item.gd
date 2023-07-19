extends CharacterBody2D
class_name DroppedItem

# Here to enforce an item limit so players can't just 
# spam items on the ground and be overall silly
static var items := []
const MAX_ITEM_COUNT = 150

@onready var sprite: Sprite2D = $Sprite
@onready var player_detection: Area2D = $PlayerDetection

@export var allowed_rotation: bool = true

var item: ItemState
var speed := 0.0
var can_pick_up := false

var _s_default := State.new("default") \
	.callback(State.CallbackType.PROC, _default_process)
var _s_pick_up := State.new("pick_up") \
	.callback(State.CallbackType.PROC, _pick_up_process) \
	.callback(State.CallbackType.START, _pick_up_start)
var _state_machine := StateMachine.new(_s_default)

signal picked_up(item: CharacterBody2D)

func _make_space() -> void:
	for i in items.size() - 1:
		var drop = items[items.size() - i - 1]
		if is_instance_valid(drop):
			continue
		items.erase(drop)
	if items.size() > MAX_ITEM_COUNT: # Keep this stuff performant
		var drop = items.pop_front()
		drop.queue_free()

func _ready() -> void:
	global_position = global_position.round()
	sprite.texture = item.item.texture
	sprite.material = sprite.material.duplicate()
	
	if allowed_rotation:
		sprite.rotation = randf() * TAU
	
	_make_space()
	items.append(self)

func _process(delta: float) -> void:
	sprite.material.set_shader_parameter("line_thickness", 0)
	
	_state_machine.process(delta)

func _default_process(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, 250 * delta)
	move_and_slide()
	
	var player = player_detection.get_player()
	if not is_instance_valid(player):
		return
	
	var mouse_close_enough := \
		get_local_mouse_position().length() < item.item.texture.get_width()
	var mouse_clicked := Input.is_action_just_pressed("pick_up")
	if mouse_close_enough and mouse_clicked and not GameManager.is_gui_open:
		if Inventory.add_item(item) == Inventory.Result.OK:
			get_viewport().set_input_as_handled()
			_state_machine.change_state(_s_pick_up)
	
	if mouse_close_enough and not GameManager.is_gui_open:
		sprite.material.set_shader_parameter("line_thickness", 1)

func _pick_up_start() -> void:
	picked_up.emit(self)

func _pick_up_process(delta: float) -> void:
	velocity = global_position.direction_to(GameManager.player.global_position) * speed
	speed += 500 * delta
	move_and_slide()
	
	var distance = global_position.distance_to(GameManager.player.global_position)
	
	sprite.scale = Vector2.ONE * clamp(distance / 16, 0, 1)
	
	if distance < 8:
		queue_free()
