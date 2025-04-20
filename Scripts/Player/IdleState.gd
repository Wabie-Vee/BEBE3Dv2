extends BaseState

func update(delta):
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	print("Input vector:", input)

	if input.length() > 0.1:
		print("Switching to WalkState")
		state_machine.change_state("WalkState")

	if Input.is_action_just_pressed("key_jump") and player.is_on_floor():
		state_machine.change_state("JumpState")
		
	player.handle_mesh_pivot(delta)
	
	if not player.is_on_floor():
		state_machine.change_state("FallState")
		return
