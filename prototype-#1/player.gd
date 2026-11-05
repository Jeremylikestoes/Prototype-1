extends CharacterBody2D

@export var speed = 120.0
@export var acceleration = 1800.0
@export var deceleration = 2400.0

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var target_velocity = direction * speed
	velocity = velocity.move_toward(target_velocity, acceleration * delta)
	
	if (direction == Vector2.ZERO):
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
		
	move_and_slide()
	
	
