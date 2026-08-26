extends Node3D

@onready var weapon_ray: RayCast3D = $RayCast3D

const BALL = preload("res://weapon/resources/ball.tres")
const EXPLOSION = preload("res://weapon/resources/explosion.tres")
const CURSE = preload("res://weapon/resources/curse.tres")

var ball_cooldown: float = 0.0
var explosion_cooldown: float = 0.0
var curse_cooldown: float = 0.0

func use_spell(selected_spell: String):
	if selected_spell == "ball" and ball_cooldown <= 0:
		use_ball()
	if selected_spell == "explosion" and explosion_cooldown <= 0:
		use_explosion()
	if selected_spell == "curse" and curse_cooldown <= 0:
		use_curse()

func use_ball():
	# instances a new bullet at the weapon end
	var new_bullet: Node3D = BALL.spell_scene.instantiate()
	new_bullet.position = weapon_ray.global_position
	new_bullet.transform.basis = weapon_ray.global_transform.basis
	get_tree().root.add_child(new_bullet)
	ball_cooldown = BALL.cooldown

func use_explosion():
	# instances an explosion centered around the player
	var new_explosion: Node3D = EXPLOSION.spell_scene.instantiate()
	new_explosion.position = self.global_position
	get_tree().root.add_child(new_explosion)
	explosion_cooldown = EXPLOSION.cooldown

func use_curse():
	# instance a curse hitbox centered around the player
	var new_curse: Node3D = CURSE.spell_scene.instantiate()
	new_curse.position = self.global_position - Vector3(0,1,0)
	get_tree().root.add_child(new_curse)
	curse_cooldown = CURSE.cooldown

func _physics_process(delta: float) -> void:
	# run cooldowns for all spells
	if ball_cooldown > 0:
		ball_cooldown -= delta
	if explosion_cooldown > 0:
		explosion_cooldown -= delta
	if curse_cooldown > 0:
		curse_cooldown -= delta
