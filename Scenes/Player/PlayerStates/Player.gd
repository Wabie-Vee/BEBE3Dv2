extends CharacterBody3D

# === NODE REFERENCES ===
@onready var state_machine = $PlayerStateMachine
@onready var camera_rig = $CameraRig
@onready var camera = $CameraRig/Camera3D
@onready var raycast = $CameraRig/Camera3D/RayCast3D
@onready var mesh = $Node3D/BebeBear
@onready var bebe_pivot: Node3D = $BebePivot
@onready var cursor_animator: AnimatedSprite2D = $CanvasLayer/Control/AnimatedSprite2D
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var footstep_ray: RayCast3D = $FootstepRay
@onready var journal_animator: AnimationPlayer = $CameraRig/Camera3D/Journal/AnimationPlayer
@onready var journal = $"../UILayer/QuestTracker"
@onready var flashlight: SpotLight3D = $CameraRig/Camera3D/Flashlight

# === EXPORTED AUDIO ===
@export_group("Footstep Sounds")
@export var step_grass: AudioStream
@export var step_stone: AudioStream
@export var step_wood: AudioStream

@export_group("General SFX")
@export var sfx_step: AudioStream
@export var sfx_jump: AudioStream
@export var sfx_land: AudioStream
@export var journal_open_sound: AudioStream 
@export var journal_close_sound: AudioStream
@export var flashlight_sound: AudioStream

# === EXPORTED RETICLES ===
@export_group("Cursor Reticles")
@export var cursor_interact: Sprite2D
@export var cursor_default: Sprite2D

# === EXPORTED CONFIGURATION ===
@export var interact_distance: float = 3.0
@export var jump_velocity: float = 10.0
@export var sprint_speed: float = 6.0
@export var move_speed: float = 4.0
@export var mouse_sensitivity: float = 0.0025
@export var camera_lean_angle: float = 3.0

# === CAMERA CONTROL ===
var pitch: float = 0.0
var camera_lean_speed: float = 6.0
@onready var cam_origin_y: float = camera_rig.position.y

# === MOVEMENT STATE ===
var is_jumping: bool = false
var jump_held_time: float = 0.0
var sprinting: bool = false
var slide_factor: float = 10.0
var rotation_speed: float = 8.0

# === HEADBOB SYSTEM ===
var headbob_timer: float = 0.0
var headbob_amplitude: float = 0.045
var base_headbob_frequency: float = 6.0
var max_headbob_frequency: float = 12.0
var last_headbob_value: float = 0.0
var footstep_played_this_cycle: bool = false
var headbob_enabled: bool = true

# === INTERNAL STATE ===
var journal_animation_played: bool = false
var journal_visible: bool = false
var cursor = cursor_default
var turn_threshold: float = 0
var turn_speed: float = 15
var last_input_dir: Vector3 = Vector3.ZERO
var air_direction: Vector3 = Vector3.ZERO
@onready var footstep: AudioStream = step_grass
var mouse_look_enabled: bool = true

func _ready():
	flashlight.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	state_machine.init(self)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("key_journal"):
		var anim_player := journal_animator
		var opening_anim := "JournalOpen"
		var closing_anim := "JournalClose"

		if journal_visible:
			if anim_player.is_playing() and anim_player.current_animation == opening_anim and anim_player.speed_scale > 0:
				anim_player.speed_scale = -1
				anim_player.seek(anim_player.current_animation_position)
			else:
				anim_player.speed_scale = 1
				anim_player.play(closing_anim)
				SoundManager.play_sfx(journal_close_sound, false)
			journal_visible = false
			GameManager.player_state = GameManager.PlayerState.FREE
		else:
			if anim_player.is_playing() and anim_player.current_animation == closing_anim and anim_player.speed_scale > 0:
				anim_player.speed_scale = -1
				anim_player.seek(anim_player.current_animation_position)
			else:
				anim_player.speed_scale = 1
				anim_player.play(opening_anim)
				SoundManager.play_sfx(journal_open_sound, false)
			journal_visible = true
			GameManager.player_state = GameManager.PlayerState.LOCKED

