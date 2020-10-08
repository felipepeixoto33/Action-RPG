extends Resource
class_name PlayerEquipament

var drag_data = null
var armor = 0;

signal items_changed(indexes)
signal armor_setted(value)

export(Array, Resource) var items = [
	null, null, null, null, null, null
]

func set_item(item_index, item):
	if item.itemType == "Equipament":
		var previousItem = items[item_index]
		items[item_index] = item
		emit_signal("items_changed", [item_index])
		set_armor()
		return previousItem

func swap_items(item_index, target_item_index):
	var targetItem = items[target_item_index]
	var item = items[item_index]
	items[target_item_index] = item
	items[item_index] = targetItem
	emit_signal("items_changed", [item_index, target_item_index])
	set_armor()

func remove_item(item_index):
	var previousItem = items[item_index]
	items[item_index] = null
	emit_signal("items_changed", [item_index])
	set_armor()
	return previousItem

func make_items_unique():
	var unique_items = []
	for item in items:
		if item is Item:
			unique_items.append(item.duplicate())
		else:
			unique_items.append(null)
	items = unique_items

func set_armor():
	armor = 0
	for i in items.size():
		if(items[i] != null):
			armor += items[i].armor
	emit_signal("armor_setted", armor)
