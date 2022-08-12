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


func _physics_process(delta: float) -> void:
	ticks += 1
	update_timer()


func get_time() -> float:
	return float(ticks) / float(Engine.physics_ticks_per_second)


func update_timer() -> void:
	var timer := get_time()
	var minutes := floori(timer / 60.0)
	var non_minutes := fmod(timer, 60.0)
	var seconds := floori(non_minutes)
	var non_seconds := fmod(non_minutes, 1.0)
	var milliseconds := floori(non_seconds * 1000)
	%TimerDisplay.text = "%02d:%02d:%03d" % [minutes, seconds, milliseconds]
