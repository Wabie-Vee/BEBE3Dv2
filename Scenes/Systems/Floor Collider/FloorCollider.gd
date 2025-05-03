extends Node3D
class_name Floor

enum FloorType { WOOD, GRASS, STONE }

@export var floor_type: FloorType = FloorType.WOOD

func _ready() -> void:
	visible = false;
