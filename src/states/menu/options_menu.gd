extends CenterContainer


@onready var back_button: Button = %BackButton
@onready var fullscreen_check: CheckButton = %FullscreenCheck
@onready var expand_analog_check: CheckButton = %ExpandAnalogCheck
@onready var fov_slider: HSlider = %FovSlider
@onready var fov_label: Label = %FovLabel


func _ready() -> void:
	back_button.grab_focus()
	fullscreen_check.set_pressed_no_signal(get_tree().get_root().mode == Window.MODE_FULLSCREEN)
	expand_analog_check.set_pressed_no_signal(Global.expand_analog)
	fov_slider.set_value_no_signal(Global.fov)
	fov_label.text = str(Global.fov)


func _process(_delta: float) -> void:
	if fullscreen_check.button_pressed:
		if get_tree().get_root().mode != Window.MODE_FULLSCREEN:
			fullscreen_check.set_pressed_no_signal(false)
	else:
		if get_tree().get_root().mode == Window.MODE_FULLSCREEN:
			fullscreen_check.set_pressed_no_signal(true)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/states/menu/main_menu.tscn")


func _on_fullscreen_check_toggled(button_pressed: bool) -> void:
	if button_pressed:
		get_tree().get_root().mode = Window.MODE_FULLSCREEN
	else:
		get_tree().get_root().mode = Window.MODE_WINDOWED


func _on_expand_analog_check_toggled(button_pressed: bool) -> void:
	Global.expand_analog = button_pressed


func _on_fov_slider_value_changed(value: float) -> void:
	Global.fov = int(value)
	fov_label.text = str(Global.fov)
