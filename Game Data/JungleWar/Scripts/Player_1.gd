extends CharacterBody2D

# Node References
@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var camera = $Camera2D
@onready var level = get_node("/root/Main/Level")
@onready var bomb_drop_timer = $BombDropTimer
@onready var explosion_boost_timer = $ExplosionBoostTimer

# Music Node refs
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
	# Set camera limits
	set_camera_limits()
	animated_sprite.modulate = Color(1,1,1,1)
		
func _physics_process(delta):
	movement_input()
	move_and_slide()
	
# Player movement
func movement_input():
	var input_direction = Input.get_vector("ui_left_1", "ui_right_1", "ui_up_1", "ui_down_1")
	velocity = input_direction * speed
	
	# -------- Animations by color ------------
	if Input.is_action_pressed("ui_left_1"):
		animated_sprite.play("left")
	elif Input.is_action_pressed("ui_right_1"):
		animated_sprite.play("right")
	elif Input.is_action_pressed("ui_up_1"):
		animated_sprite.play("up")
	elif Input.is_action_pressed("ui_down_1"):
		animated_sprite.play("down")
	else:
		animated_sprite.play("idle")
		animated_sprite.flip_h = false

# Player input		
func _input(event):
	if event.is_action_pressed("ui_drop_bomb_1"):
		animation_player.play("drop_bomb")
		bomb_drop_timer.start()
		set_physics_process(false)
			
# Sets camera limits to not go beyond map width/ height
func set_camera_limits():
	if level.map_width != 0 and  level.map_height != 0:
		var tile_size = 16
		camera.limit_left = 0
		camera.limit_top = tile_size - level.map_offset
		camera.limit_right = level.map_width * tile_size - 1
		camera.limit_bottom = (level.map_height + level.map_offset) * tile_size

# Spawns bomb
func _on_timer_timeout():
	var bomb_instance = Global.bomb_scene.instantiate()
	var spawned_bombs = get_parent().get_node("../SpawnedBombs")
	if spawned_bombs:
		# Music states
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
	if Global.lives >= 1:
		animation_player.play("take_damage")
		Global.lives -= amount
		Global.update_lives_count(Global.lives)
		print("Player 1: Lives left out of 3: ", Global.lives)
		# Music state
		damage_sfx.play()
	else:
		print("Player 1 is Dead.")
		Global.game_over.emit()

# Explosion boost coutdown
func _process(delta):
	if explosion_boost_timer.is_stopped() == false:
		var time_left = int(explosion_boost_timer.time_left)
		Global.update_boost_count(time_left)
