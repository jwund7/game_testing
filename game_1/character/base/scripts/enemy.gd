@abstract
extends Character
class_name Enemy

var CHASE_DISTANCE: float
var CHASE_SPEED: float
var WANDER_SPEED: float
var state_machine: StateMachine

@abstract
func get_speed(state: String) -> float

@abstract
func set_curse(curse_effect: float, curse_time: float) -> void
