extends Interactable

@onready var speaker: SpeakerSystem = $SpeakerSystem
@export var dial: MeshInstance3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var tracklist: Array[AudioStream] = []
var current_track: int = 0 # 0 = OFF

func _ready():
	speaker.player.stop()
	# Do not auto-play — radio starts off

func interact():
	animation_player.play("interacted")
	_change_station()

func _change_station():
	if tracklist.is_empty():
		speaker.player.stop()
		return

	current_track += 1
	current_track = wrapi(current_track, 0, tracklist.size() + 1) # +1 for off

	if current_track == 0:
		speaker.player.stop()
	else:
		var new_stream = tracklist[current_track - 1]
		speaker.player.stream = new_stream
		speaker.player.play()

	var target_rotation = 0.0
	if current_track != 0:
		target_rotation = randf_range(45.0, 315.0)

	var tween = create_tween()
	tween.tween_property(dial, "rotation_degrees:z", target_rotation, 0.3)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
