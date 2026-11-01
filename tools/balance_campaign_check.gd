extends SceneTree

var game: Control


func _initialize() -> void:
	call_deferred("run_checks")


func run_checks() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var style := "cautious"
	var first_seed := 1
	var last_seed := 20
	for arg in OS.get_cmdline_user_args():
		if str(arg).begins_with("--style="):
			style = str(arg).trim_prefix("--style=")
		elif str(arg).begins_with("--first-seed="):
			first_seed = str(arg).trim_prefix("--first-seed=").to_int()
		elif str(arg).begins_with("--last-seed="):
			last_seed = str(arg).trim_prefix("--last-seed=").to_int()
	if "--mechanics" in OS.get_cmdline_user_args():
		var mechanics_errors := check_edge_mechanics()
		print("BALANCE_MECHANICS: %d/4 passed" % [4 - mechanics_errors])
		quit(0 if mechanics_errors == 0 else 1)
		return
	if "--recruitment" in OS.get_cmdline_user_args():
		var recruitment_errors := check_recruitment_balance()
		quit(0 if recruitment_errors == 0 else 1)
		return
	if "--armistice" in OS.get_cmdline_user_args():
		var prepared_result := play_campaign(19, "prepared_armistice")
		var reachable := bool(prepared_result.get("armistice", false)) and int(prepared_result.get("forecast_errors", 0)) == 0
		print("ARMISTICE_CAMPAIGN: %s" % ("reachable" if reachable else "failed"))
		quit(0 if reachable else 1)
		return
	if "--tutorial-campaign" in OS.get_cmdline_user_args():
		var guided_result := play_campaign(1991, "tutorial")
		var completed := int(guided_result.get("week", 0)) == 27 and int(guided_result.get("forecast_errors", 0)) == 0
		print("TUTORIAL_CAMPAIGN: %s" % ("completed" if completed else "failed"))
		quit(0 if completed else 1)
		return
	if "--coverage" in OS.get_cmdline_user_args():
		var fixtures := [
			["КАПИТУЛЯЦИЯ", 1, "surrender"],
			["ДЕФОЛТ", 1, "cautious"],
			["СВЕРЖЕНИЕ", 5, "legacy"],
			["ВОЕННЫЙ ПЕРЕВОРОТ", 2, "cautious"],
			["РАСКОЛ", 9, "west"],
			["ИЗБРАННЫЙ ПРЕЗИДЕНТ", 12, "fair"],
			["МИРНАЯ ПЕРЕДАЧА ВЛАСТИ", 5, "fair"],
			["АППАРАТ НЕ СПАС", 5, "cautious"],
			["УПРАВЛЯЕМАЯ ПОБЕДА", 11, "cautious"],
			["ВЫБОРЫ БЕЗ ПРИЗНАНИЯ", 8, "cautious"],
			["ПОБЕДА ПО ПРОТОКОЛУ", 19, "rigged"],
			["ИЗБИРАТЕЛЬНЫЙ КРИЗИС", 8, "rigged"],
			["ОТЛОЖЕННЫЙ МАНДАТ", 23, "postponed_good"],
			["ПРОСРОЧЕННЫЙ МАНДАТ", 19, "postponed_bad"],
			["ДОСРОЧНЫЕ ВЫБОРЫ", 5, "unresolved"],
			["ВОСТОЧНЫЙ КУРС", 8, "east"],
			["ЗАПАДНЫЙ КУРС", 8, "west"],
			["ХРУПКИЙ НЕЙТРАЛИТЕТ", 8, "neutral"],
			["НАСЛЕДСТВО ОТЦА", 11, "legacy"]
		]
		var failures := 0
		for fixture in fixtures:
			var result := play_campaign(int(fixture[1]), str(fixture[2]))
			if str(result.get("ending", "")) != str(fixture[0]) or int(result.get("forecast_errors", 0)) > 0:
				failures += 1
				push_error("ENDING_COVERAGE: expected=%s actual=%s seed=%d style=%s forecast_errors=%d" % [str(fixture[0]), str(result.get("ending", "")), int(fixture[1]), str(fixture[2]), int(result.get("forecast_errors", 0))])
		print("ENDING_COVERAGE: %d/%d full campaigns passed" % [fixtures.size() - failures, fixtures.size()])
		quit(0 if failures == 0 else 1)
		return
	for seed in range(first_seed, last_seed + 1):
		play_campaign(seed, style)
	quit()


