extends OmniLight3D

@export var light_intensity: float = 1.0
@export var flicker_speed: float = 5.0     # Lower = slower transitions
@export var flicker_intensity: float = 0.5 # How strong the flicker can deviate
var target_energy: float = 1.0

func _ready():
	randomize()
	_pick_new_target()

func _physics_process(delta: float) -> void:
	if abs(light_energy - target_energy) < 0.05:
		_pick_new_target()

	light_energy = lerp(light_energy, target_energy, delta * flicker_speed)

func _pick_new_target():
	target_energy = randf_range(
		light_intensity - flicker_intensity * 0.5,
		light_intensity + flicker_intensity * 0.5
	)
