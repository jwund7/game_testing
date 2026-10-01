extends StateInterface
class_name AirState

var player: Player

var move_speed: float
var speed_cap: float
var accel: float

func enter(_prev_state: String) -> void:
	player = state_machine.owner
	move_speed = player.air_move_speed
	speed_cap = player.air_speed_cap
	accel = player.air_accel
	
func physics_update(delta: float) -> void:
	# change y velocity (gravity)
	player.velocity.y -= 9.0 * delta
	# get dot product of velocity and "intended" movement direction
	var speed_in_dir: float = player.velocity.dot(player.direction)
	# cap how much speed is gained
	var air_speed_cap: float = min((move_speed * player.direction).length(), speed_cap)
	# determine how much speed should be added in the current direction
	var add_speed: float = air_speed_cap - speed_in_dir
	if add_speed > 0:
		var accel_speed: float = accel * move_speed * delta
		# ensure velocity is not increased beyond speed cap
		accel_speed = min(accel_speed, add_speed)
		# only apply air physics if a grapple is not in progress
		player.velocity += accel_speed * player.direction
	
	# if an ability is in use, switch to ability state
	if player.ability_active:
		state_machine.change_state("ability")
	
	# if the player touches the floor, switch to ground movement
	if player.is_on_floor():
		state_machine.change_state("ground")
