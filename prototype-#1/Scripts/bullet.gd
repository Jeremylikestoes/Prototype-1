extends Area2D
class_name Bullet

@export var bullet_speed: float = 200.0
var direction: Vector2

func _physics_process(delta: float) -> void:
	global_position += (direction * bullet_speed * delta)

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	queue_free()
