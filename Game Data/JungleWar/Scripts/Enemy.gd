extends CharacterBody2D 

@onready var animated_sprite = $AnimatedSprite2D 
@onready var animation_player = $AnimationPlayer 
@onready var movement_timer = $MovementTimer 
@onready var damage_sfx = $GameMusic/Damage_SFX

# Enemy properties 
var is_destroyed = false
var color: String 
var damage: int 
var enemy_properties = { 
	"blue": {"damage": 1, "idle_animation": "blue_idle", "movement_animation": "blue_movement", "up_animation": "blue_up", "down_animation": "blue_down", "right_animation": "blue_right", "left_animation": "blue_left"}, 
	"lila": {"damage": 2, "idle_animation": "lila_idle", "movement_animation": "lila_movement",  "up_animation": "lila_up", "down_animation": "lila_down", "right_animation": "lila_right", "left_animation": "lila_left"}, 
	"orange": {"damage": 3, "idle_animation": "orange_idle", "movement_animation": "orange_movement",  "up_animation": "orange_up", "down_animation": "orange_down", "right_animation": "orange_right", "left_animation": "orange_left"}
}

# Movement properties 
var rng = RandomNumberGenerator.new() 
var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT] 
var current_direction = Vector2i.ZERO

func _ready(): 
	color = Global.enemy_color 
	var properties = enemy_properties[color] 
	damage = properties["damage"] 
	animated_sprite.play(properties["idle_animation"]) 
	animated_sprite.modulate = Color(1,1,1,1)
	redirect_enemy() 
	movement_timer.start() 

# Moves the enemy in the current direction 
func move_enemy(): 
	var tilemap = get_parent().get_node("../TileMap") 
	var tile_size = 16 
	var next_cell = tilemap.local_to_map(global_position) + current_direction
	var next_position = global_position + Vector2(current_direction.x, current_direction.y) * tile_size
	if tilemap.get_cell_tile_data(1, next_cell) == null and tilemap.get_cell_tile_data(2, next_cell) == null: 
		var properties = enemy_properties[color]
		var animation_name = properties["movement_animation"]
		if current_direction == Vector2i.UP:
			animation_name = properties["up_animation"]
		elif current_direction == Vector2i.DOWN:
			animation_name = properties["down_animation"]
		elif current_direction == Vector2i.LEFT:
			animation_name = properties["left_animation"]
		elif current_direction == Vector2i.RIGHT:
			animation_name = properties["right_animation"]

		animated_sprite.play(animation_name)
		global_position = next_position 
	else: 
		redirect_enemy()

# Changes the enemy's direction randomly 
func redirect_enemy(): 
	rng.randomize() 
	current_direction = directions[rng.randi() % directions.size()]

# Move Enemy 
func _on_movement_timer_timeout(): 
	move_enemy()
	
# Damage Player 
func _on_collision_indicator_body_entered(body): 
	const damage_cooldown_time = 1.0 
	var last_damage_time = 0.0
	if body.is_in_group("player"): 
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_damage_time >= damage_cooldown_time: 
			last_damage_time = current_time 
			body.take_damage(damage)
	if body.is_in_group("player_2"): 
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_damage_time >= damage_cooldown_time: 
			last_damage_time = current_time 
			body.take_damage(damage)
	
# Damage Enemy 
func take_damage():
	if not is_destroyed:
		#Music state
		damage_sfx.play()
		animation_player.play("take_damage")
		Global.enemy_count -= 1
		Global.update_enemy_count(Global.enemy_count)
		is_destroyed = true
		
# Remove Enemy 
func _on_animation_player_animation_finished(anim_name): 
	# Reset color 
	animated_sprite.modulate = Color(1,1,1,1) 
	# Remove from scene 
	self.queue_free()
