extends Node

@onready var player: Player = $".."
@onready var collision: CollisionShape3D = $"../CollisionShape3D"
@onready var uncrouch_check: Area3D = $"../UncrouchCheck"

var selected_ability: String

# crouch ability variables
var base_crouch_cooldown: float = 1.5
var crouch_cooldown: float = 0.0
var base_height: float = 1.8
var crouch_height: float = 0.4
var crouch_time: float
var is_crouched: bool = false

func _ready() -> void:
	# placeholder, could change when more abilities are added
	selected_ability = "crouch"

func _physics_process(delta: float) -> void:
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

func can_uncrouch() -> bool:
	# check if any environment obstacles exist above player
	return len(uncrouch_check.get_overlapping_bodies()) <= 0

func _unhandled_input(_event: InputEvent) -> void:
	# handle ability usage
	if Input.is_action_just_pressed("movement_ability"):
		if selected_ability == "crouch":
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
