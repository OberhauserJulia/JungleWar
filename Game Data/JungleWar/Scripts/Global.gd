extends Node

var level_scene = preload("res://Scenes/Level.tscn")
var player_scene = preload("res://Scenes/Player_1.tscn")
var player_scene_2 = preload("res://Scenes/Player_2.tscn")
var bomb_scene = preload("res://Scenes/Bomb.tscn")
var explosion_boost_pickup_scene = preload("res://Scenes/ExplosionBoostPickup.tscn")
var enemy_scene = preload("res://Scenes/Enemy.tscn")

# Game State
enum GameMode { NORMAL, BATTLE }
var current_game_mode
var can_play_button_sfx = false

# Player variables
var player
var player_2
var lives: int = 3
var lives_2: int = 3

# Enemy variables
var enemy_color : String
var enemy_count : int 

# Level variables
var current_level = 1
var elapsed_time : float = 0.0

# Signals to notify UI of changes
signal time_updated()
signal lives_updated()
signal lives_2_updated()
signal enemies_updated()
signal boost_updated(new_time)
signal boost_updated_2(new_time)
signal game_over

# Method to update the timer count and emit the signal
func update_time(new_time):
	elapsed_time = new_time
	time_updated.emit()

# Method to update the lives Player 1 count and emit the signal
func update_lives_count(new_count):
	lives = new_count
	lives_updated.emit()
	
# Method to update the lives Player 2 count and emit the signal
func update_lives_2_count(new_count):
	lives_2 = new_count
	lives_2_updated.emit()

# Method to update the enemy count and emit the signal
func update_enemy_count(new_count):
	enemy_count = new_count
	enemies_updated.emit()

# Method to update the boost time for Player 1 count and emit the signal
func update_boost_count(new_time):
	boost_updated.emit(new_time)
	
# Method to update the boost time for Player 2 count and emit the signal
func update_boost_count_2(new_time):
	boost_updated_2.emit(new_time)

# Show cursor
func activate_cursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	can_play_button_sfx = true
	
# Hide cursor
func deactivate_cursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	can_play_button_sfx = false
