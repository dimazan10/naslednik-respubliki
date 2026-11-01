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
	check_event_catalog(game)
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
	for labor_unrest in [false, true]:
		for unrest_level in range(1, 4):
			game.state.active_unrest_level = unrest_level
			game.state.active_unrest_labor = labor_unrest
			game.state.active_unrest_cause = "Счета к оплате"
			game.update_interface()
			game.show_economy()
			var unrest_screen := "strike_" if labor_unrest else "protest_"
			check_screen(unrest_screen + str(unrest_level), game.overlay)
			check_screen(unrest_screen + str(unrest_level) + "_sidebar", game.screen_layer)
			game.close_overlay(false)
	game.state.active_unrest_level = 0
	game.state.active_unrest_labor = false
	game.state.active_unrest_cause = ""
	game.update_interface()
	game.state.recruitment_model = "contract"
	game.show_army()
	check_screen("contract_army", game.overlay)
	game.close_overlay(false)
	game.show_recruitment_confirmation("contract")
	check_screen("contract_confirmation", game.overlay)
	game.close_overlay(false)
	game.state.recruitment_model = "mobilization"
	game.state.at_war = true
	game.state.war_enemy = "east"
	game.state.army_mobilized_personnel = 20000
	game.show_army()
	check_screen("mobilization_army", game.overlay)
	game.close_overlay(false)
	game.show_economy()
	check_screen("mobilization_economy", game.overlay)
	game.close_overlay(false)
	game.budget_draft["budget_health"] = 0
	game.budget_draft["budget_debt"] = 0
	game.show_economy()
	check_screen("budget_draft", game.overlay)
	for budget_key in ["budget_health", "budget_debt"]:
		var card: Control = game.overlay.find_child("BudgetIcon_" + budget_key, true, false)
		var card_text := ""
		if card != null:
			for card_label in card.find_children("*", "Label", true, false):
				card_text += " " + str(card_label.text)
		if not card_text.contains("STANDARD  →  REDUCED") or not card_text.contains("M / WEEK"):
			untranslated_count += 1
			push_error("BUDGET_CARD_TRANSLATION %s: %s" % [budget_key, card_text])
	game.close_overlay(false)
	game.show_budget_level_selector("budget_health")
	check_screen("budget_level_selector", game.overlay)
	game.close_overlay(false)
	var forecast: Dictionary = game.parliament_vote_forecast("budget")
	var vote_message := "%d за, %d против. Новые уровни бюджета зафиксированы; денежный расчёт и реакция групп произойдут при переходе к следующей неделе.\n\nОбразование и медицина: базовый → сокращённый" % [int(forecast.get("yes", 0)), int(forecast.get("no", 0))]
	game.show_parliament_vote_result("ПОПРАВКА ПРИНЯТА", vote_message, str(forecast.get("detail", "")), "economy")
	check_screen("budget_vote_result", game.overlay)
	game.close_overlay(false)
	game.show_parliament_vote_result("ПОПРАВКА ОТКЛОНЕНА", "%d за, %d против. Действующий бюджет не изменился; черновик можно исправить и внести снова." % [33, 87], "", "economy")
	check_screen("budget_vote_rejected", game.overlay)
	game.close_overlay(false)
	game.show_parliament_vote_result("ПОПРАВКА ВВЕДЕНА УКАЗОМ", "Парламентское голосование не проводилось. Новые уровни бюджета зафиксированы чрезвычайным указом; денежный расчёт и реакция групп произойдут при переходе к следующей неделе.\n\nОбразование и медицина: базовый → сокращённый", "", "economy")
	check_screen("budget_vote_decree", game.overlay)
	game.close_overlay(false)
	game.start_game("Сид: 1991", 1991)
	game.choose_option("left")
	await create_timer(0.25).timeout
	check_screen("first_decision_result", game.overlay)
	game.close_overlay(false)
	game.start_game("Без сохранений", 1991)
	game.state.week = 18
	game.state.election_rules_shown = false
	game.state.authoritarian = 0
	game.current_event = game.build_next_election_milestone_event()
	game.event_resolved = false
	game.display_current_event(false, false)
	await process_frame
	check_screen("election_rules_open", game.screen_layer)
	check_choice_bounds("election_rules_open", game)
	game.state.authoritarian = 3
	game.display_current_event(false, false)
	await process_frame
	check_screen("election_rules_hard", game.screen_layer)
	check_choice_bounds("election_rules_hard", game)
	game.state.week = 26
	game.state.election_rules = "fair"
	game.current_event = game.election_event_template()
	game.customize_event_for_ministers()
	game.display_current_event(false, false)
	await process_frame
	check_screen("election_final_hard", game.screen_layer)
	check_choice_bounds("election_final_hard", game)
	game.state.authoritarian = 0
	game.state.election_rules = "managed"
	game.current_event = game.election_event_template()
	game.customize_event_for_ministers()
	game.display_current_event(false, false)
	await process_frame
	check_screen("election_final_recount", game.screen_layer)
	check_choice_bounds("election_final_recount", game)
	game.start_game("Без сохранений", 1991)
	for report in game.recurring_events:
		if not report.has("body_en") or not report.has("title_en"):
			continue
		game.current_event = report
		game.event_resolved = false
		game.display_current_event(false, false)
		check_screen("routine_" + str(report.get("_family", "")), game.screen_layer)
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


