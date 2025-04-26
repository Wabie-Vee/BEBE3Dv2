extends NPC

func _on_interacted():
	var quest = QuestManager.active_quests.get("penny_capsule")

	if quest:
		print("📊 Penny talking. Current stage:", quest.current_stage, "Completed:", quest.completed)

		match quest.current_stage:
			0:
				GameManager.update_quest_flag("talked_to_penny", true)
				GameManager.start_dialogue([
					"Hi there! I'm [color=tomato]Penny.",
					"[tornado radius=3.0 freq=5.0 connected=1]Want to help me bury a [color=yellow]time capsule[/color]?",
					"There should be a [color=green]frog[/color] around here [wave]somewhere...[/wave]",
					"[shake rate=20 level=10]I wanna [color=yellow]bury[/color] a frog!!!"
				], interactable.voice_clip, interactable.audio_gain)

			1:
				if GameManager.has_item("frog"):
					GameManager.update_quest_flag("got_frog", true)
					GameManager.start_dialogue([
						"You found the frog!!!",
						"Let’s bury it together. This is perfect."
					], interactable.voice_clip, interactable.audio_gain)
				else:
					GameManager.start_dialogue([
						"Still no [color=green]frog[/color]?",
						"You're holding out on me, I can tell..."
					], interactable.voice_clip, interactable.audio_gain)

			2:
				GameManager.start_dialogue([
					"Thanks again for helping with the capsule.",
					"You're the realest 🐸."
				], interactable.voice_clip, interactable.audio_gain)
	else:
		GameManager.start_dialogue([
			"I have nothing more to say to you... frog thief."
		], interactable.voice_clip, interactable.audio_gain)
