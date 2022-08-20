extends Node3D


enum State {WARMUP, PLAY, FINISH}

var state: State
var ticks: int

var total_gems := 0
var gems_collected := 0

@onready var gui: Gui = %Gui


func _ready() -> void:
	ticks = 0
	gui.update_time_display(ticks)

	var level := load(Global.level_path) as PackedScene
	add_child(level.instantiate())
	var start_pad: Node3D = get_tree().get_first_node_in_group("StartPad")

	var marble: RigidDynamicBody3D = preload("res://src/objects/marble.tscn").instantiate()
	marble.position = start_pad.position + Vector3.UP * 4
	marble.rotation = start_pad.rotation
	marble.freeze = true
	marble.connect("level_finished", self._on_marble_level_finished)
	marble.connect("gem_collected", self._on_marble_gem_collected)
	marble.get_node("CenterNode/SpringArm3D/Camera3D").current = true

	gems_collected = 0
	total_gems = get_tree().get_nodes_in_group("gem").size()
	if total_gems > 0:
		for finish in get_tree().get_nodes_in_group("finish"):
			finish.monitorable = false
			finish.get_node("GPUParticles3D").emitting = false
	gui.update_gem_display(gems_collected, total_gems)

	add_child(marble)

	state = State.WARMUP

	gui.update_countdown("Ready...")
	%CountdownTimer.start(1.5)
	await %CountdownTimer.timeout

	state = State.PLAY
	gui.update_countdown("Go!")
	marble.freeze = false

	%CountdownTimer.start(2.0)
	await %CountdownTimer.timeout

	gui.update_countdown("")


func _physics_process(_delta: float) -> void:
	if state == State.PLAY:
		ticks += 1
		gui.update_time_display(ticks)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		%PauseMenu.show_pause_menu()
	elif event.is_action_pressed("restart"):
		get_viewport().set_input_as_handled()
		get_tree().reload_current_scene()


func _on_marble_level_finished() -> void:
	state = State.FINISH


func _on_marble_gem_collected() -> void:
	gems_collected += 1
	gui.update_gem_display(gems_collected, total_gems)
	if gems_collected >= total_gems:
		for finish in get_tree().get_nodes_in_group("finish"):
			finish.set_deferred("monitorable", true)
			finish.get_node("GPUParticles3D").emitting = true
