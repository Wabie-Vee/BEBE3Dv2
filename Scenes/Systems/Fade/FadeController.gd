extends CanvasLayer

@onready var fade_rect: ColorRect = $FadeRect
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready():
	fade_rect.color.a = 0.0

func fade_and_switch_scene(scene_path: String):
	anim_player.play("fade_in")
	await anim_player.animation_finished
	get_tree().change_scene_to_file(scene_path)
	anim_player.play("fade_out")
