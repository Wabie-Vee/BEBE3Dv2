extends BaseState

var acceleration := 5.0
var max_speed := 12.0
var turn_speed := 3.5
var bike_velocity := Vector3.ZERO

func enter():
	#player.animation_player.play("ride_bike")
	bike_velocity = Vector3.ZERO

func update(delta):
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	# Forward/back motion
	var target_speed = -input.y * max_speed
	bike_velocity.z = lerp(bike_velocity.z, -target_speed, delta * acceleration)

	# Turning
	player.rotation.y -= input.x * turn_speed * delta

	# Move player
	var forward = -player.transform.basis.z
	player.velocity = forward * bike_velocity.z
	player.move_and_slide()

	if Input.is_action_just_pressed("ui_accept"):

		state_machine.change_state("IdleState")
