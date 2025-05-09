extends Interactable

@onready var speaker: SpeakerSystem = $SpeakerSystem
@onready var dial: MeshInstance3D = $Dial
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var tracklist: Array[AudioStream] = []
var current_track := 0

func _ready():
	if not tracklist.is_empty():
		speaker.player.stream = tracklist[0]
		speaker.player.play()

func interact():
	animation_player.play("interacted")
	_change_station()

func _change_station():
	current_track = wrapi(current_track + 1, 0, tracklist.size())

	if tracklist.is_empty():
		speaker.player.stop()
	else:
		speaker.player.stream = tracklist[current_track]
		speaker.player.play()

	# Animate the dial (optional)
	var rot = randf_range(45.0, 315.0)
	var tween = create_tween()
	tween.tween_property(dial, "rotation_degrees:z", rot, 0.3)
