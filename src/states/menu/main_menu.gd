extends Control


func _ready() -> void:
	%PlayButton.grab_focus()


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/states/menu/level_select_menu.tscn")


func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/states/menu/options_menu.tscn")


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/states/menu/credits_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
