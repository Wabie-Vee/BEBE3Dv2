extends Node3D
@onready var look_at_modifier: LookAtModifier3D = $char_grp/rig/Skeleton3D/LookAtModifier3D
@onready var look_at: Marker3D = $LookAt
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interactable: Interactable = $".."



var quest = QuestManager.active_quests.get("penny_capsule")




func _ready() -> void:
	animation_player.play("BunnyIdle")
	$"..".custom_interact_handler = _on_interacted
	
	

func _on_interacted():
	
	
	var quest = QuestManager.active_quests.get("penny_capsule")
	if quest:
		print("📊 Current stage:", quest.current_stage, "Completed:", quest.completed)
	if quest != null:
		match quest.current_stage:
			0:
				print("📬 Attempting to set flag talked_to_penny")
				GameManager.update_quest_flag("talked_to_penny", true)
				GameManager.start_dialogue([
					"Hi there! I'm Penny.",
					"Want to help me bury a time capsule?"
				], $"..".voice_clip)
			1:
				GameManager.start_dialogue([
					"Still working on the capsule?",
					"Remember to bring the frog!"
				], $"..".voice_clip)
	else:
		GameManager.start_dialogue([
			"I have nothing more to say to you... frog thief."
		], $"..".voice_clip)


func _on_interactable_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		look_at_modifier.target_node = body.camera_rig.get_path()
		
	pass # Replace with function body.


func _on_interactable_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		look_at_modifier.target_node = look_at.get_path()
	pass # Replace with function body.
