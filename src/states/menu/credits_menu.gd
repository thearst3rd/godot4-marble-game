extends Control


const SCROLL_SPEED := 1000.0


var licenses: Array = [
	["Godot Engine", Engine.get_license_text().strip_edges()],
	["Placeholder License", "Here I can put the license of addons I use or something"],
]

var licenses_text := ""
var engine_licenses_text := ""
var showing_engine_licenses := false


@onready var back_button: Button = %BackButton
@onready var licenses_button: Button = %LicensesButton

@onready var licenses_title: Label = %LicensesTitle
@onready var licenses_label: RichTextLabel = %LicensesLabel
@onready var licenses_scroll_bar: VScrollBar = licenses_label.get_v_scroll_bar()


func _ready() -> void:
	back_button.grab_focus()

	# Don't allow up/down to move between back and license buttons, since that will scroll. Right/left will work.
	back_button.focus_neighbor_bottom = back_button.get_path()
	licenses_button.focus_neighbor_top = licenses_button.get_path()

	for license in licenses:
		if not licenses_text.is_empty():
			licenses_text += "\n\n"
		licenses_text += "[center][font_size=20][b]" + license[0] + "[/b][/font_size][/center]\n\n"
		licenses_text += license[1]
	licenses_label.text = licenses_text

	# These engine license/copyright functions are not incredibly obvious how to usefully extract information from.
	# This is similar to how it's done in the "About Godot" -> "Third-party Licenses" -> "All Components" screen
	for info in Engine.get_copyright_info():
		if not engine_licenses_text.is_empty():
			engine_licenses_text += "\n\n"
		engine_licenses_text += "[center][font_size=20][b]" + info.name + "[/b][/font_size][/center]\n"
		#engine_licenses_text += str(info.parts)
		for part in info.parts:
			for copyright in part.copyright:
				engine_licenses_text += "\n(c) " + copyright
			engine_licenses_text += "\nLicense: " + part.license

	var engine_licenses := Engine.get_license_info()
	for license in engine_licenses:
		engine_licenses_text += "\n\n[center][font_size=20][b]" + license + "[/b][/font_size][/center]\n\n"
		engine_licenses_text += engine_licenses[license]



func _process(delta: float) -> void:
	var scroll_amount := Input.get_axis("ui_up", "ui_down")
	licenses_scroll_bar.value += scroll_amount * delta * SCROLL_SPEED


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/states/menu/main_menu.tscn")


func _on_licenses_button_pressed() -> void:
	licenses_scroll_bar.value = 0
	if showing_engine_licenses:
		licenses_title.text = "Licences"
		licenses_label.text = licenses_text
		licenses_button.text = licenses_button.text.replace("Hide", "View")
		showing_engine_licenses = false
	else:
		licenses_title.text = "Third-party Components and Licenses"
		licenses_label.text = engine_licenses_text
		licenses_button.text = licenses_button.text.replace("View", "Hide")
		showing_engine_licenses = true