func check_edge_mechanics() -> int:
	var failures := 0
	game.start_game("Без сохранений", 19)
	var preview_state: Dictionary = game.state.duplicate(true)
	var law_preview: String = game.law_weekly_money_preview("Антикоррупционное бюро")
	if not law_preview.contains("недельный баланс") or game.state != preview_state:
		failures += 1
		push_error("MECHANICS: law cash preview changed game state or omitted effect")
	game.start_game("Без сохранений", 19)
	game.state.budget_debt = 2
	var old_debt := float(game.state.get("debt", 0.0))
	var due_interest := maxf(0.5, snappedf(old_debt * game.debt_weekly_interest_rate(), 0.01))
	var payment: float = game.debt_service_amount()
	game.process_weekly_budget_consequences(1)
	var actual_principal := old_debt - float(game.state.get("debt", 0.0))
	if absf(actual_principal - maxf(0.0, payment - due_interest)) > 0.011:
		failures += 1
		push_error("MECHANICS: debt principal exceeded payment after interest")
	game.start_game("Без сохранений", 19)
	game.state.at_war = true
	game.state.war_enemy = "east"
	game.state.war_weeks = 6
	game.state.east_relation = 0
	game.state.war_armistice_signed = false
	game.state.foreign_action_week = 0
	game.state.narin_crisis_channel_armed = false
	game.state.narin_crisis_delay_weeks = 0
	if bool(game.armistice_readiness().get("ready", false)):
		failures += 1
		push_error("MECHANICS: untouched army can sign armistice")
	game.state.army_personnel = 75000
	game.state.army_equipment = 550
	game.state.army_aircraft = 12
	game.state.war_support = 80
	game.state.army = 80
	game.state.oil_to_army = game.current_oil_output()
	var ready_snapshot: Dictionary = game.state.duplicate(true)
	if not bool(game.armistice_readiness().get("ready", false)) or game.state != ready_snapshot:
		failures += 1
		push_error("MECHANICS: prepared army cannot sign armistice or forecast mutated game state")
	else:
		game.state.war_weeks = 5
		var early_ready := bool(game.armistice_readiness().get("ready", false))
		game.state = ready_snapshot.duplicate(true)
		game.state.army_equipment = 200
		var poorly_equipped_ready := bool(game.armistice_readiness().get("ready", false))
		game.state = ready_snapshot.duplicate(true)
		game.state.oil_to_army = 0
		var unsupplied_ready := bool(game.armistice_readiness().get("ready", false))
		game.state = ready_snapshot.duplicate(true)
		game.state.recruitment_model = "contract"
		# A high-quality small force passes today's troop threshold but loses it
		# during the five-week forecast when no replacements are available.
		game.state.army_personnel = 46000
		game.state.population_workable = 0
		game.state.contract_volunteer_pool = 0
		var fragile_ready := bool(game.armistice_readiness().get("ready", false))
		game.state = ready_snapshot.duplicate(true)
		if early_ready or poorly_equipped_ready or unsupplied_ready or fragile_ready:
			failures += 1
			push_error("MECHANICS: armistice ignored duration, equipment, supply or five-week endurance: %s/%s/%s/%s" % [early_ready, poorly_equipped_ready, unsupplied_ready, fragile_ready])
		game.perform_foreign_action("east", "armistice")
		game.resolve_pending_week_changes()
		if bool(game.state.get("at_war", true)) or not bool(game.state.get("war_armistice_signed", false)) or int(game.state.get("east_relation", 0)) != 1:
			failures += 1
			push_error("MECHANICS: armistice did not end the war")
	game.state.east_relation = 0
	var guarded_week := int(game.state.get("war_ceasefire_until_week", 0))
	game.state.week = guarded_week
	game.start_invasion_if_needed()
	if bool(game.state.get("at_war", false)):
		failures += 1
		push_error("MECHANICS: ceasefire failed to protect the border")
	game.state.week = guarded_week + 1
	game.start_invasion_if_needed()
	if not bool(game.state.get("at_war", false)):
		failures += 1
		push_error("MECHANICS: hostile border remained protected after ceasefire expired")
	return failures


