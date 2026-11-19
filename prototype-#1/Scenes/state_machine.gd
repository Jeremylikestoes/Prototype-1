class_name StateMachine
extends Node

@export var player: Player
@export var player_movement: PlayerMovement

@export var idle_state: IdleState
@export var move_state: MoveState
@export var dodge_state: DodgeState

@export var between_dodge_timer: Timer

@export var focus_component: FocusComponent

@export var animated_sprite: AnimatedSprite2D

var current_state: State = State.Idle

enum State {
	Idle,
	Move,
	Dodge
}

func _update(direction: Vector2, delta: float) -> void:
	match current_state:
		
		State.Idle:
			idle_state._handle_idle(direction, delta)
			
			if between_dodge_timer.is_stopped():
				focus_component._gain_focus()
			
			if player_movement._is_dodging():
				_change_state(State.Dodge)
			elif player_movement._is_moving(direction):
				_change_state(State.Move)
		
		State.Move:
			move_state._handle_movement(direction, delta)
			
			focus_component._loose_focus()
			
			if player_movement._is_dodging():
				_change_state(State.Dodge) 
			elif player_movement._is_idle(direction):
				_change_state(State.Idle)
		
		State.Dodge:
			pass
		
	player.move_and_slide()

func _change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	
	_exit_state(current_state)
	
	current_state = new_state
	
	_enter_state(current_state)

func _enter_state(state: State) -> void:
	match state:
		
		State.Idle:
			animated_sprite.play("idle")
		
		State.Move:
			animated_sprite.play("move")
		
		State.Dodge:
			dodge_state._handle_enter_dodge(player._get_direction())

func _exit_state(state: State) -> void:
	match state:
		
		State.Idle:
			pass
		
		State.Move:
			pass
		
		State.Dodge:
			dodge_state._handle_exit_dodge()

func _on_dodge_timer_timeout() -> void:
	_change_state(State.Idle)
