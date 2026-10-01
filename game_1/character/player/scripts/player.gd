extends CharacterBody3D
class_name Player

@onready var cam_mount: Node3D = $Head
@onready var camera: Camera3D = $Head/PlayerCam
@onready var ability_controller: Node = $AbilityController
@onready var spell_controller: Node = $SpellController
@onready var shape_cast: ShapeCast3D = $ShapeCast3D
@onready var state_indicator: RichTextLabel = $StateIndicator

const SENS: float = 0.35

# ground movement variables
var direction: Vector3
var walk_speed: float = 3.5
var sprint_speed: float = 4.5
var ground_accel: float = 14.0
var ground_decel: float = 16.0
var ground_friction: float = 2.0

# air movement variables
var air_move_speed: float = 500.0
var air_speed_cap: float = 0.5
var air_accel: float = 700.0

# jumping variables
var jump_force: float = 4.2
var jump_buffer: bool = false
var jump_buffer_time: float = 0.1

# ability variables
var crouch_speed: float = 2.0
var levitate_speed: float = 2.5
var levitate_accel: float = 2.5
var selected_ability: String
var ability_active: bool = false

# stealth variables
var visibility: float = 1.0

var state_machine: StateMachine

func _ready() -> void:
	PlayerManager.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	state_machine = StateMachine.new()
	state_machine.owner = self
	state_machine.add_state("ground", GroundState.new())
	state_machine.add_state("air", AirState.new())
	state_machine.add_state("ability", AbilityState.new())
	state_machine.set_initial_state("ground")

func get_move_speed() -> float:
	# prevent sprinting and return unique speed if player is using crouch or levitate ability
	if ability_controller.is_crouched:
		return crouch_speed
	if ability_controller.is_levitating:
		return levitate_speed
	# otherwise, return speed based on if player is sprinting
	else:
		if Input.is_action_pressed("sprint"):
			return sprint_speed
		else:
			return walk_speed

func jump() -> void:
	# propel player upwards
	velocity.y = jump_force
	
func on_jump_buffer_timeout() -> void:
	# if timer runs out, remove jump buffer grace period
	jump_buffer = false

func _physics_process(delta: float) -> void:
	selected_ability = ability_controller.selected_ability
	ability_active = ability_controller.using_ability
	state_indicator.text = "State: " + state_machine.current_state_name
	# movement
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = (cam_mount.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# use state machine physics process
	state_machine.physics_update(delta)
	
	# jumping
	if Input.is_action_just_pressed("jump"):
		# if not on floor and jump pressed, create a jump buffer timer
		jump_buffer = true
		get_tree().create_timer(jump_buffer_time).timeout.connect(on_jump_buffer_timeout)
	
	# move player
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	# handle mouse freeing
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# handle camera movement
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			# rotate camera mount node's y angle by mouse x movement
			cam_mount.rotate_y(-event.relative.x * SENS * 0.005)
			# rotate camera node's y angle by mouse y movement
			camera.rotate_x(-event.relative.y * SENS * 0.005)
			# limit camera angle
			camera.rotation.x = clamp(camera.rotation.x, -PI / 2 + 0.1, PI / 2 - 0.1)
