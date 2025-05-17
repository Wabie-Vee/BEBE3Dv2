extends Interactable

@export_file("*.tscn") var target_scene_path: String
@export var target_spawn_point: String = ""

func interact():
	print("📁 target_scene_path:", target_scene_path)
	print("🎯 target_spawn_point:", target_spawn_point)

	if target_scene_path == "":
		push_error("🚪 Door has no scene path set!")
		return

	GameManager.next_spawn_point = target_spawn_point
	FadeController.fade_and_switch_scene(target_scene_path)
