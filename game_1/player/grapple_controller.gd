extends Node

@export var release_length: float = 1.0
@export var grapple_speed: float = 200.0
@export var is_launched: bool = false

@onready var ray: RayCast3D = $"../Head/PlayerCam/RayCast3D"
@onready var player: CharacterBody3D = $".."
@onready var rope = $"../Head/PlayerCam/Rope"
@onready var grapple_indicator: RichTextLabel = $"../GrappleIndicator"

var target_point: Vector3

func _physics_process(delta: float) -> void:
	# display the grapple reticle if a grapple point is hovered
	if ray.is_colliding() and ray.get_collider().name == "GrapplePoint":
		grapple_indicator.visible = true
	else:
		grapple_indicator.visible = false
	
	# attempt grappled launch when button is pressed
	if Input.is_action_just_pressed("grapple"):
		launch()
	if is_launched:
		handle_grapple(delta)
	update_rope()

func launch():
	var grapple_point = ray.get_collider()
	# ensure aimed collider is a grapple point
	if ray.is_colliding() and grapple_point.name == "GrapplePoint":
		target_point = grapple_point.global_position
		is_launched = true
		# create a timeout to prevent getting stuck infinitely
		get_tree().create_timer(1.5).timeout.connect(release)

func release():
	# release grapple
	is_launched = false

func handle_grapple(delta):
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
		release()
	
	# set player velocity while grappling
	player.velocity = grapple_force * delta

func update_rope():
	# do not display rope if grappling is not occurring
	if not is_launched:
		rope.visible = false
		return
	rope.visible = true
	var distance: float = player.global_position.distance_to(target_point)
	rope.look_at(target_point)
	# scale rope in z direction based on distance from grappled point
	rope.scale = Vector3(1, 1, distance)
