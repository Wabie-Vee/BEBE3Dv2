extends Interactable
class_name Lookable

@export var image: Texture2D
@export_multiline var flavor_text: String

func _ready():
	super._ready()
	custom_interact_handler = _on_interacted

func _on_interacted():
	GameManager.show_flavor_image_and_text(image, flavor_text)
