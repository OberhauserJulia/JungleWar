extends Node2D

# Node references
@onready var tilemap = $TileMap
@onready var spawned_players = $SpawnedPlayers
@onready var spawned_boosts = $SpawnedBoosts
@onready var spawned_enemies = $SpawnedEnemies
@onready var spawned_bombs = $SpawnedBombs
@onready var countdown_timer = $CountDownTimer
@onready var map_size_width = get_node("/root/Main/GamePanel/StartScreen/MapSizePopup/Border/Container/MapSizeWidthTextEdit")
@onready var map_size_height = get_node("/root/Main/GamePanel/StartScreen/MapSizePopup/Border/Container/MapSizeHeightTextEdit")

# UI Node references
@onready var game_ui_time = $GameUI/Border/Container/Time
@onready var progression_ui_batlle = $LevelCompleteUIBattle
@onready var progression_ui_normal = $LevelCompleteUINormal
@onready var progression_ui_time_normal_value = $LevelCompleteUINormal/Border/StartScreen/Time/Value
@onready var progression_ui_time_battle_value = $LevelCompleteUIBattle/Border/StartScreen/Time/Value
@onready var progression_ui_level_normal_value = $LevelCompleteUINormal/Border/StartScreen/Level/Value
@onready var progression_ui_level_battle_value = $LevelCompleteUIBattle/Border/StartScreen/Level/Value
@onready var game_over_ui = $GameOverUI
@onready var game_over_time_value = $GameOverUI/Border/StartScreen/Time/Value
@onready var game_over_level_value = $GameOverUI/Border/StartScreen/Level/Value
@onready var pause_menu_ui = $PauseMenuUI
@onready var game_info_screen = $PauseMenuUI/StartScreen/Border/Container/GameInfoScreen
@onready var current_game_level = $PauseMenuUI/StartScreen/Border/Container/LevelInfo/Label

@onready var player2_lives = $GameUI/Border/Container/Lives2
@onready var player2_powerup = $GameUI/Border/Container/Boosts2

@onready var winner_text = $LevelCompleteUIBattle/Border/StartScreen/Label

# Music node references
@onready var button_click_sfx = get_node("/root/Main/GameMusic/ButtonClick_SFX")
@onready var game_music = $GameMusic/Game_Music
@onready var pause_music = $GameMusic/PauseMenu_Music
@onready var game_over_music = $GameMusic/GameOver_Music
@onready var level_complete_music = $GameMusic/LevelComplete_Music


# Randomizer & Dimension values
var initial_width: int
var initial_height: int
var map_width = initial_width
var map_height = initial_height 
var map_offset = 4 
var rng = RandomNumberGenerator.new()

# Tilemap constants
const BACKGROUND_TILE_ID = 0
const BREAKABLE_TILE_ID = 1
const UNBREAKABLE_TILE_ID = 2
const BACKGROUND_TILE_LAYER = 0
const BREAKABLE_TILE_LAYER = 1
const UNBREAKABLE_TILE_LAYER = 2

# Bomb variables
var boost_spawner_chance = RandomNumberGenerator.new()
var player_damaged_for_current_explosion = false


func _ready():
	Global.game_over.connect(game_over)

	# Debug-Ausgaben
	print("Map size width text: ", map_size_width.text)
	print("Map size height text: ", map_size_height.text)

	# Check that the text fields are not empty before converting them to integers
	if map_size_width.text != "" and map_size_height.text != "":
		initial_width = int(map_size_width.text)
		initial_height = int(map_size_height.text)
	else:
		print("Fehler: Die Textfelder sind leer oder nicht richtig initialisiert.")
		return

	# Update map dimensions based on the current level
	map_width = initial_width + (Global.current_level - 1) * 2
	map_height = initial_height + (Global.current_level - 1) * 2
	print("Map width: ", map_width)
	print("Map height: ", map_height)

	start_level()
	
