extends CharacterBody3D
class_name Character

const HITBOX_COMPONENT = preload("res://character/components/scenes/hitbox_component.tscn")

var health_component: HealthComponent
var hitbox_component: HitboxComponent
var max_health: float
