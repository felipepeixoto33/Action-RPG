extends KinematicBody2D

signal deathAnimationCompleted

onready var enemyStats = $EnemyStats
onready var animatedSprite = $AnimatedSprite
onready var enemyDeathEffect = $EnemyDeathEffect
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var animationPlayer = $AnimationPlayer
onready var moveAwayTimer = $moveAwayTimer

var speed = 50
var seeingPlayer = null
var velocity = Vector2.ZERO
var player = null;
var FRICTION = 350
var ACCELERATION = 300
var MAX_SPEED = 120
var knockback = Vector2.ZERO
var distanceFromPlayer = 130
var canMove = Vector2.ZERO



func _ready():
	animationPlayer.play("default")

func _on_EnemyStats_area_entered(area):
	enemyStats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.3)
	print(area.damage)


func _on_EnemyStats_no_health():
	animatedSprite.visible = false
	enemyDeathEffect.play("DeathEffect")
	yield(enemyDeathEffect, "animation_finished")
	queue_free()

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	
	var player = playerDetectionZone.player
	if player != null:
		var checkDistanceFromPlayer = sqrt((player.position.x - self.position.x) * (player.position.x - self.position.x) + (player.position.y - self.position.y) * (player.position.y - self.position.y))
		if checkDistanceFromPlayer < distanceFromPlayer:
			accelerate_towards_point(player.global_position, delta)
			move_and_collide(-velocity * delta)
#			$stopTimer.start()
#			moveAwayTimer.start()
		else:
			accelerate_towards_point(player.global_position, delta)
			move_and_collide(velocity * delta)


func _follow_player():
	pass


func _on_PlayerDetectionZone_body_entered(body):
	if body == get_parent().get_node("YSort/Player"):
		player = body


func _on_PlayerDetectionZone_body_exited(body):
	if body == get_parent().get_node("YSort/Player"):
		player = null


func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	animatedSprite.flip_h = velocity.x < 0


func _on_Hurtbox_area_entered(area):
	enemyStats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.3)
	print(area.damage)

func _on_Hurtbox_invincibility_started():
	animationPlayer.play("InvencibilityStart")

func _on_Hurtbox_invincibility_ended():
	animationPlayer.play("InvencibilityEnd")


func _on_moveAwayTimer_timeout():
	canMove = -velocity


func _on_stopTimer_timeout():
	canMove = Vector2.ZERO
