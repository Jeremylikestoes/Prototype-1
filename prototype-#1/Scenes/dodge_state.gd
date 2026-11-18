class_name DodgeState
extends PlayerMovement

@export var dodge_cast: ShapeCast2D
@export var dodge_timer: Timer
@export var between_dodge_timer: Timer

var dodge_direction: Vector2
var max_dodge_distance: float = 60.0
var dodge_distance: float

var dodge_duration: float = 0.15
var between_dodge_duration: float = 0.5
var can_dodge: bool = true

func _ready() -> void:
	dodge_timer.wait_time = dodge_duration
	between_dodge_timer.wait_time = between_dodge_duration

func _handle_enter_dodge(direction: Vector2) -> void:
	_update_dodge_direction(direction)
	
	var dodge_target_position: Vector2 = player.global_position + dodge_direction * dodge_distance
	var dodge_tween: Tween = create_tween()
			
	dodge_tween.tween_property(
		player, 
		"global_position", 
		dodge_target_position, 
		dodge_duration * (dodge_distance / max_dodge_distance)
	)
			
	dodge_timer.start()

func _update_dodge_direction(direction: Vector2) -> void:
	# Direction if it's mouse or movement
	if direction:
		dodge_direction = direction
	else:
		dodge_direction = (player.get_global_mouse_position() - player.global_position).normalized()
	
	# Gets the dodge distance and direction for the shape cast
	if direction:
		dodge_cast.target_position = direction * max_dodge_distance
	else:
		dodge_cast.target_position = player.get_local_mouse_position().normalized() * max_dodge_distance
				
	dodge_cast.force_shapecast_update()
	dodge_distance = dodge_cast.get_closest_collision_safe_fraction() * max_dodge_distance
	
func _handle_exit_dodge() -> void:
	dodge_timer.stop()
	
	between_dodge_timer.start()
	can_dodge = false

func _on_between_dodge_timer_timeout() -> void:
	can_dodge = true
