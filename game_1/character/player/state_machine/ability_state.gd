extends StateInterface
class_name AbilityState

var player: Player

var accel: float

func enter(_prev_state: String) -> void:
	player = state_machine.owner
	accel = player.levitate_accel
	
func physics_update(delta: float) -> void:
	if player.selected_ability == "crouch":
		# change y velocity (gravity)
		player.velocity.y -= 9.0 * delta
		# set velocity based on direction
		player.velocity.x = player.direction.x * player.get_move_speed()
		player.velocity.z = player.direction.z * player.get_move_speed()
	
	if player.selected_ability == "levitate":
		# get the max speed as a vector
		var max_speed: Vector3 = Vector3(player.get_move_speed(), 100.0, player.get_move_speed())
		# add velocity based on direction
		player.velocity += accel * player.direction * delta
		# slow down while no movement is occurring
		if player.direction.length() == 0.0:
			player.velocity -= player.velocity * delta
		# clamp velocity to prevent going over max speed
		player.velocity = player.velocity.clamp(-max_speed, max_speed)
	
	# if an ability is no longer active, switch to regular movement
	if not player.ability_active:
		if player.is_on_floor():
			state_machine.change_state("ground")
		else:
			state_machine.change_state("air")
