extends Area3D
@export var collider_node: Node3D  # Drag your collider (or body) here in the Inspector
@export var message := "I'm just a random thing with thoughts."
var player_in_range := false

func _ready():
	if collider_node:
		collider_node.add_to_group("interactables")
	else:
		push_warning("⚠️ Interactable has no collider_node assigned!")
		
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		
func interact():
	if player_in_range:
		GameManager.new_textbox(message)
	else:
		print("❌ Player not close enough to interact.")
