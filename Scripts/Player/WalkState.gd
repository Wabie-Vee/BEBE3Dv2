extends BaseState

func update(delta):
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if input.length() < 0.1:
		state_machine.change_state("IdleState")
		return

	var direction = (player.transform.basis * Vector3(input.x, 0, input.y)).normalized()
	player.velocity.x = direction.x * player.move_speed
	player.velocity.z = direction.z * player.move_speed
	player.move_and_slide()
