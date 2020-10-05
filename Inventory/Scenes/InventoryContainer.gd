extends TextureRect

var inventory = preload("res://Inventory/Inventory.tres")
var coin = preload("res://Items/Collectables/Scenes/Coin.gd")

func _ready():
	coin.connect("collected", self, "_on_collected")

func _on_collected(item):
	inventory.collect_item(item)
