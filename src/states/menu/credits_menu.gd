extends Control


func _ready() -> void:
	%BackButton.grab_focus()


func _on_back_button_pressed() -> void:
	var error := get_tree().change_scene("res://src/states/menu/main_menu.tscn")
	assert(not error)
