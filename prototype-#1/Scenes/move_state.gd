class_name MoveState
extends PlayerMovement

func _handle_movement(direction: Vector2, delta: float):
	var target_velocity = direction * player.speed
	
	if direction:
		_accelerate(target_velocity, delta)
	else:
		_decelerate(delta)
