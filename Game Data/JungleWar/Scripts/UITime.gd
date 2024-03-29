extends ColorRect

# Node References
@onready var value = $Container/Value
@onready var hurry_up_music_1 = $"../../../../GameMusic/HurryUp1_Music"
@onready var hurry_up_music_2 = $"../../../../GameMusic/HurryUp2_Music"

var countdown_time = 300
var is_time_running = true
var stopped_time: int

func _ready(): 
	Global.time_updated.connect(update_time)
	update_time()

# Update time each second
func update_time():
	countdown_time -= 1
	
	# Play music / game over when time runs out
	if countdown_time <= 30 and countdown_time >10:
		hurry_up_music_1.play()
	elif countdown_time <= 10 and countdown_time > 0:
		hurry_up_music_1.stop()
		hurry_up_music_2.play()
	elif countdown_time < 0:
		hurry_up_music_1.stop()
		hurry_up_music_2.stop()
		countdown_time = 0
		Global.game_over.emit()
		reset_timer()
		
	var minutes = countdown_time / 60
	var seconds = countdown_time % 60
	value.text = "%02d:%02d" % [minutes, seconds]	

# Resets timer when game restarts
func reset_timer():
	countdown_time = 300
	update_time()
	
# Function to stop the timer
func stop_timer():
	stopped_time = countdown_time
	hurry_up_music_1.volume_db = -100
	hurry_up_music_2.volume_db = -100

# Function to resume the timer
func resume_timer():
	countdown_time = stopped_time
	hurry_up_music_1.volume_db = 0
	hurry_up_music_2.volume_db = 0