func check_recruitment_balance() -> int:
	var outcomes: Dictionary = {}
	for later_model in ["mixed", "mobilization"]:
		game.start_game("Без сохранений", 19)
		game.state.at_war = true
		game.state.war_enemy = "east"
		game.state.war_support = 65
		game.state.recruitment_model = "contract"
		game.state.metal_to_equipment = 0
		game.state.budget_defense = 0
		var short_war: Dictionary = {}
		var preserved_core: Dictionary = {}
		for war_week in range(1, 13):
			if war_week == 7:
				game.set_recruitment_model(later_model)
				game.resolve_pending_week_changes()
				if later_model == "mobilization":
					preserved_core = {"training": game.army_training(), "rate": float(game.state.get("mobilization_core_rate", 0.0))}
			game.process_army_recruitment()
			game.process_military_production()
			var battle: Dictionary = game.process_war_week(true)
			game.apply_effects(battle.get("political_effects", {}))
			if war_week == 6:
				short_war = {"readiness": game.army_effectiveness(), "volunteers": int(game.state.contract_volunteer_pool)}
			game.state.week = int(game.state.get("week", 1)) + 1
		outcomes[later_model] = {
			"short_war": short_war,
			"readiness": game.army_effectiveness(),
			"personnel": int(game.state.army_personnel),
			"war_support": int(game.state.war_support),
			"target": game.recruitment_target(),
			"balance": game.weekly_actual_income() - game.weekly_actual_expenses(),
			"mobilized": int(game.state.army_mobilized_personnel),
			"preserved_core": preserved_core,
			"training": game.army_training()
		}
	var contract_six: Dictionary = outcomes["mixed"]["short_war"]
	var mixed_twelve: Dictionary = outcomes["mixed"]
	var mobilized_twelve: Dictionary = outcomes["mobilization"]
	var preserved_core: Dictionary = mobilized_twelve["preserved_core"]
	var valid := int(contract_six["readiness"]) >= 65 and int(contract_six["volunteers"]) <= 1000 and int(mobilized_twelve["readiness"]) > int(mixed_twelve["readiness"]) and int(mobilized_twelve["personnel"]) < 100000 and int(mobilized_twelve["target"]) < 100000 and int(mobilized_twelve["war_support"]) < int(mixed_twelve["war_support"]) and float(mobilized_twelve["balance"]) < float(mixed_twelve["balance"]) - 0.2 and int(preserved_core.get("training", 0)) == 75 and is_equal_approx(float(preserved_core.get("rate", 0.0)), 0.026) and int(mobilized_twelve["training"]) > 40
	game.start_game("Без сохранений", 19)
	game.state.recruitment_model = "contract"
	game.state.war_support = 80
	var high_support_contract_target: int = game.recruitment_target()
	game.state.war_support = 20
	var low_support_contract_target: int = game.recruitment_target()
	valid = valid and high_support_contract_target > low_support_contract_target
	game.start_game("Без сохранений", 19)
	var support_before: int = int(game.state.support)
	game.set_recruitment_model("contract")
	game.resolve_pending_week_changes()
	valid = valid and int(game.state.support) - support_before == 2
	game.recruitment_changed_this_week = false
	game.state.influence = 3
	game.state.media_restricted = true
	game.set_recruitment_model("mixed")
	game.resolve_pending_week_changes()
	valid = valid and int(game.state.support) == support_before
	game.recruitment_changed_this_week = false
	game.state.influence = 3
	game.set_recruitment_model("contract")
	game.resolve_pending_week_changes()
	valid = valid and int(game.state.support) == support_before + 2
	game.recruitment_changed_this_week = false
	game.state.influence = 3
	game.set_recruitment_model("contract")
	game.resolve_pending_week_changes()
	valid = valid and int(game.state.support) == support_before + 2 and int(game.state.influence) == 3
	game.recruitment_changed_this_week = false
	game.state.influence = 3
	game.state.at_war = true
	game.state.media_restricted = false
	var stability_before: int = int(game.state.stability)
	game.set_recruitment_model("mobilization")
	game.resolve_pending_week_changes()
	valid = valid and int(game.state.stability) == stability_before - 2 and int(game.state.support) == support_before - 5
	game.start_game("Без сохранений", 19)
	game.state.at_war = true
	game.apply_effects({"army_personnel": 25000, "population_workable": -25000})
	game.apply_state_flags({"recruitment_model": "mobilization", "mobilization_event_recruits": 25000})
	valid = valid and int(game.state.army_mobilized_personnel) == 25000 and int(game.state.mobilization_core_training) == 60 and is_equal_approx(float(game.state.mobilization_core_rate), 0.014)
	game.start_game("Без сохранений", 19)
	game.state.at_war = true
	game.current_event = game.build_war_crisis_event()
	game.choose_option("left")
	var mixed_event_support: int = int((game.pending_week_changes.back() as Dictionary).get("effects", {}).get("support", 0))
	game.start_game("Без сохранений", 19)
	game.state.at_war = true
	game.state.recruitment_model = "contract"
	game.current_event = game.build_war_crisis_event()
	game.choose_option("left")
	var contract_event_support: int = int((game.pending_week_changes.back() as Dictionary).get("effects", {}).get("support", 0))
	valid = valid and contract_event_support == mixed_event_support - 2
	print("RECRUITMENT_BALANCE: %s | contract week 6: %d%%, volunteers %d | mixed week 12: %d%%, war support %d, balance %.2f | late mobilization week 12: %d%%, troops %d, mobilized %d, target %d, war support %d, balance %.2f" % ["OK" if valid else "FAIL", int(contract_six["readiness"]), int(contract_six["volunteers"]), int(mixed_twelve["readiness"]), int(mixed_twelve["war_support"]), float(mixed_twelve["balance"]), int(mobilized_twelve["readiness"]), int(mobilized_twelve["personnel"]), int(mobilized_twelve["mobilized"]), int(mobilized_twelve["target"]), int(mobilized_twelve["war_support"]), float(mobilized_twelve["balance"])])
	return 0 if valid else 1


