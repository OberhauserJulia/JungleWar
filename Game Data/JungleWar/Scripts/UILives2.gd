extends ColorRect

# Node reference
@onready var value = $Container/Value

func _ready():
	Global.lives_2_updated.connect(update_lives_2_count)
	update_lives_2_count()

# Update lives value
func update_lives_2_count():
	value.text = str(Global.lives_2)
	if Global.lives_2 == 0:
		Global.game_over.emit()
