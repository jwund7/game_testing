extends Node3D

func _ready():
	# sets a short max existence timer
	var death_timer: Timer = Timer.new()
	death_timer.wait_time = 0.3
	death_timer.timeout.connect(queue_free)
	death_timer.autostart = true
	add_child(death_timer)
