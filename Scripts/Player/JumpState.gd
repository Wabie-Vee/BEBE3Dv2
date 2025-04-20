extends BaseState

func enter():
	player.velocity.y = player.jump_velocity
	player.is_jumping = true
	player.jump_held_time = 0.0

func update(delta):
	player.jump_held_time += delta

	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (player.transform.basis * Vector3(-input.x, 0, -input.y)).normalized()

	var speed = player.move_speed
	if player.sprinting:
		speed = player.sprint_speed

	player.velocity.x = lerp(player.velocity.x, direction.x * speed, player.slide_factor * delta)
	player.velocity.z = lerp(player.velocity.z, direction.z * speed, player.slide_factor * delta)

	player.velocity.y -= 20.0 * delta
	player.move_and_slide()

	if player.velocity.y < 0:
		state_machine.change_state("FallState")
		
	player.handle_mesh_pivot(delta)
