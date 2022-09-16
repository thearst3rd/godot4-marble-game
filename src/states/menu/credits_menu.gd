extends Control


const SCROLL_SPEED := 1000.0

@onready var licenses_scroll_bar := (%LicensesText as RichTextLabel).get_v_scroll_bar()


func _ready() -> void:
	%BackButton.grab_focus()


func _process(delta: float) -> void:
	licenses_scroll_bar.value += Input.get_axis("ui_up", "ui_down") * delta * SCROLL_SPEED


func _on_back_button_pressed() -> void:
	var error := get_tree().change_scene_to_file("res://src/states/menu/main_menu.tscn")
	assert(not error)
