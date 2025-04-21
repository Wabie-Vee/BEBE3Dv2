extends Node

@onready var audio_bus := "SFX"

func play_sfx(stream: AudioStream, pitch_variation: bool = true, volume_db := 0.0):
	if stream == null:
		print("SoundManager: Tried to play a null stream.")
		return

	var audio = AudioStreamPlayer.new()
	add_child(audio)

	audio.bus = audio_bus
	audio.stream = stream
	audio.volume_db = volume_db

	if pitch_variation:
		audio.pitch_scale = randf_range(0.95, 1.05)

	audio.play()
	audio.finished.connect(audio.queue_free)
