extends Node3D


enum State {WARMUP, PLAY, FINISH}

var state: State
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
	marble.freeze = true
	marble.connect("level_finished", self._on_marble_level_finished)
	add_child(marble)

	state = State.WARMUP

	await get_tree().create_timer(1.5).timeout

	state = State.PLAY
	%Countdown.text = "Go!"
	marble.freeze = false

	await get_tree().create_timer(2.0).timeout

	%Countdown.hide()


func _physics_process(_delta: float) -> void:
	if state == State.PLAY:
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


func _on_marble_level_finished() -> void:
	state = State.FINISH
