extends Control

var world = preload("res://World/Scenes/World.tscn")
var player = preload("res://Player/Player.tscn")

onready var restartButton = $TextureRect/RestartButton
onready var quitButton = $TextureRect/QuitButton

func _physics_process(delta):
	if(restartButton.pressed):
		yield(restartButton, "pressed")
		get_tree().change_scene("res://World/Scenes/World.tscn")
		self.set_physics_process(true)
		self.hide()
		PlayerStats.health = PlayerStats.max_health
	elif(quitButton.pressed):
		get_tree().quit()
