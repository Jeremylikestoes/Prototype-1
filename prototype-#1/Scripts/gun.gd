extends Node2D

@export var gun_pivot: Marker2D
@export var gun: Node2D
@export var muzzle: Marker2D

var bullet_speed: float = 200.0
var can_shoot: bool = true
var shoot_timer: float = 0.0

func _process(delta: float) -> void:
	_update_gun_rotation(delta)

func _physics_process(delta: float) -> void:
	var mouse_position := get_global_mouse_position()
	var direction: Vector2 =  (mouse_position - muzzle.global_position).normalized()
	
	shoot(direction)
	
	shoot_timer -= delta
	if shoot_timer < 0.0:
		shoot_timer = 0.0

func _update_gun_rotation(delta) -> void:
	var mouse_position := get_global_mouse_position()
	var gun_rotation_to_mouse = gun_pivot.global_position.angle_to_point(mouse_position)
	var mouse_relative_position := (mouse_position - gun_pivot.global_position)
	
	const SMOOTHING_SPEED = 7.0
	var weight: float = 1 - exp(-SMOOTHING_SPEED * delta)
	
	var orbit_position = lerp_angle(gun_rotation_to_mouse, gun_pivot.rotation, weight)
	
	gun_pivot.global_rotation = orbit_position
	
	gun.scale.y = 1 if mouse_relative_position.x > 0 else -1
	gun_pivot.show_behind_parent = mouse_relative_position.y  < -2

func shoot(direction: Vector2) -> void:
	const BULLET = preload("res://Scenes/bullet.tscn")
	
	if Input.is_action_just_pressed("shoot") && shoot_timer == 0.0:
		var new_bullet: Bullet = BULLET.instantiate()
		shoot_timer += 0.5
		
		get_tree().current_scene.add_child(new_bullet)
		new_bullet.global_position = muzzle.global_position
		new_bullet.global_rotation = muzzle.global_rotation
		new_bullet.direction = direction
