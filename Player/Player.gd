extends KinematicBody2D

# Bugs:
# Sistema de Stamina: Toda vez que o jogador rola, conta como 2 vezes a redução da stamina.
signal mounted
signal unmounted
signal attacked_by(Monster)

var playerEquipament = preload("res://PlayerEquipment/PlayerEquipament.gd")

var staminaRegen = false;
var canRoll = true;
var staminaLoss = 10 #Keep in mind that the player will be losing 2x this each time.
var staminaGain = 1
var canLoseStamina = true;
var canMount = false;
var mounted = false;
var showInventory = false;
var playerReady = false;

const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")


export var ACCELERATION = 500
export var MAX_SPEED = 80
export var FRICTION = 500
export var ROLL_SPEED = 120

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2(0, 0)
var roll_vector = Vector2.DOWN
var stats = PlayerStats
var armor = 0;

onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer
onready var collisionShape2D = $CollisionShape2D
onready var inventory = $CanvasLayer/InventoryContainer
onready var playerEquipment = $CanvasLayer/PlayerEquipamentContainer



#var inventory_resource = load("res://Player/Inventory.gd")
#var inventory = inventory_resource.new()




func _ready():
	randomize()
	stats.connect("no_health", self, "change_scene")
	stats.connect("no_stamina", self, "cannotRoll")
	playerReady = true
	
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector
	
	global.player = self

func _physics_process(delta):
	armor = self.armor
	
	if Input.is_action_just_pressed("activateUI"):
		showInventory = !showInventory
		inventory.visible = showInventory
		playerEquipment.visible = showInventory
	
	if(stats.stamina >= 2*staminaLoss):
		canRoll = true;
	else:
		canRoll = false;
	
	if(stats.stamina < 0):
		stats.stamina = 0
	elif(stats.stamina > stats.max_stamina):
		stats.stamina = stats.max_stamina
	
	if staminaRegen:
		stats.stamina += staminaGain
	
	match state:
		MOVE:
			move_state(delta)
	
		ROLL:
			roll_state()
	
		ATTACK:
			attack_state()
	
	# Mount
	
	if canMount:
		if Input.is_action_just_pressed("action"):
			mounted = !mounted
			print(mounted)
	
	if(mounted):
		emit_signal("mounted")
		sprite.visible = false
		collisionShape2D.disabled = true
		ACCELERATION = 300
		MAX_SPEED = 120
		FRICTION = 350
		ROLL_SPEED = 0
	else:
		emit_signal("unmounted")
		sprite.visible = true
		collisionShape2D.disabled = false
		ACCELERATION = 500
		MAX_SPEED = 80
		FRICTION = 500
		ROLL_SPEED = 120

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("moveEast") - Input.get_action_strength("moveWest")
	input_vector.y = Input.get_action_strength("moveSouth") - Input.get_action_strength("moveNorth")
	input_vector = input_vector.normalized()
	
	
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		animationState.travel("Run")
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	move()
	
	if Input.is_action_just_pressed("roll"):
		if(canRoll):
			state = ROLL
			if canLoseStamina:
				lose_stamina()
			$CanvasLayer/StaminaUI/ToRegen.start()
			staminaRegen = false
		else:
			state = state 
		print("Executed")
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func roll_state():
	velocity = roll_vector * ROLL_SPEED
	if canRoll:
		animationState.travel("Roll")
	move()

func attack_state():
	velocity = Vector2.ZERO
	animationState.travel("Attack")

func move():
	velocity = move_and_slide(velocity)

func roll_animation_finished():
	velocity = velocity * 0.7
	state = MOVE

func attack_animation_finished():
	state = MOVE


func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage - area.damage * armor/100
	print(area.damage - area.damage * armor/100)
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()
	var playerHurtSound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)
	emit_signal("attacked_by", area.location)


func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")


func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")


func _on_StaminaUI_canRegen():
	staminaRegen = true;

func cannotRoll():
	canRoll = false

func lose_stamina():
	stats.stamina -= staminaLoss
	$CanvasLayer/StaminaUI/ToLoseAgain.start()
	canLoseStamina = false


func _on_StaminaUI_canLoseAgain():
	canLoseStamina = true


func _on_SaddledBird_canMount():
	canMount = true;


func _on_SaddledBird_cannotMount():
	canMount = false;


func _on_Coin_collected(item):
	inventory._on_collected(item)

func change_scene():
	get_tree().change_scene("res://UI/GameOverUI.tscn")
	self.hide()
	self.set_physics_process(false)
