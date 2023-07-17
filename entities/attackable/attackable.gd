extends CharacterBody2D
class_name Attackable

@onready var sprite := $Scaler/Sprite
@onready var player_detector := $PlayerDetection

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
