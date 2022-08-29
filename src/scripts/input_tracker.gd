extends Node
# This feels so messy...


signal mouse_moved(Vector2)

var actions: Dictionary


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(-1, 4):
		actions[i] = {
			"forward": 0.0,
			"backward": 0.0,
			"left": 0.0,
			"right": 0.0,
			"camera_up": 0.0,
			"camera_down": 0.0,
			"camera_left": 0.0,
			"camera_right": 0.0,
			"restart": false,
			"jump": false,
			"powerup": false,
		}


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
	else:
		for device in actions.keys():
			if event.is_echo():
				continue
			if event.device != maxi(device, 0):
				continue
			var d_actions: Dictionary = actions[device]
			for action in d_actions:
				var real_action = action
				if device > -1:
					real_action += "_controller"
				if action in ["restart", "jump", "powerup"]:
					if event.is_action(real_action):
						get_viewport().set_input_as_handled()
						d_actions[action] = event.is_action_pressed(real_action)
				else:	# must be an axis
					if event.is_action(real_action):
						get_viewport().set_input_as_handled()
						d_actions[action] = event.get_action_strength(real_action)
