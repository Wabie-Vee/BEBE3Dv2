extends Interactable

@onready var speaker: SpeakerSystem = $SpeakerSystem
@onready var dial: MeshInstance3D = $Dial
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var tracklist: Array[AudioStream] = []
var current_track: int = 0

func _ready():
	if not tracklist.is_empty():
		speaker.player.stream = tracklist[0]
		speaker.player.play()

func interact():
	animation_player.play("interacted")
	_change_station()

func _change_station():
	if tracklist.is_empty():
		speaker.player.stop()
		return

	current_track += 1
	if current_track >= tracklist.size():
		current_track = 0

	var new_stream = tracklist[current_track]
	speaker.player.stream = new_stream
	speaker.player.play()

	var target_rotation = 0.0
	if current_track != 0:
		target_rotation = randf_range(45.0, 315.0)

	var tween = create_tween()
	tween.tween_property(dial, "rotation_degrees:z", target_rotation, 0.3)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
