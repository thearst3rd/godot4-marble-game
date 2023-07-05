extends TextureRect


@onready var camera: Camera3D = %Camera3D


func _ready() -> void:
	# Do this here instead of in the scene to prevent debugger errors
	texture = ($SubViewport as SubViewport).get_texture()

	camera.fov = Global.fov

	set_viewport_size()
	get_viewport().connect("size_changed", self.set_viewport_size)


func set_viewport_size() -> void:
	var new_size := (get_viewport() as Window).size
	new_size.x /= get_parent().owner.num_players

	$SubViewport.size = new_size
