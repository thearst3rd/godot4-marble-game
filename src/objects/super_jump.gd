extends Area3D


@onready var mesh: Node3D = $Mesh


func _process(delta: float) -> void:
	mesh.rotate_y(1.5 * delta)
