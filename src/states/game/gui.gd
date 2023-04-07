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
	@warning_ignore("integer_division")
	var minutes := absi(ticks / (60 * Engine.physics_ticks_per_second))
	var non_minute_ticks := ticks % (60 * Engine.physics_ticks_per_second)
	@warning_ignore("integer_division")
	var seconds := absi(non_minute_ticks / Engine.physics_ticks_per_second)
	var non_second_ticks := ticks % Engine.physics_ticks_per_second
	@warning_ignore("integer_division")
	var milliseconds := absi(non_second_ticks * 1000 / Engine.physics_ticks_per_second)
	var neg_sign := "" if ticks >= 0 else "-"
	%TimeDisplay.text = "%s%02d:%02d.%03d" % [neg_sign, minutes, seconds, milliseconds]
