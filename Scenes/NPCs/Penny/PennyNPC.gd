extends NPC

func _on_interacted():
	var quest = QuestManager.active_quests.get("penny_capsule")

	if quest:
		print("📊 Penny talking. Current stage:", quest.current_stage, "Completed:", quest.completed)

		match quest.current_stage:
			0:
				GameManager.update_quest_flag("talked_to_penny", true)
				GameManager.start_dialogue([
					"Hi there! I'm [color=tomato][wave amp=30 freq=5]Penny[/wave][/color].",
					"[tornado radius=3.0 freq=5.0 connected=1][b]Want to help me bury a [color=yellow]time capsule[/color]?[/b]",
					"There should be a [color=green][wave amp=20 freq=3.5]frog[/wave][/color] around here [wave]somewhere...[/wave]",
					"[shake rate=25 level=10]I wanna [color=yellow][shake]bury[/shake][/color] a frog!!! [shake rate=30 level=5][b]RIGHT NOW!![/b][/shake]"
				], interactable.voice_clip, interactable.audio_gain)

			1:
				if GameManager.has_item("Frog"):
					GameManager.update_quest_flag("got_frog", true)
					GameManager.start_dialogue([
						"[wave amp=40 freq=4]You found the frog!!![/wave]",
						"[shake rate=15 level=8]Let’s bury it together. This is [b]perfect[/b]!"
					], interactable.voice_clip, interactable.audio_gain)
				else:
					GameManager.start_dialogue([
						"[tornado radius=2.5 freq=4.0]Still no [color=green]frog[/color]?[/tornado]",
						"[shake rate=30 level=7]You're holding out on me, I [b]KNOW[/b] it...[/shake]"
					], interactable.voice_clip, interactable.audio_gain)

			2:
				GameManager.start_dialogue([
					"[color=lightblue][wave amp=15 freq=2]Thanks again for helping with the capsule.[/wave][/color]",
					"You're the realest [shake rate=10 level=5]🐸.[/shake]"
				], interactable.voice_clip, interactable.audio_gain)
	else:
		GameManager.start_dialogue([
			"[shake rate=40 level=10][color=crimson]I have nothing more to say to you... frog thief.[/color][/shake]"
		], interactable.voice_clip, interactable.audio_gain)
