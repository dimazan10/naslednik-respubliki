extends Control

const MAX_WIDTH := 520.0
const MIN_WIDTH := 220.0
const FONT_SIZE := 16
const HORIZONTAL_PADDING := 14.0


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
	var tooltip_width := clampf(longest_line + HORIZONTAL_PADDING * 2.0, MIN_WIDTH, maximum_width)
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = tooltip_width
	var background := StyleBoxFlat.new()
	background.bg_color = Color("#1b2229")
	background.border_color = Color("#b7a47e")
	background.border_width_left = 1
	background.border_width_top = 1
	background.border_width_right = 1
	background.border_width_bottom = 1
	background.corner_radius_top_left = 7
	background.corner_radius_top_right = 7
	background.corner_radius_bottom_left = 7
	background.corner_radius_bottom_right = 7
	background.content_margin_left = HORIZONTAL_PADDING
	background.content_margin_right = HORIZONTAL_PADDING
	background.content_margin_top = 12
	background.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", background)
	var message := Label.new()
	message.text = for_text
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.custom_minimum_size.x = tooltip_width - HORIZONTAL_PADDING * 2.0
	message.add_theme_font_size_override("font_size", FONT_SIZE)
	message.add_theme_color_override("font_color", Color("#eee6d7"))
	message.add_theme_constant_override("line_spacing", 3)
	panel.add_child(message)
	return panel
