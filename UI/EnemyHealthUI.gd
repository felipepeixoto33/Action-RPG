extends Control

signal health_changed
var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty
onready var healthBar = $TextureProgress
onready var label = $TextureProgress/Label
onready var enemyStats = get_parent().get_node("Stats")
onready var enemy = get_parent()

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heartUIFull != null:
		heartUIFull.rect_size.x = hearts * 15
		healthBar.max_value = max_hearts
		healthBar.value = hearts
		label.text = String((hearts / max_hearts) * 100)

func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = max_hearts * 15

func _ready():
	self.max_hearts = enemyStats.max_health
	self.hearts = enemyStats.health
	enemyStats.connect("health_changed", self, "set_hearts")
	enemyStats.connect("max_health_changed", self, "set_max_hearts")
	set_hearts(hearts - 1)


func _on_EnemyBase_health_changed(damage):
	set_hearts(hearts - damage)
