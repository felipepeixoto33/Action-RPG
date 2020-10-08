extends Control

signal playButtonPressed
signal quitButtonPressed

onready var playButton = $TextureRect/PlayButton
onready var quitButton = $TextureRect/QuitButton

func _physics_process(delta):
	if(playButton.pressed):
		get_tree().change_scene("res://World/Scenes/World.tscn")
	elif(quitButton.pressed):
		get_tree().quit()
