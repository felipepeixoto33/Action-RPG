extends Node

var world = preload("res://World/Scenes/World.tscn")

func _ready():
	pass



func _on_StartGameUI_playButtonPressed():
	get_tree().change_scene("res://World/Scenes/World.tscn")
