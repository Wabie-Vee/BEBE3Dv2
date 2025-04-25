extends Area3D
class_name Interactable

@export_enum("talk", "grab") var interaction_type: String = "talk"

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
		GameManager.start_dialogue(dialog_lines, voice_clip)
