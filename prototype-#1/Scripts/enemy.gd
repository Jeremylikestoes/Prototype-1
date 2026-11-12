extends CharacterBody2D


@onready var player: CharacterBody2D = get_parent().get_node("Player")

var speed: float = 75.0
var should_chase: bool = false

func _physics_process(delta: float) -> void:
	if should_chase:
		var target_position = player.global_position
		var direction: Vector2 = (target_position - global_position).normalized()
		
		velocity = lerp(velocity, direction * speed, 8.5 * delta)
		move_and_slide()
		
		if direction.x > 0:
			$Sprite2D.flip_h = false
		elif direction.x < 0:
			$Sprite2D.flip_h = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	pass

func _on_enter_area_body_entered(body: Node2D) -> void:
	if body == player:
		should_chase = true

func _on_exit_area_body_exited(body: Node2D) -> void:
	if body == player:
		should_chase = false
