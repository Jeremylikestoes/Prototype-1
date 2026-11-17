extends Node

@onready var player: CharacterBody2D = $"../.."

var acceleration: float = 1800.0
var deceleration: float = 2400.0		
		
func accelerate(target_velocity: Vector2, delta: float) -> void:
	player.velocity = player.velocity.move_toward(target_velocity, acceleration * delta)
	
func decelerate(delta: float) -> void:
	player.velocity = player.velocity.move_toward(Vector2.ZERO, deceleration * delta)
