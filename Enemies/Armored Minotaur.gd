extends KinematicBody2D

signal deathAnimationCompleted
signal _attack_completed
signal attacked(damage)

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
var attacked = true
var random = 1;

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
	$Sprite3.visible = false;
	enemyDeathEffect.play("DeathEffect")
	yield(enemyDeathEffect, "animation_finished")
	queue_free()

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	randomize()
	
	if(velocity.x < 0):
		$Sprite.flip_h = true;
		$Sprite2.flip_h = true;
		$Sprite3.flip_h = true;
#		$Hitbox/CollisionPolygon2D.disabled = false
#		$Hitbox/CollisionPolygon2D2.disabled = true
	else: 
		$Sprite.flip_h = false;
		$Sprite2.flip_h = false;
		$Sprite3.flip_h = false;
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
				_attack_left()
			elif checkDistanceFromPlayer > 60: 
				_attack_drop()
				yield(animationPlayer, "animation_finished")
				_walk()
		
		#Domination and Taming
		else:
			hitbox.set_collision_mask_bit(2, false) #Não pode atacar o player
			hitbox.set_collision_mask_bit(3, true) #Pode atacar os inimigos
			hurtbox.set_collision_layer_bit(2, true) #Pode ser atacada pelos inimigos
			hurtbox.set_collision_layer_bit(3, false)
			if masterAttacked || target != null:
				if is_instance_valid(target) && target.position !=null:
					var checkDistanceFromTarget = sqrt((target.position.x - self.position.x) * (target.position.x - self.position.x) + (target.position.y - self.position.y) * (target.position.y - self.position.y))
					accelerate_towards_point(target.global_position, delta)
					move_and_collide(velocity * delta)
					if checkDistanceFromTarget < 60:
						_attack_left()
					elif checkDistanceFromTarget > 60: 
						_attack_drop()
						yield(animationPlayer, "animation_finished")
						_walk()
				else:
					masterAttacked = false
					if checkDistanceFromPlayer > 15: 
						_walk()
					accelerate_towards_point(player.global_position, delta)
					move_and_collide(velocity * delta)
				
			else:
				if checkDistanceFromPlayer > 15: 
							_walk()
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
	knockback = area.knockback_vector * 30
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.3)
	target = area.location

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


func _walk():
	animationPlayer.play("Walk")
	$Sprite.visible = true;
	$Sprite2.visible = false;
	$Sprite3.visible = false;


func _random_attack():
	randomize()
	if(attacked):
		random = randi()%4+1;
		attacked = false;
	if(random == 4):
		_attack_drop()
		yield(animationPlayer, "animation_finished")
		attacked = true;
		$Hitbox/CollisionShape2D.disabled = true
	else:
		_attack_left()
		yield(animationPlayer, "animation_finished")
		attacked = true
		$Hitbox/CollisionShape2D2.disabled = true


func _attack_drop():
	animationPlayer.play("Attack", 0, 1)
	$Sprite.visible = false;
	$Sprite2.visible = true;
	$Sprite3.visible = false;
	yield(animationPlayer, "animation_finished")
	$attackedTimer.start()
	$Hitbox/CollisionShape2D.disabled = true
	$Hitbox/CollisionShape2D2.disabled = true
	emit_signal("attacked", 10)


func _attack_left():
	animationPlayer.play("AttackLeft", 0, 1.5)
	$Sprite.visible = false;
	$Sprite2.visible = false;
	$Sprite3.visible = true;
	yield(animationPlayer, "animation_finished")
	$attackedTimer.start()
	$Hitbox/CollisionShape2D2.disabled = true
	$Hitbox/CollisionShape2D.disabled = true
	emit_signal("attacked", 5)


func _on_attackedTimer_timeout():
	$Hitbox/CollisionShape2D2.disabled = true
	$Hitbox/CollisionShape2D.disabled = true
	print("CollisionDisabled")
