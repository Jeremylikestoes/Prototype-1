extends Node2D

@export var bullet_speed: float = 200.0
@onready var muzzle: Marker2D = $Muzzle
@onready var gun: Node2D = $"."

var can_shoot: bool = true
var shoot_timer: float = 0.0

func _physics_process(delta: float) -> void:
	shoot()
	
	shoot_timer -= delta
	if shoot_timer < 0.0:
		shoot_timer = 0.0
	
func shoot():
	const BULLET = preload("res://bullet.tscn")
	
	if Input.is_action_just_pressed("shoot") && shoot_timer == 0.0:
		var new_bullet = BULLET.instantiate()
		shoot_timer += 0.5
		
		gun.get_parent().get_parent().get_parent().add_child(new_bullet)
		new_bullet.global_position = muzzle.global_position
		new_bullet.global_rotation = muzzle.global_rotation
