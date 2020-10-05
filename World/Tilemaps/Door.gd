extends TileMap

onready var bat = get_parent().get_node("Bat")
var killed = 0;

func disable():
	self.visible = false
	self.set_collision_layer_bit(0, false)

func increment():
	print("Working")
	killed+=1;
	if(killed >= 4):
		disable()


func _on_Bat4_killed():
	increment()


func _on_Bat3_killed():
	increment()


func _on_Bat2_killed():
	increment()


func _on_Bat_killed():
	increment()
