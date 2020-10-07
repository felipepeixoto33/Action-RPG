extends Control

signal playButtonPressed
signal quitButtonPressed

onready var playButton = $TextureRect/PlayButton
onready var quitButton = $TextureRect/QuitButton

func _physics_process(delta):
	if(playButton.pressed):
		yield(playButton, "pressed")
		emit_signal("playButtonPressed")
	elif(quitButton.pressed):
		get_tree().quit()
