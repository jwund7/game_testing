extends Area3D
class_name HitboxComponent

var character: CharacterBody3D

func setup(parent: CharacterBody3D) -> void:
	# set character to the initializing CharacterBody
	character = parent
	# remove collision objects that are not the parent's
	for collider: CollisionShape3D in get_children():
		# get the parent's class name
		if character.get_script().get_global_name() != collider.name:
			collider.queue_free()
	# binary values for the collision layer and mask
	# layer 1 is bit 0, layer 2 is bit 1, etc
	if character.name == "Player":
		collision_layer = 1
		collision_mask = 2
	else:
		collision_layer = 16
		collision_mask = 27

func hit(damage: float) -> void:
	# inflict damage on character's health component
	character.health_component.take_damage(damage)
