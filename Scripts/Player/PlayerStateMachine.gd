extends Node

var states = {}
var current_state = null
var player = null

func init(_player):
	player = _player
	_load_states()
	change_state("IdleState")

func _load_states():
	for state_node in get_children():
		if state_node is BaseState:
			states[state_node.name] = state_node
			state_node.init(self, player)

func update_state(delta):
	if current_state:
		current_state.update(delta)

func change_state(state_name: String):
	if current_state:
		current_state.exit()
	current_state = states.get(state_name)
	if current_state:
		current_state.enter()
