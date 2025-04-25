extends Interactable
class_name Collectible

@export var item_name: String
@export var pickup_sound: AudioStream
@export var auto_destroy: bool = true

@onready var sfx = AudioStreamPlayer3D.new()

func _ready():
	super._ready()  # Call Interactable's _ready if needed
	add_child(sfx)

func interact():
	print("🧲 Interacted to collect:", item_name)
	GameManager.add_to_inventory(item_name)

	if pickup_sound:
		SoundManager.play_sfx(pickup_sound, true)

	if auto_destroy:
		queue_free()
