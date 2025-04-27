extends NPC

@onready var talked_to = false

func _on_interacted():
	var quest = QuestManager.active_quests.get("penny_capsule")
	var voice = interactable.voice_clip
	if quest:
		match quest.current_stage:
			0: 
				if !talked_to:
					talked_to = true
					GameManager.start_dialogue([
						"[shake]H-h-hi there! I'm Menmo...",
						"[shake]I think [color=gold]PENNY[/color] has something she wants to ask you..."
					], voice, interactable.audio_gain)
				else:
					GameManager.start_dialogue([
						"[shake]O-O-Oh... hi again..."
					], voice)
			1:
				if GameManager.has_item("Frog"):
					GameManager.start_dialogue([
						"[shake]Oh a [wave]frog!!!",
						"[shake]T-T-That's exactly what [color=gold]PENNY[/color] wanted to bury!",
						"[shake]You should g-g-go give that to her!"
					], voice)
				else:
					GameManager.start_dialogue([
						"[shake]O-O-Oh... you're looking for frogs?",
						"[shake]I-I-I don't have any frogs, but I have... crumbs?"
					], interactable.voice_clip, interactable.audio_gain)
			2:
				GameManager.start_dialogue([
					"[shake]Y-Y-You're a nice person for helping [color=gold]PENNY[/color] out with her dream...",
					"[shake]... of burying a frog?"
				], voice)
	else:
		GameManager.start_dialogue([
			"[shake]Y-Y-You're a nice person for helping [color=gold]PENNY[/color] out with her dream...",
			"[shake]... of burying a frog?"
		], voice)
