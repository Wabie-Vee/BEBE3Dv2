extends CanvasLayer

@onready var label: RichTextLabel = $Panel/RichTextLabel
@onready var icon: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation: AnimationPlayer = $Panel/AnimationPlayer
@onready var image_rect: TextureRect = $Panel/TextureRect

@export var initial_text: String = ""
@export var initial_image: Texture2D
@export var open_sound: AudioStream
@export var voice: AudioStream
@export var voice_volume: float = 1.0

var ready_for_input := false
var visible_char_count := 0
var last_visible_ratio := 0.0
var tween: Tween
var open_animation_playing := false
@onready var label_initial_y = label.position.y
func _ready():
	SoundManager.play_sfx(open_sound, true, .5)
	set_process_input(true)
	label.text = ""
	icon.visible = false
	icon.position = Vector2.ZERO


	label.visible_ratio = 1
	open_animation_playing = true
	animation.play("open")
	await animation.animation_finished

	open_animation_playing = false
	ready_for_input = true

	# NOW show text and image after animation finishes
	set_image_and_text(initial_image, initial_text)

func set_image_and_text(image: Texture2D, text: String):
	image_rect.texture = image
	label.visible_ratio = 1.0
	label.bbcode_text = text

	var regex = RegEx.new()
	regex.compile("\\[.*?\\]")
	var plain_text = regex.sub(text, "", true)
	visible_char_count = plain_text.length()

	if tween:
		tween.kill()

	var duration = visible_char_count * 0.07
	tween = create_tween()
	tween.tween_property(label, "visible_ratio", 1.0, duration)

func _process(delta):
	var t = Time.get_ticks_msec() / 1000.0
	label.position.y = label_initial_y + wave(t, .5, 1.0)
	if not ready_for_input:
		return

	var current_char = int(round(label.visible_ratio * visible_char_count))
	var last_char = int(round(last_visible_ratio * visible_char_count))

	if current_char > last_char and current_char % 2 == 0 and voice:
		SoundManager.stop_sfx(voice)
		SoundManager.play_sfx(voice, true, .2)

	last_visible_ratio = label.visible_ratio
	if label.visible_ratio == 1.0:
		if not animation.is_playing() or animation.current_animation != "bounce":
			animation.play("bounce")
		icon.visible = true

func _input(event):
	if not ready_for_input:
		return

	if event.is_action_pressed("ui_accept") or event.is_action_pressed("key_interact"):
		if open_animation_playing:
			animation.stop()
			open_animation_playing = false
			ready_for_input = true
			return

		if label.visible_ratio < 1.0:
			if tween:
				tween.kill()
			label.visible_ratio = 1.0
		else:
			dismiss()

func dismiss():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GameManager.player_state = GameManager.PlayerState.FREE
	queue_free()
	
func wave(time: float, amplitude: float = 1.0, frequency: float = 1.0, phase: float = 0.0) -> float:
	return sin(time * frequency * TAU + phase) * amplitude
