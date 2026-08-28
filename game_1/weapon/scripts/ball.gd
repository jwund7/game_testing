extends Node3D

# weird error happens when trying to preload this, "forgets" Spell class somehow
# based on Github issue report it might be fixed in 4.6?
var BALL: Spell = load("res://weapon/resources/ball.tres")

@onready var ray: RayCast3D = $RayCast3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const SPEED: float = 10.0

func _ready():
	animation_player.play("grow")
	# sets a 2 second max existence timer
	var death_timer: Timer = Timer.new()
	death_timer.wait_time = 2.0
	death_timer.timeout.connect(queue_free)
	death_timer.autostart = true
	add_child(death_timer)

func _physics_process(delta: float) -> void:
	# moves projectile based on speed
	position += transform.basis * Vector3(0,0, -SPEED) * delta
	# updates raycast every physics tick
	ray.force_raycast_update()
	# deletes projectile if it collides with a wall
	if ray.is_colliding() and ray.get_collider() is StaticBody3D:
		print("DELETE")
		queue_free()

func _on_hitbox_area_entered(area: Area3D) -> void:
	if area is HitboxComponent:
		# make enemy take damage if the hitbox collides with theirs
		area.hit(BALL.damage)
		queue_free()
