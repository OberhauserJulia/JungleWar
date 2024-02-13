extends AnimatedSprite2D

@onready var PlayerColorSingelton = get_node("/root/NewColorsPlayer1")

var toggleInt := 1

func _ready():
	if PlayerColorSingelton.EyeColor:
		material.set_shader_parameter("newColorEyes", PlayerColorSingelton.EyeColor)
	if PlayerColorSingelton.BodyColor:
		material.set_shader_parameter("newColorBody", PlayerColorSingelton.BodyColor)
	if PlayerColorSingelton.BodyDetail1:
		material.set_shader_parameter("newColor1", PlayerColorSingelton.BodyDetail1)
	if PlayerColorSingelton.BodyDetail2:
		material.set_shader_parameter("newColor2", PlayerColorSingelton.BodyDetail2)


func _on_toggle_color_body_details_button_toggled(button_pressed):
	material.set_shader_parameter("onlyPickMainColor",int(not button_pressed))
