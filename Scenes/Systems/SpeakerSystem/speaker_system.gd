extends Node3D
class_name SpeakerSystem

@onready var player: AudioStreamPlayer3D = $AudioPlayer
@onready var obstruction_timer: Timer = $ObstructionCheckTimer

@export var bus_name := "Speaker"
@export var max_thickness := 5.0
@export var grid_size := 3
@export var spacing := 0.2

func _ready():
	player.bus = bus_name
	obstruction_timer.timeout.connect(_check_obstruction)
	obstruction_timer.start()

func _check_obstruction():
	if not player.playing:
		return

	var listeners = get_tree().get_nodes_in_group("player")
	if listeners.is_empty():
		return

	var origin = listeners[0].global_transform.origin
	var target = player.global_transform.origin

	var space_state = get_world_3d().direct_space_state
	var ray_count = 0
	var hit_count = 0
	var thickness_accum = 0.0

	for x in range(grid_size):
		for y in range(grid_size):
			var offset = Vector3((x - grid_size / 2.0) * spacing, (y - grid_size / 2.0) * spacing, 0)
			var start = origin + listeners[0].global_transform.basis * offset
			var end = target + player.global_transform.basis * offset

			var query = PhysicsRayQueryParameters3D.create(start, end)
			query.exclude = [listeners[0], self]
			var result = space_state.intersect_ray(query)
			ray_count += 1

			if result:
				hit_count += 1
				var reverse_query = PhysicsRayQueryParameters3D.create(end, start)
				reverse_query.exclude = [listeners[0], self]
				var reverse_result = space_state.intersect_ray(reverse_query)

				if reverse_result:
					var thickness = result.position.distance_to(reverse_result.position)
					thickness_accum += thickness

	var occlusion = float(hit_count) / max(ray_count, 1)
	var avg_thickness = thickness_accum / max(hit_count, 1)
	var obstruction = clamp(occlusion * clamp(avg_thickness / max_thickness, 0.0, 1.0), 0.0, 1.0)

	var bus_index = AudioServer.get_bus_index(bus_name)
	var filter = AudioServer.get_bus_effect(bus_index, 0) as AudioEffectLowPassFilter
	if filter:
		filter.cutoff_hz = lerp(8000.0, 20000.0, 1.0 - obstruction)

	AudioServer.set_bus_volume_db(bus_index, lerp(-12.0, 0.0, 1.0 - obstruction))
