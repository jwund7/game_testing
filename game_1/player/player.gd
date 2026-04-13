extends CharacterBody3D
class_name Player

@export var weapon_cooldown: float = 0.5

@onready var cam_mount: Node3D = $Head
@onready var camera: Camera3D = $Head/PlayerCam

const SENS: float = 0.35

# ground movement variables
var walk_speed: float = 3.5
var sprint_speed: float = 4.5
var ground_accel: float = 14.0
var ground_decel: float = 16.0
var ground_friction: float = 2.0

# air movement variables
var air_move_speed: float = 500.0
var air_speed_cap: float = 0.5
var air_accel: float = 800.0

# jumping variables
var jump_force: float = 4.2
var jump_buffer: bool = false
var jump_buffer_time: float = 0.1

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
	pass

func get_move_speed() -> float:
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

# ground movement
func _ground_physics(delta: float, direction: Vector3) -> void:
	# get dot product of velocity and "intended" movement direction
	var speed_in_dir: float = self.velocity.dot(direction)
	# determine how much speed should be added in the current direction
	var add_speed: float = get_move_speed() - speed_in_dir
	if add_speed > 0:
		var accel_speed: float = ground_accel * get_move_speed() * delta
		# ensure velocity is not increased beyond speed cap
		accel_speed = min(accel_speed, add_speed)
		self.velocity += accel_speed * direction
	
	# friction
	# get velocity drop based on friction strength
	var drop: float = max(self.velocity.length(), ground_decel) * ground_friction * delta
	# ensure new speed value is greather than 0
	var new_speed: float = max(self.velocity.length() - drop, 0.0)
	if self.velocity.length() > 0:
		# create a ratio for speed decrease ((abs_velocity - drop) / abs_velocity)
		new_speed /= self.velocity.length()
	# multiply velocity by speed ratio
	self.velocity *= new_speed

# air movement
func _air_physics(delta: float, direction: Vector3) -> void:
	# change y velocity (gravity)
	velocity.y -= 9.0 * delta
	# get dot product of velocity and "intended" movement direction
	var speed_in_dir: float = self.velocity.dot(direction)
	# cap how much speed is gained
	var speed_cap: float = min((air_move_speed * direction).length(), air_speed_cap)
	# determine how much speed should be added in the current direction
	var add_speed: float = speed_cap - speed_in_dir
	if add_speed > 0:
		var accel_speed: float = air_accel * air_move_speed * delta
		# ensure velocity is not increased beyond speed cap
		accel_speed = min(accel_speed, add_speed)
		self.velocity += accel_speed * direction

func _physics_process(delta: float) -> void:
	# movement
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (cam_mount.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		_ground_physics(delta, direction)
		# if there is a jump buffered, jump
		if jump_buffer == true:
			jump()
	else:
		_air_physics(delta, direction)
	
	# jumping
	if Input.is_action_just_pressed("jump"):
		# if on floor, jump
		if is_on_floor():
			jump()
		# if not on floor and jump pressed, create a jump buffer timer
		else:
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
