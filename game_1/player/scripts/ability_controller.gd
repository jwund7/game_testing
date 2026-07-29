extends Node

@onready var player: Player = $".."
@onready var collision: CollisionShape3D = $"../CollisionShape3D"
@onready var uncrouch_check: Area3D = $"../UncrouchCheck"
@onready var ability_menu: Control = $AbilityMenu
@onready var dodge_timer: Timer = $DodgeTime
@onready var levitate_timer: Timer = $LevitateTime
@onready var grapple_timeout: Timer = $GrappleTimeout
@onready var ray: RayCast3D = $"../Head/PlayerCam/RayCast3D"
@onready var rope = $"../Head/PlayerCam/Rope"
@onready var grapple_indicator: RichTextLabel = $GrappleIndicator
@onready var ability_indicator: RichTextLabel = $AbilityIndicator

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

# levitate ability variables
@export var is_levitating: bool = false
var start_height: float
var end_height: float
var ascent_time: float = 1.0
var levitate_height: float = 2.0
var levitate_time: float = 10.0

# grapple ability variables
@export var is_grappling: bool = false
var target_point: Vector3
var grapple_time: float
var grapple_speed: float = 200.0
var release_length: float = 1.0

# menu variables
var select_open: bool = false
var ability_timer: float = 1.0

func _ready() -> void:
	# start game using dodge ability
	selected_ability = "grapple"
	dodge_timer.timeout.connect(stop_dodge)
	levitate_timer.timeout.connect(stop_levitate)
	grapple_timeout.timeout.connect(_grapple_release)

func _physics_process(delta: float) -> void:
	# change ability indicator to current ability
	ability_indicator.text = selected_ability
	# ensure grapple is not visible when ability is not in use
	if not selected_ability == "grapple":
		grapple_indicator.visible = false
	# run ability process functions
	if selected_ability == "crouch":
		_crouch_process(delta)
	if selected_ability == "dodge":
		_dodge_process(delta)
	if selected_ability == "levitate":
		_levitate_process(delta)
	if selected_ability == "grapple":
		_grapple_process(delta)
	# run ability switch cooldown
	if ability_timer >= 0:
		ability_timer -= delta
		# temporarily continue every process function to finish canceling abilities
		_crouch_process(delta)
		_dodge_process(delta)
		_levitate_process(delta)
		_grapple_process(delta)

func _unhandled_input(_event: InputEvent) -> void:
	# handle selection wheel opening and closing
	var switch_restricted: bool = is_crouched or is_dodging or is_levitating or is_grappling
	# only allow wheel opening if no abilities are active
	if Input.is_action_just_pressed("ui_focus_next") and not switch_restricted:
		select_open = true
		ability_menu.open()
	if Input.is_action_just_released("ui_focus_next"):
		# start a cooldown since abilities have just been switched
		ability_timer = crouch_time + dodge_time + grapple_time
		# get the currently used ability
		var current_ability: String = selected_ability
		select_open = false
		selected_ability = ability_menu.close()
		# if no ability was selected with the wheel, revert to previously used ability
		if selected_ability == "":
			selected_ability = current_ability
	
	# handle ability usage
	if Input.is_action_just_pressed("movement_ability") and not select_open and ability_timer < 0:
		if selected_ability == "crouch":
			_handle_crouch()
		if selected_ability == "dodge":
			_handle_dodge()
		if selected_ability == "levitate":
			_handle_levitate()
		if selected_ability == "grapple" and not is_grappling:
			_handle_grapple()

## ----- CROUCH -----
func _handle_crouch() -> void:
	# only allow ability use if player is on floor and cooldown is off
	if player.is_on_floor() and crouch_cooldown < 0:
		# start uncrouch
		if is_crouched:
			# uncrouch and start cooldown
			stop_crouch()
		elif not is_crouched:
			# crouch and start cooldown
			is_crouched = true
			crouch_cooldown = base_crouch_cooldown

func _crouch_process(delta: float) -> void:
	# run timer for crouch ability cooldown
	if crouch_cooldown >= 0:
		crouch_cooldown -= delta
	# handle crouching animation speed
	# keep crouch_time between 0.0 and 1.0, going up or down depending on is_crouched
	if crouch_time <= 1.0 and is_crouched:
		crouch_time += delta
	elif crouch_time >= 0.0 and not is_crouched:
		crouch_time -= delta
	# cancel uncrouch if player collides with something
	if player.is_on_ceiling():
		is_crouched = true
	# linear interpolation of collision shape using crouch_time as weight
	# (e.g. crouch_time = 0.0 -> fully at base_height)
	collision.shape.height = lerp(base_height, crouch_height, crouch_time)

func can_uncrouch() -> bool:
	# check if any environment obstacles exist above player
	# found a different solution since this sometimes randomly just doesn't work
	#print(uncrouch_check.get_overlapping_bodies())
	#return len(uncrouch_check.get_overlapping_bodies()) <= 0
	return true

func stop_crouch() -> void:
	# uncrouch and start cooldown
	is_crouched = false
	crouch_cooldown = base_crouch_cooldown

## ----- DODGE -----
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

func _dodge_process(delta: float) -> void:
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

## ----- LEVITATE -----
func _handle_levitate() -> void:
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

func _levitate_process(delta: float) -> void:
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

## ----- GRAPPLE -----
func _handle_grapple():
	var grapple_point = ray.get_collider()
	# ensure aimed collider is a grapple point
	if ray.is_colliding() and grapple_point is GrapplePoint:
		target_point = grapple_point.global_position
		is_grappling = true
		# create a timeout to prevent getting stuck infinitely
		grapple_timeout.start()

func _grapple_process(delta: float) -> void:
	# display the grapple reticle if a grapple point is hovered
	if ray.is_colliding() and ray.get_collider() is GrapplePoint:
		grapple_indicator.visible = true
	else:
		grapple_indicator.visible = false
	
	# attempt grappled launch when button is pressed
	if not is_grappling:
		grapple_time = 0.0
	# handle movement if launch has occurred
	if is_grappling:
		# get grapple direction and distance
		var direction: Vector3 = player.global_position.direction_to(target_point)
		var distance: float = player.global_position.distance_to(target_point)
	
		# get the length between the distance from the target and the intended grapple release length
		var displacement: float = distance - release_length
		var grapple_force: Vector3
		# set grapple force if further movement is required
		if displacement > 0:
			grapple_force = direction * grapple_speed * sqrt(4 * displacement)
		# if the release length has been reached, release grapple
		else:
			_grapple_release()
		
		# set player velocity while grappling using linear interpolation for smoothing
		grapple_time += delta
		player.velocity = player.velocity.lerp(grapple_force * delta, 0.5*grapple_time)
	update_rope()

func update_rope():
	# do not display rope if grappling is not occurring
	if not is_grappling:
		rope.visible = false
		return
	rope.visible = true
	var distance: float = player.global_position.distance_to(target_point)
	rope.look_at(target_point)
	# scale rope in its z direction based on distance from grappled point
	rope.scale = Vector3(1, 1, distance)

func _grapple_release():
	# release grapple
	is_grappling = false
	grapple_timeout.stop()
	
