extends ColorRect


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func show_pause_menu() -> void:
	if visible:
		return
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	%ResumeButton.grab_focus()
	get_tree().paused = true


func hide_pause_menu() -> void:
	if not visible:
		return
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false


func restart_level() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		hide_pause_menu()
	elif event.is_action_pressed("restart"):
		get_viewport().set_input_as_handled()
		restart_level()


func _on_resume_button_pressed() -> void:
	hide_pause_menu()


func _on_restart_button_pressed() -> void:
	restart_level()


func _on_exit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/states/menu/level_select_menu.tscn")
