extends AbilityInterface
class_name GrappleAbility

# nodes used in grapple functions
var player: Player
var grapple_timeout: Timer
var raycast: RayCast3D
var rope: Node3D
var grapple_indicator: RichTextLabel

# ability variables
@export var is_grappling: bool = false
var target_point: Vector3
var grapple_time: float
var grapple_speed: float = 200.0
var release_length: float = 1.0

func _init(p: Player, timer: Timer, ray: RayCast3D, r: Node3D, indicator: RichTextLabel) -> void:
	# set paths to necessary nodes
	player = p
	grapple_timeout = timer
	raycast = ray
	rope = r
	grapple_indicator = indicator
	grapple_timeout.timeout.connect(_grapple_release)

func handle_ability():
	var grapple_point = raycast.get_collider()
	# ensure aimed collider is a grapple point
	if raycast.is_colliding() and grapple_point is GrapplePoint:
		target_point = grapple_point.global_position
		is_grappling = true
		# create a timeout to prevent getting stuck infinitely
		grapple_timeout.start()

func ability_process(delta: float) -> void:
	# display the grapple reticle if a grapple point is hovered
	if raycast.is_colliding() and raycast.get_collider() is GrapplePoint:
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
	_update_rope()

func _update_rope():
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
