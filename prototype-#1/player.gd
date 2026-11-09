extends CharacterBody2D

const SMOOTHING_SPEED = 7.0

@export var speed = 120.0
@export var acceleration = 1800.0
@export var deceleration = 2400.0

@onready var gun : Node2D = $GunPivot/Gun
@onready var gun_pivot : Marker2D = $GunPivot

func _process(delta: float) -> void:
	var mouse_position := get_global_mouse_position()
	var rotation_to_mouse = gun_pivot.global_position.angle_to_point(mouse_position)
	var mouse_relative_position := (mouse_position - gun_pivot.global_position)
	
	var weight = 1 - exp(-SMOOTHING_SPEED * delta)
	var orbit_position = lerp_angle(rotation_to_mouse, gun_pivot.rotation, weight)
	
	gun_pivot.global_rotation = orbit_position
	
	gun.scale.y = 1 if mouse_relative_position.x > 0 else -1
	gun_pivot.show_behind_parent = mouse_relative_position.y  < -2

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
