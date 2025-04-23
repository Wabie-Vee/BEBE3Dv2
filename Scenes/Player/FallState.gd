extends BaseState

var last_input_dir := Vector3.ZERO

func enter():
	player.is_jumping = false
	
func exit():
	SoundManager.play_sfx(player.sfx_land)
	player.air_direction = Vector3.ZERO

func update(delta):
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

	var air_slide_factor = player.slide_factor * 0.8

	var target_vel_x = direction.x * speed
	var target_vel_z = direction.z * speed

	# Cancel bounce-back direction swap
	if sign(player.velocity.x) != sign(target_vel_x) and abs(player.velocity.x) > 0.1:
		player.velocity.x = 0.0
	if sign(player.velocity.z) != sign(target_vel_z) and abs(player.velocity.z) > 0.1:
		player.velocity.z = 0.0

	player.velocity.x = lerp(player.velocity.x, target_vel_x, delta * air_slide_factor)
	player.velocity.z = lerp(player.velocity.z, target_vel_z, delta * air_slide_factor)

	# Gravity
	player.velocity.y -= 20.0 * delta

	player.move_and_slide()

	# Landed? Transition out
	if player.is_on_floor():
		if input.length() > 0.1:
			state_machine.change_state("WalkState")
		else:
			state_machine.change_state("IdleState")

	player.handle_mesh_pivot(delta)
