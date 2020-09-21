extends Area2D

var id = "hitbox"
onready var location = get_parent()
export var damage = 1
var knockback_vector = Vector2.ZERO
