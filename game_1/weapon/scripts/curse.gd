extends Node3D

@onready var shape_cast: ShapeCast3D = $ShapeCast3D

var cursed_enemies: Array[Enemy]
var curse_effect: float = 0.5
var curse_time: float = 2.0

func _ready():
	# sets a short max existence timer
	var death_timer: Timer = Timer.new()
	death_timer.wait_time = 0.2
	death_timer.timeout.connect(queue_free)
	death_timer.autostart = true
	add_child(death_timer)

func _physics_process(_delta: float) -> void:
	# force a shapecast update (essentially a hitbox)
	shape_cast.force_shapecast_update()
	# get total number of colliding bodies inside curse radius
	var body_count := shape_cast.get_collision_count()
	for i in range(body_count):
		# for each area, check if it is an Enemy type
		var current_body := shape_cast.get_collider(i)
		if current_body is Enemy and current_body not in cursed_enemies:
			# add any cursed enemy to a list so they cannot be affected twice
			cursed_enemies.append(current_body)
			# activate the curse effect for the designated power and time
			current_body.set_curse(curse_effect, curse_time)
