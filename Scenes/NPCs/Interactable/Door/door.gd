extends Interactable

@export_file("*.tscn") var target_scene_path: String
@export var target_spawn_point: String = ""
const KEY_PICKUP_SFX = preload("res://Assets/Audio/key_pickup_sfx.ogg")
@export var anim_player: AnimationPlayer
@export var door_open: String 
@export var door_sound: AudioStream

func ready():
	if door_sound == null:
		door_sound = KEY_PICKUP_SFX

func interact():
	SoundManager.play_sfx(door_sound)
	print("📁 target_scene_path:", target_scene_path)
	print("🎯 target_spawn_point:", target_spawn_point)
	
	if anim_player && door_open:
		anim_player.play(door_open)

	if target_scene_path == "":
		push_error("🚪 Door has no scene path set!")
		return

	GameManager.next_spawn_point = target_spawn_point
	FadeController.fade_and_switch_scene(target_scene_path)
