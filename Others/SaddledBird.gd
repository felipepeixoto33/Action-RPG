extends KinematicBody2D

signal deathAnimationCompleted
signal canMount
signal cannotMount

onready var enemyStats = $EnemyStats
onready var animatedSprite = $AnimatedSprite
onready var enemyDeathEffect = $EnemyDeathEffect
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var animationPlayer = $AnimationPlayer
onready var moveAwayTimer = $moveAwayTimer
onready var mountCollisionShape = $MountArea/CollisionShape2D2
onready var mountTimer = $mountTimer
onready var sprite = $Sprite
onready var mountedSprite = $MountedSprite

var speed = 50
var seeingPlayer = null
var velocity = Vector2.ZERO
var player = null;
var FRICTION = 350
var ACCELERATION = 300
var MAX_SPEED = 115
var knockback = Vector2.ZERO
var distanceFromPlayer = 0
var canMove = Vector2.ZERO
var mounted = false;
var resetMountedCollision = false;
var unmounted = true;

func _ready():
	animationPlayer.play("default")

func _on_EnemyStats_area_entered(area):
	enemyStats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.3)
	print(area.damage)


func _on_EnemyStats_no_health():
	if !mounted:
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
	
	if velocity.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
	#Mounted
	
	if(mounted):
		if Input.is_action_pressed("moveEast"):
			mountedSprite.flip_h = false;
		if Input.is_action_pressed("moveWest"):
			mountedSprite.flip_h = true;
		
		
		self.position = get_parent().get_node("YSort/Player").position
		animationPlayer.play("Mounted")
		sprite.visible = false
		mountedSprite.visible = true
		$Hurtbox/CollisionShape2D.disabled = true #Trocar a mask dos collision shapes
		$Hurtbox/wingCollision.disabled = true
		mountTimer.start()
		if(resetMountedCollision):
			mountCollisionShape.disabled = true
			mountCollisionShape.disabled = false
			resetMountedCollision = false;
	if (unmounted):
		if is_instance_valid(self):
			self.position != get_parent().get_node("YSort/Player").position
		sprite.visible = true
		mountedSprite.visible = false
		animationPlayer.play("default")
		mounted = false
		ACCELERATION = 300
		speed = 50
		FRICTION = 350
		MAX_SPEED = 115


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
	if !mounted:
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


func _on_MountArea_body_entered(body):
	if body == get_parent().get_node("YSort/Player"):
		emit_signal("canMount")
		$mountTimer.start()
	pass


func _on_mountTimer_timeout():
	emit_signal("cannotMount")
	resetMountedCollision = true;


func _on_Player_mounted():
	mounted = true;
	unmounted = false;
	resetMountedCollision = true;


func _on_Player_unmounted():
	unmounted = true;
