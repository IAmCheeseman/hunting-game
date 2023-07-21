extends Prey

const RABBIT_ITEM := preload("res://items/rabbit/rabbit.tres")

@export var wander_speed := 100.0
@export var run_speed := 300.0
@export var accel := 30.0

@export var min_hop_time := 0.5
@export var max_hop_time := 1.0

@export var scared_min_hop_time := 0.25
@export var scared_max_hop_time := 0.5

@onready var hop_timer := $HopTime
@onready var anim := $AnimationPlayer

var hop_direction: Vector2
var player: CharacterBody2D

var _s_scared := State.new("scared") \
	.callback(State.CallbackType.PROC, _process_scared)

func _change_hop_direction() -> void:
	if _state_machine.get_state_name() == "scared":
		_change_hop_direction_scared()
		return
	hop_direction = _get_wander_direction()
	hop_timer.start(randf_range(min_hop_time, max_hop_time))

func _change_hop_direction_scared() -> void:
	hop_direction = _get_wander_direction()
	var player_dir = global_position.direction_to(GameManager.player.global_position)
	if hop_direction.dot(player_dir) > 0.5:
		_change_hop_direction_scared()
		return
	hop_timer.start(randf_range(scared_min_hop_time, scared_max_hop_time))

func _ready_() -> void:
	_change_hop_direction()

func _process(delta: float) -> void:
	super._process(delta)
	
	if global_position.distance_to(GameManager.camera.global_position) > 640:
		queue_free() 

func _process_default(delta: float) -> void:
	velocity = velocity.move_toward(hop_direction * wander_speed, accel * delta)
	sprite.scale.x = 1 if velocity.x < 0 else -1
	anim.play("hop")
	move_and_slide() 
	
	player = player_detector.get_player()
	if is_instance_valid(player):
		_state_machine.change_state(_s_scared)
 
func _process_scared(delta: float) -> void:
	velocity = hop_direction * run_speed
	sprite.scale.x = 1 if velocity.x < 0 else -1
	anim.play("hop")
	move_and_slide()
 
func _drop_meat() -> void:
	var drop = Item.create_drop(RABBIT_ITEM)
	drop.global_position = global_position
	call_deferred("add_sibling", drop)
