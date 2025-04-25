extends Control

@onready var label := $Panel/RichTextLabel
@onready var textbox_ui: AnimatedSprite2D = $Panel/AnimatedSprite2D
@onready var icon: Sprite2D = $Panel/Sprite2D
@onready var animation: AnimationPlayer = $Panel/AnimationPlayer


@export var voice: AudioStream
@export var voice_volume: float = 1.0

var ready_for_input := false
var visible_char_count := 0
var last_visible_ratio := 0.0
var tween: Tween

func _ready():
	icon.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	await get_tree().create_timer(0.15).timeout
	ready_for_input = true
	textbox_ui.play()
	

func set_message(msg: String):
	label.visible_ratio = 0.0
	label.bbcode_text = msg

	var regex = RegEx.new()
	regex.compile("\\[.*?\\]")
	var plain_text = regex.sub(msg, "", true)
	visible_char_count = plain_text.length()

	if tween:
		tween.kill()

	var duration = visible_char_count * 0.05
	tween = create_tween()
	tween.tween_property(label, "visible_ratio", 1.0, duration)

func _process(delta):
	var current_char = int(round(label.visible_ratio * visible_char_count))
	var last_char = int(round(last_visible_ratio * visible_char_count))

	if current_char > last_char and current_char % 2 == 0 and voice:
		SoundManager.stop_sfx(voice)
		SoundManager.play_sfx(voice, true, voice_volume)

	last_visible_ratio = label.visible_ratio
	if label.visible_ratio == 1:
		icon.visible = true
		animation.play("Bounce")
		

func _unhandled_input(event):
	if not ready_for_input:
		return

	if event.is_action_pressed("key_interact") or event.is_action_pressed("left_click"):
		if label.visible_ratio < 1:
			if tween:
				tween.kill()
			label.visible_ratio = 1.0
		else:
			dismiss()

func dismiss():
	queue_free()
	if GameManager.is_in_dialogue:
		GameManager.show_next_line()
