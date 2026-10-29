extends SceneTree

var untranslated_count := 0


func _initialize() -> void:
	call_deferred("audit")


func audit() -> void:
	var game: Variant = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.language_code = "en"
	game.game_localization.set_language("en")
	game.show_start_screen()
	game.localize_visible_tree()
	check_screen("main_menu", game.screen_layer)
	game.show_new_game_menu()
	check_screen("new_game", game.overlay)
	game.close_overlay(false)
	game.show_settings()
	check_screen("settings", game.overlay)
	game.close_overlay(false)
	game.start_game("Без сохранений", 1991)
	game.localize_visible_tree()
	check_screen("first_report", game.screen_layer)
	game.show_prologue()
	check_screen("prologue", game.overlay)
	game.close_overlay(false)
	game.show_weekly_report()
	check_screen("weekly_report", game.overlay)
	game.close_overlay(false)
	for screen in ["show_economy", "show_clans", "show_army", "show_ministers", "show_foreign_policy", "show_law_selection", "show_guide"]:
		game.call(screen)
		check_screen(screen, game.overlay)
		game.close_overlay(false)
	quit(1 if untranslated_count > 0 else 0)


func check_screen(name: String, node: Node) -> void:
	var untranslated: Array[String] = []
	var untranslated_tooltips: Array[String] = []
	for child in node.find_children("*", "Control", true, false):
		if not child.is_visible_in_tree():
			continue
		if child is Label or child is BaseButton:
			var visible_text := str(child.get("text"))
			if has_russian(visible_text):
				untranslated.append(visible_text.replace("\n", " ").substr(0, 110))
		if has_russian(child.tooltip_text):
			untranslated_tooltips.append(child.tooltip_text.replace("\n", " ").substr(0, 1800))
	print("LOCALIZATION_UI_AUDIT ", name, " untranslated=", untranslated.size())
	untranslated_count += untranslated.size() + untranslated_tooltips.size()
	for item in untranslated.slice(0, 12):
		print("  ", item)
	print("LOCALIZATION_TOOLTIP_AUDIT ", name, " untranslated=", untranslated_tooltips.size())
	for item in untranslated_tooltips.slice(0, 8):
		print("  ", item)


func has_russian(value: String) -> bool:
	for character in value:
		if character.unicode_at(0) >= 0x0400 and character.unicode_at(0) <= 0x052f:
			return true
	return false
