extends StateInterface
class_name WanderState

var character: Enemy
var wander_time: float
var wander_target: Vector3
var player: CharacterBody3D = PlayerManager.player
var ray: RayCast3D

# variables used for stealth meter
var detection: float
var max_detection: float = 100.0
var detection_speed: float = 7.0

# variables used in vision cone check
var look_vec2: Vector2
var player_vec: Vector3
var player_vec2: Vector2

# variables for overall player detection
var in_range: bool = false
var in_cone: bool = false
var no_walls: bool = false

func randomize_wander() -> void:
	# randomly choose a location and a time
	wander_time = randf_range(2, 4)
	var x_target: float = character.global_position[0] + randf_range(-1.0, 1.0)
	var z_target: float = character.global_position[2] + randf_range(-1.0, 1.0)
	wander_target = Vector3(x_target, 0.0, z_target)

func enter(_prev_state: String) -> void:
	character = state_machine.owner
	ray = character.view_ray
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
	
	# stealth detection does 3 checks:
	# 1. player is within range (CHASE_DISTANCE)
	# 2. player is within the enemy's "field of view" (LOOK_ANGLE)
	# 3. player is not behind any walls (ray)
	
	# get the player's position
	var player_pos: Vector3 = player.global_position
	# get range check
	in_range = char_pos.distance_to(player_pos) < character.CHASE_DISTANCE
	# if the player is in range, check other requirements
	if in_range:
		# get 2d normalized vectors for look direction and enemy to player
		look_vec2 = Vector2(direction.x, direction.z).normalized()
		player_vec = player_pos - char_pos
		player_vec2 = Vector2(player_vec.x, player_vec.z).normalized()
		in_cone = abs(look_vec2.angle_to(player_vec2)) < character.LOOK_ANGLE
		if in_cone:
			# position the enemy's ray so that it points at the player
			ray.target_position = player_pos - char_pos
			ray.rotation.y = -1 * character.rotation.y
			ray.force_raycast_update()
			# if the closest detected object is the player, no walls exist between them
			no_walls = ray.get_collider() is Player
	
	# if player meets all checks, add to detection meter
	if in_range and in_cone and no_walls:
		# add more if the player is closer to the enemy
		detection += (detection_speed / char_pos.distance_to(player_pos))
	# otherwise, subtract from meter
	elif detection > 0.0:
		detection -= 0.5
	print(detection)
	# if the designated max detection has been reached, move to chase state
	if detection >= max_detection:
		state_machine.change_state("chase")
