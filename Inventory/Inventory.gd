extends Resource
class_name Inventory

var drag_data = null

#Collectables:
var coin = preload("res://Items/Collectables/Scenes/Coin.tscn")

signal items_changed(indexes)


export(Array, Resource) var items = [
	null, null, null, null, null, null, null, null, null 
]

func _ready():
	coin.connect("collected", self, "collect_item")
	pass

func set_item(item_index, item):
	var previousItem = items[item_index]
	items[item_index] = item
	emit_signal("items_changed", [item_index])
	return previousItem

func swap_items(item_index, target_item_index):
	var targetItem = items[target_item_index]
	var item = items[item_index]
	items[target_item_index] = item
	items[item_index] = targetItem
	emit_signal("items_changed", [item_index, target_item_index])

func remove_item(item_index):
	var previousItem = items[item_index]
	items[item_index] = null
	emit_signal("items_changed", [item_index])
	return previousItem

func make_items_unique():
	var unique_items = []
	for item in items:
		if item is Item:
			unique_items.append(item.duplicate())
		else:
			unique_items.append(null)
	items = unique_items

func collect_item(item):
	for i in items.size():
		if items[i] == null:
			set_item(i, item)
			break;
