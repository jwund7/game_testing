extends Node

# general nodes required for ability function
@onready var player: Player = $".."
@onready var ability_indicator: RichTextLabel = $AbilityIndicator
@onready var ability_menu: Control = $AbilityMenu
# nodes required for crouch ability
@onready var collision: CollisionShape3D = $"../CollisionShape3D"
@onready var uncrouch_check: Area3D = $"../UncrouchCheck"
# nodes required for dodge ability
@onready var dodge_timer: Timer = $DodgeTime
# nodes required for levitate ability
@onready var levitate_timer: Timer = $LevitateTime
# nodes required for grapple ability
@onready var grapple_timeout: Timer = $GrappleTimeout
@onready var ray: RayCast3D = $"../Head/PlayerCam/RayCast3D"
@onready var rope: Node3D = $"../Head/PlayerCam/Rope"
@onready var grapple_indicator: RichTextLabel = $GrappleIndicator

var selected_ability: String

# ability variables
@export var is_crouched: bool = false
@export var is_dodging: bool = false
@export var is_levitating: bool = false
@export var is_grappling: bool = false

# ability objects
var crouch_ability: CrouchAbility
var dodge_ability: DodgeAbility
var levitate_ability: LevitateAbility
var grapple_ability: GrappleAbility

# menu variables
var select_open: bool = false
var ability_timer: float = 0.0

func _ready() -> void:
	# start game using grapple ability
	selected_ability = "grapple"
	# create ability class objects
	crouch_ability = CrouchAbility.new(player, collision)
	dodge_ability = DodgeAbility.new(player, dodge_timer)
	levitate_ability = LevitateAbility.new(player, dodge_timer)
	grapple_ability = GrappleAbility.new(player, grapple_timeout, ray, rope, grapple_indicator)

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
	if ability_timer > 0:
		ability_timer -= delta
		# temporarily continue every process function to finish canceling abilities
		_crouch_process(delta)
		_dodge_process(delta)
		_levitate_process(delta)
		_grapple_process(delta)

func _unhandled_input(_event: InputEvent) -> void:
	# handle selection wheel opening and closing
	var crouch_check: bool = crouch_ability.crouch_progress > 0
	var switch_restricted: bool = crouch_check or is_dodging or is_levitating or is_grappling
	# only allow wheel opening if no abilities are active
	if Input.is_action_just_pressed("ui_focus_next") and not switch_restricted:
		select_open = true
		ability_menu.open()
	if Input.is_action_just_released("ui_focus_next"):
		# start a cooldown since abilities have just been switched
		ability_timer = crouch_ability.crouch_progress + dodge_ability.dodge_time + grapple_ability.grapple_time
		# get the currently used ability
		var current_ability: String = selected_ability
		select_open = false
		selected_ability = ability_menu.close()
		# if no ability was selected with the wheel, revert to previously used ability
		if selected_ability == "":
			selected_ability = current_ability
	
	# handle ability usage
	if Input.is_action_just_pressed("movement_ability") and not select_open and ability_timer <= 0:
		if selected_ability == "crouch":
			crouch_ability.handle_ability()
		if selected_ability == "dodge":
			dodge_ability.handle_ability()
		if selected_ability == "levitate":
			levitate_ability.handle_ability()
		if selected_ability == "grapple" and not is_grappling:
			grapple_ability.handle_ability()

# each function below runs its respective process and pass through its ability active variable
func _crouch_process(delta: float) -> void:
	crouch_ability.ability_process(delta)
	is_crouched = crouch_ability.is_crouched

func _dodge_process(delta: float) -> void:
	dodge_ability.ability_process(delta)
	is_dodging = dodge_ability.is_dodging

func _levitate_process(delta: float) -> void:
	levitate_ability.ability_process(delta)
	is_levitating = levitate_ability.is_levitating

func _grapple_process(delta: float) -> void:
	grapple_ability.ability_process(delta)
	is_grappling = grapple_ability.is_grappling
