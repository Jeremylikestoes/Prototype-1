class_name Player
extends CharacterBody2D

@onready var gun: Node2D = $GunPivot/Gun
@onready var gun_pivot: Marker2D = $GunPivot
@onready var dodge_cast: ShapeCast2D = $DodgeCast
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dodge_timer: Timer = $DodgeTimer

const SMOOTHING_SPEED = 7.0

var speed: float = 120.0
var acceleration: float = 1800.0
var deceleration: float = 2400.0

var dodge_direction: Vector2
var dodge_start_position: Vector2
var dodge_target_position: Vector2
var max_dodge_distance: float = 60.0
var dodge_distance: float
var dodge_duration: float = 0.15
var dodge_tween: Tween

var weight: float
var dodge_elapsed_time: float = 0.0

var current_state: State = State.Idle

enum State {
	Idle,
	Run,
	Dodge
}

func _ready() -> void:
	dodge_timer.timeout.connect(_on_dodge_timer_timeout)
	
	dodge_timer.wait_time = dodge_duration

func _process(delta: float) -> void:
	
	# Gun rotation
	var mouse_position := get_global_mouse_position()
	var gun_rotation_to_mouse = gun_pivot.global_position.angle_to_point(mouse_position)
	var mouse_relative_position := (mouse_position - gun_pivot.global_position)
	
	weight = 1 - exp(-SMOOTHING_SPEED * delta)
	var orbit_position = lerp_angle(gun_rotation_to_mouse, gun_pivot.rotation, weight)
	
	gun_pivot.global_rotation = orbit_position
	
	gun.scale.y = 1 if mouse_relative_position.x > 0 else -1
	gun_pivot.show_behind_parent = mouse_relative_position.y  < -2
	
	# Dodge Cast target position
	var future_point: Vector2 = global_position + (get_direction() * max_dodge_distance)
	
	
		
	if get_direction():
		dodge_cast.target_position = get_direction() 
	else:
		dodge_cast.target_position = get_local_mouse_position().normalized() * max_dodge_distance
		
	dodge_distance = dodge_cast.get_closest_collision_safe_fraction() * max_dodge_distance

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
	
	if direction:
		change_state(State.Run)
	elif Input.is_action_just_pressed("dodge"):
		change_state(State.Dodge) 
	
func run_state(direction: Vector2, delta: float) -> void:
	var target_velocity = direction * speed
	
	if direction:
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	
	if direction == Vector2.ZERO and velocity.length() < 1.0:
		change_state(State.Idle)
	elif Input.is_action_just_pressed("dodge"):
		change_state(State.Dodge)

func dodge_state(_direction: Vector2, delta: float) -> void:
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
				
			dodge_start_position = global_position
			dodge_target_position = dodge_start_position + dodge_direction * dodge_distance
			dodge_tween = create_tween()
			
			dodge_tween.tween_property(
				self, 
				"global_position", 
				dodge_target_position, 
				dodge_duration * (dodge_distance / max_dodge_distance)
			)
			
			dodge_elapsed_time = 0.0
			dodge_timer.start()
	
func exit_state(state: State) -> void:
	match state:
		
		State.Idle:
			pass
			
		State.Run:
			pass
			
		State.Dodge:
			dodge_timer.stop()

func get_direction():
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	return direction.round().normalized()
	
func _on_dodge_timer_timeout() -> void:
	change_state(State.Idle)
