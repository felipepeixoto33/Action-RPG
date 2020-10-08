extends Node2D



func _on_Giant_White_Kurnas_killed():
	PlayerStats.health += PlayerStats.max_health/2
	get_tree().change_scene("res://World/Scenes/EPR.tscn")
