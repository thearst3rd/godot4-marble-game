extends Area3D


const FLOAT_PERIOD = 500.0

var time_offset: float


func _ready() -> void:
	time_offset = TAU * FLOAT_PERIOD * randf()
	$MeshInstance3D.rotate_y(TAU * randf())


func _process(delta) -> void:
	$MeshInstance3D.position.y = 0.1 * sin((Time.get_ticks_msec() + time_offset) / FLOAT_PERIOD)
	$MeshInstance3D.rotate_y(1.5 * delta)