func start_level():   
	Global.deactivate_cursor()
	current_game_level.text = str("CURRENT LEVEL: ", Global.current_level)
	match Global.current_game_mode:
		# Normal game setup
		Global.GameMode.NORMAL:
			generate_map()
			boost_spawner_chance.randomize()
			var player = spawn_players(Global.player_scene, 1)
			if player:
				Global.player = player
			spawn_enemies()
			player2_lives.hide()
			player2_powerup.hide()
		# Battle game setup	
		Global.GameMode.BATTLE:
			generate_map()
			boost_spawner_chance.randomize()
			var player_1 = spawn_players(Global.player_scene, 1)
			var player_2 = spawn_players(Global.player_scene_2, 1)
			if player_1:
				Global.player = player_1
			if player_2:
				Global.player_2 = player_2
			spawn_enemies()
	# Music state
	game_music.play()
			
# ---------------- Map Generation -------------------------------------
func generate_map():
	generate_unbreakables()
	generate_breakables()
	generate_background()
	generate_boosts()

# Checks if tiles are empty or not
func is_cell_empty(layer, coords):
	var data = tilemap.get_cell_tile_data(layer, coords)
	return data == null

# Finds and returns remaining empty cells
func find_empty_cells(map_width, map_height, map_offset, BREAKABLE_TILE_LAYER, UNBREAKABLE_TILE_LAYER):
	var empty_cells = []
	for x in range(1, map_width - 1):
		for y in range(1, map_height - 1):
			var current_cell = Vector2i(x, y + map_offset)
			if is_cell_empty(BREAKABLE_TILE_LAYER, current_cell) and is_cell_empty(UNBREAKABLE_TILE_LAYER, current_cell):
				empty_cells.append(current_cell)
	return empty_cells	
	
func generate_unbreakables():
	#--------------------------------- UBREAKABLES ------------------------------
	# Generate unbreakable walls at the borders on Layer 2
	for x in range(map_width):
		for y in range(map_height):
			if x == 0 or x == map_width - 1 or y == 0 or y == map_height - 1:
				tilemap.set_cell(UNBREAKABLE_TILE_LAYER, Vector2i(x, y + map_offset), UNBREAKABLE_TILE_ID, Vector2i(0, 0), 0)
	# Generate solid walls in a grid on Layer 2, starting from (1, 1)
	for x in range(1, map_width - 2):  
		for y in range(1, map_height - 2):  
			if x % 2 == 0 and y % 2 == 0: 
				tilemap.set_cell(UNBREAKABLE_TILE_LAYER, Vector2i(x, y + map_offset), UNBREAKABLE_TILE_ID, Vector2i(0, 0), 0)
	
func generate_breakables():
	#--------------------------------- BREAKABLES ------------------------------
	# Define an array for the corners and their safe zones
	var spawn_zones = [
		# Near top-left corner
		[Vector2i(1, 1 + map_offset), Vector2i(1, 2 + map_offset), Vector2i(1, 3 + map_offset)],
		# Near top-right corner
		[Vector2i(map_width - 2, 1 + map_offset), Vector2i(map_width - 2, 2 + map_offset), Vector2i(map_width - 2, 3 + map_offset)],
		# Near bottom-left corner
		[Vector2i(1, map_height - 2 + map_offset), Vector2i(1, map_height - 3 + map_offset), Vector2i(1, map_height - 4 + map_offset)],
		# Near bottom-right corner
		[Vector2i(map_width - 2, map_height - 2 + map_offset), Vector2i(map_width - 2, map_height - 3 + map_offset), Vector2i(map_width - 2, map_height - 4 + map_offset)]
	]

	# Randomly place breakable walls on Layer 1
	rng.randomize()
	for x in range(1, map_width - 1):
		for y in range(1, map_height - 1):
			var base_breakable_chance = 0.2  
			var level_chance_multiplier = 0.01  
			var breakable_spawn_chance = base_breakable_chance + (Global.current_level - 1) * level_chance_multiplier
			breakable_spawn_chance = min(breakable_spawn_chance, 0.5) 
			var current_cell = Vector2i(x, y  + map_offset)
			var skip_current_cell = false
			if x % 2 == 0 and y % 2 == 0:
				skip_current_cell = true
			for corner in spawn_zones:
				if current_cell in corner:
					skip_current_cell = true
					break
			if skip_current_cell:
				continue
			if is_cell_empty(BREAKABLE_TILE_LAYER, current_cell):
				if rng.randf() < breakable_spawn_chance: 
					tilemap.set_cell(BREAKABLE_TILE_LAYER, current_cell, BREAKABLE_TILE_ID, Vector2i(0, 0), 0)

