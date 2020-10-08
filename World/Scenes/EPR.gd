extends Node2D

func _ready():
	$TeleportToBoss.visible = false
	$TeleportToBoss/CollisionShape2D.disabled = true

func _on_TeleportToBoss_body_entered(body):
	PlayerStats.health += PlayerStats.max_health/2
	get_tree().change_scene("res://World/Scenes/BossBattleScene.tscn")


func _on_Golden_Danaburnu_killed():
	$TeleportToBoss.visible = true
	$TeleportToBoss/CollisionShape2D.disabled = false
