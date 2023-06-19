class_name Gui
extends Control


func update_countdown(string: String) -> void:
	if string.is_empty():
		%CountdownDisplay.hide()
		return
	%CountdownDisplay.text = string
	%CountdownDisplay.show()


func update_gem_display(gems_collected: int, total_gems: int = -1) -> void:
	if gems_collected <= 0 and total_gems == 0:
		%GemDisplay.hide()
		return
	if total_gems <= 0: # For gem hunt
		%GemDisplay.text = "%d" % [gems_collected]
	else:
		%GemDisplay.text = "%d / %d" % [gems_collected, total_gems]


func update_time_display(ticks: int) -> void:
	var neg_sign := ""
	if ticks < 0:
		neg_sign = "-"
		ticks = -ticks
	var minutes: int
	var seconds: int
	var milliseconds: int
	if 1000 % Engine.physics_ticks_per_second != 0:
		# Keep this case around in case I change the tickrate. I want it to have an integer number of milliseconds per
		# tick (125 tps) but maybe I'll change that
		@warning_ignore("integer_division")
		minutes = ticks / (60 * Engine.physics_ticks_per_second)
		var non_minute_ticks := ticks % (60 * Engine.physics_ticks_per_second)
		@warning_ignore("integer_division")
		seconds = non_minute_ticks / Engine.physics_ticks_per_second
		var non_second_ticks := ticks % Engine.physics_ticks_per_second
		@warning_ignore("integer_division")
		milliseconds = non_second_ticks * 1000 / Engine.physics_ticks_per_second
	else:
		@warning_ignore("integer_division")
		var total_milliseconds: int = ticks * (1000 / Engine.physics_ticks_per_second)
		#total_milliseconds += floor(1000.0 * Engine.get_physics_interpolation_fraction() / float(Engine.physics_ticks_per_second))
		milliseconds = total_milliseconds % 1000
		@warning_ignore("integer_division")
		seconds = (total_milliseconds / 1000) % 60
		@warning_ignore("integer_division")
		minutes = (total_milliseconds / (60 * 1000))

	%TimeDisplay.text = "%s%02d:%02d.%03d" % [neg_sign, minutes, seconds, milliseconds]