func check_choice_bounds(name: String, game: Node) -> void:
	var viewport_size: Vector2 = game.get_viewport().get_visible_rect().size
	for node in [game.left_button, game.right_button, game.third_button, game.left_hint, game.right_hint, game.third_hint]:
		if not node.visible:
			continue
		var bounds: Rect2 = node.get_global_rect()
		if bounds.position.x < 0 or bounds.position.y < 0 or bounds.end.x > viewport_size.x or bounds.end.y > viewport_size.y:
			untranslated_count += 1
			push_error("ELECTION_LAYOUT: %s / %s outside viewport %s" % [name, node.name, viewport_size])


func check_event_catalog(game: Node) -> void:
	var untranslated: Array[String] = []
	var all_events: Array = []
	all_events.append_array(game.recurring_events)
	all_events.append_array(game.event_queue)
	all_events.append_array(game.recurring_event_queue)
	all_events.append_array(game.weekly_event_queue)
	all_events.append(game.current_event)
	for event_data in all_events:
		if not event_data is Dictionary:
			continue
		if event_data.has("body_en") and event_data.has("_family"):
			var old_save: Dictionary = event_data.duplicate(true)
			old_save.erase("body_en")
			old_save.erase("title_en")
			var upgraded: Dictionary = game.normalize_event_population_effects(old_save)
			if str(upgraded.get("body_en", "")) != str(event_data.get("body_en", "")) or str(upgraded.get("title_en", "")) != str(event_data.get("title_en", "")):
				untranslated.append(str(event_data.get("title", "")) + " / old save migration lost its English context")
		for field in ["source", "title", "body"]:
			var text_value := str(event_data.get(field, ""))
			var displayed := str(event_data.get(field + "_en", game.game_localization.text(text_value)))
			if has_russian(displayed):
				untranslated.append(str(event_data.get("title", "")) + " / " + field + ": " + text_value.substr(0, 100))
		for side in ["left", "right", "third"]:
			var option_data: Dictionary = event_data.get(side, {})
			for field in ["label", "hint", "result"]:
				var text_value := str(option_data.get(field, ""))
				if has_russian(game.game_localization.text(text_value)):
					untranslated.append(str(event_data.get("title", "")) + " / " + side + "." + field + ": " + text_value.substr(0, 100))
	print("LOCALIZATION_EVENT_AUDIT untranslated=", untranslated.size())
	untranslated_count += untranslated.size()
	for item in untranslated.slice(0, 30):
		print("  ", item)


func has_russian(value: String) -> bool:
	for character in value:
		if character.unicode_at(0) >= 0x0400 and character.unicode_at(0) <= 0x052f:
			return true
	return false
