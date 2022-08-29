class_name PlayerController
extends Node


signal mouse_moved(Vector2)

@export var uses_all_devices := true
@export var which_device := -1	#-1 means mouse and keyboard


func _init() -> void:
	InputTracker.connect("mouse_moved", self._on_mouse_moved)


func get_action(action: String) -> bool:
	if uses_all_devices:
		for i in range(-1, 4):
			if InputTracker.actions[i][action]:
				return true
		return false
	return InputTracker.actions[which_device][action]


func get_axis(axis: String) -> float:
	if uses_all_devices:
		var axis_value := 0.0
		for i in range(-1, 4):
			var device_value: float = InputTracker.actions[i][axis]
			if device_value > axis_value:
				axis_value = device_value
		return axis_value
	return InputTracker.actions[which_device][axis]


func get_vector(x_neg, x_pos, y_neg, y_pos) -> Vector2:
	return Vector2(get_axis(x_pos) - get_axis(x_neg), get_axis(y_pos) - get_axis(y_neg))


func get_move_direction() -> Vector2:
	return get_vector("left", "right", "forward", "backward")


func get_camera_direction() -> Vector2:
	return get_vector("camera_left", "camera_right", "camera_up", "camera_down")


func _on_mouse_moved(relative) -> void:
	if uses_all_devices or which_device == -1:
		emit_signal("mouse_moved", relative)