func generate_background():
	#--------------------------------- BACKGROUND ------------------------------
	for x in range(map_width):
		for y in range(map_height):
			var cell_coords = Vector2i(x, y + map_offset)
			if is_cell_empty(BREAKABLE_TILE_LAYER, cell_coords) and is_cell_empty(UNBREAKABLE_TILE_LAYER, cell_coords):
				tilemap.set_cell(BACKGROUND_TILE_LAYER, cell_coords, BACKGROUND_TILE_ID, Vector2i(0, 0), 0)

func generate_boosts():
	# ------------------------------------- BOOST SPAWNING ------------------
	var empty_cells = find_empty_cells(map_width, map_height, map_offset, BREAKABLE_TILE_LAYER, UNBREAKABLE_TILE_LAYER)
	var number_of_boosts = randi_range(1 , 5) 
	# Randomly spawn 1 - 5 boosts on empty cells
	for boost in range(number_of_boosts):
		if empty_cells.size() > 0:
			var random_index = rng.randi() % empty_cells.size()
			var random_cell = empty_cells[random_index]
			spawn_explosion_boost(random_cell)
			empty_cells.remove_at(random_index) 
			
# ---------------- Entity Spawning -------------------------------------
# Checks corners for valid spawnpoint		
func is_valid_spawnpoint(coords):
	for layer in [BREAKABLE_TILE_LAYER, UNBREAKABLE_TILE_ID]:
		var data = tilemap.get_cell_tile_data(layer, coords)
		if data != null:
			return false
	return true

# Checks corners for existing players at spawnpoints	
func is_spawnpoint_taken(coords: Vector2i) -> bool:
	for player in spawned_players.get_children():
		if tilemap.local_to_map(player.global_position) == coords:
			return true
	return false
	
# Spawns playera in corners
func spawn_players(player_scene, instance_count = 1):
	rng.randomize()
	var spawn_points = [
		Vector2i(1, 1 + map_offset),
		Vector2i(map_width - 2, 1  + map_offset),
		Vector2i(1, map_height - 2  + map_offset),
		Vector2i(map_width - 2, map_height - 2  + map_offset)
	]
	var players_in_level = []
	
	for i in range(instance_count):
		var attempts = 0
		var spawned = false
		while attempts < spawn_points.size() and not spawned:
			var random_index = rng.randi() % spawn_points.size()
			var spawn_coords = spawn_points[random_index]
			spawn_points.remove_at(random_index)  
			if is_valid_spawnpoint(spawn_coords) and not is_spawnpoint_taken(spawn_coords):
				var player = player_scene.instantiate()
				player.global_position = tilemap.map_to_local(spawn_coords)
				spawned_players.add_child(player)
				players_in_level.append(player)
				spawned = true
			else:
				attempts += 1
				
	if instance_count == 1 and players_in_level.size() > 0:
		return players_in_level[0] 
	else:
		return players_in_level 

# Randomly spawns explosion boosts
func spawn_explosion_boost(coords):
	var boost = Global.explosion_boost_pickup_scene.instantiate()
	boost.global_position = tilemap.map_to_local(coords)
	spawned_boosts.add_child(boost)

