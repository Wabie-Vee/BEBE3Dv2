extends Control

@onready var quest_list: VBoxContainer = $QuestList
var folder_display_names = {
	"Penny": "Penumbra",
	"Menmo": "Menmo’s Mischief",
	"MainStory": "Main Story"
}

var folder_notes = {
	"Penny": "Help Penumbra find her frog!",
	"MainStory": "These choices affect the ending.",
	"Menmo": "He's just a little guy!",
}

func _ready():
	
	await wait_for_dialogic_var_ready()
	refresh_all_dialogic_vars()
	Dialogic.VAR.variable_changed.connect(_on_var_changed)

func wait_for_dialogic_var_ready():
	while Dialogic.VAR == null:
		await get_tree().process_frame
	print("✅ Dialogic.VAR is ready")

func refresh_all_dialogic_vars():
	# Clear previous UI
	for child in quest_list.get_children():
		child.queue_free()

	# Loop over each folder (e.g. Penny, Menmo)
	for folder in Dialogic.VAR.folders():
		var folder_name = folder.path
		var folder_box := VBoxContainer.new()

		# 🟡 Folder title
		var title := Label.new()
		if folder_name in folder_display_names:
			title.text = "🗒️ " + folder_display_names[folder_name]
		else:
			title.text = "🗒️ " + folder_name.replace("_", " ").capitalize()
		title.add_theme_color_override("font_color", Color.YELLOW)
		folder_box.add_child(title)

		# 🔹 Folder note (if any)
		if folder_name in folder_notes:
			var note_label := Label.new()
			note_label.text = folder_notes[folder_name]
			note_label.add_theme_color_override("font_color", Color.NAVY_BLUE)
			folder_box.add_child(note_label)

		# ✅ Loop through each tracked variable
		for var_name in folder.variables():
			var full_path = folder_name + "." + var_name
			var value = Dialogic.VAR.get_variable(full_path)
			var label = Label.new()
			var display_name = var_name.replace("_", " ").capitalize()

			if value == true:
				label.text = "✅ " + display_name 
			elif value == false:
				label.text = "❌ " + display_name
			else:
				label.text = "🔸 " + display_name + ": " + str(value)

			folder_box.add_child(label)

		quest_list.add_child(folder_box)


func _on_var_changed(info: Dictionary):
	await get_tree().process_frame
	refresh_all_dialogic_vars()
