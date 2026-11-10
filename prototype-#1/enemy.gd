extends CharacterBody2D


@onready var player: CharacterBody2D = get_parent().get_node("Player")

var speed: float = 75.0
var should_chase: bool = true

func _physics_process(delta: float) -> void:
	if should_chase:
		var target_position = player.global_position
		var direction: Vector2 = (target_position - global_position).normalized()
		
		velocity = lerp(velocity, direction * speed, 8.5 * delta)
		move_and_slide()
