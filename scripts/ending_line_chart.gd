extends Control

var values: Array[float] = []
var stroke := Color("#536f82")
var unit := ""
var start_week := 0
var end_week := 0


func configure(points: Array, color: Color, value_unit: String, first_week: int, last_week: int) -> void:
	values.clear()
	for point in points:
		values.append(float(point))
	stroke = color
	unit = value_unit
	start_week = first_week
	end_week = last_week
	queue_redraw()


func _draw() -> void:
	var bounds := Rect2(Vector2(48, 12), Vector2(maxf(10.0, size.x - 64.0), maxf(10.0, size.y - 38.0)))
	var ink := Color("#69645b")
	for step in range(4):
		var y := bounds.position.y + bounds.size.y * float(step) / 3.0
		draw_line(Vector2(bounds.position.x, y), Vector2(bounds.end.x, y), Color("#d7cebc"), 1.0)
	if values.is_empty():
		return
	var bottom := values[0]
	var top := values[0]
	for value in values:
		bottom = minf(bottom, value)
		top = maxf(top, value)
	if is_equal_approx(bottom, top):
		bottom -= 1.0
		top += 1.0
	var font := ThemeDB.fallback_font
	var font_size := 12
	var axis_format := "%.2f%s" if top - bottom < 5.0 else "%.0f%s"
	draw_string(font, Vector2(2, bounds.position.y + 5), axis_format % [top, unit], HORIZONTAL_ALIGNMENT_LEFT, 44, font_size, ink)
	draw_string(font, Vector2(2, bounds.end.y), axis_format % [bottom, unit], HORIZONTAL_ALIGNMENT_LEFT, 44, font_size, ink)
	draw_string(font, Vector2(bounds.position.x, size.y - 3), "%d" % start_week, HORIZONTAL_ALIGNMENT_LEFT, 60, font_size, ink)
	draw_string(font, Vector2(bounds.end.x - 34, size.y - 3), "%d" % end_week, HORIZONTAL_ALIGNMENT_RIGHT, 34, font_size, ink)
	var points := PackedVector2Array()
	for index in range(values.size()):
		var x := bounds.position.x + bounds.size.x * float(index) / float(maxi(1, values.size() - 1))
		var y := bounds.end.y - (values[index] - bottom) / (top - bottom) * bounds.size.y
		points.append(Vector2(x, y))
	if points.size() > 1:
		draw_polyline(points, stroke, 3.0, true)
	for index in [0, points.size() - 1]:
		draw_circle(points[index], 4.0, stroke)
