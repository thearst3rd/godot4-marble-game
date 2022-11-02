extends Node


enum State {WARMUP, PLAY, FINISH}

var state: State
var ticks: int

var total_gems := 0
var gems_collected := 0

var num_players := 1
var players: Array[Dictionary] = []

var gem_hunt := false
var gem_hunt_spawns: Array[Node] = []
var gem_hunt_gems: Array[Node] = []
var time_limit_ticks: int


func _ready() -> void:
	var level_scene := load(Global.level_path) as PackedScene
	var level := level_scene.instantiate() as Level

	var start_pad: Node3D
	gem_hunt = level.gem_hunt
	if gem_hunt:
		gem_hunt_spawns = level.find_child("PlayerSpawns").get_children()
		time_limit_ticks = roundi(level.time_limit * Engine.physics_ticks_per_second)
	else:
		start_pad = level.find_child("StartPad")

	for i in range(num_players):
		var viewport_texture: TextureRect = preload("res://src/states/game/game_viewport.tscn").instantiate()
		$Viewports.add_child(viewport_texture)
		var viewport: SubViewport = viewport_texture.get_node("SubViewport")
		if i == 0:
			viewport.add_child(level)
		else:
			viewport.world_3d = players[0].viewport.world_3d

		var marble: RigidBody3D = preload("res://src/objects/marble.tscn").instantiate()
		if gem_hunt:
			var spawn_point := gem_hunt_spawns[randi_range(0, gem_hunt_spawns.size() - 1)] as Marker3D
			marble.position = spawn_point.position
			marble.rotation = spawn_point.rotation
			marble.connect("gem_collected", self._on_marble_gem_collected_hunt.bind(i))
		else:
			marble.position = start_pad.position + Vector3.UP * 4
			if num_players > 1:
				var offset_inc := TAU / num_players
				var offset := Vector3(1.25 * cos(i * offset_inc), 0, 1.25 * sin(i * offset_inc))
				offset = offset.rotated(Vector3.UP, -PI + start_pad.rotation.y)
				marble.position += offset
			marble.rotation = start_pad.rotation
			marble.connect("gem_collected", self._on_marble_gem_collected)
			marble.connect("level_finished", self._on_marble_level_finished)
		marble.freeze = true
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

		var player_dict := {
			"marble": marble,
			"viewport": viewport,
			"camera": camera,
			"gui": gui,
		}
		if gem_hunt:
			player_dict["score"] = 0
		players.append(player_dict)

	ticks = 0
	for player in players:
		player.gui.update_time_display((time_limit_ticks - ticks) if gem_hunt else ticks)

	gems_collected = 0
	if gem_hunt:
		total_gems = -1
		for gem in get_tree().get_nodes_in_group("gem"):
			var global_pos = gem.global_position
			gem.get_parent().remove_child(gem)
			gem.position = global_pos
			gem_hunt_gems.append(gem)
		spawn_gem_cluster()
	else:
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
		if gem_hunt and ticks >= time_limit_ticks:
			state = State.FINISH
			for player in players:
				player.marble.do_finish_effect(player.marble.position)
		for player in players:
			player.gui.update_time_display((time_limit_ticks - ticks) if gem_hunt else ticks)


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


func _on_marble_gem_collected_hunt(index: int, value := 1) -> void:
	var player = players[index]
	player.score += value
	player.gui.update_gem_display(player.score)
	var should_spawn_gems = true
	for gem in get_tree().get_nodes_in_group("gem"):
		if not gem.is_queued_for_deletion():
			should_spawn_gems = false
	if should_spawn_gems:
		spawn_gem_cluster()


func spawn_gem_cluster() -> void:
	var starting_gem = gem_hunt_gems[randi_range(0, gem_hunt_gems.size() - 1)] as Node3D
	add_child(starting_gem.duplicate())
	for gem_raw in gem_hunt_gems:
		var gem = gem_raw as Node3D
		if gem == starting_gem:
			continue
		if gem.position.distance_to(starting_gem.position) <= 5:
			add_child(gem.duplicate())
