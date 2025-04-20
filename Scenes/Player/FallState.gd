extends BaseState

func enter():
	# optional: play falling animation, reset jump state
	player.is_jumping = false

func update(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = Vector3.ZERO

	direction += -player.global_transform.basis.z * input_dir.y
	direction += player.global_transform.basis.x * input_dir.x
	direction = direction.normalized()

	var speed = player.move_speed
	if player.sprinting:
		speed = player.sprint_speed

	player.velocity.x = lerp(player.velocity.x, direction.x * speed, player.slide_factor * delta)
	player.velocity.z = lerp(player.velocity.z, direction.z * speed, player.slide_factor * delta)

	# gravity do be gravityin'
	player.velocity.y -= 20.0 * delta

	player.move_and_slide()

	# grounded check to transition out
	if player.is_on_floor():
		if input_dir.length() > 0.1:
			state_machine.change_state("WalkState")
		else:
			state_machine.change_state("IdleState")
