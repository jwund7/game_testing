extends AbilityInterface
class_name DodgeAbility

# nodes used in dodge functions
var player: Player
var dodge_timer: Timer

# ability variables
@export var is_dodging: bool = false
var base_dodge_cooldown: float = 1.0
var dodge_cooldown: float = 0.0
var dodge_time: float = 0.2
var dodge_power: float = 20.0

func _init(p: Player, timer: Timer) -> void:
	# set paths to necessary nodes
	player = p
	dodge_timer = timer
	dodge_timer.timeout.connect(stop_dodge)

func handle_ability() -> void:
	# only allow use if cooldown is off
	if dodge_cooldown < 0:
		# get the player's current input direction vector w.r.t. the direction they are looking
		var input_dir := Input.get_vector("left", "right", "forward", "backward")
		var direction := (player.cam_mount.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		# only count a "dodge" if the player is holding a direction
		if direction.length() > 0:
			# set dodging to true and start timers
			is_dodging = true
			dodge_cooldown = base_dodge_cooldown
			dodge_time = 0.2
			dodge_timer.wait_time = dodge_time
			dodge_timer.start()
			# set (not add) velocity of player
			player.velocity = direction * dodge_power

func ability_process(delta: float) -> void:
	# run timer for dodge length and interpolate velocity to prevent instant stop
	if dodge_time >= 0:
		dodge_time -= delta
		# linear interpolation of velocity with time spent dodging as weight
		player.velocity = player.velocity.lerp(Vector3(0,0,0), dodge_time)
	# run timer for dodge cooldown
	if dodge_cooldown >= 0:
		dodge_cooldown -= delta

func stop_dodge() -> void:
	# end the dodge when timer runs out
	is_dodging = false
	dodge_timer.stop()
