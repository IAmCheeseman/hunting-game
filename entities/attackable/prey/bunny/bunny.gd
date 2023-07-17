extends Prey

const RABBIT_ITEM := preload("res://items/rabbit/rabbit.tres")

@export var wander_speed := 100.0
@export var run_speed := 300.0
@export var accel := 30.0

@export var min_hop_time := 0.5
@export var max_hop_time := 1.0

@onready var hop_timer := $HopTime
@onready var anim := $AnimationPlayer

var hop_direction: Vector2
var player: CharacterBody2D

var _s_scared := State.new("scared") \
	.callback(State.CallbackType.PROC, _process_scared)

func _change_hop_direction() -> void:
	hop_direction = _get_wander_direction()
	hop_timer.start(randf_range(min_hop_time, max_hop_time))

func _ready_() -> void:
	_change_hop_direction()

func _process_default(delta: float) -> void:
	velocity = velocity.move_toward(hop_direction * wander_speed, accel * delta)
	sprite.scale.x = 1 if velocity.x < 0 else -1
	anim.play("hop")
	move_and_slide() 
	
	player = player_detector.get_player()
	if is_instance_valid(player):
		_state_machine.change_state(_s_scared)
	
	if global_position.distance_to(GameManager.camera.global_position) > 640:
		queue_free() 
 
func _process_scared(delta: float) -> void:
	var direction = -global_position.direction_to(player.global_position)
	velocity = velocity.move_toward(direction * run_speed, accel * delta * 4)
	sprite.scale.x = 1 if velocity.x < 0 else -1
	anim.play("hop")
	move_and_slide()
	
	if global_position.distance_to(player.global_position) > 640:
		queue_free() 
 
func _drop_meat() -> void:
	var drop = Item.create_drop(RABBIT_ITEM)
	drop.global_position = global_position
	call_deferred("add_sibling", drop)
