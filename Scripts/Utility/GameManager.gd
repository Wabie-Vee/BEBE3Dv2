extends Node

const textbox_scene = preload("res://Scenes/UI/Textbox.tscn")

var player_state := "PlayerStateFree"

var current_textbox = null
var is_in_dialogue = false
var current_tree = null
var current_node_id = ""

var debug_draw_raycast := false


# 🧰 Inventory system
var inventory := {}

# 🧩 Quest/Flag tracking system
var quest_flags := {}  # e.g. { "talked_to_penny": true, "got_frog": true }

func _ready():
	print("GameManager initialized.")

# 🔳 Dialogue system basics
func new_textbox(message: String):
	if current_textbox:
		current_textbox.queue_free()

	var textbox = textbox_scene.instantiate()
	textbox.call_deferred("set_message", message)
	current_textbox = textbox

	var ui_layer = get_tree().current_scene.get_node("UILayer")
	if ui_layer:
		ui_layer.add_child(textbox)
	else:
		print("❌ UILayer not found.")

	start_dialogue()

func start_dialogue():
	player_state = "LockedState"
	is_in_dialogue = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # ✨ Stay in control

func end_dialogue():
	player_state = "PlayerStateFree"
	is_in_dialogue = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# ✅ Get the player node
	var player = get_tree().current_scene.get_node("Player")  # adjust path if different

	if player:
		# ✅ Force change to IdleState
		player.state_machine.change_state("IdleState")

		# ✅ Stop camera lean
		player.camera_rig.rotation_degrees.z = 0.0  # zero out lean
		player.headbob_timer = 0.0  # optional: reset headbob if it's leaning on movement
