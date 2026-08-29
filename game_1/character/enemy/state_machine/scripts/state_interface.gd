extends RefCounted
class_name StateInterface

var state_machine: StateMachine

func enter(_prev_state: String) -> void:
	pass

func exit() -> void:
	pass

#func update(_delta: float) -> void:
	#pass
#
#func physics_update(_delta: float) -> void:
	#pass
