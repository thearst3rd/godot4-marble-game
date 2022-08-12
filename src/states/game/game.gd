extends Node3D


var state: String
var ticks: int


func _ready() -> void:
	ticks = 0
	update_timer()

	var level := load(Global.level_path) as PackedScene
	add_child(level.instantiate())
	var start_pad: Node3D = get_tree().get_first_node_in_group("StartPad")

	var marble: RigidDynamicBody3D = preload("res://src/objects/marble.tscn").instantiate()
	marble.position = start_pad.position + Vector3.UP * 4
	marble.rotation = start_pad.rotation
	add_child(marble)


func _physics_process(_delta: float) -> void:
	ticks += 1
	update_timer()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		%PauseMenu.show_pause_menu()
	elif event.is_action_pressed("restart"):
		get_viewport().set_input_as_handled()
		get_tree().reload_current_scene()


func update_timer() -> void:
	@warning_ignore(integer_division)
	var minutes := ticks / (60 * Engine.physics_ticks_per_second)
	var non_minute_ticks := ticks % (60 * Engine.physics_ticks_per_second)
	@warning_ignore(integer_division)
	var seconds := non_minute_ticks / Engine.physics_ticks_per_second
	var non_second_ticks := ticks % Engine.physics_ticks_per_second
	@warning_ignore(integer_division)
	var milliseconds := non_second_ticks * 1000 / Engine.physics_ticks_per_second
	%TimerDisplay.text = "%02d:%02d.%03d" % [minutes, seconds, milliseconds]
