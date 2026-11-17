extends Node

var current_state: State = State.Idle

enum State {
	Idle,
	Move,
	Dodge
}

func update():
	match current_state:
		
		State.Idle:
			pass
				
		State.Move:
			pass
			
		State.Dodge:
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
			pass
			
		State.Move:
			pass
			
		State.Dodge:
			pass

func exit_state(state: State) -> void:
	match state:
		
		State.Idle:
			pass
			
		State.Move:
			pass
			
		State.Dodge:
			pass
