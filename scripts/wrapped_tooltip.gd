extends Control

const MAX_WIDTH := 520.0
const MIN_WIDTH := 170.0
const FONT_SIZE := 16


func _make_custom_tooltip(for_text: String) -> Object:
	if for_text.is_empty():
		return null
	var available_width := maxf(MIN_WIDTH, get_viewport_rect().size.x - 64.0)
	var maximum_width := minf(MAX_WIDTH, available_width)
	var longest_line := 0.0
	var font := get_theme_default_font()
	if font != null:
		for line in for_text.split("\n"):
			longest_line = maxf(longest_line, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x)
	var tooltip_width := clampf(longest_line + 8.0, MIN_WIDTH, maximum_width)
	var message := Label.new()
	message.text = for_text
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.custom_minimum_size.x = tooltip_width
	message.custom_maximum_size.x = tooltip_width
	message.add_theme_font_size_override("font_size", FONT_SIZE)
	message.add_theme_color_override("font_color", Color("#eee6d7"))
	message.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
	message.add_theme_constant_override("shadow_offset_x", 1)
	message.add_theme_constant_override("shadow_offset_y", 1)
	return message
