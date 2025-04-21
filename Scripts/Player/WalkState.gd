extends BaseState

func update(delta):
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if input.length() < 0.1:
		state_machine.change_state("IdleState")
		return

	var cam_basis = player.camera_rig.global_transform.basis
	var forward = -cam_basis.z
	var right = -cam_basis.x
	var direction = (right * input.x) + (forward * input.y)
	direction = direction.normalized()

	

	var speed = player.move_speed
	if player.sprinting:
		speed = player.sprint_speed

	player.velocity.x = lerp(player.velocity.x, direction.x * speed, player.slide_factor * delta)
	player.velocity.z = lerp(player.velocity.z, direction.z * speed, player.slide_factor * delta)
	


	# Keep gravity falling
	if not player.is_on_floor():
		player.velocity.y -= 20.0 * delta
	else:
		player.velocity.y = 0.0

	player.move_and_slide()
	
	if not player.is_on_floor():
		state_machine.change_state("FallState")
		return
	
	if Input.is_action_just_pressed("key_jump") and player.is_on_floor():
		state_machine.change_state("JumpState")

	# Smoothly rotate the mesh to face movement direction
	
	player.handle_mesh_pivot(delta)
