extends Node


enum State {WARMUP, PLAY, FINISH}

var state: State
var ticks: int

var total_gems := 0
var gems_collected := 0

var num_players := 1
var players: Array[Dictionary] = []


func _ready() -> void:
	var level_scene := load(Global.level_path) as PackedScene
	var level := level_scene.instantiate() as Node3D
	var start_pad: Node3D = level.find_child("StartPad")

	for i in range(num_players):
		var viewport_texture: TextureRect = preload("res://src/states/game/game_viewport.tscn").instantiate()
		$Viewports.add_child(viewport_texture)
		var viewport: SubViewport = viewport_texture.get_node("SubViewport")
		if i == 0:
			viewport.add_child(level)
		else:
			viewport.world_3d = players[0].viewport.world_3d

		var marble: RigidBody3D = preload("res://src/objects/marble.tscn").instantiate()
		marble.position = start_pad.position + Vector3.UP * 4
		if num_players > 1:
			var offset_inc := TAU / num_players
			var offset := Vector3(1.25 * cos(i * offset_inc), 0, 1.25 * sin(i * offset_inc))
			offset = offset.rotated(Vector3.UP, -PI + start_pad.rotation.y)
			marble.position += offset
		marble.rotation = start_pad.rotation
		marble.freeze = true
		marble.connect("level_finished", self._on_marble_level_finished)
		marble.connect("gem_collected", self._on_marble_gem_collected)
		level.add_child(marble)

		if num_players > 1:
			var controller := PlayerController.new()
			controller.uses_all_devices = false
			controller.which_device = i - 1

			marble.set_player_controller(controller)

		var camera: Camera3D = viewport.get_node("Camera3D")
		marble.find_child("CameraRemoteTransform").remote_path = camera.get_path()
		camera.fov += 20 * (num_players - 1)

		var gui: Gui = viewport_texture.get_node("Gui")

		players.append({
			"marble": marble,
			"viewport": viewport,
			"camera": camera,
			"gui": gui,
		})

	ticks = 0
	for player in players:
		player.gui.update_time_display(ticks)

	gems_collected = 0
	total_gems = get_tree().get_nodes_in_group("gem").size()
	if total_gems > 0:
		for finish in get_tree().get_nodes_in_group("finish"):
			finish.monitorable = false
	for player in players:
		player.gui.update_gem_display(gems_collected, total_gems)

	state = State.WARMUP

	for player in players:
		player.gui.update_countdown("Ready...")
	%CountdownTimer.start(1.5)
	await %CountdownTimer.timeout

	state = State.PLAY
	for player in players:
		player.gui.update_countdown("Go!")
		player.marble.freeze = false

	%CountdownTimer.start(2.0)
	await %CountdownTimer.timeout

	for player in players:
		player.gui.update_countdown("")


func _physics_process(_delta: float) -> void:
	if state == State.PLAY:
		ticks += 1
		for player in players:
			player.gui.update_time_display(ticks)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		%PauseMenu.show_pause_menu()
	elif event.is_action_pressed("restart") or event.is_action_pressed("restart_controller"):
		get_viewport().set_input_as_handled()
		get_tree().reload_current_scene()


func _on_marble_level_finished() -> void:
	state = State.FINISH


func _on_marble_gem_collected() -> void:
	gems_collected += 1
	for player in players:
		player.gui.update_gem_display(gems_collected, total_gems)
	if gems_collected >= total_gems:
		for finish in get_tree().get_nodes_in_group("finish"):
			finish.set_deferred("monitorable", true)
