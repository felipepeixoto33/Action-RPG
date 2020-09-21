extends Area2D

func _on_Coin_body_entered(body):
	if body == GameManager.player:
		GameManager.player.inventory.add_item("Coin", 1)
		queue_free()
