extends CharacterBody2D

@export var speed = 120.0
@export var acceleration = 1800.0
@export var deceleration = 2400.0

@onready var gun : Node2D = $Gun
@onready var gun_pivot : Marker2D = $GunPivot

const ROTATION_DEADZONE = 10.0

func _process(delta: float) -> void:
	var mouse_position := get_global_mouse_position()
	var distance_to_mouse := gun_pivot.global_position.distance_to(mouse_position)
	
	if (distance_to_mouse > ROTATION_DEADZONE):
		var mouse_direction := gun_pivot.global_position.direction_to(mouse_position)
	
		gun.global_position = gun_pivot.global_position + mouse_direction * ROTATION_DEADZONE
		
		gun.scale.y = 1 if mouse_direction.x > 0 else -1
		gun.show_behind_parent = mouse_direction.y < 0
	
		gun.look_at(mouse_position)

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var target_velocity = direction * speed
	velocity = velocity.move_toward(target_velocity, acceleration * delta)
	
	if (direction == Vector2.ZERO):
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
		
	move_and_slide()
	
	if (velocity.length() > 0.0):
		%AnimatedSprite2D.play("run")
	else:
		%AnimatedSprite2D.play("idle")
	
	if velocity.x:
		%AnimatedSprite2D.flip_h = velocity.x < 0