func choose_report_side(report: Dictionary, style: String) -> String:
	if str(report.get("title", "")) == "Счета к оплате" and style == "optimize_credit":
		return "right"
	if str(report.get("title", "")) == "Условия кредитной линии" and style == "optimize_credit":
		return "left"
	if str(report.get("title", "")) == "Кто будет считать":
		return available_report_side(report, "left" if style in ["fair", "fair_loss", "fair_win"] else "right")
	if str(report.get("title", "")) == "Досрочные выборы":
		var preferred := "third" if style in ["rigged", "rigged_crisis", "rigged_protocol", "postponed", "postponed_good", "postponed_bad"] and report.has("third") else "right" if style in ["managed", "managed_loss", "managed_win", "unrecognized"] else "left"
		return available_report_side(report, preferred)
	var best: String = game.adaptive_side(report)
	var best_score := -100000.0
	for side in ["left", "right", "third"]:
		if not report.has(side) or bool((report[side] as Dictionary).get("unavailable", false)):
			continue
		var option: Dictionary = report[side]
		var flags: Dictionary = option.get("set", {})
		var effects: Dictionary = game.amplify_decision_effects(option.get("effects", {}), str(report.get("_kind", "general")))
		var east: int = game.projected_pending_value("east_relation") + int(effects.get("east_relation", 0))
		var west: int = game.projected_pending_value("west_relation") + int(effects.get("west_relation", 0))
		var score := 0.0
		var postponed_war_window := style in ["postponed", "postponed_good", "postponed_bad"] and int(game.state.get("week", 1)) >= 20
		if not bool(game.state.get("at_war", false)) and style != "surrender" and not postponed_war_window and (style not in ["armistice", "prepared_armistice"] or bool(game.state.get("war_armistice_signed", false)) or (style == "prepared_armistice" and int(game.state.get("week", 1)) < 12)):
			if east <= 0 or west <= 0:
				score -= 1000.0
			elif east <= 1 and west <= 1:
				score -= 150.0
			elif east <= 1 or west <= 1:
				score -= 30.0
		var money: float = game.adjusted_money_transaction(float(effects.get("money", 0.0)), game.projected_corruption_tier())
		var cash: float = game.projected_pending_float("money")
		score += money * (5.0 if cash < 25.0 else 2.0)
		score += float(effects.get("support", 0)) * (3.0 if int(game.state.get("support", 0)) < 35 else 1.0)
		score += float(effects.get("stability", 0)) * (2.5 if int(game.state.get("stability", 0)) < 35 else 1.0)
		score += float(effects.get("army", 0)) * 0.5
		if bool(game.state.get("at_war", false)):
			score += float(effects.get("war_support", 0)) * 3.0
			if style == "prepared_armistice":
				score += float(effects.get("army_equipment", 0)) * 2.0 + float(effects.get("army_aircraft", 0)) * 8.0 + float(effects.get("army_personnel", 0)) * 0.002
		if style in ["overthrow", "fair_loss", "managed_loss"]:
			score -= float(effects.get("support", 0)) * (5.0 if style == "overthrow" else 1.0)
		if style == "overthrow" and int(game.state.get("support", 0)) <= 15:
				score += float(effects.get("stability", 0)) * 3.0
		if style == "split":
			score -= float(effects.get("stability", 0)) * 7.0
		if style == "coup":
			score -= float(effects.get("army", 0)) * 7.0
		if style == "surrender":
			score -= float(effects.get("war_support", 0)) * (8.0 if bool(game.state.get("at_war", false)) else 0.2)
			if not bool(game.state.get("at_war", false)):
				score -= float(effects.get("east_relation", 0)) * 35.0
				score -= float(effects.get("west_relation", 0)) * 35.0
		if style in ["armistice", "prepared_armistice"] and not bool(game.state.get("at_war", false)) and not bool(game.state.get("war_armistice_signed", false)) and (style == "armistice" or int(game.state.get("week", 1)) >= 12):
			score -= float(effects.get("east_relation", 0)) * 35.0
			score -= float(effects.get("west_relation", 0)) * 35.0
		if postponed_war_window and not bool(game.state.get("at_war", false)):
			score -= float(effects.get("east_relation", 0) + effects.get("west_relation", 0)) * 100.0
			if east <= 0 or west <= 0:
				score += 500.0
		if style == "east":
			score += float(effects.get("east_relation", 0)) * 20.0
		if style == "west":
			score += float(effects.get("west_relation", 0)) * 20.0
		if style == "legacy":
			score += float(effects.get("authoritarian", 0)) * 15.0
		if style == "postponed_good":
			if int(game.state.get("war_support", 0)) < 45:
				score += float(effects.get("war_support", 0)) * 2.0
			if int(game.state.get("support", 0)) < 55:
				score += float(effects.get("support", 0)) * 1.5
			if int(game.state.get("stability", 0)) < 45:
				score += float(effects.get("stability", 0)) * 1.5
		if (style == "postponed_bad" or (style == "postponed_good" and not game.law_enacted("Чрезвычайные полномочия"))) and int(game.state.get("week", 1)) >= 10 and int(game.state.get("stability", 0)) > 60:
			score -= float(effects.get("stability", 0)) * 8.0
		if style in ["postponed", "postponed_good", "postponed_bad"] and bool(flags.get("emergency_powers_repealed", false)):
			score -= 1000.0
		if style == "postponed_bad":
			if int(game.state.get("week", 1)) >= 16 and int(game.state.get("support", 0)) > 43:
				score -= float(effects.get("support", 0)) * 6.0
			elif int(game.state.get("support", 0)) < 30:
				score += float(effects.get("support", 0)) * 5.0
		if side == best:
			score += 5.0
		if score > best_score:
			best_score = score
			best = side
	return best


