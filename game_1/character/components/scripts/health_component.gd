extends RefCounted
class_name HealthComponent

var character: CharacterBody3D
var health: float

func setup(owner: CharacterBody3D) -> void:
	# set character to the initializing CharacterBody
	character = owner
	health = character.max_health

func take_damage(attack_damage: float) -> void:
	# reduce health by the damage of the attack
	if character is Player:
		print("ouch")
	health -= attack_damage
	
	# if no health is left, delete the character
	if health <= 0 and character is not Player:
		character.queue_free()
	elif health <= 0 and character is Player:
		print("PLAYER DEAD")
