extends Node3D

const BALL = preload("res://weapon/resources/ball.tres")
const EXPLOSION = preload("res://weapon/resources/explosion.tres")
const CURSE = preload("res://weapon/resources/curse.tres")

@onready var weapon_ray: RayCast3D = $RayCast3D

func use_spell(selected_spell: String) -> void:
	if selected_spell == "ball":
		use_ball()
	if selected_spell == "explosion":
		use_explosion()
	if selected_spell == "curse":
		use_curse()

func use_ball() -> void:
	# instances a new bullet at the weapon end
	var new_bullet: Node3D = BALL.spell_scene.instantiate()
	new_bullet.position = weapon_ray.global_position
	new_bullet.transform.basis = weapon_ray.global_transform.basis
	get_tree().root.add_child(new_bullet)

func use_explosion() -> void:
	# instances an explosion centered around the player
	var new_explosion: Node3D = EXPLOSION.spell_scene.instantiate()
	new_explosion.position = self.global_position
	get_tree().root.add_child(new_explosion)

func use_curse() -> void:
	# instance a curse hitbox centered around the player
	var new_curse: Node3D = CURSE.spell_scene.instantiate()
	new_curse.position = self.global_position - Vector3(0,1,0)
	get_tree().root.add_child(new_curse)