func available_report_side(report: Dictionary, preferred: String) -> String:
	if report.has(preferred) and not bool((report[preferred] as Dictionary).get("unavailable", false)):
		return preferred
	for side in ["left", "right", "third"]:
		if report.has(side) and not bool((report[side] as Dictionary).get("unavailable", false)):
			return side
	return preferred


func configure_week(style: String) -> void:
	var week := int(game.state.get("week", 1))
	if week == 1:
		var cuts := ["budget_social", "budget_infrastructure", "budget_defense"]
		if style == "coup":
			cuts = ["budget_defense", "budget_admin", "budget_infrastructure"]
		elif style == "split":
			cuts = ["budget_health", "budget_infrastructure", "budget_admin"]
		elif style == "overthrow":
			cuts = ["budget_social", "budget_admin", "budget_infrastructure"]
		elif style in ["surrender", "armistice"]:
			cuts = ["budget_social", "budget_admin", "budget_infrastructure"]
		elif style == "prepared_armistice":
			cuts = ["budget_social", "budget_admin", "budget_infrastructure", "budget_debt"]
		elif style == "postponed_good":
			cuts = ["budget_social", "budget_defense", "budget_infrastructure"]
		elif style in ["postponed", "postponed_bad"]:
			cuts = ["budget_social", "budget_health", "budget_infrastructure"]
		for key in cuts:
			game.budget_draft[key] = 0
		game.submit_budget_amendment()
	if style == "surrender" and bool(game.state.get("at_war", false)) and str(game.state.get("recruitment_model", "mixed")) != "mobilization" and int(game.state.get("influence", 0)) > 0:
		game.set_recruitment_model("mobilization")
	if style in ["armistice", "prepared_armistice"] and bool(game.armistice_readiness().get("ready", false)) and not game.foreign_action_used_this_week() and int(game.state.get("influence", 0)) > 0:
		print("ARMISTICE_READY seed=%d week=%d war_weeks=%d money=%.2f effectiveness=%d equipment=%d personnel=%d support=%d" % [int(game.state.get("campaign_seed", 0)), week, int(game.state.get("war_weeks", 0)), float(game.state.get("money", 0.0)), game.army_effectiveness(), int(game.state.get("army_equipment", 0)), int(game.state.get("army_personnel", 0)), int(game.state.get("war_support", 0))])
		game.perform_foreign_action(str(game.state.get("war_enemy", "east")), "armistice")
	if style == "prepared_armistice":
		var target_oil: int = mini(game.army_oil_need(), game.current_oil_output()) if bool(game.state.get("at_war", false)) else 4
		while int(game.state.get("oil_to_army", 0)) != target_oil:
			game.change_resource_allocation("oil_to_army", 1 if int(game.state.get("oil_to_army", 0)) < target_oil else -1)
		var target_metal: int = game.current_metal_output() if bool(game.state.get("at_war", false)) or week >= 9 else 2
		while int(game.state.get("metal_to_equipment", 0)) != target_metal:
			game.change_resource_allocation("metal_to_equipment", 1 if int(game.state.get("metal_to_equipment", 0)) < target_metal else -1)
	if style in ["reform", "optimize", "optimize_credit", "prepared_armistice"] and week == 2 and game.active_law == "" and not game.law_enacted("Антикоррупционное бюро") and int(game.state.get("influence", 0)) >= 2:
		game.begin_law("Антикоррупционное бюро", 3, 2)
	if style in ["optimize", "optimize_credit", "east", "postponed_good"]:
		var target_oil: int = game.army_oil_need() if bool(game.state.get("at_war", false)) else ceili(float(game.army_oil_need()) * 0.55)
		target_oil = mini(target_oil, game.current_oil_output())
		while int(game.state.get("oil_to_army", 0)) != target_oil:
			game.change_resource_allocation("oil_to_army", 1 if int(game.state.get("oil_to_army", 0)) < target_oil else -1)
		var target_metal := 2 if bool(game.state.get("at_war", false)) else 0
		while int(game.state.get("metal_to_equipment", 0)) != target_metal:
			game.change_resource_allocation("metal_to_equipment", 1 if int(game.state.get("metal_to_equipment", 0)) < target_metal else -1)
		if int(game.state.get("army", 0)) <= 40 and int(game.state.get("budget_defense", 1)) == 0:
			game.budget_draft["budget_defense"] = 1
			game.submit_budget_amendment()
	if str(game.selected_ministers.get("foreign", "")) == "narin" and not game.foreign_action_used_this_week() and int(game.state.get("influence", 0)) > 0 and not bool(game.state.get("at_war", false)) and not (style in ["postponed", "postponed_good", "postponed_bad"] and week >= 22):
		var weaker := "east" if game.projected_pending_value("east_relation") < game.projected_pending_value("west_relation") else "west"
		if game.projected_pending_value(weaker + "_relation") == 1 and game.projected_pending_value(("west" if weaker == "east" else "east") + "_relation") >= 3:
			game.perform_foreign_action(weaker, "mission")
	if style in ["east", "west"] and week >= 16 and week < 20 and str(game.selected_ministers.get("foreign", "")) == "narin" and not game.foreign_action_used_this_week() and game.projected_pending_value(style + "_relation") == 2:
		game.perform_foreign_action(style, "mission")
	if style == "legacy" and bool(game.state.get("at_war", false)) and int(game.state.get("authoritarian", 0)) < 1 and game.active_law == "" and game.emergency_powers_lock_reason() == "":
		game.begin_law("Чрезвычайные полномочия", 2, 1)
	if style in ["postponed", "postponed_good", "postponed_bad"]:
		if bool(game.state.get("at_war", false)) and not game.law_enacted("Чрезвычайные полномочия") and game.active_law == "" and game.emergency_powers_lock_reason() == "":
			game.begin_law("Чрезвычайные полномочия", 2, 1)
	if week >= 20 and style in ["east", "west", "neutral", "legacy", "unresolved"] and game.final_course_available(style):
		game.perform_final_course_action(style)