func _input(event):
	if (
		event is InputEventKey
		and event.pressed
		and event.keycode == KEY_ESCAPE
		and !GameManager.is_in_dialogue
	):
		mouse_look_enabled = !mouse_look_enabled
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if mouse_look_enabled else Input.MOUSE_MODE_VISIBLE)

	if event is InputEventMouseMotion and mouse_look_enabled and GameManager.player_state == GameManager.PlayerState.FREE:
		camera_rig.rotation.y -= event.relative.x * mouse_sensitivity
		pitch -= -event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(-80), deg_to_rad(80))
		camera.rotation.x = -pitch

	sprinting = Input.is_action_pressed("key_sprint")

	if GameManager.player_state == GameManager.PlayerState.FREE:
		if event.is_action_pressed("key_interact") or event.is_action_pressed("left_click"):
			handle_interact()

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F3:
			var debug_panel = get_tree().current_scene.get_node("UILayer/DebugPanel")
			debug_panel.visible = not debug_panel.visible
		if event.keycode == KEY_F4:
			GameManager.debug_draw_raycast = not GameManager.debug_draw_raycast
			var debug_panel = get_tree().current_scene.get_node("UILayer/DebugPanel")
			debug_panel.raycast_debug_enabled = GameManager.debug_draw_raycast

func _physics_process(delta):
	if Input.is_action_just_pressed("key_b"):
		state_machine.change_state("BikeState")
	
	if GameManager.player_state == GameManager.PlayerState.FREE:
		if Input.is_action_just_pressed("key_f"):
			flashlight.visible = !flashlight.visible
			SoundManager.play_sfx(flashlight_sound)
	
	if footstep_ray.is_colliding():
		var target = footstep_ray.get_collider()
		while target and not (target is Floor):
			target = target.get_parent()
		if target and target is Floor:
			match target.floor_type:
				Floor.FloorType.GRASS:
					footstep = step_grass
				Floor.FloorType.STONE:
					footstep = step_stone
				Floor.FloorType.WOOD:
					footstep = step_wood

	canvas_layer.visible = GameManager.player_state == GameManager.PlayerState.FREE

	if (
		Input.is_action_just_pressed("left_click")
		and !mouse_look_enabled
		and !GameManager.is_in_dialogue
	):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		mouse_look_enabled = true

	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var target_tilt = input.x * camera_lean_angle
	var current_tilt = camera_rig.rotation_degrees.z
	if GameManager.player_state == GameManager.PlayerState.LOCKED:
		target_tilt = 0.0
	camera_rig.rotation_degrees.z = lerp(current_tilt, target_tilt, delta * camera_lean_speed)

	if GameManager.player_state == GameManager.PlayerState.LOCKED:
		return

	if (
		headbob_enabled
		and velocity.length() > 0.1
		and is_on_floor()
		and GameManager.player_state == GameManager.PlayerState.FREE
	):
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

		if (
			last_headbob_value < -0.95
			and bob_value >= last_headbob_value
			and not footstep_played_this_cycle
		):
			SoundManager.play_sfx(footstep, true)
			footstep_played_this_cycle = true
		if bob_value > 0.1:
			footstep_played_this_cycle = false

		last_headbob_value = bob_value
	else:
		var current_pos = camera_rig.position
		current_pos.y = lerp(current_pos.y, cam_origin_y, delta * 10.0)
		camera_rig.position = current_pos

	handle_reticle()
	state_machine.update_state(delta)

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
		if target and target.has_method("interact") and "interaction_type" in target:
			match target.interaction_type:
				"talk": next_anim = "Speak"
				"grab": next_anim = "Grab"
				"inspect": next_anim = "Inspect"
	if cursor_animator.animation != next_anim:
		cursor_animator.play(next_anim)

func handle_interact():
	if raycast == null:
		return
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var target = raycast.get_collider()
		while target and not target.has_method("interact"):
			target = target.get_parent()
		if target and target.is_in_group("interactables") and target.has_method("interact"):
			target.interact()
