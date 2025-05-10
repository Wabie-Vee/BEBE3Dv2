extends Node3D

@export var background_music: AudioStream 
@export var background_ambience: AudioStream

func _ready() -> void:
	if background_music and not SoundManager.is_music_playing():
		SoundManager.play_music(background_music)
		
	if background_ambience and not SoundManager.is_ambience_playing():
		SoundManager.play_ambience(background_ambience)

func _physics_process(delta: float) -> void:
	if background_music and not SoundManager.is_music_playing():
		SoundManager.play_music(background_music)
		
	if background_ambience and not SoundManager.is_ambience_playing():
		SoundManager.play_ambience(background_ambience)
