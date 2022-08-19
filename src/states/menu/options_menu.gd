extends CenterContainer


@onready var back_button: Button = %BackButton
@onready var fullscreen_check: CheckButton = %FullscreenCheck


func _ready() -> void:
	back_button.grab_focus()
	fullscreen_check.set_pressed_no_signal(get_tree().get_root().mode == Window.MODE_FULLSCREEN)


func _process(_delta: float) -> void:
	if fullscreen_check.button_pressed:
		if get_tree().get_root().mode != Window.MODE_FULLSCREEN:
			fullscreen_check.set_pressed_no_signal(false)
	else:
		if get_tree().get_root().mode == Window.MODE_FULLSCREEN:
			fullscreen_check.set_pressed_no_signal(true)


func _on_back_button_pressed() -> void:
	var error := get_tree().change_scene("res://src/states/menu/main_menu.tscn")
	assert(not error)


func _on_fullscreen_check_toggled(button_pressed: bool) -> void:
	if button_pressed:
		get_tree().get_root().mode = Window.MODE_FULLSCREEN
	else:
		get_tree().get_root().mode = Window.MODE_WINDOWED
