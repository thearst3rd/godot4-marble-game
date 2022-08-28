extends Node


signal mouse_moved(Vector2)

var level_path: String

var expand_analog := true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		get_viewport().set_input_as_handled()
		var window := get_tree().get_root()
		if window.mode == Window.MODE_FULLSCREEN:
			window.mode = Window.MODE_WINDOWED
		else:
			window.mode = Window.MODE_FULLSCREEN


func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		var window := get_viewport() as Window
		window.set_input_as_handled()
		var relative := (event as InputEventMouseMotion).relative

		# Because of the canvas_items scaling mode, the game "scales" our mouse input to match the current window size.
		# That means if you make the window bigger, your mouse inputs will be relatively smaller. We don't want this,
		# since that doesn't make sense for 3D mouse look. So here, we "un-scale" it back to normal
		var scale := minf(
				float(window.size.x) / float(window.content_scale_size.x),
				float(window.size.y) / float(window.content_scale_size.y)
		)
		relative *= scale
		# Correct any rounding error
		relative.x = round(relative.x)
		relative.y = round(relative.y)

		emit_signal("mouse_moved", relative)
