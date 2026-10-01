@abstract
extends RefCounted
class_name StateInterface

var state_machine: StateMachine

@abstract
func enter(_prev_state: String) -> void

@abstract
func physics_update(_delta: float) -> void
