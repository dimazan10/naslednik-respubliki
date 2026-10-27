extends SceneTree


func _initialize() -> void:
	for name in ["characters", "characters_preview"]:
		var source_path := "res://assets/portraits/%s.svg" % name
		var image := Image.new()
		var error := image.load_svg_from_string(FileAccess.get_file_as_string(source_path))
		if error != OK:
			push_error("Не удалось открыть %s: %s" % [source_path, error_string(error)])
			quit(1)
			return
		error = image.save_png("res://assets/portraits/%s.png" % name)
		if error != OK:
			push_error("Не удалось записать PNG: %s" % error_string(error))
			quit(1)
			return
	quit(0)
