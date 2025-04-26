extends Node3D
class_name NPC

@onready var look_at_modifier: LookAtModifier3D = $char_grp/rig/Skeleton3D/LookAtModifier3D
@onready var look_at: Marker3D = $LookAt
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interactable: Interactable = $".."

# 🧠 Default values NPCs can override
var npc_name: String = "Unnamed NPC"

func _ready() -> void:
	animation_player.play("Idle")
	interactable.custom_interact_handler = _on_interacted

func _on_interacted():
	# Base interaction (you override this in child classes)
	print("👋", npc_name, "says hello!")

func _on_interactable_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		look_at_modifier.target_node = body.camera_rig.get_path()

func _on_interactable_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		look_at_modifier.target_node = look_at.get_path()
