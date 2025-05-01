extends Node3D
class_name NPC

@export var look_at_modifier: LookAtModifier3D
@export var look_at: Marker3D
@export var animation_player: AnimationPlayer
@onready var interactable: Interactable = $".."
@export var animation_idle: String

# 🧠 Default values NPCs can override
var npc_name: String = "Unnamed NPC"    

func _ready() -> void:
	var interactable = get_parent()  # Assuming parent is Interactable
	if interactable.has_signal("body_entered"):
		interactable.connect("body_entered", Callable(self, "_on_interactable_body_entered"))
	if interactable.has_signal("body_exited"):
		interactable.connect("body_exited", Callable(self, "_on_interactable_body_exited"))
	look_at_modifier.duration = 1.0
	look_at_modifier.transition_type = Tween.TRANS_QUINT
	look_at_modifier.ease_type = Tween.EASE_OUT
	if animation_player:
		animation_player.play(animation_idle)
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
