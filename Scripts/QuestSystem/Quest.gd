extends Resource
class_name Quest

@export var id: String
@export var title: String
@export var stages: Array[QuestStage]
@export var description: String = ""

var current_stage := 0
var completed := false

func advance_stage():
	if current_stage < stages.size() - 1:
		current_stage += 1
	else:
		completed = true
