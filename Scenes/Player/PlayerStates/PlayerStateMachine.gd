extends Node

var states = {}
var current_state = null
var player = null

func init(_player):
	player = _player
	for child in get_children():
		if child is BaseState:
			states[child.name] = child
			child.init(self, player)
	change_state("IdleState")

func update_state(delta):
	if current_state:
		current_state.update(delta)

func change_state(state_name: String):
	if current_state:
		current_state.exit()
	current_state = states.get(state_name)
	if current_state:
		current_state.enter()
