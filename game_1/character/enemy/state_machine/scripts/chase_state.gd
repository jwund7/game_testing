extends StateInterface
class_name ChaseState

var character: CharacterBody3D
var player: CharacterBody3D = PlayerManager.player

func enter(_prev_state: String) -> void:
	character = state_machine.owner

func physics_update(_delta: float) -> void:
	var player_dist: float = character.global_position.distance_to(player.global_position)
	# get the player's current position
	character.navigator.target_position = player.global_position
	# move in the direction of the next navigation path position
	var direction: Vector3 = (character.navigator.get_next_path_position() - character.global_position).normalized()
	character.velocity = direction * character.get_speed("chase")
	character.move_and_slide()
	
	character.look_at(Vector3(player.position[0], 0.8, player.position[2]))
	
	# wander if the player is out of range
	if player_dist > character.CHASE_DISTANCE:
		state_machine.change_state("wander")
