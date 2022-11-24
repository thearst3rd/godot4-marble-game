extends CenterContainer


# TODO put this somewhere else probably
const LEVELS = [
	"res://src/levels/test_level.tscn",
	"res://src/levels/test_gem_level.tscn",
	"res://src/levels/test_hunt_level.tscn",
]


@onready var level_buttons := %LevelButtons as VBoxContainer


func _ready() -> void:
	for level_path in LEVELS:
		var level_scene := load(level_path) as PackedScene
		var state := level_scene.get_state()
		var level_name = null
		for prop_index in state.get_node_property_count(0):
			if state.get_node_property_name(0, prop_index) == "level_name":
				level_name = state.get_node_property_value(0, prop_index)
				break
		if level_name == null:
			level_name = level_path
		var button := Button.new()
		button.text = level_name
		button.connect("pressed", self.play_level.bind(level_path))
		level_buttons.add_child(button)


func play_level(path: String) -> void:
	Global.level_path = path
	get_tree().change_scene_to_file("res://src/states/game/game.tscn")


func back_to_menu() -> void:
	get_tree().change_scene_to_file("res://src/states/menu/main_menu.tscn")
