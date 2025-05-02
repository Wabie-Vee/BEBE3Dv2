extends Node

var all_quests: Array[QuestData] = []

func _ready():
	await wait_for_dialogic_var_ready()
	load_all_quests("res://Quests/")

	print("✅ QuestManager initialized with ", all_quests.size(), " quests.")

func wait_for_dialogic_var_ready() -> void:
	while Dialogic.VAR == null:
		await get_tree().process_frame
	print("✅ Dialogic.VAR is ready!")

func load_all_quests(folder_path: String):
	var dir := DirAccess.open(folder_path)
	if dir == null:
		push_error("❌ Could not open quest folder: " + folder_path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var quest_path := folder_path.path_join(file_name)
			var quest := load(quest_path)
			if quest is QuestData:
				all_quests.append(quest)
		file_name = dir.get_next()
	dir.list_dir_end()
	

func debug_print_dialogic_vars():
	print("📋 Dialogic Variables:")
	for var_name in Dialogic.VAR.variables(true):
		var value = Dialogic.VAR.get(var_name)
		print("  ", var_name, "→", value)
