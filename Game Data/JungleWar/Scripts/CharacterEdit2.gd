extends Popup

@onready var button_click_sfx = get_node("/root/Main/GameMusic/ButtonClick_SFX")

@export var EyeColorPicker_2: Control
@export var BodyColorPicker_2: Control
@export var BodyDetailPicker1_2: Control
@export var BodyDetailPicker2_2: Control

var eyeColorPopup_2
var bodyColorPopup_2
var body1ColorPopup_2
var body2ColorPopup_2

func _ready():
	call_deferred("deferred_ready")


func deferred_ready():
	EyeColorPicker_2.set_edit_alpha(false)
	BodyColorPicker_2.set_edit_alpha(false)
	BodyDetailPicker1_2.set_edit_alpha(false)
	BodyDetailPicker2_2.set_edit_alpha(false)


func _on_eye_color_picker_picker_created():
	eyeColorPopup_2 = EyeColorPicker_2.get_popup()
	reposition_popup(eyeColorPopup_2)
	
func _on_eye_color_picker_pressed():
	# Music state
	button_click_sfx.play()
	reposition_popup(eyeColorPopup_2)


func _on_body_color_picker_picker_created():
	bodyColorPopup_2 = BodyColorPicker_2.get_popup()
	reposition_popup(bodyColorPopup_2)

	
func _on_body_color_picker_pressed():
	# Music state
	button_click_sfx.play()
	reposition_popup(bodyColorPopup_2)


func _on_body_detail_picker_1_picker_created():
	body1ColorPopup_2 = BodyDetailPicker1_2.get_popup()
	reposition_popup(body1ColorPopup_2)

func _on_body_detail_picker_1_pressed():
	# Music state
	button_click_sfx.play()
	reposition_popup(body1ColorPopup_2)


func _on_body_detail_picker_2_picker_created():
	body2ColorPopup_2 = BodyDetailPicker2_2.get_popup()
	reposition_popup(body2ColorPopup_2)

func _on_body_detail_picker_2_pressed():
	# Music state
	button_click_sfx.play()
	reposition_popup(body2ColorPopup_2)
	
	
func reposition_popup(windowPopup:Node):
	windowPopup.set_position(Vector2i(20,20))
