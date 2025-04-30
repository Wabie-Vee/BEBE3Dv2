extends BaseState



func enter():
	SoundManager.play_sfx(player.sfx_jump, true)
	player.velocity.y = player.jump_velocity
	player.is_jumping = true
	player.jump_held_time = 0.0
	player.last_input_dir = Vector3.ZERO  # Reset on jump start
	



func update(delta):
	player.jump_held_time += delta

	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var cam_basis = player.camera_rig.global_transform.basis
	var forward = -cam_basis.z
	var right = cam_basis.x

	if input.length() > 0.1:
		player.air_direction = (right * -input.x + forward * input.y).normalized()
	else:
		player.air_direction = lerp(player.air_direction, Vector3.ZERO, delta * 0.5)

	var direction = player.air_direction



	var speed = player.move_speed
	if player.sprinting:
		speed = player.sprint_speed

	var target_vel_x = direction.x * speed
	var target_vel_z = direction.z * speed

	# Cancel bounce if switching directions midair
	if sign(player.velocity.x) != sign(target_vel_x) and abs(player.velocity.x) > 0.1:
		player.velocity.x = 0.0
	if sign(player.velocity.z) != sign(target_vel_z) and abs(player.velocity.z) > 0.1:
		player.velocity.z = 0.0

	# Apply smooth lateral control
	var air_slide_factor = player.slide_factor * 0.8
	player.velocity.x = lerp(player.velocity.x, target_vel_x, delta * air_slide_factor)
	player.velocity.z = lerp(player.velocity.z, target_vel_z, delta * air_slide_factor)

	player.velocity.y -= 20.0 * delta
	player.move_and_slide()

	if player.velocity.y < 0:
		state_machine.change_state("FallState")
		
	if player.is_on_floor():
		SoundManager.play_sfx(player.sfx_land, true, 4.0)
		player.air_direction = Vector3.ZERO
		if input.length() > 0.1:
			state_machine.change_state("WalkState")
		else:
			state_machine.change_state("IdleState")

	player.handle_mesh_pivot(delta)
