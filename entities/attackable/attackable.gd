extends CharacterBody2D
class_name Attackable

const CORPSE := preload("res://entities/corpse/corpse.tscn")

@onready var sprite := $Scaler/Sprite
@onready var player_detector := $PlayerDetection

@export var corpse_frame := 2

var shadow: Sprite2D

var _s_default := State.new("default") \
	.callback(State.CallbackType.PROC, _process_default)
var _state_machine := StateMachine.new(_s_default)

func _ready() -> void:
	shadow = SpriteShadow.create(self, sprite)
	_ready_()

func _ready_() -> void:
	pass

func _process(delta: float) -> void:
	_state_machine.process(delta)
	SpriteShadow.update(shadow)

func _get_wander_direction() -> Vector2:
	return Vector2.RIGHT.rotated(randf() * TAU)

func _process_default(_delta: float) -> void:
	pass

func _exit_tree() -> void:
	shadow.queue_free()

func _on_death() -> void:
	var corpse := CORPSE.instantiate()
	corpse.position = position
	corpse.copy_sprite = sprite
	corpse.frame = corpse_frame
	corpse.velocity = velocity
	GameManager.world.add_child(corpse)
