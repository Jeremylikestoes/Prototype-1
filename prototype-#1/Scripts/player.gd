extends CharacterBody2D

const SMOOTHING_SPEED = 7.0

@export var speed: float = 120.0
@export var dodge_speed: float = 500.0
@export var acceleration: float = 1800.0
@export var deceleration: float = 2400.0

@onready var gun: Node2D = $GunPivot/Gun
@onready var gun_pivot: Marker2D = $GunPivot
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dodge_timer: Timer = $DodgeTimer

enum State {
	Idle,
	Run,
	Dodge
}

var current_state: State = State.Idle

func _ready() -> void:
	dodge_timer.timeout.connect(_on_dodge_timer_timeout)

func _process(delta: float) -> void:
	var mouse_position := get_global_mouse_position()
	var rotation_to_mouse = gun_pivot.global_position.angle_to_point(mouse_position)
	var mouse_relative_position := (mouse_position - gun_pivot.global_position)
	
	var weight = 1 - exp(-SMOOTHING_SPEED * delta)
	var orbit_position = lerp_angle(rotation_to_mouse, gun_pivot.rotation, weight)
	
	gun_pivot.global_rotation = orbit_position
	
	gun.scale.y = 1 if mouse_relative_position.x > 0 else -1
	gun_pivot.show_behind_parent = mouse_relative_position.y  < -2

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	match current_state:
		
		State.Idle:
			idle_state(direction, delta)
				
		State.Run:
			run_state(direction, delta)
			
		State.Dodge:
			dodge_state(direction, delta)
				
	move_and_slide()
		
	if velocity.x != 0:
		animated_sprite.flip_h = velocity.x < 0
		
func idle_state(direction: Vector2, delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	
	if direction != Vector2.ZERO:
		change_state(State.Run)
	elif Input.is_action_just_pressed("dodge"):
		change_state(State.Dodge) 
	
func run_state(direction: Vector2, delta: float) -> void:
	var target_velocity = direction * speed
	
	if (direction != Vector2.ZERO):
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	
	if direction == Vector2.ZERO and velocity.length() < 1.0:
		change_state(State.Idle)
	elif Input.is_action_just_pressed("dodge"):
		change_state(State.Dodge)

func dodge_state(direction: Vector2, delta: float) -> void:
	var target_velocity = direction * dodge_speed
	
	if (direction != Vector2.ZERO):
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
		
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
	change_state(State.Idle)
