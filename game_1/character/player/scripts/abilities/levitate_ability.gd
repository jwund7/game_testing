extends AbilityInterface
class_name LevitateAbility

# nodes used in levitate functions
var player: Player
var levitate_timer: Timer

# ability variables
@export var is_levitating: bool = false
var start_height: float
var end_height: float
var ascent_time: float = 1.0
var levitate_height: float = 2.0
var levitate_time: float = 10.0

func _init(p: Player, timer: Timer) -> void:
	# set paths to necessary nodes
	player = p
	levitate_timer = timer
	levitate_timer.timeout.connect(stop_levitate)

func handle_ability() -> void:
	# only allow ability use if player is on floor
	if player.is_on_floor():
		ascent_time = 0
		# get positions for beginning and intended heights
		start_height = player.position.y
		end_height = start_height + levitate_height
		is_levitating = true
		levitate_timer.wait_time = levitate_time
		levitate_timer.start()
	# cancel levitate if in the air
	elif is_levitating and ascent_time >= 1.0:
		stop_levitate()

func ability_process(delta: float) -> void:
	# run timer for length of ascent
	if ascent_time < 1.0:
		ascent_time += delta
		# linear interpolation of y position using ascent_time as weight
		player.position.y = lerp(start_height, end_height, ascent_time)
		# stop upward movement if player collides with something
		if player.is_on_ceiling():
			end_height = player.position.y
			ascent_time = 1.0

func stop_levitate() -> void:
	# end levitate when timer runs out
	is_levitating = false
	levitate_timer.stop()
