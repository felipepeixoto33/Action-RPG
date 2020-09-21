extends Area2D

var player = null;
var enemy = null;

func can_see_player():
	return player != null

func _on_PlayerDetectionZone_body_entered(body):
	if body == global.player:
		player = body


func _on_PlayerDetectionZone_body_exited(body):
	player = null
