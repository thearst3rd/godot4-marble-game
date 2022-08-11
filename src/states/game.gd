extends Node3D


var state: String

var timer: float


func _ready() -> void:
	var level := load(Global.level_path) as PackedScene
	add_child(level.instantiate())
	timer = 0.0
	update_timer()


func _physics_process(delta: float) -> void:
	timer += delta
	update_timer()


func update_timer() -> void:
	var minutes := floor(timer / 60.0)
	var non_minutes := fmod(timer, 60.0)
	var seconds := floor(non_minutes)
	var non_seconds = fmod(non_minutes, 1.0)
	var milliseconds = floor(non_seconds * 1000)
	%TimerDisplay.text = "%02d:%02d:%03d" % [minutes, seconds, milliseconds]
