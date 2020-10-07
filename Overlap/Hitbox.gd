extends Area2D

var id = "hitbox"
var location = self
var damage = 1 setget set_damage
var knockback_vector = Vector2.ZERO

func set_damage(value):
	damage = value;
	print("connected")

func _ready():
	if get_parent().is_in_group("Enemies"):
		get_parent().connect("attacked", self, "set_damage");


func _on_Giant_White_Kurnas_attacked(damage):
	set_damage(50)


func _on_Megnaton_attacked(damage):
	set_damage(30)
