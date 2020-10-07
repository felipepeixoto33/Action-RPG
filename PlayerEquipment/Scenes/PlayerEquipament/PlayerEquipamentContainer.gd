extends TextureRect

var playerEquipament = preload("res://PlayerEquipment/PlayerEquipament.tres")

func _ready():
	playerEquipament.set_armor()
	playerEquipament.connect("items_changed", playerEquipament, "set_armor")

