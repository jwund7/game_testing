extends StateInterface
class_name WanderState

var character: Enemy
var wander_time: float
var wander_target: Vector3
var player: CharacterBody3D = PlayerManager.player

func randomize_wander() -> void:
	# randomly choose a location (or stand still) and a time
	wander_time = randf_range(2, 4)
	var x_target: float = character.global_position[0] + randf_range(-1.0, 1.0)
	var z_target: float = character.global_position[2] + randf_range(-1.0, 1.0)
	wander_target = Vector3(x_target, 0.0, z_target)

func enter(_prev_state: String) -> void:
	character = state_machine.owner
	randomize_wander()

func physics_update(delta: float) -> void:
	if wander_time < 0:
		randomize_wander()
	wander_time -= delta
	
	# set the navigation target to a random nearby location
	character.navigator.target_position = wander_target
	# get the character position and next path point
	var char_pos: Vector3 = character.global_position
	var next_pos: Vector3 = character.navigator.get_next_path_position()
	# snap character to point if they are too close
	# this prevents floating point and other math errors
	if char_pos.distance_to(next_pos) < 0.01:
		character.global_position = next_pos
		return
	
	# move in the direction of the next navigation path position
	var direction: Vector3 = char_pos.direction_to(next_pos)
	character.velocity = direction * character.get_speed("wander")
	character.move_and_slide()
	
	# rotate the enemy in the direction they are moving
	var look_direction: Vector3 = char_pos + direction
	character.look_at(Vector3(look_direction.x, 0.0, look_direction.z))
	# prevent enemy from looking at the ground
	character.rotation.x = 0.0
	
	# get the player's position
	var player_pos: Vector3 = player.global_position
	
	# if player is in range, check other requirements
	if char_pos.distance_to(player_pos) < character.CHASE_DISTANCE:
		# get 2d normalized vectors for look direction and enemy to player
		var look_v2: Vector2 = Vector2(direction.x, direction.z).normalized()
		var player_vec: Vector3 = player_pos - char_pos
		var player_v2: Vector2 = Vector2(player_vec.x, player_vec.z).normalized()
		
		# get the character's raycast
		var ray: RayCast3D = character.view_ray
		ray.target_position = player_pos - char_pos
		ray.rotation.y = -1 * character.rotation.y
		ray.force_raycast_update()
		# if the closest detected object is the player, no walls exist between them
		var no_walls: bool = ray.is_colliding() and ray.get_collider() is Player
		
		# if player is within vision angle and not behind walls, move to chase state
		if abs(look_v2.angle_to(player_v2)) < character.LOOK_ANGLE and no_walls:
			state_machine.change_state("chase")
