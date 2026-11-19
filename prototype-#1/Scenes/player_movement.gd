class_name PlayerMovement
extends Node

@export var player: Player
@export var dodge_state: DodgeState

@export var focus_component: FocusComponent

var acceleration: float = 1800.0
var deceleration: float = 2400.0

func _accelerate(target_velocity: Vector2, delta: float) -> void:
	player.velocity = player.velocity.move_toward(target_velocity, acceleration * delta)

func _decelerate(delta: float) -> void:
	player.velocity = player.velocity.move_toward(Vector2.ZERO, deceleration * delta)

func _is_idle(direction: Vector2) -> bool:
	if direction == Vector2.ZERO and player.velocity.length() < 1.0:
		return true
	else: 
		return false

func _is_moving(direction: Vector2) -> bool:
	if direction != Vector2.ZERO:
		return true
	else:
		return false

func _is_dodging() -> bool:
	if Input.is_action_just_pressed("dodge") and dodge_state.can_dodge:
		return true
	else:
		return false
