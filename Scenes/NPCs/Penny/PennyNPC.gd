extends NPC



func _on_interacted():
	var quest = QuestManager.active_quests.get("penny_capsule")
	Dialogic.start('Penumbra')
