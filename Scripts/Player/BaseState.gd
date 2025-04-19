extends Node
class_name BaseState

var state_machine = null
var player = null

func init(_state_machine, _player):
	state_machine = _state_machine
	player = _player

func enter(): pass
func exit(): pass
func update(delta): pass
