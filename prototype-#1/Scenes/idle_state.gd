class_name IdleState
extends PlayerMovement

func _handle_idle(_direction: Vector2, delta: float) -> void:
	player.velocity = player.velocity.move_toward(Vector2.ZERO, deceleration * delta)
