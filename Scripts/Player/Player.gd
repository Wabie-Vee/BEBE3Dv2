extends CharacterBody3D

@onready var state_machine = $PlayerStateMachine
@onready var camera_rig = $CameraRig
@onready var raycast = $RayCast3D

var move_speed := 4.0

func _ready():
	state_machine.init(self)
	velocity = Vector3.ZERO

func _physics_process(delta):
	state_machine.update_state(delta)
