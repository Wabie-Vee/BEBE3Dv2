extends Area3D
class_name Interactable

@export var dialog_lines: Array[String] = [
	"[wave]Heyyyy[/wave] I'm Penny.",
	"Did you bury the frog yet?",
	"[shake]Don't lie to me. I *smell* frogs.[/shake]"
]

@export var voice_clip: AudioStream

func interact():
	GameManager.start_dialogue(dialog_lines, voice_clip)
