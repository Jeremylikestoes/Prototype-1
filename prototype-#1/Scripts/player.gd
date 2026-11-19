class_name Player
extends CharacterBody2D

@export var state_machine: StateMachine
@export var animated_sprite: AnimatedSprite2D

var speed: float = 120.0

func _process(_delta: float) -> void:
	if get_local_mouse_position().x != 0:
		animated_sprite.flip_h = get_local_mouse_position().x < 0

func _physics_process(delta: float) -> void:
	state_machine._update(_get_direction(), delta)

func _get_direction() -> Vector2:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	return direction.round().normalized()
