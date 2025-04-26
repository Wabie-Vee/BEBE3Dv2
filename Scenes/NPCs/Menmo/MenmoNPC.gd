extends NPC

func _on_interacted():
	GameManager.start_dialogue([
		"H-h-hi there! I'm Menmo...",
		"I-I-I don't have any frogs, but I have... crumbs?"
	], interactable.voice_clip, interactable.audio_gain)
