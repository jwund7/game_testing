extends Node3D

var EXPLOSION: Spell = load("res://weapon/resources/explosion.tres")

@onready var shape_cast: ShapeCast3D = $ShapeCast3D

var damaged_enemies: Array[HitboxComponent]

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
	# get total number of colliding areas inside explosion
	var area_count := shape_cast.get_collision_count()
	for i in range(area_count):
		# for each area, check if it is a hitbox component
		var current_area := shape_cast.get_collider(i)
		if current_area is HitboxComponent and current_area not in damaged_enemies:
			# add any damaged enemy to a list so they cannot be damaged twice
			damaged_enemies.append(current_area)
			# make the enemy take damage
			current_area.hit(EXPLOSION.damage)
