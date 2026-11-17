class_name Player
extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var gun: Node2D = $GunPivot/Gun
@onready var gun_pivot: Marker2D = $GunPivot

@onready var dodge_cast: ShapeCast2D = $DodgeCast
@onready var dodge_timer: Timer = $DodgeTimer
@onready var between_dodge_timer: Timer = $BetweenDodgeTimer

@onready var focus_bar: ProgressBar = $FocusBar

var speed: float = 120.0
var acceleration: float = 1800.0
var deceleration: float = 2400.0

var dodge_direction: Vector2
var max_dodge_distance: float = 60.0
var dodge_distance: float

var dodge_duration: float = 0.15
var between_dodge_duration: float = 0.5
var can_dodge: bool = true

var maximum_focus: float = 30.0
var minimum_focus: float = 10.0

var current_state: State = State.Idle

enum State {
	Idle,
	Run,
	Dodge
}

func _ready() -> void:
	dodge_timer.wait_time = dodge_duration
	between_dodge_timer.wait_time = between_dodge_duration
	
	focus_bar.max_value = maximum_focus
	focus_bar.min_value = minimum_focus

func _process(delta: float) -> void:
	var mouse_position := get_global_mouse_position()
	var gun_rotation_to_mouse = gun_pivot.global_position.angle_to_point(mouse_position)
	var mouse_relative_position := (mouse_position - gun_pivot.global_position)
	
	const SMOOTHING_SPEED = 7.0
	var weight: float = 1 - exp(-SMOOTHING_SPEED * delta)
	
	var orbit_position = lerp_angle(gun_rotation_to_mouse, gun_pivot.rotation, weight)
	
	gun_pivot.global_rotation = orbit_position
	
	gun.scale.y = 1 if mouse_relative_position.x > 0 else -1
	gun_pivot.show_behind_parent = mouse_relative_position.y  < -2
	

func _physics_process(delta: float) -> void:
	var mouse_relative_position = (get_global_mouse_position() - global_position)
	
	match current_state:
		
		State.Idle:
			idle_state(get_direction(), delta)
				
		State.Run:
			run_state(get_direction(), delta)
			
		State.Dodge:
			dodge_state(get_direction(), delta)
				
	move_and_slide()
		
	if mouse_relative_position.x != 0:
		animated_sprite.flip_h = mouse_relative_position.x < 0

func idle_state(direction: Vector2, delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	
	gain_focus()
	
	if direction:
		change_state(State.Run)
	elif Input.is_action_just_pressed("dodge") and can_dodge:
		change_state(State.Dodge) 

func run_state(direction: Vector2, delta: float) -> void:
	var target_velocity = direction * speed
	
	if direction:
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	
	loose_focus()
	
	if direction == Vector2.ZERO and velocity.length() < 1.0:
		change_state(State.Idle)
	elif Input.is_action_just_pressed("dodge") and can_dodge:
		change_state(State.Dodge)

func dodge_state(_direction: Vector2, _delta: float) -> void:
	pass

func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
		
	exit_state(current_state)
	
	current_state = new_state
	
	enter_state(current_state)

func enter_state(state: State) -> void:
	match state:
		
		State.Idle:
			animated_sprite.play("idle")
			
		State.Run:
			animated_sprite.play("run")
			
		State.Dodge:
			if get_direction():
				dodge_direction = get_direction()
			else:
				dodge_direction = (get_global_mouse_position() - global_position).normalized()
			
			update_dodge_position()
			
			var dodge_target_position: Vector2 = global_position + dodge_direction * dodge_distance
			var dodge_tween: Tween = create_tween()
			
			dodge_tween.tween_property(
				self, 
				"global_position", 
				dodge_target_position, 
				dodge_duration * (dodge_distance / max_dodge_distance)
			)
			
			dodge_timer.start()

func exit_state(state: State) -> void:
	match state:
		
		State.Idle:
			pass
			
		State.Run:
			pass
			
		State.Dodge:
			dodge_timer.stop()
			
			between_dodge_timer.start()
			can_dodge = false

func get_direction():
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	return direction.round().normalized()

func update_dodge_position() -> void:
	if get_direction():
		dodge_cast.target_position = get_direction() * max_dodge_distance
	else:
		dodge_cast.target_position = get_local_mouse_position().normalized() * max_dodge_distance
				
	dodge_cast.force_shapecast_update()
	dodge_distance = dodge_cast.get_closest_collision_safe_fraction() * max_dodge_distance

func _on_dodge_timer_timeout() -> void:
	change_state(State.Idle)

func _on_between_dodge_timer_timeout() -> void:
	can_dodge = true
	
func gain_focus() -> void:
	var focus_gain_rate: float = 0.02
	
	focus_bar.value += focus_gain_rate
	
func loose_focus() -> void:
	var focus_loss_rate: float = 0.04
	
	focus_bar.value -= focus_loss_rate
