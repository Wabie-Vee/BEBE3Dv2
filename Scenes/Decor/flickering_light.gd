@tool
extends OmniLight3D

# === EXPORTS ===
@export var light_intensity: float = 1.5      # Base brightness
@export var flicker_speed: float = 10.0       # Flicker responsiveness
@export var flicker_intensity: float = 0.6    # Max fluctuation range

@export var positional_flicker_toggle: bool = true
@export var positional_flicker_speed: float = 8.0
@export var positional_flicker_intensity: float = 0.3 # Keep subtle for flame wobble

# === INTERNAL ===
var target_energy: float = 1.0
var target_position: Vector3
var time_passed: float = 0.0

@onready var light_origin: Vector3 = global_position


func _ready():
	randomize()
	target_position = global_position
	target_energy = light_intensity


func _physics_process(delta: float) -> void:
	time_passed += delta

	# Update light origin if we moved the light manually in editor
	if not positional_flicker_toggle:
		light_origin = global_position

	# === Flicker intensity using smooth noise ===
	var noise_value = sin(time_passed * flicker_speed) + randf_range(-0.2, 0.2)
	var energy_variation = flicker_intensity * 0.5 * noise_value
	light_energy = lerp(light_energy, light_intensity + energy_variation, delta * flicker_speed)

	# === Positional wiggle (optional) ===
	if positional_flicker_toggle:
		var offset = Vector3(
			sin(time_passed * 3.1 + 1.0) * randf_range(-1.0, 1.0),
			cos(time_passed * 2.3 + 3.0) * randf_range(-1.0, 1.0),
			sin(time_passed * 2.7 + 2.0) * randf_range(-1.0, 1.0)
		) * positional_flicker_intensity

		target_position = light_origin + offset
		global_position = global_position.lerp(target_position, delta * positional_flicker_speed)
