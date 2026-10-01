extends StateInterface
class_name GroundState

var player: Player

var accel: float
var decel: float
var friction: float

func enter(_prev_state: String) -> void:
	player = state_machine.owner
	accel = player.ground_accel
	decel = player.ground_decel
	friction = player.ground_friction
	
func physics_update(delta: float) -> void:
	var direction: Vector3 = player.direction
	# get dot product of velocity and "intended" movement direction
	var speed_in_dir: float = player.velocity.dot(direction)
	# determine how much speed should be added in the current direction
	var add_speed: float = player.get_move_speed() - speed_in_dir
	if add_speed > 0:
		var accel_speed: float = accel * player.get_move_speed() * delta
		# ensure velocity is not increased beyond speed cap
		accel_speed = min(accel_speed, add_speed)
		player.velocity += accel_speed * direction
	
	# friction
	# get velocity drop based on friction strength
	var drop: float = max(player.velocity.length(), decel) * friction * delta
	# ensure new speed value is greather than 0
	var new_speed: float = max(player.velocity.length() - drop, 0.0)
	if player.velocity.length() > 0:
		# create a ratio for speed decrease ((abs_velocity - drop) / abs_velocity)
		new_speed /= player.velocity.length()
	# multiply velocity by speed ratio
	player.velocity *= new_speed
	
	# if an ability is in use, switch to ability state
	if player.ability_active:
		state_machine.change_state("ability")
	
	# if there is a jump buffered, jump
	if player.jump_buffer == true:
		jump()
	
	# if the player leaves the floor, switch to air movement
	if not player.is_on_floor():
		state_machine.change_state("air")

func jump() -> void:
	# propel player upwards
	player.velocity.y = player.jump_force
