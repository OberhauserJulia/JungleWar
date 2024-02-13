extends Node2D

@onready var game_panel = $GamePanel
@onready var game_mode_popup = $GamePanel/StartScreen/GameModePopup
@onready var map_size_popup = $GamePanel/StartScreen/MapSizePopup
@onready var character_edit_popup_1 = $GamePanel/StartScreen/CharacterEditCharakter1
@onready var character_edit_popup_2 = $GamePanel/StartScreen/CharacterEditCharakter2
@onready var game_info_screen = $GamePanel/StartScreen/GameInfoScreen
@onready var map_size_width_main = $GamePanel/StartScreen/MapSizePopup/Border/Container/MapSizeWidthTextEdit
@onready var map_size_height_main = $GamePanel/StartScreen/MapSizePopup/Border/Container/MapSizeHeightTextEdit
@onready var error_label = $GamePanel/StartScreen/MapSizePopup/Border/Container/ErrorLabel

@onready var menu_music = $GameMusic/MenuMusic
@onready var button_click_sfx = $GameMusic/ButtonClick_SFX

func _ready():
	game_panel.visible = true
	# Music state
	menu_music.play()
	
# ------------------------ Main Menu Buttons -------------------------	
# Start new game
func _on_new_game_button_pressed():
	# Music state
	button_click_sfx.play()
	Global.current_level = 1
	map_size_popup.show()
		
# Exit game
func _on_exit_game_button_pressed():
	# Music state
	button_click_sfx.play()
	get_tree().quit()

# ------------------------ Game Start Logic -------------------------
# Create an instance of our Level scene
func start_level():
	game_panel.visible = false
	var level = Global.level_scene.instantiate()
	add_child(level)
	get_tree().paused = false
	# Music state
	menu_music.stop()


# ------------------------ MapSize ------------------------------
func _on_start_button_pressed():
	# Music state
	button_click_sfx.play()
	var mapwidth_main = int(map_size_width_main.text)
	var mapheight_main = int(map_size_height_main.text)
	
	if mapwidth_main < 5 or mapwidth_main <= 0 or mapheight_main < 5 or mapheight_main <= 0 or mapwidth_main > 36 or mapheight_main > 17:
		error_label.visible = true
	else:
		map_size_popup.hide()
		game_mode_popup.show()


# ------------------------ Game Mode Logic -------------------------
# NORMAL Mode
func _on_normal_mode_button_pressed():
	# Music state
	button_click_sfx.play()
	game_mode_popup.hide()
	Global.current_game_mode = Global.GameMode.NORMAL
	character_edit_popup_1.show()

# BATTLE Mode
func _on_battle_mode_button_pressed():
	# Music state
	button_click_sfx.play()
	game_mode_popup.hide()
	Global.current_game_mode = Global.GameMode.BATTLE
	character_edit_popup_1.show()

# ------------------------ Hide Popups -------------------------
func _on_close_button_pressed():
	# Music state
	button_click_sfx.play()
	game_info_screen.visible = false

func _on_close_button_map_size_pressed():
	# Music state
	button_click_sfx.play()
	map_size_popup.hide()

func _on_close_button_game_mode_pressed():
	# Music state
	button_click_sfx.play()
	game_mode_popup.hide()
	map_size_popup.show()

func _on_close_button_charakter_edit_1_pressed():
	# Music state
	button_click_sfx.play()
	character_edit_popup_1.hide()
	game_mode_popup.show()

func _on_close_button_charakter_edit_2_pressed():
	# Music state
	button_click_sfx.play()
	character_edit_popup_2.hide()
	character_edit_popup_1.show()


# ------------------------ Edit Character -------------------------
func _on_continue_button_pressed():
	# Music state
	button_click_sfx.play()
	print (Global.current_game_mode == Global.GameMode.BATTLE)
	if Global.current_game_mode == Global.GameMode.NORMAL:
		character_edit_popup_1.hide()
		Global.current_game_mode = Global.GameMode.NORMAL
		start_level()
	if Global.current_game_mode == Global.GameMode.BATTLE:
		character_edit_popup_1.hide()
		character_edit_popup_2.show()
		
func _on_continue_button_2_pressed():
	# Music state
	button_click_sfx.play()
	character_edit_popup_2.hide()
	Global.current_game_mode = Global.GameMode.BATTLE
	start_level()
	
func _on_start_battle_pressed():
	character_edit_popup_1.hide()
	Global.current_game_mode = Global.GameMode.BATTLE
	start_level()


# ------------------------ Game Info Screen ------------------------------
func _on_game_info_button_pressed():
	# Music state
	button_click_sfx.play()
	game_info_screen.visible = true
