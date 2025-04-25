extends Node3D
@onready var look_at_modifier: LookAtModifier3D = $char_grp/rig/Skeleton3D/LookAtModifier3D
@onready var look_at: Marker3D = $LookAt
@onready var animation_player: AnimationPlayer = $AnimationPlayer



func _ready() -> void:
	animation_player.play("BunnyIdle")

func _on_interactable_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		look_at_modifier.target_node = body.camera_rig.get_path()
		
	pass # Replace with function body.


func _on_interactable_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		look_at_modifier.target_node = look_at.get_path()
	pass # Replace with function body.
