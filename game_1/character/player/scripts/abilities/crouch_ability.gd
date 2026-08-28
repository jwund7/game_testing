extends AbilityInterface
class_name CrouchAbility

# nodes used in crouch functions
var player: Player
var collision: CollisionShape3D

# ability variables
@export var is_crouched: bool = false
var base_crouch_cooldown: float = 1.5
var crouch_cooldown: float = 0.0
var base_height: float = 1.8
var crouch_height: float = 0.4
var crouch_progress: float

func _init(p: Player, coll: CollisionShape3D) -> void:
	# set paths to necessary nodes
	player = p
	collision = coll

func handle_ability() -> void:
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

func ability_process(delta: float) -> void:
	# run timer for crouch ability cooldown
	if crouch_cooldown >= 0:
		crouch_cooldown -= delta
	# handle crouching animation speed
	# keep crouch_time between 0.0 and 1.0, going up or down depending on is_crouched
	if crouch_progress <= 1.0 and is_crouched:
		crouch_progress += delta
	elif crouch_progress >= 0.0 and not is_crouched:
		crouch_progress -= delta
	# cancel uncrouch if player collides with something
	if player.is_on_ceiling() and crouch_progress > 0:
		is_crouched = true
	# linear interpolation of collision shape using crouch_time as weight
	# (e.g. crouch_time = 0.0 -> fully at base_height)
	collision.shape.height = lerp(base_height, crouch_height, crouch_progress)

#func can_uncrouch() -> bool:
	# check if any environment obstacles exist above player
	# found a different solution since this sometimes randomly just doesn't work
	# would work better than current solution if it could be implemented successfully
	#print(uncrouch_check.get_overlapping_bodies())
	#return len(uncrouch_check.get_overlapping_bodies()) <= 0

func stop_crouch() -> void:
	# uncrouch and start cooldown
	is_crouched = false
	crouch_cooldown = base_crouch_cooldown
