extends CenterContainer


func _ready() -> void:
	%PlayButton.grab_focus()


func _on_play_button_pressed() -> void:
	Global.level_path = "res://src/levels/test_gem_level.tscn"
	var error := get_tree().change_scene("res://src/states/game/game.tscn")
	assert(not error)


func _on_credits_button_pressed() -> void:
	var error := get_tree().change_scene("res://src/states/menu/credits_menu.tscn")
	assert(not error)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
