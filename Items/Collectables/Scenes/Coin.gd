extends Area2D

signal collected(item)

var coinItem = preload("res://Items/Collectables/Resouces/Coin.tres")

func _on_Coin_body_entered(body):
	emit_signal("collected", coinItem)
	queue_free()
