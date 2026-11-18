class_name Player
extends CharacterBody2D

@export var state_machine: StateMachine
@export var animated_sprite: AnimatedSprite2D

@export var gun_pivot: Marker2D
@export var gun: Node2D

@export var focus_bar: ProgressBar

var speed: float = 120.0

var maximum_focus: float = 30.0
var minimum_focus: float = 10.0

func _ready() -> void:
	focus_bar.max_value = maximum_focus
	focus_bar.min_value = minimum_focus

func _process(delta: float) -> void:
	_update_gun_rotation(delta)
	
	if get_local_mouse_position().x != 0:
		animated_sprite.flip_h = get_local_mouse_position().x < 0

func _physics_process(delta: float) -> void:
	state_machine._update(_get_direction(), delta)

func _get_direction() -> Vector2:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	return direction.round().normalized()

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

func gain_focus() -> void:
	var focus_gain_rate: float = 0.02
	
	focus_bar.value += focus_gain_rate

func loose_focus() -> void:
	var focus_loss_rate: float = 0.04
	
	focus_bar.value -= focus_loss_rate
