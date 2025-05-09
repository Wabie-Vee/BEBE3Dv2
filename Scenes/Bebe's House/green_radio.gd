extends Interactable

@onready var radio_player: AudioStreamPlayer3D = $RadioPlayer
@onready var click_player: AudioStreamPlayer3D = $ClickPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dial: MeshInstance3D = $GreenRadio/Cylinder
@onready var obstruction_timer: Timer = $ObstructionCheckTimer


@export var tracklist: Array[AudioStream] = [] # Station 0 = off, 1+ = music
@export var radio_click_sound: AudioStream
@export var click_sound: AudioStream
@onready var radio_station: int = 0

func _ready() -> void:
	radio_player.bus = "Radio"
	click_player.stream = radio_click_sound
	obstruction_timer.timeout.connect(_check_radio_obstruction)
	obstruction_timer.start() # <- important if Autostart is off
	print("radio is alive")
	
func _check_radio_obstruction():
	if not radio_player.playing:
		return
	
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return

	var player = players[0]
	var origin = player.global_transform.origin
	var target = radio_player.global_transform.origin

	var space_state = get_world_3d().direct_space_state
	var ray_count = 0
	var hit_count = 0
	var thickness_accum = 0.0

	var grid_size = 3
	var spacing = 0.2

	for x in range(grid_size):
		for y in range(grid_size):
			var offset = Vector3(
				(x - grid_size / 2.0) * spacing,
				(y - grid_size / 2.0) * spacing,
				0
			)

			var start = origin + (player.global_transform.basis * offset)
			var end = target + (radio_player.global_transform.basis * offset)

			var query = PhysicsRayQueryParameters3D.create(start, end)
			query.exclude = [player, self]

			var result = space_state.intersect_ray(query)
			ray_count += 1
			DebugDraw3D.draw_line(start, end, Color.YELLOW, 0.2)

			if result:
				hit_count += 1
				var hit_point = result.position

				var reverse_query = PhysicsRayQueryParameters3D.create(end, start)
				reverse_query.exclude = [player, self]
				var reverse_result = space_state.intersect_ray(reverse_query)

				if reverse_result:
					var reverse_hit = reverse_result.position
					var thickness = hit_point.distance_to(reverse_hit)
					thickness_accum += thickness

					DebugDraw3D.draw_sphere(hit_point, 0.05, Color.RED, 0.2)
					DebugDraw3D.draw_sphere(reverse_hit, 0.05, Color.BLUE, 0.2)
					DebugDraw3D.draw_line(hit_point, reverse_hit, Color.DARK_SLATE_GRAY, 0.2)

	var occlusion = float(hit_count) / max(ray_count, 1)
	var avg_thickness = thickness_accum / max(hit_count, 1)
	var scaled_thickness = clamp(avg_thickness / 5.0, 0.0, 1.0)  # 5.0 is the new max thickness
	var obstruction_strength = clamp(occlusion * scaled_thickness, 0.0, 1.0)

	# 🎧 FILTER: cutoff range
	var cutoff_hz = lerp(8000.0, 20000.0, 1.0 - obstruction_strength)

	# 🔉 VOLUME: fade between -12 dB (quiet) and 0 dB (full)
	var volume_db = lerp(-12.0, 0.0, 1.0 - obstruction_strength)

	var bus_index = AudioServer.get_bus_index("Radio")
	var filter = AudioServer.get_bus_effect(bus_index, 0) as AudioEffectLowPassFilter

	if filter:
		filter.cutoff_hz = cutoff_hz
	AudioServer.set_bus_volume_db(bus_index, volume_db)

	# 📢 Debug log
	print("🔊 Occlusion: ", occlusion)
	print("📏 Thickness: ", avg_thickness)
	print("🎛️ Cutoff Hz: ", cutoff_hz)
	print("📉 Volume dB: ", volume_db)



func interact():
	animation_player.play("interacted")
	change_radio_station()

func change_radio_station():
	if tracklist.is_empty():
		return

	radio_player.stop()
	click_player.play()

	# Calculate new rotation immediately
	var target_rotation := 0.0

	if radio_station == tracklist.size():
		# Looping back to 0 (off) → reset rotation
		target_rotation = 0.0
	else:
		# Spin to a random rotation
		target_rotation = randf_range(45.0, 315.0)

	# Start the dial tween right away (before await)
	var tween := create_tween()
	tween.tween_property(dial, "rotation_degrees:z", target_rotation, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Wait before switching audio
	await get_tree().create_timer(0.5).timeout

	# Change the station after click + spin
	radio_station = wrapi(radio_station + 1, 0, tracklist.size() + 1)

	if radio_station == 0:
		radio_player.stop()
	else:
		radio_player.stream = tracklist[radio_station - 1]
		radio_player.play()
