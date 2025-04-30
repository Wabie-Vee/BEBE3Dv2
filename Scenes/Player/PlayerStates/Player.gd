extends CharacterBody3D

@onready var state_machine = $PlayerStateMachine
@onready var camera_rig = $CameraRig
@onready var camera = $CameraRig/Camera3D
@onready var raycast = $CameraRig/Camera3D/RayCast3D
@onready var mesh = $Node3D/BebeBear
@onready var bebe_pivot: Node3D = $BebePivot
@onready var cursor_animator: AnimatedSprite2D = $CanvasLayer/Control/AnimatedSprite2D
@onready var canvas_layer: CanvasLayer = $CanvasLayer

@onready var cam_origin_y :float = camera_rig.position.y

@export var sfx_step = AudioStream
@export var sfx_jump = AudioStream
@export var sfx_land = AudioStream
@export var interact_distance := 3.0

var is_jumping := false
@export var jump_velocity := 10.0
var jump_held_time := 0.0

var sprinting := false
@export var sprint_speed := 6.0
var slide_factor := 10.0
var rotation_speed := 8.0

@export var move_speed := 4.0

var mouse_look_enabled := true
@export var mouse_sensitivity := 0.0025
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

@export var cursor_interact = Sprite2D
@export var cursor_default = Sprite2D
var cursor = cursor_default

var turn_threshold := 0
var turn_speed := 15

var last_input_dir := Vector3.ZERO
var air_direction := Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	state_machine.init(self)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and !GameManager.is_in_dialogue:
		if mouse_look_enabled:
			mouse_look_enabled = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			mouse_look_enabled = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


	if event is InputEventMouseMotion and mouse_look_enabled:
		if GameManager.player_state == "PlayerStateFree":
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
	if GameManager.player_state == "PlayerStateFree":	
		if event.is_action_pressed("key_interact") or event.is_action_pressed("left_click"):
				handle_interact()
	
	if event is InputEventKey and event.pressed:
		if event.is_pressed() and event.keycode == KEY_F3:
			var debug_panel = get_tree().current_scene.get_node("UILayer/DebugPanel")
			debug_panel.visible = not debug_panel.visible
			
		if event.is_pressed() and event.keycode == KEY_F4:
			GameManager.debug_draw_raycast = not GameManager.debug_draw_raycast
			var debug_panel = get_tree().current_scene.get_node("UILayer/DebugPanel")
			debug_panel.raycast_debug_enabled = GameManager.debug_draw_raycast

func debug_draw_interact():
	if raycast:
		raycast.force_raycast_update()

		if raycast.is_colliding():
			var target = raycast.get_collider()
			var distance = raycast.global_transform.origin.distance_to(raycast.get_collision_point())

			var within_range = target.is_in_group("interactables") and distance <= interact_distance
			var color = Color.RED
			if within_range:
				color = Color.GREEN

			# Draw line from camera to hit point
			var start = raycast.global_transform.origin
			var end = raycast.get_collision_point()

			DebugDraw3D.draw_line(start, end, color, 0.05)

			# Print debug info
			print("🎯 Hit:", target.name, "| Distance:", distance, "| In Range:", within_range)
			print("🎯 Target groups:", target.get_groups())
			print("📏 interact_distance:", interact_distance)
		else:
			var forward = -raycast.global_transform.basis.z
			var end = raycast.global_transform.origin + forward * interact_distance
			DebugDraw3D.draw_line(raycast.global_transform.origin, end, Color.GRAY, 0.05)
			print("🔘 Nothing hit.")

func _physics_process(delta):
	if GameManager.player_state == "PlayerStateFree":
		canvas_layer.visible = true
	else:
		canvas_layer.visible = false
	if Input.is_action_just_pressed("left_click") and !mouse_look_enabled and !GameManager.is_in_dialogue:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if !mouse_look_enabled:
			mouse_look_enabled = !mouse_look_enabled
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	# Calculate target tilt
	var target_tilt = input.x * camera_lean_angle  # Left = positive Z rotation

	# Lerp the camera rig's Z-rotation toward target
	var current_tilt = camera_rig.rotation_degrees.z
	if GameManager.player_state == "PlayerStateLocked":
		target_tilt = 0.0
	var new_tilt = lerp(current_tilt, target_tilt, delta * camera_lean_speed)
	camera_rig.rotation_degrees.z = new_tilt
	
	if GameManager.player_state == "PlayerStateLocked":
		return #freeze player
	
	if headbob_enabled and velocity.length() > 0.1 and is_on_floor() and GameManager.player_state == "PlayerStateFree":
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
	

	handle_reticle()
	
	state_machine.update_state(delta)
	
	if GameManager.debug_draw_raycast:
		debug_draw_interact()
	
func handle_mesh_pivot(delta):
	var pivot_yaw = wrapf(camera_rig.rotation_degrees.y, 0, 360)
	var mesh_yaw = wrapf(bebe_pivot.rotation_degrees.y, 0, 360)
	var angle_diff = abs(pivot_yaw - mesh_yaw)

	if angle_diff > turn_threshold:
		var target_yaw = deg_to_rad(pivot_yaw)
		var current_yaw = bebe_pivot.rotation.y
		bebe_pivot.rotation.y = lerp_angle(current_yaw, target_yaw, delta * turn_speed)
	
func handle_reticle():
	var next_anim = "Default"

	if raycast.is_colliding():
		var target = raycast.get_collider()

		while target and not target.has_method("interact"):
			target = target.get_parent()

		if target and target.has_method("interact"):
			if "interaction_type" in target:
				match target.interaction_type:
					"talk":
						next_anim = "Speak"
					"grab":
						next_anim = "Grab"
					"inspect":
						next_anim = "Inspect"

	# 🔁 Only play the animation if it's different
	if cursor_animator.animation != next_anim:
		cursor_animator.play(next_anim)


	

func handle_interact():
	if raycast == null:
		print("Raycast not found!")
		return

	raycast.force_raycast_update()

	if raycast.is_colliding():
		var target = raycast.get_collider()
		var start = target  # Keep the original for debug

		# Traverse upward to find a node with interact()
		while target and not target.has_method("interact"):
			target = target.get_parent()

		if target and target.is_in_group("interactables"):
			target.interact()


	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target and target.is_in_group("interactables") and target.has_method("interact"):
			target.interact()
