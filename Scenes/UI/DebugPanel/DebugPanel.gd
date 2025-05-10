extends Control

@export var player: Node3D  # Drag your player into this field

@onready var debug_label := $DebugLabel
var raycast_debug_enabled := false
var raycast_text := "OFF"


func _process(_delta):
	print("debuglabel running!")
	visible = true
	if raycast_debug_enabled:
		raycast_text = "ON"
	
	if not visible:
		return

	var debug_text := ""

	if player:
		debug_text += "Velocity: " + str(player.velocity) + "\n"
		debug_text += "State: " + str(player.state_machine.current_state) + "\n"
		debug_text += "Raycast Debug: " + raycast_text + "\n"
		debug_text += "FPS: " + str(Engine.get_frames_per_second()) + "\n"
		debug_text += "Frogs: " + str(GameManager.has_item("Frog")) + "\n"
		debug_text += "Journal Open " + str(player.journal_visible) + "\n"
		debug_text += "Floor Type: " + str(player.footstep.resource_path) + "\n"

	debug_label.text = debug_text
