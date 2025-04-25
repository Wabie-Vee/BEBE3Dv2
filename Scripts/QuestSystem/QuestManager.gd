extends Node


signal stage_completed(quest_id: String, event: String)

var active_quests := {}
var completed_quests := {}

func _ready():
	autoload_all_quests_from_folder()

func add_quest(quest: Quest):
	active_quests[quest.id] = quest
	print("📜 Added quest:", quest.title)

func load_quest(path: String):
	var quest: Quest = load(path)
	if quest:
		add_quest(quest)
	else:
		push_error("❌ Failed to load quest at path: " + path)

func check_quests(flags: Dictionary):
	print("🔍 Checking all quests...")

	for quest_id in active_quests.keys():
		var quest: Quest = active_quests[quest_id]
		if quest.completed:
			print("⏩ Skipping completed quest:", quest_id)
			continue

		print("🔎 Quest:", quest.id, "Current stage:", quest.current_stage)

		if quest.current_stage >= quest.stages.size():
			print("❌ Stage index out of range for quest:", quest.id)
			continue

		var stage = quest.stages[quest.current_stage]
		print("📋 Stage conditions for stage", quest.current_stage, ":", stage.conditions)

		var all_met = true
		for cond in stage.conditions:
			if flags.get(cond, false):
				print("✅ Condition met:", cond)
			else:
				print("❌ Condition NOT met:", cond)
				all_met = false
				break

		if all_met:
			print("🎯 All conditions met for quest:", quest.id, "→ advancing stage")
			if stage.on_complete != "":
				emit_signal("stage_completed", quest.id, stage.on_complete)

			quest.advance_stage()
			print("➡️ New stage for", quest.id, "is now:", quest.current_stage)

			if quest.completed:
				completed_quests[quest_id] = quest
				active_quests.erase(quest_id)
				print("🎉 Quest completed:", quest.title)

func autoload_all_quests_from_folder(folder_path: String = "res://Quests/"):
	var dir := DirAccess.open(folder_path)
	if dir == null:
		push_error("❌ Could not open quest folder: " + folder_path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var quest_path = folder_path.path_join(file_name)
			load_quest(quest_path)
		file_name = dir.get_next()
	dir.list_dir_end()