func play_campaign(seed: int, style: String) -> Dictionary:
	game.start_game("Обучение" if style == "tutorial" else "Без сохранений", seed)
	var configured := 0
	var reports := 0
	var forecast_errors := 0
	var trace := ""
	while int(game.state.get("week", 1)) <= game.DEMO_WEEKS and str(game.state.get("last_ending_title", "")) == "" and reports < 150:
		var week := int(game.state.get("week", 1))
		if configured != week:
			configured = week
			configure_week(style)
		var report: Dictionary = game.current_event
		if report.is_empty():
			break
		var side := choose_report_side(report, style)
		var picked: Dictionary = report[side]
		var original_effects: Dictionary = game.option_effects_for_current_ministers(picked)
		var effects: Dictionary = game.amplify_decision_effects(original_effects, str(report.get("_kind", "general")))
		var flags: Dictionary = (picked.get("set", {}) as Dictionary).duplicate(true)
		var free_foreign_appointment := str(flags.get("free_foreign_appointment", ""))
		if free_foreign_appointment != "":
			game.apply_free_foreign_appointment(free_foreign_appointment)
			flags.erase("free_foreign_appointment")
		game.queue_week_change("Проверка: " + str(report.get("title", "")), effects, flags)
		game.event_resolved = true
		game.events_resolved_this_week += 1
		reports += 1
		if game.week_ready_for_new_week():
			var predicted: float = game.weekly_balance_forecast()
			game.advance_week()
			var actual := float(game.state.get("money", 0.0))
			if absf(predicted - actual) > 0.011:
				forecast_errors += 1
				trace += " w%d %.2f>%.2f" % [week, predicted, actual]
		else:
			game.next_event(false, false)
	print("CAMPAIGN seed=%d style=%s week=%d ending=%s money=%.2f support=%d stability=%d war=%s armistice=%s crisis=%s printed=%s foreign=%s relations=%d/%d course=%s forecast_errors=%d%s" % [seed, style, int(game.state.get("week", 0)), str(game.state.get("last_ending_title", "")), float(game.state.get("money", 0.0)), int(game.state.get("support", 0)), int(game.state.get("stability", 0)), str(game.state.get("at_war", false)), str(game.state.get("war_armistice_signed", false)), str(game.state.get("financial_crisis_shown", false)), str(game.state.get("printed_money", false)), str(game.selected_ministers.get("foreign", "")), int(game.state.get("east_relation", 0)), int(game.state.get("west_relation", 0)), str(game.state.get("final_alignment", "")), forecast_errors, trace])
	return {"ending": str(game.state.get("last_ending_title", "")), "forecast_errors": forecast_errors, "week": int(game.state.get("week", 0)), "armistice": bool(game.state.get("war_armistice_signed", false))}
