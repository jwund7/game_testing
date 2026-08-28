extends Enemy
class_name Enemy1

@onready var navigator: NavigationAgent3D = $NavigationAgent3D

var curse_mod: float = 1.0

func _ready() -> void:
	# set up enemy variables
	CHASE_DISTANCE = 8.0
	CHASE_SPEED = 3.0
	WANDER_SPEED = 0.8
	max_health = 50.0
	
	# create new state machine (declared in Enemy class) and its states
	state_machine = StateMachine.new()
	state_machine.owner = self
	state_machine.add_state("wander", WanderState.new())
	state_machine.add_state("chase", ChaseState.new())
	state_machine.set_initial_state("wander")
	
	# set up health and hitbox components declared in Character class
	health_component = HealthComponent.new()
	health_component.setup(self)
	var new_hitbox: HitboxComponent = HITBOX_COMPONENT.instantiate()
	hitbox_component = new_hitbox
	add_child(new_hitbox)
	hitbox_component.setup(self)

func _physics_process(delta: float) -> void:
	# change y velocity (gravity)
	if not is_on_floor():
		velocity.y -= 9.0 * delta
	# update state machine
	state_machine.physics_update(delta)

func set_curse(curse_effect: float, curse_time: float) -> void:
	# set curse speed modification to the provided curse effect
	curse_mod = curse_effect
	# create a timer that waits the designated curse time
	await get_tree().create_timer(curse_time).timeout
	# reset to default speed
	curse_mod = 1.0

func get_speed(state: String) -> float:
	# return enemy speed based on current state and curse effect
	if state == "wander":
		return WANDER_SPEED * curse_mod
	elif state == "chase":
		return CHASE_SPEED * curse_mod
	else:
		print("you did something crazy wrong")
		return 0.0
