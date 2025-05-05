extends Resource
class_name QuestData


@export var id: String = ""  # Used as the Dialogic.VAR prefix (e.g. "Penny")
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture
@export var tracked_vars: Array[String] = []  # e.g. ["talked_to_penny", "got_frog"]
@export var required_flags_to_complete: Array[String] = []
@export var is_main_quest: bool = false