# Spawns enemies
func spawn_enemies():
	var empty_cells = find_empty_cells(map_width, map_height, map_offset, BREAKABLE_TILE_LAYER, UNBREAKABLE_TILE_LAYER)
	var number_of_enemies = 0 
	number_of_enemies = 1 + (1 * (Global.current_level - 1))
	number_of_enemies = min(number_of_enemies, 20) 
	var level_colors = {
		1: ["blue"],
		2: ["blue", "lila"],
		"default": ["blue", "lila", "orange"]
	}
	for i in range(number_of_enemies):
		if empty_cells.size() > 0:
			var random_index = rng.randi() % empty_cells.size()
			var random_cell = empty_cells[random_index]
			empty_cells.remove_at(random_index)
			var enemy_colors = level_colors.get(Global.current_level, level_colors["default"])
			Global.enemy_color = enemy_colors[rng.randi() % enemy_colors.size()]
			var enemy_scene = Global.enemy_scene
			if enemy_scene:
				var enemy = enemy_scene.instantiate()
				enemy.global_position = tilemap.map_to_local(random_cell)
				spawned_enemies.add_child(enemy)	
	Global.enemy_count = number_of_enemies
	Global.update_enemy_count(number_of_enemies)  
		
# ---------------- Entity Damage -------------------------------------	
# Remove bricks and check for player/enemy damage
func remove_entities(bomb_position, explosion_radius, bomb_owner):
	player_damaged_for_current_explosion = false
	#----------- Tile damage -------------------------------
	var tile_size = 16
	var tile_position = tilemap.local_to_map(bomb_position)
	var tiles_in_radius = int(explosion_radius / tile_size)
	var explosion_min = tile_position - Vector2i(tiles_in_radius, tiles_in_radius)
	var explosion_max = tile_position + Vector2i(tiles_in_radius, tiles_in_radius)
	for x in range(explosion_min.x, explosion_max.x + 1):
		for y in range(explosion_min.y, explosion_max.y + 1):
			var cell_coords = Vector2i(x, y)
			var overlapping_tile = tilemap.get_cell_tile_data(BREAKABLE_TILE_LAYER, cell_coords)
			if overlapping_tile:
				tilemap.set_cell(BREAKABLE_TILE_LAYER, cell_coords, -1) 
				tilemap.set_cell(BACKGROUND_TILE_LAYER, cell_coords, BACKGROUND_TILE_ID, Vector2i(0, 0), 0)
				if boost_spawner_chance.randf() < 0.1:
					spawn_explosion_boost(cell_coords)
					
	#----------- Damage Bounds-------------------------------	
	var explosion_bounds = Rect2(tilemap.map_to_local(explosion_min), tilemap.map_to_local(explosion_max) - tilemap.map_to_local(explosion_min))				

	#----------- Player damage -------------------------------	
	# Check if the player 1 and explosion bounds
	var player_bounds = Rect2(Global.player.global_position - Vector2(16, 16), Vector2(25.6, 25.6))
	if not player_damaged_for_current_explosion and player_bounds.intersects(explosion_bounds):
		Global.player.take_damage(1)
		player_damaged_for_current_explosion = true
		
	# Check if the player 2 and explosion bounds
	if Global.current_game_mode == Global.GameMode.BATTLE:
		var player_bounds_2 = Rect2(Global.player_2.global_position - Vector2(16, 16), Vector2(25.6, 25.6))
		if not player_damaged_for_current_explosion and player_bounds_2.intersects(explosion_bounds):
			Global.player_2.take_damage(1)
			player_damaged_for_current_explosion = true

	#----------- Enemy damage -------------------------------
	for enemy in spawned_enemies.get_children():
		var enemy_bounds = Rect2(enemy.global_position - Vector2(16, 16), Vector2(25.6, 25.6)) 
		if enemy_bounds.intersects(explosion_bounds):
			enemy.take_damage()

