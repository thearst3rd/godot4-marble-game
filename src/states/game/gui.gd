class_name Gui
extends Control


func update_countdown(string: String) -> void:
	if string.is_empty():
		%CountdownDisplay.hide()
		return
	%CountdownDisplay.text = string
	%CountdownDisplay.show()


func update_gem_display(gems_collected: int, total_gems: int) -> void:
	if total_gems <= 0:
		%GemDisplay.hide()
		return
	%GemDisplay.text = "%d / %d" % [gems_collected, total_gems]


func update_time_display(ticks: int) -> void:
	@warning_ignore(integer_division)
	var minutes := ticks / (60 * Engine.physics_ticks_per_second)
	var non_minute_ticks := ticks % (60 * Engine.physics_ticks_per_second)
	@warning_ignore(integer_division)
	var seconds := non_minute_ticks / Engine.physics_ticks_per_second
	var non_second_ticks := ticks % Engine.physics_ticks_per_second
	@warning_ignore(integer_division)
	var milliseconds := non_second_ticks * 1000 / Engine.physics_ticks_per_second
	%TimeDisplay.text = "%02d:%02d.%03d" % [minutes, seconds, milliseconds]
