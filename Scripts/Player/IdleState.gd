extends BaseState

func update(delta):
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if input.length() > 0.1:
		state_machine.change_state("WalkState")
