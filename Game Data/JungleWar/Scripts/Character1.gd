extends AnimatedSprite2D

@onready var PlayerColorSingelton = get_node("/root/NewColorsPlayer1")

var toggleInt := 1

func _ready():
	play("default")


func _on_eye_color_picker_color_changed(color):
	material.set_shader_parameter("newColorEyes", color)
	PlayerColorSingelton.EyeColor = color


func _on_body_color_picker_color_changed(color):
	material.set_shader_parameter("newColorBody", color)
	PlayerColorSingelton.BodyColor = color


func _on_body_detail_picker_1_color_changed(color):
	material.set_shader_parameter("newColor1", color)
	PlayerColorSingelton.BodyDetail1 = color


func _on_body_detail_picker_2_color_changed(color):
	material.set_shader_parameter("newColor2", color)
	PlayerColorSingelton.BodyDetail2 = color

func _on_toggle_color_body_details_button_toggled(button_pressed):
	material.set_shader_parameter("onlyPickMainColor",int(not button_pressed))
