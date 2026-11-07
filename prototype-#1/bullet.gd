extends Area2D

@export var bullet_speed: float = 200.0

@onready var muzzle: Marker2D = %muzzle

func _process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	var direction: Vector2 =  (mouse_position - muzzle.global_position).normalized()
	
	
