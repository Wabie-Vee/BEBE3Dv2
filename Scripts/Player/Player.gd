extends CharacterBody3D

@onready var state_machine = $PlayerStateMachine
@onready var camera_rig = $CameraRig
@onready var camera = $CameraRig/Camera3D
@onready var raycast = $RayCast3D
@onready var mesh = $BebeBear

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

var turn_threshold := 5
var turn_speed := 8.0

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
		rotation.y -= event.relative.x * mouse_sensitivity

		# Pitch: rotate camera up/down (through camera rig)
		pitch -= -event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(-80), deg_to_rad(80))
		camera.rotation.x = -pitch
	
	#Sprint check	
	if Input.is_action_pressed("key_sprint"):
		sprinting = true;
	else:
		sprinting = false;
		
	print(state_machine.current_state)

func _physics_process(delta):
	state_machine.update_state(delta)
	
func handle_mesh_pivot(delta):
	var pivot_yaw = wrapf(camera.rotation_degrees.y, 0, 360)
	var mesh_yaw = wrapf(mesh.rotation_degrees.y, 0, 360)
	var angle_diff = abs(pivot_yaw - mesh_yaw)

	if angle_diff > turn_threshold:
		var target_yaw = deg_to_rad(pivot_yaw)
		var current_yaw = mesh.rotation.y
		mesh.rotation.y = lerp_angle(current_yaw, target_yaw, delta * turn_speed)
