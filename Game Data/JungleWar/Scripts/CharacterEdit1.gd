extends Popup

@onready var button_click_sfx = get_node("/root/Main/GameMusic/ButtonClick_SFX")


@export var EyeColorPicker_1: Control
@export var BodyColorPicker_1: Control
@export var BodyDetailPicker1_1: Control
@export var BodyDetailPicker2_1: Control

var eyeColorPopup_1
var bodyColorPopup_1
var body1ColorPopup_1
var body2ColorPopup_1

func _ready():
	call_deferred("deferred_ready")


func deferred_ready():
	EyeColorPicker_1.set_edit_alpha(false)
	BodyColorPicker_1.set_edit_alpha(false)
	BodyDetailPicker1_1.set_edit_alpha(false)
	BodyDetailPicker2_1.set_edit_alpha(false)


func _on_eye_color_picker_picker_created():
	eyeColorPopup_1 = EyeColorPicker_1.get_popup()
	reposition_popup(eyeColorPopup_1)
	
func _on_eye_color_picker_pressed():
	# Music state
	button_click_sfx.play()
	reposition_popup(eyeColorPopup_1)


func _on_body_color_picker_picker_created():
	bodyColorPopup_1 = BodyColorPicker_1.get_popup()
	reposition_popup(bodyColorPopup_1)

	
func _on_body_color_picker_pressed():
	# Music state
	button_click_sfx.play()
	reposition_popup(bodyColorPopup_1)


func _on_body_detail_picker_1_picker_created():
	body1ColorPopup_1 = BodyDetailPicker1_1.get_popup()
	reposition_popup(body1ColorPopup_1)

func _on_body_detail_picker_1_pressed():
	# Music state
	button_click_sfx.play()
	reposition_popup(body1ColorPopup_1)


func _on_body_detail_picker_2_picker_created():
	body2ColorPopup_1 = BodyDetailPicker2_1.get_popup()
	reposition_popup(body2ColorPopup_1)

func _on_body_detail_picker_2_pressed():
	# Music state
	button_click_sfx.play()
	reposition_popup(body2ColorPopup_1)
	
	
func reposition_popup(windowPopup:Node):
	windowPopup.set_position(Vector2i(20,20))
