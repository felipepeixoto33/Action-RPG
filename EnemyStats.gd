extends Area2D

signal no_health
signal health_changed

export var max_health = 5

onready var player = get_node("/root/Player")
onready var enemy = get_parent()

onready var health = max_health
export var armor = 0
var direction = Vector2.ZERO
var speed = 200

func _process(delta):
	if health == 0:
		emit_signal("no_health")



func chasePlayer(delta):
	var enemy = get_parent()
	direction = Vector2(player.position - self.position)


func _on_Hurtbox_area_entered(area):
	emit_signal("health_changed");
