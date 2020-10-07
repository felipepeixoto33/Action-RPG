extends KinematicBody2D

signal deathAnimationCompleted
signal attacked(damage);

onready var enemyStats = $EnemyStats
onready var animatedSprite = $AnimatedSprite
onready var enemyDeathEffect = $EnemyDeathEffect
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var animationPlayer = $AnimationPlayer
onready var moveAwayTimer = $moveAwayTimer
onready var hitbox = $Hitbox
onready var playerScene = get_parent().get_node("YSort/Player")

var speed = 50
var seeingPlayer = null
var velocity = Vector2.ZERO
var player = null;
var FRICTION = 350
var ACCELERATION = 300
var MAX_SPEED = 50
var knockback = Vector2.ZERO
var distanceFromPlayer = 0
var canMove = Vector2.ZERO
var target = null
var masterAttacked = false

#Taming and Dominating

var isDominatable;
var isTamable;
export var dominated = false;
export var tamed = false;


func _on_EnemyStats_area_entered(area):
	enemyStats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.3)
	print(area.damage)


func _on_EnemyStats_no_health():
	$Sprite.visible = false
	$ShadowSprite.visible = false
	$ShadowSprite2.visible = false
	enemyDeathEffect.play("DeathEffect")
	yield(enemyDeathEffect, "animation_finished")
	queue_free()

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	
	if(velocity.x < 0):
		$Sprite.flip_h = false;
		$ShadowSprite.visible = true;
		$ShadowSprite2.visible = false;
#		$Hitbox/CollisionPolygon2D.disabled = false
#		$Hitbox/CollisionPolygon2D2.disabled = true
	else: 
		$Sprite.flip_h = true;
		$ShadowSprite.visible = false;
		$ShadowSprite2.visible = true;
#		$Hitbox/CollisionPolygon2D.disabled = true
#		$Hitbox/CollisionPolygon2D2.disabled = false
	
	var player = playerDetectionZone.player
	if player != null:
		var checkDistanceFromPlayer = sqrt((player.position.x - self.position.x) * (player.position.x - self.position.x) + (player.position.y - self.position.y) * (player.position.y - self.position.y))
		if(!dominated and !tamed):
			hitbox.set_collision_mask_bit(2, true)
			hitbox.set_collision_mask_bit(3, false)
			hurtbox.set_collision_layer_bit(2, false)
			hurtbox.set_collision_layer_bit(3, true)
			if checkDistanceFromPlayer < distanceFromPlayer:
				accelerate_towards_point(player.global_position, delta)
				move_and_collide(-velocity * delta)
	#			$stopTimer.start()
	#			moveAwayTimer.start()
			else:
				accelerate_towards_point(player.global_position, delta)
				move_and_collide(velocity * delta)
			
			if checkDistanceFromPlayer < 60:
				animationPlayer.play("Attack")
			elif checkDistanceFromPlayer > 60: 
				animationPlayer.play("Walk")
		
		#Domination and Taming
		else:
			hitbox.set_collision_mask_bit(2, false) #Não pode atacar o player
			hitbox.set_collision_mask_bit(3, true) #Pode atacar os inimigos
			hurtbox.set_collision_layer_bit(2, true) #Pode ser atacada pelos inimigos
			hurtbox.set_collision_layer_bit(3, false)
			if masterAttacked || target != null:
				if is_instance_valid(target):
					var checkDistanceFromTarget = sqrt((target.position.x - self.position.x) * (target.position.x - self.position.x) + (target.position.y - self.position.y) * (target.position.y - self.position.y))
					accelerate_towards_point(target.global_position, delta)
					move_and_collide(velocity * delta)
					if checkDistanceFromTarget < 60:
						animationPlayer.play("Attack")
					elif checkDistanceFromTarget > 60: 
						animationPlayer.play("Walk")
				else:
					masterAttacked = false
					if checkDistanceFromPlayer > 15: 
						animationPlayer.play("Walk")
					accelerate_towards_point(player.global_position, delta)
					move_and_collide(velocity * delta)
				
			else:
				if checkDistanceFromPlayer > 15: 
						animationPlayer.play("Walk")
				accelerate_towards_point(player.global_position, delta)
				move_and_collide(velocity * delta)


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
	knockback = area.knockback_vector * 30
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.3)
	target = area.location
	print(area.damage)


func _on_Hurtbox_invincibility_started():
	animationPlayer.play("InvencibilityStart")


func _on_Hurtbox_invincibility_ended():
	animationPlayer.play("InvencibilityEnd")


func _on_moveAwayTimer_timeout():
	canMove = -velocity


func _on_stopTimer_timeout():
	canMove = Vector2.ZERO


func _on_Player_attacked_by(Monster):
	target = Monster
	masterAttacked = true

func attack():
	emit_signal("attacked", 30)
	animationPlayer.play("Attack")
