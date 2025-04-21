extends CharacterBody3D

@onready var state_machine = $PlayerStateMachine
@onready var camera_rig = $CameraRig
@onready var camera = $CameraRig/Camera3D
@onready var raycast = $RayCast3D
@onready var mesh = $Node3D/BebeBear
@onready var bebe_pivot: Node3D = $BebePivot

@onready var cam_origin_y :float = camera_rig.position.y

@export var sfx_step = AudioStream
@export var sfx_jump = AudioStream

var is_jumping := false
var jump_velocity := 10.0
var jump_held_time := 0.0

var sprinting := false
var sprint_speed := 8
var slide_factor := 10.0
var rotation_speed := 8.0

var move_speed := 4.0

var mouse_look_enabled := true
var mouse_sensitivity := 0.005
var pitch := 0.0

@export var camera_lean_angle := 3.0     # Max degrees of tilt
var camera_lean_speed := 6.0      # How fast it lerps in/out

var headbob_timer := 0.0
var headbob_amplitude := .07
var headbob_frequency := 16
var base_headbob_frequency := 6.0  # low speed bob
var max_headbob_frequency := 12.0  # full speed bob
var headbob_enabled := true
var last_headbob_value := 0.0
var footstep_played_this_cycle := false

var turn_threshold := 0
var turn_speed := 8 

var last_input_dir := Vector3.ZERO
var air_direction := Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	state_machine.init(self)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if mouse_look_enabled:
			mouse_look_enabled = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			mouse_look_enabled = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event is InputEventMouseMotion and mouse_look_enabled:
		# Yaw: rotate player left/right
		camera_rig.rotation.y -= event.relative.x * mouse_sensitivity

		# Pitch: rotate camera up/down (through camera rig)
		pitch -= -event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(-80), deg_to_rad(80))
		camera.rotation.x = -pitch
		

	
	#Sprint check	
	if Input.is_action_pressed("key_sprint"):
		sprinting = true;
	else:
		sprinting = false;
		

func _physics_process(delta):
	
	if Input.is_action_just_pressed("left_click") and !mouse_look_enabled:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if !mouse_look_enabled:
			mouse_look_enabled = !mouse_look_enabled
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	# Calculate target tilt
	var target_tilt = input.x * camera_lean_angle  # Left = positive Z rotation

	# Lerp the camera rig's Z-rotation toward target
	var current_tilt = camera_rig.rotation_degrees.z
	var new_tilt = lerp(current_tilt, target_tilt, delta * camera_lean_speed)
	camera_rig.rotation_degrees.z = new_tilt

	if headbob_enabled and velocity.length() > 0.1 and is_on_floor():
		# Get horizontal speed (ignoring vertical movement)
		var horizontal_velocity = velocity
		horizontal_velocity.y = 0
		var speed_factor = clamp(horizontal_velocity.length() / sprint_speed, 0.0, 1.0)

		var current_bob_freq = lerp(base_headbob_frequency, max_headbob_frequency, speed_factor)
		headbob_timer += delta * current_bob_freq * 2
		var bob_value = sin(headbob_timer)
		var y_offset = bob_value * headbob_amplitude

		var current_pos = camera_rig.position
		current_pos.y = lerp(current_pos.y, cam_origin_y + y_offset, delta * 10.0)
		camera_rig.position = current_pos

		# Footstep SFX sync (optional)
		if last_headbob_value < -0.95 and bob_value >= last_headbob_value and not footstep_played_this_cycle:
			SoundManager.play_sfx(sfx_step, true) # optional step sound
			footstep_played_this_cycle = true
		if bob_value > 0.1:
			footstep_played_this_cycle = false

		last_headbob_value = bob_value
	else:
		# Reset Y position if not walking
		var current_pos = camera_rig.position
		current_pos.y = lerp(current_pos.y, cam_origin_y, delta * 10.0)
		camera_rig.position = current_pos

	
	state_machine.update_state(delta)
	
func handle_mesh_pivot(delta):
	var pivot_yaw = wrapf(camera_rig.rotation_degrees.y, 0, 360)
	var mesh_yaw = wrapf(bebe_pivot.rotation_degrees.y, 0, 360)
	var angle_diff = abs(pivot_yaw - mesh_yaw)

	if angle_diff > turn_threshold:
		var target_yaw = deg_to_rad(pivot_yaw)
		var current_yaw = bebe_pivot.rotation.y
		bebe_pivot.rotation.y = lerp_angle(current_yaw, target_yaw, delta * turn_speed)
		
	
