extends CenterContainer


# TODO put this somewhere else probably
const LEVELS = [
	"res://src/levels/test_level.tscn",
	"res://src/levels/test_gem_level.tscn",
]


@onready var level_buttons := %LevelButtons as VBoxContainer


func _ready() -> void:
	for level_path in LEVELS:
		var button := Button.new()
		button.text = level_path
		button.connect("pressed", self.play_level.bind(level_path))
		level_buttons.add_child(button)


func play_level(path: String) -> void:
	Global.level_path = path
	var error := get_tree().change_scene_to_file("res://src/states/game/game.tscn")
	assert(not error)


func back_to_menu() -> void:
	var error := get_tree().change_scene_to_file("res://src/states/menu/main_menu.tscn")
	assert(not error)
