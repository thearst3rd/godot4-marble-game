extends Control


@onready var play_button: Button = %PlayButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	if OS.has_feature("web"):
		quit_button.hide()
	play_button.grab_focus()


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/states/menu/level_select_menu.tscn")


func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/states/menu/options_menu.tscn")


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/states/menu/credits_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().get_root().propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
