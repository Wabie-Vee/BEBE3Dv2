extends BaseState

func enter():
	# Optional gravity reset on enter
	if player.is_on_floor():
		player.velocity.y = 0.0

func update(delta):
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if input.length() > 0.1:
		state_machine.change_state("WalkState")
		return

	# Lerp X/Z velocity to 0, slightly snappier than WalkState slide
	var decel_factor = player.slide_factor * 1.5  # ← adjust multiplier here for snappiness
	player.velocity.x = lerp(player.velocity.x, 0.0, delta * decel_factor)
	player.velocity.z = lerp(player.velocity.z, 0.0, delta * decel_factor)

	# Gravity stays cookin'
	if not player.is_on_floor():
		player.velocity.y -= 20.0 * delta
		
	if Input.is_action_just_pressed("key_jump"):
		state_machine.change_state("JumpState")

	player.move_and_slide()

	# Rotate toward camera while idle
	player.handle_mesh_pivot(delta)
