extends Node

const textbox_scene = preload("res://Scenes/UI/Textbox/Textbox.tscn")

var player_state := "PlayerStateFree"
var is_in_dialogue = false
var current_textbox = null
var dialog_index = 0
var active_dialog: Array[String] = []
var active_voice: AudioStream = null
var active_audio_gain := 1.0

# ✅ Extras
var current_tree = null
var current_node_id = ""
var debug_draw_raycast := false

# 🧰 Inventory system
var inventory := {}

# 🧩 Flag tracking system (used by QuestManager)
var quest_flags := {}  # e.g. { "talked_to_penny": true, "got_frog": true }

func _ready():
	print("GameManager initialized.")
	QuestManager.autoload_all_quests_from_folder("res://Quests/")

func start_dialogue(dialog_array: Array[String], voice_clip: AudioStream, audio_gain: float = 1.00):
	if current_textbox:
		current_textbox.queue_free()

	active_dialog = dialog_array
	dialog_index = 0
	active_voice = voice_clip
	active_audio_gain = audio_gain
	is_in_dialogue = true
	player_state = "PlayerStateLocked"
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	show_next_line()

func show_next_line():
	if dialog_index < active_dialog.size():
		var textbox = textbox_scene.instantiate()
		textbox.voice = active_voice
		textbox.voice_volume = active_audio_gain
		current_textbox = textbox
		dialog_index += 1

		var ui_layer = get_tree().current_scene.get_node("UILayer")
		if ui_layer:
			ui_layer.add_child(textbox)
			await get_tree().process_frame
			textbox.set_message(active_dialog[dialog_index - 1])
		else:
			print("❌ UILayer not found.")
	else:
		end_dialogue()

func end_dialogue():
	player_state = "PlayerStateFree"
	is_in_dialogue = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	var player = get_tree().current_scene.get_node("Player")
	if player:
		player.state_machine.change_state("IdleState")
		player.camera_rig.rotation_degrees.z = 0.0
		player.headbob_timer = 0.0

func update_quest_flag(flag: String, value: bool):
	quest_flags[flag] = value
	print("🧠 Flag set:", flag, "=", value)
	print("🧠 All quest flags now:", quest_flags)
	QuestManager.check_quests(quest_flags)
	
func add_to_inventory(item_name: String):
	inventory[item_name] = true
	print("🎒 Collected:", item_name)
	
	# If this item is a quest flag trigger
	if item_name == "frog":
		update_quest_flag("got_frog", true)

func has_item(item_name: String) -> bool:
	return inventory.get(item_name, false)
