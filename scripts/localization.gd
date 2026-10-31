extends RefCounted

const ENGLISH_CATALOG := "res://localization/en.json"
const EDITED_TRANSLATIONS := "res://localization/overrides_en.json"
const COMPOSITE_PREFIXES := ["Финансы: ", "Страна: ", "Группы: ", "Население: ", "Вооружённые силы: ", "Отношения: ", "Институты: "]

var language := "en"
var catalog: Dictionary = {}
var cache: Dictionary = {}
var templates: Array[Dictionary] = []
var prefixes: Array[String] = []
var format_marker := RegEx.new()


func _init() -> void:
	format_marker.compile("%(?:[-+ 0-9.]*)[dfs]|\\{[a-z_]+\\}")
	var file := FileAccess.open(ENGLISH_CATALOG, FileAccess.READ)
	if file == null:
		push_error("English localization catalog is missing: " + ENGLISH_CATALOG)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		push_error("English localization catalog is invalid")
		return
	catalog = parsed
	var edited_file := FileAccess.open(EDITED_TRANSLATIONS, FileAccess.READ)
	if edited_file != null:
		var edited: Variant = JSON.parse_string(edited_file.get_as_text())
		if edited is Dictionary:
			catalog.merge(edited, true)
	# Event titles and response buttons are often rendered in uppercase.
	for original in catalog.keys():
		var uppercase := str(original).to_upper()
		if uppercase != original and not catalog.has(uppercase):
			catalog[uppercase] = str(catalog[original]).to_upper()
		if str(original).ends_with(": ") and str(original).length() < 48:
			prefixes.append(str(original))
	prefixes.sort_custom(func(a: String, b: String) -> bool: return a.length() > b.length())
	for original in catalog.keys():
		var source_parts := split_format(str(original))
		if source_parts.size() < 2:
			continue
		var target_parts := split_format(str(catalog[original]))
		if target_parts.size() == source_parts.size():
			var markers: Array[String] = []
			for hit in format_marker.search_all(str(original)):
				markers.append(hit.get_string())
			templates.append({"source": source_parts, "target": target_parts, "markers": markers})
	templates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_source: Array = a["source"]
		var b_source: Array = b["source"]
		if str(a_source[0]).length() != str(b_source[0]).length():
			return str(a_source[0]).length() > str(b_source[0]).length()
		var a_literals := 0
		var b_literals := 0
		for part in a_source:
			a_literals += str(part).length()
		for part in b_source:
			b_literals += str(part).length()
		return a_literals > b_literals
	)


func set_language(code: String) -> void:
	language = "ru" if code == "ru" else "en"
	cache.clear()


func text(source: String) -> String:
	if language == "ru" or source.is_empty():
		return source
	if cache.has(source):
		return str(cache[source])
	if catalog.has(source):
		cache[source] = str(catalog[source])
		return str(cache[source])
	if not contains_russian(source):
		return source
	if source.begins_with("• "):
		cache[source] = "• " + text(source.substr(2))
		return str(cache[source])
	for prefix in COMPOSITE_PREFIXES:
		if source.begins_with(prefix):
			cache[source] = text(prefix).rstrip(" ") + " " + text(source.substr(prefix.length()))
			return str(cache[source])
	for item in templates:
		if str((item["source"] as Array)[0]) == "":
			continue
		var rendered := match_template(source, item)
		if rendered != "":
			cache[source] = rendered
			return rendered
	if source.length() > 0 and source[0].is_valid_int():
		for item in templates:
			if str((item["source"] as Array)[0]) != "":
				continue
			var rendered := match_template(source, item)
			if rendered != "":
				cache[source] = rendered
				return rendered
	if source.ends_with("ⓘ"):
		var before_icon := source.trim_suffix("ⓘ").rstrip(" ")
		cache[source] = text(before_icon) + "  ⓘ"
		return str(cache[source])
	if source.contains("\n"):
		var localized_lines: Array[String] = []
		for line in source.split("\n", true):
			localized_lines.append(text(line))
		cache[source] = "\n".join(localized_lines)
		return str(cache[source])
	if source.contains(" • "):
		var separator := source.find(" • ")
		cache[source] = text(source.substr(0, separator)) + " • " + text(source.substr(separator + 3))
		return str(cache[source])
	for prefix in prefixes:
		if source.begins_with(prefix) and source != prefix:
			var english_prefix := str(catalog[prefix]).rstrip(" ") + " "
			cache[source] = english_prefix + text(source.substr(prefix.length()))
			return str(cache[source])
	for sign_separator in [" +", " −", " -"]:
		var sign_position := source.find(sign_separator)
		if sign_position > 0 and sign_position < 64:
			var term := source.substr(0, sign_position)
			if catalog.has(term):
				cache[source] = text(term) + " " + text(source.substr(sign_position + 1))
				return str(cache[source])
	if source.length() > 1 and source[0] in ["+", "−", "-"] and source[1].is_valid_int():
		cache[source] = source[0] + text(source.substr(1))
		return str(cache[source])
	for item in templates:
		if str((item["source"] as Array)[0]) != "":
			continue
		var rendered := match_template(source, item)
		if rendered != "":
			cache[source] = rendered
			return rendered
	cache[source] = source
	return source


func contains_russian(value: String) -> bool:
	for character in value:
		if character.unicode_at(0) >= 0x0400 and character.unicode_at(0) <= 0x052f:
			return true
	return false


func split_format(value: String) -> Array[String]:
	var parts: Array[String] = []
	var offset := 0
	for hit in format_marker.search_all(value):
		parts.append(value.substr(offset, hit.get_start() - offset).replace("%%", "%"))
		offset = hit.get_end()
	parts.append(value.substr(offset).replace("%%", "%"))
	return parts


func match_template(value: String, item: Dictionary) -> String:
	var source: Array = item["source"]
	var target: Array = item["target"]
	var markers: Array = item["markers"]
	# This short connector is useful for names, but must not consume whole
	# sentences or multi-line reports before a more precise template can act.
	if source.size() == 3 and str(source[0]) == "" and str(source[1]) == " и " and str(source[2]) == "":
		if value.length() > 80 or value.contains("\n") or value.contains(":") or value.contains("."):
			return ""
	if source.size() < 2 or not value.begins_with(str(source[0])):
		return ""
	var captures: Array[String] = []
	var cursor := str(source[0]).length()
	for index in range(1, source.size()):
		var suffix := str(source[index])
		var end := value.length() if suffix == "" else value.find(suffix, cursor)
		if end < cursor:
			return ""
		var capture := value.substr(cursor, end - cursor)
		var marker := str(markers[index - 1])
		if marker.ends_with("d") and not capture.is_valid_int():
			return ""
		if marker.ends_with("f") and not capture.is_valid_float():
			return ""
		captures.append(capture)
		cursor = end + suffix.length()
	if cursor != value.length():
		return ""
	var translated := str(target[0])
	for index in range(captures.size()):
		translated += text(captures[index]) + str(target[index + 1])
	return translated
