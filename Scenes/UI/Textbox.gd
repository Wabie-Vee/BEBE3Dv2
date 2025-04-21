extends Control

@onready var label := $Panel/RichTextLabel
var auto_pause := true
var ready_for_input := false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameManager.start_dialogue()

	await get_tree().create_timer(0.15).timeout
	ready_for_input = true

func set_message(msg: String):
	label.text = msg
	
func _unhandled_input(event):
	if not ready_for_input:
		return

	if event.is_action_pressed("key_interact"):
		print("👋 Interact pressed inside Textbox")
		dismiss()



func dismiss():
	if GameManager.is_in_dialogue:
		GameManager.end_dialogue()
	queue_free()
