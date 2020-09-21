extends Control

signal canRegen
signal canLoseAgain

var stamina = 100 setget set_stamina
var max_stamina = 100 setget set_max_stamina

onready var staminaBar = $TextureProgress
onready var label = $TextureProgress/Label

func set_stamina(value):
	stamina = clamp(value, 0, max_stamina)
	staminaBar.max_value = max_stamina
	staminaBar.value = stamina
#	if heartUIFull != null:
#		heartUIFull.rect_size.x = hearts * 15
#		healthBar.max_value = max_hearts
#		healthBar.value = hearts
#		label.text = String((hearts / max_hearts) * 100)

func set_max_stamina(value):
	max_stamina = max(value, 1)
	self.stamina = min(stamina, max_stamina)
#	if heartUIEmpty != null:
#		heartUIEmpty.rect_size.x = max_hearts * 15

func _ready():
	self.max_stamina = PlayerStats.max_stamina
	self.stamina = PlayerStats.stamina
	PlayerStats.connect("stamina_changed", self, "set_stamina")
	PlayerStats.connect("max_stamina_changed", self, "set_max_stamina")



func _on_ToRegen_timeout():
	emit_signal("canRegen")
	print("Timed Out!")


func _on_ToLoseAgain_timeout():
	emit_signal("canLoseAgain")
