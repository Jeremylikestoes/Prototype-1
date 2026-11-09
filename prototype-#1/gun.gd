extends Node2D

@export var bullet_speed: float = 200.0
@onready var muzzle: Marker2D = $Muzzle
@onready var gun: Node2D = $"."

var can_shoot: bool = true
var shoot_timer: float = 0.0

func _physics_process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	var direction: Vector2 =  (mouse_position - muzzle.global_position).normalized()
	
	shoot(direction)
	
	shoot_timer -= delta
	if shoot_timer < 0.0:
		shoot_timer = 0.0
	
func shoot(direction: Vector2):
	const BULLET = preload("res://bullet.tscn")
	
	if Input.is_action_just_pressed("shoot") && shoot_timer == 0.0:
		var new_bullet: Bullet = BULLET.instantiate()
		shoot_timer += 0.5
		
		get_tree().current_scene.add_child(new_bullet)
		new_bullet.global_position = muzzle.global_position
		new_bullet.global_rotation = muzzle.global_rotation
		new_bullet.direction = direction
