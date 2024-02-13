extends CharacterBody2D

# Node References
@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var camera = $Camera2D
@onready var level = get_node("/root/Main/Level")
@onready var bomb_drop_timer = $BombDropTimer
@onready var explosion_boost_timer = $ExplosionBoostTimer

@onready var damage_sfx = $GameMusic/Damage_SFX
@onready var pickup_sfx = $GameMusic/Pickup_SFX
@onready var bomb_drop_sfx = $GameMusic/BombDrop_SFX

# Player states
var color: String
var speed = 100

# Bomb variables
var bomb_positions = []
var explosion_radius = 30
var max_explosion_radius = 70
var explosion_boost_count = 0

func _ready():
	animated_sprite.modulate = Color(1,1,1,1)
		
func _physics_process(delta):
	movement_input()
	move_and_slide()
	
# Player movement
func movement_input():
	var input_direction = Input.get_vector("ui_left_2", "ui_right_2", "ui_up_2", "ui_down_2")
	velocity = input_direction * speed
	
	# -------- Animation ------------
	if Input.is_action_pressed("ui_left_2"):
		animated_sprite.play("left")
	elif Input.is_action_pressed("ui_right_2"):
		animated_sprite.play("right")
	elif Input.is_action_pressed("ui_up_2"):
		animated_sprite.play("up")
	elif Input.is_action_pressed("ui_down_2"):
		animated_sprite.play("down")
	else:
		animated_sprite.play("idle")
		animated_sprite.flip_h = false

# Player input		
func _input(event):
	if event.is_action_pressed("ui_drop_bomb_2"):
		animation_player.play("drop_bomb")
		bomb_drop_timer.start()
		set_physics_process(false)

# Spawns bomb
func _on_timer_timeout():
	var bomb_instance = Global.bomb_scene.instantiate()
	var spawned_bombs = get_parent().get_node("../SpawnedBombs")
	if spawned_bombs:
		# Music state
		bomb_drop_sfx.play()
		spawned_bombs.add_child(bomb_instance)	
		bomb_instance.global_position = self.global_position
		bomb_instance.bomb_owner = self
		# Add the bomb's position to the tracking list
		bomb_positions.append(self.global_position)
		bomb_drop_timer.stop()
		set_physics_process(true)
		

# Starts boost timer
func start_explosion_boost_timer():
	explosion_boost_timer.start(10) 
	# Music state
	pickup_sfx.play() 
	
# Stops boost timer & resets value
func _on_explosion_boost_timer_timeout():
	explosion_boost_timer.stop()
	explosion_boost_count = 0
	explosion_radius = 30

# Reset color
func _on_animation_player_animation_finished(anim_name):
	animated_sprite.modulate = Color(1,1,1,1)
	
# Player damage
func take_damage(amount):
	if Global.lives_2 >= 1: 
		animation_player.play("take_damage")
		Global.lives_2 -= amount
		Global.update_lives_2_count(Global.lives_2)
		print("Player 2: Lives left out of 3: ", Global.lives_2)
		# Music state
		damage_sfx.play()
	else:
		print("Player 2 is Dead.")
		Global.game_over.emit()

func _process(delta):
	if explosion_boost_timer.is_stopped() == false:
		var time_left = int(explosion_boost_timer.time_left)
		Global.update_boost_count_2(time_left)
