extends Area3D


func _process(delta) -> void:
	$MeshInstance3D.position.y = 0.1 * sin(Time.get_ticks_msec() / 500.0)
	$MeshInstance3D.rotate_y(1.5 * delta)
