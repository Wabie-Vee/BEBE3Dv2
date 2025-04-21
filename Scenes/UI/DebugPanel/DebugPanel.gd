extends Control

@export var player: Node3D  # Drag your player into this field

@onready var debug_label := $DebugLabel
var raycast_debug_enabled := false
var raycast_text := "OFF"


func _process(_delta):
	if raycast_debug_enabled:
		raycast_text = "ON"
	
	if not visible:
		return

	var debug_text := ""

	if player:
		debug_text += "Velocity: " + str(player.velocity) + "\n"
		debug_text += "State: " + str(player.state_machine.current_state) + "\n"
		debug_text += "Raycast Debug: " + raycast_text + "\n"

	debug_label.text = debug_text
