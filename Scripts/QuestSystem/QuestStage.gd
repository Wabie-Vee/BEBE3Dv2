extends Resource
class_name QuestStage

@export var description: String
@export var conditions: Array[String] = []
@export var on_complete: String = ""  # Optional trigger like cutscene or effect
