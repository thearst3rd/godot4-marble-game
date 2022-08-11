extends CenterContainer


func _on_play_button_pressed() -> void:
	Global.level_path = "res://src/levels/test_level.tscn"
	var error := get_tree().change_scene("res://src/states/game.tscn")
	assert(not error)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