# ------------------------- Level Progression ----------------------------------
# Checks if level is complete
func check_for_level_completion():
	if Global.current_game_mode == Global.GameMode.NORMAL:
		if Global.enemy_count <= 0:
			countdown_timer.stop()
			var remaining_time = game_ui_time.countdown_time
			var minutes = remaining_time / 60
			var seconds = remaining_time % 60
			get_tree().paused = true
			progression_ui_normal.visible = true
			Global.activate_cursor()
			progression_ui_time_normal_value.text = "%02d:%02d" % [minutes, seconds]
			progression_ui_level_normal_value.text = str(Global.current_level)
			map_width += 2
			map_height += 2
			# Music state
			game_music.stop()
			level_complete_music.play()
			
	if Global.current_game_mode == Global.GameMode.BATTLE:
		if Global.lives <= 0 or Global.lives_2 <= 0:
			countdown_timer.stop()
			var remaining_time = game_ui_time.countdown_time
			var minutes = remaining_time / 60
			var seconds = remaining_time % 60
			get_tree().paused = true
			if Global.lives > Global.lives_2:
				winner_text.text = "Spieler 1 hat gewonnen"
			elif Global.lives < Global.lives_2:
				winner_text.text = "Spieler 2 hat gewonnen"
			progression_ui_batlle.visible = true
			Global.activate_cursor()
			progression_ui_time_battle_value.text = "%02d:%02d" % [minutes, seconds]
			progression_ui_level_battle_value.text = str(Global.current_level)
			if map_width < 36 or map_width + 2 <= 36:
				map_width += 2
			if map_height < 16 or map_height + 2 <= 16:
				map_height += 2
			# Music state
			game_music.stop()
			level_complete_music.play()

# ------------------------- UI ----------------------------------
func _on_count_down_timer_timeout():
	Global.update_time(Global.elapsed_time - 1)
	check_for_level_completion()


func _on_continue_button_pressed():
	# Music state
	button_click_sfx.play()
	clear_existing_entities()
	Global.current_level += 1
	game_ui_time.reset_timer()
	start_level()

# ------------------------------- Game State ------------------------------------
# Reset Game States
func clear_existing_entities():
	tilemap.clear()
	for child in spawned_boosts.get_children():
		child.queue_free() 
	for child in spawned_bombs.get_children():
		child.queue_free() 
	for entity in spawned_players.get_children():
		entity.queue_free() 
		entity.explosion_boost_count = 0
	for child in spawned_enemies.get_children():
		child.queue_free()
	Global.update_boost_count(0)
	Global.update_enemy_count(Global.enemy_count)
	Global.update_lives_count(3)
	Global.update_lives_2_count(3)
	game_ui_time.reset_timer()
	countdown_timer.start()
	progression_ui_batlle.visible = false
	progression_ui_normal.visible = false
	game_over_ui.visible = false
	get_tree().paused = false

# -------------------------------- Game Over ------------------------------------
# When game over signal emits 
func game_over():
	if Global.current_game_mode == Global.GameMode.NORMAL:
		countdown_timer.stop()
		var remaining_time = game_ui_time.countdown_time
		var minutes = remaining_time / 60
		var seconds = remaining_time % 60
		game_over_time_value.text = "%02d:%02d" % [minutes, seconds]
		game_over_level_value.text = str(Global.current_level)
		get_tree().paused = true
		game_over_ui.visible = true
		Global.activate_cursor()
		# Music state
		game_over_music.play()

func _on_replay_button_pressed():
	# Music state
	button_click_sfx.play()
	countdown_timer.start()
	clear_existing_entities()
	start_level()

# -------------------------------- Pause Menu ------------------------------------
# Pause game
func _input(event):
	if event.is_action_pressed("ui_pause"):
		Global.activate_cursor()
		game_ui_time.stop_timer()
		pause_menu_ui.visible = true
		get_tree().paused = true	
		# Music state
		game_music.stop()
		pause_music.play()


# Resume Game
func _on_resume_game_button_pressed():
	Global.deactivate_cursor()
	# Music state
	button_click_sfx.play()
	pause_menu_ui.visible = false
	get_tree().paused = false			
	game_ui_time.resume_timer()
	# Music state
	pause_music.stop()
	game_music.play()

# Restart Level
func _on_restart_game_button_pressed():
	Global.deactivate_cursor()
	# Music state
	button_click_sfx.play()
	clear_existing_entities()
	pause_menu_ui.visible = false
	get_tree().paused = false
	start_level()
	
# Quit to Main Menu
func _on_quit_game_button_pressed():
	# Music state
	button_click_sfx.play()
	get_tree().reload_current_scene()
	
# ------------------------ Game Info Screen ------------------------------
func _on_game_info_button_pressed():
	# Music state
	button_click_sfx.play()
	game_info_screen.visible = true

func _on_close_button_pressed():
	# Music state
	button_click_sfx.play()
	game_info_screen.visible = false
