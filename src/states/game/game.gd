extends Node3D


enum State {WARMUP, PLAY, FINISH}

var state: State
var ticks: int

var total_gems := 0
var gems_collected := 0


func _ready() -> void:
	ticks = 0
	update_time_display()

	var level := load(Global.level_path) as PackedScene
	add_child(level.instantiate())
	var start_pad: Node3D = get_tree().get_first_node_in_group("StartPad")

	var marble: RigidDynamicBody3D = preload("res://src/objects/marble.tscn").instantiate()
	marble.position = start_pad.position + Vector3.UP * 4
	marble.rotation = start_pad.rotation
	marble.freeze = true
	marble.connect("level_finished", self._on_marble_level_finished)
	marble.connect("gem_collected", self._on_marble_gem_collected)

	gems_collected = 0
	total_gems = get_tree().get_nodes_in_group("gem").size()
	if total_gems <= 0:
		%GemDisplay.hide()
	else:
		for finish in get_tree().get_nodes_in_group("finish"):
			finish.monitorable = false
			finish.get_node("GPUParticles3D").emitting = false
		update_gem_display()

	add_child(marble)

	state = State.WARMUP

	%CountdownTimer.start(1.5)
	await %CountdownTimer.timeout

	state = State.PLAY
	%Countdown.text = "Go!"
	marble.freeze = false

	%CountdownTimer.start(2.0)
	await %CountdownTimer.timeout

	%Countdown.hide()


func _physics_process(_delta: float) -> void:
	if state == State.PLAY:
		ticks += 1
		update_time_display()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		%PauseMenu.show_pause_menu()
	elif event.is_action_pressed("restart"):
		get_viewport().set_input_as_handled()
		get_tree().reload_current_scene()


func update_time_display() -> void:
	@warning_ignore(integer_division)
	var minutes := ticks / (60 * Engine.physics_ticks_per_second)
	var non_minute_ticks := ticks % (60 * Engine.physics_ticks_per_second)
	@warning_ignore(integer_division)
	var seconds := non_minute_ticks / Engine.physics_ticks_per_second
	var non_second_ticks := ticks % Engine.physics_ticks_per_second
	@warning_ignore(integer_division)
	var milliseconds := non_second_ticks * 1000 / Engine.physics_ticks_per_second
	%TimeDisplay.text = "%02d:%02d.%03d" % [minutes, seconds, milliseconds]


func update_gem_display() -> void:
	%GemDisplay.text = "%d / %d" % [gems_collected, total_gems]


func _on_marble_level_finished() -> void:
	state = State.FINISH


func _on_marble_gem_collected() -> void:
	gems_collected += 1
	update_gem_display()
	if gems_collected >= total_gems:
		for finish in get_tree().get_nodes_in_group("finish"):
			finish.set_deferred("monitorable", true)
			finish.get_node("GPUParticles3D").emitting = true
