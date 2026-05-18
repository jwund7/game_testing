extends Node

@onready var player: Player = $".."
@onready var collision: CollisionShape3D = $"../CollisionShape3D"
@onready var uncrouch_check: Area3D = $"../UncrouchCheck"
@onready var dodge_timer: Timer = $DodgeTime


var selected_ability: String

# crouch ability variables
@export var is_crouched: bool = false
var base_crouch_cooldown: float = 1.5
var crouch_cooldown: float = 0.0
var base_height: float = 1.8
var crouch_height: float = 0.4
var crouch_time: float

# dodge ability variables
@export var is_dodging: bool = false
var base_dodge_cooldown: float = 1.0
var dodge_cooldown: float = 0.0
var dodge_time: float = 0.2
var dodge_power: float = 20.0

func _ready() -> void:
	# placeholder, could change when more abilities are added
	selected_ability = "dodge"
	dodge_timer.timeout.connect(stop_dodge)

func _physics_process(delta: float) -> void:
	if selected_ability == "crouch":
		# run timer for crouch ability cooldown
		if crouch_cooldown >= 0:
			crouch_cooldown -= delta
		# handle crouching animation speed
		# keep crouch_time between 0.0 and 1.0, going up or down depending on is_crouched
		if crouch_time <= 1.0 and is_crouched:
			crouch_time += delta
		elif crouch_time >= 0.0 and not is_crouched:
			crouch_time -= delta
		# linear interpolation of collision shape using crouch_time as weight
		# (e.g. crouch_time = 0.0 -> fully at base_height)
		collision.shape.height = lerp(base_height, crouch_height, crouch_time)
	if selected_ability == "dodge":
		# run timer for dodge length and interpolate velocity to prevent instant stop
		if dodge_time >= 0:
			dodge_time -= delta
			player.velocity = player.velocity.lerp(Vector3(0,0,0), dodge_time)
		# run timer for dodge cooldown
		if dodge_cooldown >= 0:
			dodge_cooldown -= delta

func stop_dodge() -> void:
	# end the dodge when timer runs out
	is_dodging = false
	dodge_timer.stop()

func can_uncrouch() -> bool:
	# check if any environment obstacles exist above player
	return len(uncrouch_check.get_overlapping_bodies()) <= 0

func _unhandled_input(_event: InputEvent) -> void:
	# handle ability usage
	if Input.is_action_just_pressed("movement_ability"):
		if selected_ability == "crouch":
			_handle_crouch()
		if selected_ability == "dodge":
			_handle_dodge()

func _handle_crouch() -> void:
	# only allow ability use if player is on floor and cooldown is off
	if player.is_on_floor() and crouch_cooldown < 0:
		# ensure nothing is above player if uncrouching
		if is_crouched and can_uncrouch():
			# uncrouch and start cooldown
			is_crouched = false
			crouch_cooldown = base_crouch_cooldown
		elif not is_crouched:
			# crouch and start cooldown
			is_crouched = true
			crouch_cooldown = base_crouch_cooldown

func _handle_dodge() -> void:
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
