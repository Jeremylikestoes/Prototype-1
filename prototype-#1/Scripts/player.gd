class_name Player
extends CharacterBody2D

@onready var gun: Node2D = $GunPivot/Gun
@onready var gun_pivot: Marker2D = $GunPivot
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dodge_timer: Timer = $DodgeTimer

const SMOOTHING_SPEED = 7.0

var speed: float = 120.0
var acceleration: float = 1800.0
var deceleration: float = 2400.0

var dodge_direction: Vector2
var dodge_start_position: Vector2
var dodge_target_position: Vector2
var dodge_distance: float = 60.0
var dodge_duration: float = 0.15

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
	var mouse_position := get_global_mouse_position()
	var rotation_to_mouse = gun_pivot.global_position.angle_to_point(mouse_position)
	var mouse_relative_position := (mouse_position - gun_pivot.global_position)
	
	weight = 1 - exp(-SMOOTHING_SPEED * delta)
	var orbit_position = lerp_angle(rotation_to_mouse, gun_pivot.rotation, weight)
	
	gun_pivot.global_rotation = orbit_position
	
	gun.scale.y = 1 if mouse_relative_position.x > 0 else -1
	gun_pivot.show_behind_parent = mouse_relative_position.y  < -2

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var mouse_relative_position = (get_global_mouse_position() - global_position)
	
	match current_state:
		
		State.Idle:
			idle_state(direction, delta)
				
		State.Run:
			run_state(direction, delta)
			
		State.Dodge:
			dodge_state(direction, delta)
				
	move_and_slide()
		
	if mouse_relative_position.x != 0:
		animated_sprite.flip_h = mouse_relative_position.x < 0
		
func idle_state(direction: Vector2, delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	
	if direction != Vector2.ZERO:
		change_state(State.Run, direction)
	elif Input.is_action_just_pressed("dodge"):
		change_state(State.Dodge, direction) 
	
func run_state(direction: Vector2, delta: float) -> void:
	var target_velocity = direction * speed
	
	if (direction != Vector2.ZERO):
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	
	if direction == Vector2.ZERO and velocity.length() < 1.0:
		change_state(State.Idle, direction)
	elif Input.is_action_just_pressed("dodge"):
		change_state(State.Dodge, direction)

func dodge_state(_direction: Vector2, delta: float) -> void:
	dodge_elapsed_time += delta
	weight = clampf((dodge_elapsed_time / dodge_duration), 0, 1) 
	
	dodge_target_position = dodge_start_position + dodge_direction * dodge_distance
	
	global_position = lerp(dodge_start_position, dodge_target_position, weight)
		
func change_state(new_state: State, direction: Vector2) -> void:
	if current_state == new_state:
		return
		
	exit_state(current_state)
	
	current_state = new_state
	
	enter_state(current_state, direction)
	
func enter_state(state: State, direction: Vector2) -> void:
	match state:
		
		State.Idle:
			animated_sprite.play("idle")
			
		State.Run:
			animated_sprite.play("run")
			
		State.Dodge:
			if (direction != Vector2.ZERO):
				dodge_direction = direction.normalized()
			else:
				dodge_direction = (get_global_mouse_position() - global_position).normalized()
				
			dodge_start_position = global_position
			
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


func _on_dodge_timer_timeout() -> void:
	change_state(State.Idle, Vector2.ZERO)
