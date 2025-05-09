extends Area3D
class_name Interactable

@export_enum("talk", "grab","inspect") var interaction_type: String = "talk"
@export var audio_gain:= 1.0
@export var dialog_lines: Array[String] = [
	"[wave]Heyyyy[/wave] I'm Penny.",
	"Did you bury the frog yet?",
	"[shake]Don't lie to me. I *smell* frogs.[/shake]"
]

@export var voice_clip: AudioStream
var custom_interact_handler = null

func _ready():
	pass

func interact():
	if custom_interact_handler != null:
		custom_interact_handler.call()
	else:
		Dialogic.start("error_timeline")
