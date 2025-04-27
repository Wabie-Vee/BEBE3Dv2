extends Control

@onready var label: RichTextLabel = $Panel/RichTextLabel
@onready var textbox_ui: AnimatedSprite2D = $Panel/TextBox
@onready var icon: Sprite2D = $Panel/Sprite2D
@onready var animation: AnimationPlayer = $Panel/AnimationPlayer

@export var open_sound: AudioStream
@export var voice: AudioStream
@export var voice_volume: float = 1.0

var ready_for_input := false
var visible_char_count := 0
var last_visible_ratio := 0.0
var tween: Tween
var open_animation_playing := false

func _ready():
	label.text = ""
	icon.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	textbox_ui.play()

	# 🛡 Wait a tiny frame just to be safe
	await get_tree().process_frame

	if not GameManager.textbox_is_open:
		GameManager.textbox_is_open = true
		open_animation_playing = true
		animation.play("textbox_open")
		await animation.animation_finished
		open_animation_playing = false
		ready_for_input = true
	else:
		animation.play("RESET")
		ready_for_input = true

func play_open_sound():
	SoundManager.play_ui(open_sound)

func set_message(msg: String):
	# Only start revealing if ready
	if not ready_for_input:
		await get_tree().create_timer(0.01).timeout
		await _wait_until_ready()

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

func _wait_until_ready():
	while not ready_for_input:
		await get_tree().process_frame

func _process(delta):
	if not ready_for_input or not is_instance_valid(label):
		return

	var current_char = int(round(label.visible_ratio * visible_char_count))
	var last_char = int(round(last_visible_ratio * visible_char_count))

	if current_char > last_char and current_char % 2 == 0 and voice:
		SoundManager.stop_sfx(voice)
		SoundManager.play_sfx(voice, true, voice_volume)

	last_visible_ratio = label.visible_ratio
	if label.visible_ratio == 1:
		if not animation.is_playing() or animation.current_animation != "Bounce":
			animation.play("Bounce")
		icon.visible = true

func _unhandled_input(event):
	if not ready_for_input:
		return

	if event.is_action_pressed("key_interact") or event.is_action_pressed("left_click"):
		# Allow skip of opening animation
		if open_animation_playing:
			animation.stop()
			open_animation_playing = false
			ready_for_input = true
			return

		if label.visible_ratio < 1:
			if tween:
				tween.kill()
			label.visible_ratio = 1.0
		else:
			dismiss()

func dismiss():
	queue_free()
	GameManager.textbox_is_open = true
	if GameManager.is_in_dialogue:
		GameManager.show_next_line()
