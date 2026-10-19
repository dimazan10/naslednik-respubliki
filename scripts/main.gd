extends Control

const INK := Color("#17191c")
const PAPER := Color("#e8dfcb")
const CREAM := Color("#f4eddd")
const GOLD := Color("#c7a96b")
const RED := Color("#a9473f")
const BLUE := Color("#536f82")
const PENDING_BLUE := Color("#58a9d1")
const GREEN := Color("#668269")
const MUTED := Color("#8c887d")
const CORRUPTION_LABELS := ["минимальная", "низкая", "средняя", "повсеместная", "парализующая"]
const CORRUPTION_TRANSACTION_RATES := [2, 5, 10, 20, 35]
const CREDITOR_OBLIGATION_LABELS := ["нет", "ограниченные условия", "обязательные условия", "внешний надзор"]
const CREDITOR_OVERSIGHT_COSTS := [0.0, 0.20, 0.45, 0.80]
const EMISSION_SHOCK_WEEKS := 6
const CREDITOR_BUDGET_LOCK_WEEKS := 4
const CREDITOR_AUSTERITY_TARGETS := ["budget_social", "budget_health", "budget_admin", "budget_defense", "budget_infrastructure"]
const CLAN_LOW_SUPPORT := 40
const CLAN_HIGH_SUPPORT := 60
const CLAN_CRITICAL_LOW_SUPPORT := 20
const CLAN_CRITICAL_HIGH_SUPPORT := 80
const WAR_SUPPORT_LOW := 30
const WAR_SUPPORT_HIGH := 65
const WAR_SUPPORT_CRITICAL_HIGH := 80
const WAR_PRESSURE_INTERVAL := 2
const WAR_SHORTENED_FRONT_REDUCTION := 8000
const FINANCIAL_CRISIS_RESERVE := 2.0
const DEMO_WEEKS := 26
const EVENTS_PER_WEEK := 3
const STORY_SEED_SALT := 0x53544F52
const ROUTINE_SEED_SALT := 0x524F5554
const BUDGET_LEVEL_NAMES := ["сокращённый", "базовый", "приоритетный"]
const PARLIAMENT_TOTAL_SEATS := 120
const PARLIAMENT_MAJORITY := 61
const PARLIAMENT_CONSTITUTIONAL_MAJORITY := 80
const EMERGENCY_POWERS_MAX_STABILITY := 60
const PARLIAMENT_FACTIONS := [
	{"key": "center", "title": "Президентский центр", "seats": 50, "group": "Партия президента"},
	{"key": "guard", "title": "Старая гвардия", "seats": 32, "group": "Партия президента"},
	{"key": "regions", "title": "Региональный список", "seats": 18, "group": "Вне коалиции"},
	{"key": "civic", "title": "Гражданская коалиция", "seats": 20, "group": "Оппозиция"}
]
const WEEKLY_BUDGET_LINES := [
	{"key": "budget_social", "title": "Социальная помощь", "impact": "Пенсии, пособия, помощь безработным и беженцам."},
	{"key": "budget_health", "title": "Образование и медицина", "impact": "Школы, больницы, миграционная привлекательность и лечение раненых."},
	{"key": "budget_admin", "title": "Государственный аппарат", "impact": "Работа ведомств, канцелярии и подготовка законов."},
	{"key": "budget_defense", "title": "Армия и внутренние силы", "impact": "Содержание военнослужащих, техники, авиации и сил безопасности."},
	{"key": "budget_debt", "title": "Обслуживание долга", "impact": "Обязательные выплаты по государственному долгу."},
	{"key": "budget_infrastructure", "title": "Инфраструктура", "impact": "Ремонт сетей, дорог и региональной инфраструктуры."}
]
const MINISTER_OFFICES := {
	"economy": "МИНИСТР ЭКОНОМИКИ",
	"interior": "МИНИСТР ВНУТРЕННИХ ДЕЛ",
	"defense": "МИНИСТР ОБОРОНЫ",
	"foreign": "МИНИСТР ИНОСТРАННЫХ ДЕЛ"
}
const MINISTER_CANDIDATES := {
	"economy": [
		{"id": "radan", "name": "Анна Радан", "ideology": "рыночный реформатор", "loyalty": "осторожная", "patron": "городской бизнес и международные кредиторы", "trait": "Доверие кредиторов", "known": "Открывает кредиты и приватизацию; сокращение социальных расходов сильнее злит профсоюзы.", "effects": {}},
		{"id": "grad", "name": "Виктор Град", "ideology": "государственник", "loyalty": "высокая к курсу отца", "patron": "директора государственных предприятий", "trait": "Чрезвычайный сбор", "known": "Открывает национализацию и сырьевой сбор; конфликтует с олигархами.", "effects": {"clan_workers": 4, "clan_oligarchs": -6}},
		{"id": "sorec", "name": "Мила Сорец", "ideology": "социальный компромисс", "loyalty": "условная", "patron": "профсоюзы", "trait": "Трёхстороннее соглашение", "known": "Улучшает переговорные варианты в трудовых конфликтах; кредиторы предлагают более жёсткие условия.", "effects": {"clan_workers": 8, "clan_oligarchs": -8}}
	],
	"interior": [
		{"id": "volsky", "name": "Марек Вольский", "ideology": "крепкая рука", "loyalty": "высокая", "patron": "силовики", "trait": "Быстрый разгон", "known": "Предлагает точечные задержания организаторов протестов: без расходов, но ценой поддержки и отношений с профсоюзами.", "effects": {}},
		{"id": "kovach", "name": "Ирина Ковач", "ideology": "гражданская реформа", "loyalty": "надёжная", "patron": "юристы и городские активисты", "trait": "Посредники", "known": "Легализует переговоры с протестующими: поддержка и профсоюзы растут, но уличное давление снижает стабильность и поддержку войны. Армия возмущается только при брате во главе обороны.", "effects": {"support": 2}},
		{"id": "sava", "name": "Антон Сава", "ideology": "административный нейтрал", "loyalty": "неизвестная", "patron": "губернаторы", "trait": "Тихая сеть", "known": "Раскалывает протест через губернаторов: быстро возвращает порядок, но усиливает региональные элиты, враждебность профсоюзов и на следующую неделю отнимает у центра одно очко решений.", "effects": {"clan_regions": 6}}
	],
	"defense": [
		{"id": "brother", "name": "Старший брат", "ideology": "авторитарный государственник", "loyalty": "семье и наследию отца", "patron": "армейское командование", "trait": "Война на истощение", "known": "Сильный оборонительный командир. Обычным кадровым решением снять его нельзя.", "locked": true, "locked_reason": "Защищён положением в армии и сюжетом.", "effects": {}},
		{"id": "yun", "name": "Милош Юн", "ideology": "либеральный профессионал", "loyalty": "гражданской власти", "patron": "младшие офицеры", "trait": "Глухая оборона", "known": "Повышает качество обороны и гражданский контроль, но слабее в наступлении.", "locked": true, "locked_reason": "Станет доступен после сюжетного ослабления брата.", "effects": {}},
		{"id": "zukan", "name": "Грегор Жукан", "ideology": "сторонник массовой армии", "loyalty": "неизвестная", "patron": "ветеранские организации", "trait": "Пехотный вал", "known": "Получает выгоду от численности ценой больших людских потерь.", "locked": true, "locked_reason": "Станет доступен после сюжетного ослабления брата.", "effects": {}}
	],
	"foreign": [
		{"id": "narin", "name": "Лея Нарин", "ideology": "нейтралист", "loyalty": "надёжная", "patron": "профессиональная дипломатия", "trait": "Красные линии", "known": "Снижает цену дипломатической миссии с 3 до 2 млн и заранее показывает постоянные последствия соглашений.", "effects": {}},
		{"id": "varek", "name": "Элиан Варек", "ideology": "прозападный либерал", "loyalty": "идее западного курса", "patron": "экспортёры и западные фонды", "trait": "Открытые двери", "known": "При назначении улучшает отношения с Западной Федерацией и тем самым ухудшает отношения с Восточным Союзом.", "effects": {"west_commitment": 1}},
		{"id": "kres", "name": "Дарья Крес", "ideology": "сторонница сделки с Востоком", "loyalty": "прагматичная", "patron": "энергетические компании", "trait": "Старая линия", "known": "При назначении улучшает отношения с Восточным Союзом и тем самым ухудшает отношения с Западной Федерацией.", "effects": {"east_commitment": 1}}
	]
}
const RECRUITMENT_MODELS := {
	"contract": {"title": "Контрактная", "training": 75, "rate": 0.026, "speed": 3000, "description": "Меньше людей, высокая подготовка и цена содержания."},
	"mixed": {"title": "Смешанная", "training": 60, "rate": 0.014, "speed": 6000, "description": "Профессиональное ядро и ограниченный ежегодный призыв."},
	"universal": {"title": "Всеобщая обязанность", "training": 50, "rate": 0.009, "speed": 10000, "description": "Большой резерв, но слабее подготовка и выше политическая цена потерь."},
	"mobilization": {"title": "Мобилизация", "training": 40, "rate": 0.007, "speed": 25000, "description": "Временное военное расширение армии за счёт экономики и поддержки войны."}
}
const OIL_OUTPUT := 12
const METAL_OUTPUT := 8
const PRIVATIZED_OIL_OUTPUT_LOSS := 2
const PRIVATIZED_METAL_OUTPUT_LOSS := 2
const OIL_PRICE := 0.22
const METAL_PRICE := 0.30
const SAVE_VERSION := 1
const SAVE_PATH := "user://campaign_save.json"
const SETTINGS_PATH := "user://display_settings.json"
const ACHIEVEMENTS_PATH := "user://ending_achievements.json"
const ENDING_ACHIEVEMENTS := [
	{"ending": "КАПИТУЛЯЦИЯ", "title": "Белый флаг", "description": "Завершить правление капитуляцией после распада фронта или исчезновения воли к сопротивлению."},
	{"ending": "ДЕФОЛТ", "title": "Казна сказала «нет»", "description": "Допустить государственный дефолт и остановку обязательных выплат."},
	{"ending": "СВЕРЖЕНИЕ", "title": "Ноль процентов", "description": "Потерять последнюю общественную опору и быть свергнутым улицей."},
	{"ending": "ВОЕННЫЙ ПЕРЕВОРОТ", "title": "Семейный совет", "description": "Потерять лояльность армии и уступить власть военному руководству."},
	{"ending": "РАСКОЛ", "title": "Каждый сам за себя", "description": "Довести государственную стабильность до полного распада страны."},
	{"ending": "ИЗБРАННЫЙ ПРЕЗИДЕНТ", "title": "Собственный мандат", "description": "Победить на проверяемых досрочных выборах."},
	{"ending": "МИРНАЯ ПЕРЕДАЧА ВЛАСТИ", "title": "Уйти вовремя", "description": "Проиграть честные выборы и добровольно передать власть."},
	{"ending": "АППАРАТ НЕ СПАС", "title": "Даже аппарат не всесилен", "description": "Проиграть выборы несмотря на управляемый подсчёт."},
	{"ending": "УПРАВЛЯЕМАЯ ПОБЕДА", "title": "Демократия с инструкцией", "description": "Получить признанный мандат при помощи административного ресурса."},
	{"ending": "ВЫБОРЫ БЕЗ ПРИЗНАНИЯ", "title": "Победа, которую никто не признал", "description": "Выиграть управляемый подсчёт, но потерять общественное признание результата."},
	{"ending": "ПОБЕДА ПО ПРОТОКОЛУ", "title": "Главное — протокол", "description": "Удержать власть после заранее объявленного результата выборов."},
	{"ending": "ИЗБИРАТЕЛЬНЫЙ КРИЗИС", "title": "Два президента", "description": "Завершить кампанию двумя конкурирующими центрами власти."},
	{"ending": "ОТЛОЖЕННЫЙ МАНДАТ", "title": "После войны", "description": "Перенести выборы во время войны и сохранить достаточное общественное принятие."},
	{"ending": "ПРОСРОЧЕННЫЙ МАНДАТ", "title": "Временно навсегда", "description": "Отменить выборы, не убедив страну в законности продления полномочий."},
	{"ending": "ДОСРОЧНЫЕ ВЫБОРЫ", "title": "Срок истёк", "description": "Довести временный срок до конца без признанного порядка передачи власти."},
	{"ending": "ВОСТОЧНЫЙ КУРС", "title": "Снова вместе", "description": "Завершить кампанию в политической орбите Восточного Союза."},
	{"ending": "ЗАПАДНЫЙ КУРС", "title": "Открытые двери", "description": "Завершить кампанию в системе договоров Западной Федерации."},
	{"ending": "ХРУПКИЙ НЕЙТРАЛИТЕТ", "title": "Между двух стульев", "description": "Сохранить промежуточное положение между двумя соседями."},
	{"ending": "НАСЛЕДСТВО ОТЦА", "title": "Достойный наследник", "description": "Сохранить и укрепить семейную авторитарную систему."}
]


class Backdrop:
	extends Control

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var s := size
		draw_rect(Rect2(Vector2.ZERO, s), Color("#111418"))
		for i in range(8):
			var y := s.y * (0.10 + float(i) * 0.13)
			draw_line(Vector2(0, y), Vector2(s.x, y - 90), Color(0.82, 0.74, 0.58, 0.04), 2.0)
		draw_circle(Vector2(s.x * 0.82, s.y * 0.14), s.x * 0.32, Color(0.42, 0.17, 0.15, 0.16))
		draw_circle(Vector2(s.x * 0.12, s.y * 0.86), s.x * 0.42, Color(0.18, 0.29, 0.34, 0.18))


class PortraitArt:
	extends Control
	var role := "official"
	var accent := BLUE

	func setup(new_role: String, new_accent: Color) -> void:
		role = new_role
		accent = new_accent
		queue_redraw()

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var s := size
		var center := Vector2(s.x * 0.5, s.y * 0.48)
		var glow := accent
		glow.a = 0.13
		draw_circle(center, min(s.x, s.y) * 0.43, glow)
		for i in range(5):
			var ring := accent
			ring.a = 0.10
			draw_arc(center, min(s.x, s.y) * (0.42 - i * 0.045), PI * 0.15, PI * 0.85, 24, ring, 2.0)
		var silhouette := Color("#202226")
		var head_radius := minf(s.x, s.y) * 0.105
		var head_pos := Vector2(center.x, center.y - s.y * 0.075)
		draw_circle(head_pos, head_radius, silhouette)
		var shoulders := PackedVector2Array([
			Vector2(center.x - s.x * 0.24, s.y * 0.86),
			Vector2(center.x - s.x * 0.18, s.y * 0.62),
			Vector2(center.x, s.y * 0.55),
			Vector2(center.x + s.x * 0.18, s.y * 0.62),
			Vector2(center.x + s.x * 0.24, s.y * 0.86)
		])
		draw_polygon(shoulders, PackedColorArray([silhouette]))
		if role == "military":
			draw_rect(Rect2(head_pos.x - head_radius * 1.15, head_pos.y - head_radius * 0.9, head_radius * 2.3, head_radius * 0.35), accent)
			draw_line(Vector2(center.x - s.x * 0.19, s.y * 0.68), Vector2(center.x + s.x * 0.19, s.y * 0.68), accent, 5.0)
		elif role == "diplomat":
			draw_circle(Vector2(center.x, s.y * 0.72), 8.0, accent)
		elif role == "family":
			draw_arc(head_pos, head_radius * 1.25, PI, TAU, 20, accent, 5.0)
		else:
			draw_line(Vector2(center.x, s.y * 0.57), Vector2(center.x, s.y * 0.78), accent, 5.0)


class BudgetIconArt:
	extends Control
	var budget_key := ""
	var accent := GOLD

	func setup(new_key: String, new_accent: Color) -> void:
		budget_key = new_key
		accent = new_accent
		queue_redraw()

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var s := size
		var c := Vector2(s.x * 0.5, s.y * 0.5)
		var dark := Color("#24272b")
		draw_rect(Rect2(Vector2(2, 2), s - Vector2(4, 4)), Color(accent, 0.13), true)
		draw_rect(Rect2(Vector2(2, 2), s - Vector2(4, 4)), accent, false, 2.0)
		match budget_key:
			"budget_social":
				for offset in [-18.0, 0.0, 18.0]:
					draw_circle(Vector2(c.x + offset, c.y - 10), 6.0, dark)
					draw_line(Vector2(c.x + offset, c.y - 2), Vector2(c.x + offset, c.y + 17), dark, 6.0)
			"budget_health":
				draw_rect(Rect2(c - Vector2(7, 24), Vector2(14, 48)), dark)
				draw_rect(Rect2(c - Vector2(24, 7), Vector2(48, 14)), dark)
			"budget_admin":
				var roof := PackedVector2Array([Vector2(c.x - 27, c.y - 13), Vector2(c.x, c.y - 29), Vector2(c.x + 27, c.y - 13)])
				draw_polygon(roof, PackedColorArray([dark]))
				for x in [-18.0, -6.0, 6.0, 18.0]:
					draw_rect(Rect2(Vector2(c.x + x - 3, c.y - 10), Vector2(6, 28)), dark)
				draw_rect(Rect2(Vector2(c.x - 29, c.y + 18), Vector2(58, 6)), dark)
			"budget_defense":
				var shield := PackedVector2Array([Vector2(c.x, c.y - 29), Vector2(c.x + 25, c.y - 18), Vector2(c.x + 20, c.y + 13), Vector2(c.x, c.y + 30), Vector2(c.x - 20, c.y + 13), Vector2(c.x - 25, c.y - 18)])
				draw_polygon(shield, PackedColorArray([dark]))
				draw_line(Vector2(c.x, c.y - 18), Vector2(c.x, c.y + 18), accent, 3.0)
			"budget_debt":
				for index in range(3):
					var coin_center := Vector2(c.x, c.y + 14 - float(index) * 14.0)
					draw_ellipse_icon(coin_center, Vector2(26, 8), dark)
			"budget_infrastructure":
				draw_line(Vector2(c.x - 29, c.y + 19), Vector2(c.x - 15, c.y - 17), dark, 7.0)
				draw_line(Vector2(c.x + 29, c.y + 19), Vector2(c.x + 15, c.y - 17), dark, 7.0)
				draw_line(Vector2(c.x - 18, c.y - 8), Vector2(c.x + 18, c.y - 8), dark, 7.0)
				draw_line(Vector2(c.x - 30, c.y + 20), Vector2(c.x + 30, c.y + 20), dark, 6.0)

	func draw_ellipse_icon(center: Vector2, radii: Vector2, color: Color) -> void:
		var points := PackedVector2Array()
		for index in range(24):
			var angle := TAU * float(index) / 24.0
			points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
		draw_polygon(points, PackedColorArray([color]))


var story_rng := RandomNumberGenerator.new()
var routine_rng := RandomNumberGenerator.new()
var state: Dictionary = {}
var events: Array[Dictionary] = []
var story_event_pool: Array[Dictionary] = []
var recurring_events: Array[Dictionary] = []
var event_queue: Array[Dictionary] = []
var recurring_event_queue: Array[Dictionary] = []
var weekly_event_queue: Array[Dictionary] = []
var financial_crisis_event: Dictionary = {}
var creditor_review_event: Dictionary = {}
var social_protest_event: Dictionary = {}
var emergency_powers_protest_event: Dictionary = {}
var current_event: Dictionary = {}
var game_mode := "Обычный"
var active_law := ""
var law_progress := 0
var law_target := 0
var law_weekly_cost := 1
var law_worked_this_week := false
var selected_ministers: Dictionary = {"economy": "radan", "interior": "volsky", "defense": "brother", "foreign": "narin"}
var budget_draft: Dictionary = {}
var recruitment_changed_this_week := false
var pending_week_changes: Array[Dictionary] = []

var screen_layer: Control
var game_root: Control
var week_label: Label
var mode_label: Label
var economy_name_label: Label
var interior_name_label: Label
var defense_name_label: Label
var foreign_name_label: Label
var card_panel: PanelContainer
var portrait: PortraitArt
var source_label: Label
var title_label: Label
var body_label: Label
var left_button: Button
var right_button: Button
var third_button: Button
var left_hint: Label
var right_hint: Label
var third_hint: Label
var choice_grid: GridContainer
var law_button: Button
var end_week_button: Button
var influence_label: Label
var stat_labels: Dictionary = {}
var stat_caption_labels: Dictionary = {}
var sidebar_summary_labels: Dictionary = {}
var overlay: Control
var overlay_can_cancel := false
var active_overlay_scroll: ScrollContainer
var event_resolved := false
var events_resolved_this_week := 0
var events_required_this_week := EVENTS_PER_WEEK
var save_path_override := ""
var fullscreen_enabled := false
var audio_enabled := true
var audio_streams: Dictionary = {}
var audio_players: Dictionary = {}


func _ready() -> void:
	theme = build_interface_theme()
	load_display_settings()
	setup_audio()
	build_event_database()
	show_start_screen()
	call_deferred("capture_preview_if_requested")


func capture_preview_if_requested() -> void:
	var args := OS.get_cmdline_user_args()
	if "--settings-smoke-test" in args:
		run_settings_smoke_test()
		return
	if "--logic-smoke-test" in args:
		run_logic_smoke_test()
		return
	if "--parliament-smoke-test" in args:
		run_parliament_smoke_test()
		return
	if "--consequence-smoke-test" in args:
		run_consequence_smoke_test()
		return
	if "--campaign-smoke-test" in args:
		run_campaign_smoke_test()
		return
	if "--difficulty-smoke-test" in args:
		run_difficulty_smoke_test()
		return
	if "--adaptive-smoke-test" in args:
		run_adaptive_smoke_test()
		return
	if "--financial-crisis-smoke-test" in args:
		run_financial_crisis_smoke_test()
		return
	if "--scroll-smoke-test" in args:
		await run_scroll_smoke_test()
		return
	if "--result-flow-smoke-test" in args:
		await run_result_flow_smoke_test()
		return
	if "--save-smoke-test" in args:
		run_save_smoke_test()
		return
	if "--foreign-smoke-test" in args:
		run_foreign_smoke_test()
		return
	if "--election-smoke-test" in args:
		run_election_smoke_test()
		return
	if "--unrest-smoke-test" in args:
		run_unrest_smoke_test()
		return
	var game_captures := ["--capture-game", "--capture-clans", "--capture-economy", "--capture-budget-icons", "--capture-budget-levels", "--capture-budget-vote", "--capture-army", "--capture-population", "--capture-government", "--capture-candidates", "--capture-minister-vote", "--capture-laws", "--capture-foreign", "--capture-war", "--capture-war-crisis", "--capture-weekly", "--capture-routine", "--capture-result", "--capture-new-week", "--capture-crisis", "--capture-creditor", "--capture-protest", "--capture-unrest"]
	var requested_capture := ""
	for capture_arg in game_captures:
		if capture_arg in args:
			requested_capture = capture_arg
			break
	if not "--capture-preview" in args and requested_capture == "":
		return
	if requested_capture != "":
		start_game("Сид: 1991", 1991)
		if requested_capture == "--capture-clans":
			show_clans()
		elif requested_capture == "--capture-economy":
			show_economy()
		elif requested_capture == "--capture-budget-icons":
			show_economy(480)
		elif requested_capture == "--capture-budget-levels":
			show_budget_level_selector("budget_social")
		elif requested_capture == "--capture-budget-vote":
			budget_draft["budget_debt"] = 0
			budget_draft["budget_infrastructure"] = 2
			show_economy(5000)
		elif requested_capture == "--capture-army":
			show_army()
		elif requested_capture == "--capture-population":
			show_population()
		elif requested_capture == "--capture-government":
			show_ministers()
		elif requested_capture == "--capture-candidates":
			show_minister_candidates("economy")
		elif requested_capture == "--capture-minister-vote":
			show_minister_confirmation("economy", "grad")
		elif requested_capture == "--capture-laws":
			show_law_selection()
		elif requested_capture == "--capture-foreign":
			apply_state_flags({"east_energy_promise": true})
			apply_state_flags({"western_package": true})
			apply_state_flags({"double_standards_started": true})
			show_foreign_policy()
		elif requested_capture == "--capture-war":
			state.east_relation = 0
			start_invasion_if_needed()
			show_foreign_policy()
		elif requested_capture == "--capture-war-crisis":
			state.west_relation = 0
			start_invasion_if_needed()
			process_war_week()
			current_event = build_war_crisis_event()
			current_event["_kind"] = "urgent"
			event_resolved = false
			display_current_event()
		elif requested_capture == "--capture-weekly":
			event_resolved = true
			events_resolved_this_week = events_required_this_week
			weekly_event_queue.clear()
			state.financial_slot_consumed = true
			advance_week()
		elif requested_capture == "--capture-routine":
			event_resolved = true
			events_resolved_this_week = 1
			next_event()
		elif requested_capture == "--capture-result":
			choose_option("left")
			await get_tree().create_timer(0.20).timeout
		elif requested_capture == "--capture-new-week":
			event_resolved = true
			events_resolved_this_week = events_required_this_week
			weekly_event_queue.clear()
			state.financial_slot_consumed = true
			left_button.disabled = true
			right_button.disabled = true
			third_button.disabled = true
			update_interface()
		elif requested_capture == "--capture-crisis":
			state.money = 0.01
			state.financial_slot_consumed = false
			event_resolved = true
			events_resolved_this_week = EVENTS_PER_WEEK
			weekly_event_queue.clear()
			next_event()
		elif requested_capture == "--capture-creditor":
			state.creditor_demand_budget_key = choose_creditor_austerity_target()
			current_event = creditor_review_event.duplicate(true)
			current_event["_kind"] = "urgent"
			event_resolved = false
			customize_event_for_ministers()
			display_current_event()
		elif requested_capture == "--capture-protest":
			current_event = social_protest_event.duplicate(true)
			current_event["_kind"] = "urgent"
			event_resolved = false
			customize_event_for_ministers()
			display_current_event()
		elif requested_capture == "--capture-unrest":
			state.support = 32
			state.clan_workers = 25
			schedule_unrest({"cause": "увольнение бастующих шахтёров и найм штрейкбрехеров", "kind": "labor", "labor": true, "base_level": 2, "reversible": false}, 0)
			current_event = take_unrest_event()
			current_event["_kind"] = "urgent"
			event_resolved = false
			customize_event_for_ministers()
			display_current_event()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var output_path := "res://preview.png"
	if requested_capture == "--capture-game":
		output_path = "res://preview_game.png"
	elif requested_capture == "--capture-clans":
		output_path = "res://preview_clans.png"
	elif requested_capture == "--capture-economy":
		output_path = "res://preview_economy.png"
	elif requested_capture == "--capture-budget-icons":
		output_path = "res://preview_budget_icons.png"
	elif requested_capture == "--capture-budget-levels":
		output_path = "res://preview_budget_levels.png"
	elif requested_capture == "--capture-budget-vote":
		output_path = "res://preview_budget_vote.png"
	elif requested_capture == "--capture-army":
		output_path = "res://preview_army.png"
	elif requested_capture == "--capture-population":
		output_path = "res://preview_population.png"
	elif requested_capture == "--capture-government":
		output_path = "res://preview_government.png"
	elif requested_capture == "--capture-candidates":
		output_path = "res://preview_candidates.png"
	elif requested_capture == "--capture-minister-vote":
		output_path = "res://preview_minister_vote.png"
	elif requested_capture == "--capture-laws":
		output_path = "res://preview_laws.png"
	elif requested_capture == "--capture-foreign":
		output_path = "res://preview_foreign.png"
	elif requested_capture == "--capture-war":
		output_path = "res://preview_war.png"
	elif requested_capture == "--capture-war-crisis":
		output_path = "res://preview_war_crisis.png"
	elif requested_capture == "--capture-weekly":
		output_path = "res://preview_weekly.png"
	elif requested_capture == "--capture-routine":
		output_path = "res://preview_routine.png"
	elif requested_capture == "--capture-result":
		output_path = "res://preview_result.png"
	elif requested_capture == "--capture-new-week":
		output_path = "res://preview_new_week.png"
	elif requested_capture == "--capture-crisis":
		output_path = "res://preview_crisis.png"
	elif requested_capture == "--capture-creditor":
		output_path = "res://preview_creditor.png"
	elif requested_capture == "--capture-protest":
		output_path = "res://preview_protest.png"
	elif requested_capture == "--capture-unrest":
		output_path = "res://preview_unrest.png"
	image.save_png(output_path)
	get_tree().quit()


func run_logic_smoke_test() -> void:
	var failures: Array[String] = []
	if campaign_seed_from_text("1991") != 1991:
		failures.append("Числовой сид из меню должен совпадать с числом, используемым тестами и обменом кампаниями.")
	for office in MINISTER_CANDIDATES:
		for candidate in MINISTER_CANDIDATES[office]:
			if (candidate as Dictionary).has("competence"):
				failures.append("У кандидатов не должно быть механики компетентности.")
				break
	start_game("Сид: 1991", 1991)
	var seeded_story_signature := story_event_signature(true)
	var seeded_routine_order_signature := recurring_event_signature(false)
	var seeded_routine_set_signature := recurring_event_signature(true)
	start_game("Сид: 1991", 1991)
	if story_event_signature(true) != seeded_story_signature:
		failures.append("Одинаковый сид не воспроизводит выборку сюжетных событий.")
	if recurring_event_signature(false) != seeded_routine_order_signature:
		failures.append("Одинаковый сид не воспроизводит порядок малых событий.")
	start_game("Сид: 1992", 1992)
	if story_event_signature(true) == seeded_story_signature:
		failures.append("Новая кампания с другим сидом получила тот же набор необязательных сюжетных событий.")
	if recurring_event_signature(true) == seeded_routine_set_signature:
		failures.append("Новая кампания с другим сидом получила тот же набор малых событий.")
	start_game("Сид: 1991", 1991)
	var highest_corruption_tier := CORRUPTION_LABELS.size() - 1
	if not is_equal_approx(adjusted_money_transaction(10.0, highest_corruption_tier), 6.5):
		failures.append("Парализующая коррупция должна урезать доход 10 млн до 6.5 млн.")
	if not is_equal_approx(adjusted_money_transaction(-10.0, highest_corruption_tier), -10.0):
		failures.append("Коррупция не должна увеличивать расходы.")
	var saved_corruption_tier := int(state.get("corruption_tier", 0))
	state.corruption_tier = 0
	var expenses_with_minimal_corruption := weekly_actual_expenses()
	var oil_price_with_minimal_corruption := current_oil_price()
	state.corruption_tier = highest_corruption_tier
	if not is_equal_approx(weekly_actual_expenses(), expenses_with_minimal_corruption):
		failures.append("Категория коррупции изменила недельные расходы.")
	if not is_equal_approx(current_oil_price(), oil_price_with_minimal_corruption):
		failures.append("Категория коррупции изменила рыночную цену ресурса.")
	state.corruption_tier = saved_corruption_tier
	state.raw_sector_privatized = false
	if current_oil_output() != OIL_OUTPUT or current_metal_output() != METAL_OUTPUT:
		failures.append("До приватизации государству недоступен полный объём собственной добычи.")
	state.raw_sector_privatized = true
	if current_oil_output() != OIL_OUTPUT - PRIVATIZED_OIL_OUTPUT_LOSS or current_metal_output() != METAL_OUTPUT - PRIVATIZED_METAL_OUTPUT_LOSS:
		failures.append("Приватизация сырьевого сектора не уменьшает доступную добычу нефти и металлов.")
	state.raw_sector_privatized = false
	var achievement_endings := {}
	for achievement in ENDING_ACHIEVEMENTS:
		var achievement_ending := str(achievement.get("ending", ""))
		if achievement_ending == "" or achievement_endings.has(achievement_ending):
			failures.append("Каталог достижений содержит пустую или повторяющуюся концовку.")
			break
		achievement_endings[achievement_ending] = true
	if achievement_endings.size() != 19:
		failures.append("Каждая из 19 доступных концовок должна иметь отдельное достижение.")
	for required_ending in ["КАПИТУЛЯЦИЯ", "ДЕФОЛТ", "СВЕРЖЕНИЕ", "ВОЕННЫЙ ПЕРЕВОРОТ", "РАСКОЛ", "ИЗБРАННЫЙ ПРЕЗИДЕНТ", "МИРНАЯ ПЕРЕДАЧА ВЛАСТИ", "УПРАВЛЯЕМАЯ ПОБЕДА", "ИЗБИРАТЕЛЬНЫЙ КРИЗИС"]:
		if not achievement_endings.has(required_ending):
			failures.append("Для концовки «%s» не создано достижение." % required_ending)
	if week_count_text(1) != "1 неделю" or week_count_text(2) != "2 недели" or week_count_text(11) != "11 недель":
		failures.append("Финальный экран неверно склоняет количество прожитых недель.")
	if story_event_pool.size() != 46:
		failures.append("Авторский сюжетный пул должен содержать 46 событий.")
	var pool_story_ids := {}
	var pool_mandatory_count := 0
	var pool_bucket_counts := {"economy": 0, "army": 0, "society": 0, "world": 0}
	for pool_event in story_event_pool:
		var pool_story_id := str(pool_event.get("_story_id", ""))
		if pool_story_id == "" or pool_story_ids.has(pool_story_id):
			failures.append("Сюжетный пул содержит пустой или повторяющийся идентификатор.")
			break
		pool_story_ids[pool_story_id] = true
		if bool(pool_event.get("_mandatory", false)):
			pool_mandatory_count += 1
		else:
			var pool_bucket := str(pool_event.get("_bucket", ""))
			pool_bucket_counts[pool_bucket] = int(pool_bucket_counts.get(pool_bucket, 0)) + 1
	if pool_mandatory_count != 12 or pool_bucket_counts != {"economy": 8, "army": 5, "society": 15, "world": 6}:
		failures.append("Сюжетный пул должен состоять из 12 обязательных и 34 квотируемых событий (8/5/15/6).")
	var personal_event_titles := ["Ужин остывает", "Бутылка из погреба", "Комната отца", "Машина у школы"]
	for personal_title in personal_event_titles:
		if not pool_story_ids.has(personal_title):
			failures.append("В случайном общественном пуле отсутствует личное событие «%s»." % personal_title)
	var saved_current_event := current_event.duplicate(true)
	var saved_defense_minister := str(selected_ministers.get("defense", "brother"))
	var wine_template: Dictionary = {}
	var dinner_template: Dictionary = {}
	for pool_event in story_event_pool:
		if str(pool_event.get("title", "")) == "Бутылка из погреба":
			wine_template = pool_event
		elif str(pool_event.get("title", "")) == "Ужин остывает":
			dinner_template = pool_event
	selected_ministers.defense = "brother"
	current_event = wine_template.duplicate(true)
	customize_event_for_ministers()
	if not str(current_event.get("body", "")).contains("Ваш брат") or int(current_event.get("left", {}).get("effects", {}).get("support", 0)) != 1 or int(current_event.get("left", {}).get("effects", {}).get("army", 0)) != -1 or current_event.has("third"):
		failures.append("История с бутылкой не учитывает старшего брата на посту министра обороны.")
	selected_ministers.defense = "yun"
	current_event = wine_template.duplicate(true)
	customize_event_for_ministers()
	if not str(current_event.get("body", "")).contains(current_minister_name("defense")) or int(current_event.get("right", {}).get("effects", {}).get("support", 0)) != -1 or int(current_event.get("right", {}).get("effects", {}).get("army", 0)) != 1:
		failures.append("История с бутылкой не подставляет действующего министра обороны после кадровой замены.")
	state.media_restricted = true
	current_event = dinner_template.duplicate(true)
	customize_event_for_ministers()
	if not str(current_event.get("body", "")).contains("три одинаковые первые полосы"):
		failures.append("Реплика супруги не реагирует на ограничение СМИ.")
	state.media_restricted = false
	selected_ministers.defense = saved_defense_minister
	current_event = saved_current_event
	if events.size() != DEMO_WEEKS:
		failures.append("На 26 недель должно быть подготовлено ровно 26 сюжетных событий.")
	if recurring_events.size() != DEMO_WEEKS * (EVENTS_PER_WEEK - 1):
		failures.append("Для трёх событий в неделю должно быть подготовлено 52 малых доклада.")
	if financial_crisis_event.is_empty():
		failures.append("Условное событие финансового кризиса не настроено.")
	if creditor_review_event.is_empty() or not creditor_review_event.has("third"):
		failures.append("Требования международных кредиторов не настроены как отдельный доклад с тремя решениями.")
	if social_protest_event.is_empty() or not social_protest_event.has("third"):
		failures.append("Социальные протесты не настроены как отдельный условный доклад с тремя решениями.")
	for branch_kind in ["reception_tape", "election_protocols", "heating_debt", "constitutional_court", "faith_schism", "volunteer_command"]:
		var branch_event := build_story_followup_event(branch_kind)
		if branch_event.is_empty() or not branch_event.has("third"):
			failures.append("Сюжетное продолжение %s не настроено как доклад с тремя решениями." % branch_kind)
	if not financial_crisis_event.has("third"):
		failures.append("У события «Счета к оплате» нет третьего решения.")
	if str(current_event.get("title", "")) != "День после похорон" or str(current_event.get("_kind", "")) != "core":
		failures.append("Кампания начинается не с первого сюжетного доклада.")
	else:
		var opening_right: Dictionary = current_event.get("right", {})
		var opening_effects: Dictionary = opening_right.get("effects", {})
		if str(opening_right.get("label", "")) != "Передать объекты армии":
			failures.append("Первый доклад должен предлагать конкретную передачу ключевых объектов под охрану армии.")
		if not str(current_event.get("body", "")).contains("на две недели"):
			failures.append("Срок усиленной охраны в первом докладе должен быть прямо ограничен двумя неделями.")
		if int(opening_effects.get("money", 0)) != -2 or int(opening_effects.get("stability", 0)) != 5 or opening_effects.has("authoritarian"):
			failures.append("Охрана объектов армией должна влиять на казну, стабильность и армию без скрытого авторитарного режима.")
		if opening_right.get("set", {}).has("special_regime_declared"):
			failures.append("В первом докладе не должно оставаться флага неопределённого особого режима.")
	if event_queue.size() != DEMO_WEEKS - 1:
		failures.append("После начала кампании в сюжетной очереди должно оставаться 25 событий.")
	if recurring_event_queue.size() != DEMO_WEEKS * (EVENTS_PER_WEEK - 1) - 2:
		failures.append("После подготовки первой недели в малой очереди должно оставаться 50 событий.")
	if weekly_event_queue.size() != EVENTS_PER_WEEK - 1:
		failures.append("После показа первого доклада в недельной очереди должны оставаться ещё два.")
	for queued_event in weekly_event_queue:
		if str(queued_event.get("_kind", "")) != "routine":
			failures.append("После первого сюжетного доклада неделя должна содержать два малых события.")
			break
	if events_resolved_this_week != 0 or events_required_this_week != EVENTS_PER_WEEK:
		failures.append("Недельный счётчик не начал цикл с 0/3.")
	if str(events.back().get("title", "")) != "Досрочные выборы":
		failures.append("«Досрочные выборы» должны оставаться последним сюжетным событием.")
	var active_story_titles: Array[String] = []
	var active_mandatory_count := 0
	var active_bucket_counts := {"economy": 0, "army": 0, "society": 0, "world": 0}
	for story_event in events:
		active_story_titles.append(str(story_event.get("title", "")))
		if bool(story_event.get("_mandatory", false)):
			active_mandatory_count += 1
		else:
			var story_bucket := str(story_event.get("_bucket", ""))
			active_bucket_counts[story_bucket] = int(active_bucket_counts.get(story_bucket, 0)) + 1
	if active_mandatory_count != 12:
		failures.append("В кампании должны присутствовать все 12 обязательных сюжетных узлов.")
	var expected_bucket_counts := {"economy": 4, "army": 3, "society": 4, "world": 3}
	for story_bucket in expected_bucket_counts:
		if int(active_bucket_counts.get(story_bucket, 0)) != int(expected_bucket_counts[story_bucket]):
			failures.append("Случайная сюжетная выборка нарушила квоту категории %s." % story_bucket)
			break
	if active_story_titles.find("Обвинение без доказательств") > active_story_titles.find("Папка без печати") or active_story_titles.find("Папка без печати") > active_story_titles.find("Пропавший свидетель"):
		failures.append("Цепочка расследования покушения собрана в неверном порядке.")
	if active_story_titles.find("Два паспорта") > active_story_titles.find("Таможня до заката"):
		failures.append("Пограничный ультиматум появился раньше сюжетного узла о двойном гражданстве.")
	var recurring_titles := {}
	var recurring_bodies := {}
	var recurring_families := {}
	var recurring_family_counts := {}
	var recurring_variants := {}
	var recent_recurring_families: Array[String] = []
	for routine_event in recurring_events:
		var routine_title := str(routine_event.get("title", ""))
		var routine_body := str(routine_event.get("body", ""))
		var routine_family := str(routine_event.get("_family", ""))
		var routine_variant := str(routine_event.get("_generation_key", ""))
		if routine_title == "" or recurring_titles.has(routine_title):
			failures.append("Заголовки малых событий должны быть заполнены и уникальны.")
			break
		recurring_titles[routine_title] = true
		if routine_body == "" or routine_body.contains("{") or recurring_bodies.has(routine_body):
			failures.append("Малые события должны иметь различающийся региональный контекст без незаполненных шаблонов.")
			break
		recurring_bodies[routine_body] = true
		if routine_family == "":
			failures.append("У малого события не указано семейство для защиты от повторов.")
			break
		recurring_families[routine_family] = true
		recurring_family_counts[routine_family] = int(recurring_family_counts.get(routine_family, 0)) + 1
		if routine_variant == "" or recurring_variants.has(routine_variant):
			failures.append("Процедурный набор содержит пустой или повторяющийся вариант малого события.")
			break
		recurring_variants[routine_variant] = true
		if routine_family in recent_recurring_families:
			failures.append("Семейство малого события повторилось раньше чем через четыре других доклада.")
			break
		recent_recurring_families.append(routine_family)
		if recent_recurring_families.size() > 4:
			recent_recurring_families.pop_front()
		for side in ["left", "right"]:
			var routine_option: Dictionary = routine_event.get(side, {})
			var routine_effects: Dictionary = routine_option.get("effects", {})
			if routine_effects.is_empty():
				failures.append("У малого события не должно быть пустого выбора без немедленной цены или выгоды.")
				break
			var routine_flags: Dictionary = routine_option.get("set", {})
			var allowed_unrest_flag := routine_flags.is_empty() or (routine_flags.size() == 1 and routine_flags.has("unrest"))
			if routine_effects.has("corruption_tier") or not allowed_unrest_flag:
				failures.append("Малые события не должны менять коррупцию или постоянные сюжетные флаги; допустимо только причинное последствие в виде протеста.")
				break
		var routine_left: Dictionary = routine_event.get("left", {}).get("effects", {})
		var routine_right: Dictionary = routine_event.get("right", {}).get("effects", {})
		if option_effects_dominate(routine_left, routine_right) or option_effects_dominate(routine_right, routine_left):
			failures.append("В малом событии «%s» один выбор численно доминирует над другим." % routine_title)
			break
	if recurring_families.size() != 13:
		failures.append("Малые события должны охватывать 13 разных семейств.")
	for routine_family in recurring_family_counts:
		if int(recurring_family_counts[routine_family]) != 4:
			failures.append("Каждое семейство малых событий должно появляться ровно четыре раза за кампанию.")
			break
	for queued_event in event_queue:
		if str(queued_event.get("title", "")) == "Счета к оплате":
			failures.append("Финансовый кризис попал в обычную очередь событий.")
			break
	for queued_event in recurring_event_queue:
		if str(queued_event.get("title", "")) == "Счета к оплате":
			failures.append("Финансовый кризис попал в очередь малых событий.")
			break
	for queued_event in weekly_event_queue:
		if str(queued_event.get("title", "")) == "Счета к оплате":
			failures.append("Финансовый кризис заранее занял место среди трёх событий недели.")
			break
	var credit_effects: Dictionary = financial_crisis_event.get("right", {}).get("effects", {})
	if int(credit_effects.get("debt", 0)) > 50 or int(credit_effects.get("creditor_obligations", 0)) < 1:
		failures.append("Кредит фонда снова создаёт несоразмерный долг либо не создаёт обязательств перед кредиторами.")
	for clan_key in ["clan_oligarchs", "clan_church", "clan_workers", "clan_regions"]:
		if credit_effects.has(clan_key):
			failures.append("Сам кредит Международного фонда не должен менять поддержку групп.")
			break
	if should_trigger_financial_crisis():
		failures.append("Финансовый кризис появился при здоровом прогнозе казны.")
	var healthy_money := float(state.get("money", 0.0))
	state.money = snappedf(weekly_actual_expenses() - weekly_actual_income(), 0.01)
	if weekly_balance_forecast() > 0.0:
		failures.append("Тестовый прогноз финансового кризиса неожиданно остался положительным.")
	if should_trigger_financial_crisis():
		failures.append("Финансовый кризис появился раньше последних двух дней недели.")
	events_resolved_this_week = EVENTS_PER_WEEK
	weekly_event_queue.clear()
	if not should_trigger_financial_crisis():
		failures.append("Финансовый кризис не сработал при прогнозе пустой казны.")
	state.financial_slot_consumed = true
	if should_trigger_financial_crisis():
		failures.append("Финансовый кризис может повториться после использования слота.")
	state.financial_slot_consumed = false
	state.money = healthy_money
	appoint_minister("economy", "grad")
	if str(selected_ministers.get("economy", "")) != "grad":
		failures.append("Назначение выбранного министра не применилось.")
	set_recruitment_model("universal")
	if str(state.get("recruitment_model", "")) != "universal":
		failures.append("Смена модели комплектования не применилась.")
	change_resource_allocation("metal_to_equipment", 1, "army")
	var population_before := total_population()
	event_resolved = true
	events_resolved_this_week = events_required_this_week
	weekly_event_queue.clear()
	state.financial_slot_consumed = true
	advance_week()
	if int(state.get("week", 0)) != 2:
		failures.append("Недельный цикл не перешёл ко второй неделе.")
	var weekly_sections = (state.get("last_weekly_report", {}) as Dictionary).get("sections", {})
	if not (weekly_sections is Dictionary) or not (weekly_sections as Dictionary).has("finance") or not (weekly_sections as Dictionary).has("society") or not (weekly_sections as Dictionary).has("security"):
		failures.append("Недельная сводка не разделяет последствия по категориям.")
	if events_resolved_this_week != 0 or events_required_this_week < EVENTS_PER_WEEK or current_event.is_empty():
		failures.append("Новая неделя не подготовила новый цикл из трёх докладов.")
	if int(state.get("army_personnel", 0)) <= 50000:
		failures.append("Призыв не изменил численность армии.")
	if int(state.get("army_equipment", 0)) <= 300:
		failures.append("Производство не выпустило наземную технику.")
	if total_population() != population_before:
		failures.append("Призыв создал или уничтожил население.")
	if failures.is_empty():
		print("LOGIC_SMOKE_TEST: OK | story=%d | routine=%d | baseline=%d | week=%d | population=%d | personnel=%d | equipment=%d" % [events.size(), recurring_events.size(), events.size() + recurring_events.size(), int(state.get("week", 0)), total_population(), int(state.get("army_personnel", 0)), int(state.get("army_equipment", 0))])
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("LOGIC_SMOKE_TEST: " + failure)
		get_tree().quit(1)


func run_unrest_smoke_test() -> void:
	var failures: Array[String] = []
	start_game("Сид: 1991", 1991)
	state.support = 32
	state.clan_workers = 25
	schedule_unrest({"cause": "нарушение трудовых прав", "kind": "labor", "labor": true, "base_level": 2, "reversible": false}, 0)
	if not should_trigger_unrest():
		failures.append("Гарантированное нарушение трудовых прав не поставило забастовку в очередь.")
	var strike_event := take_unrest_event()
	if str(strike_event.get("title", "")) != "Смена не началась" or not strike_event.has("third"):
		failures.append("Забастовка не собрана как срочное событие с тремя решениями.")
	if int(state.get("active_unrest_level", 0)) != 3 or not bool(state.get("active_unrest_labor", false)):
		failures.append("Низкая поддержка и враждебность профсоюзов не усилили забастовку до всеобщей.")
	var strike_income := weekly_actual_income()
	clear_active_unrest()
	var normal_income := weekly_actual_income()
	if strike_income >= normal_income - 0.5:
		failures.append("Всеобщая забастовка не уменьшила реальные недельные доходы.")
	activate_unrest({"cause": "неизменённое решение", "kind": "civic", "labor": false, "level": 2, "reversible": false})
	var snapshot := active_unrest_snapshot()
	apply_state_flags({"unrest_continue": true})
	var stability_before := int(state.get("stability", 0))
	var unrest_note := process_active_unrest_week(snapshot)
	if int(state.get("stability", 0)) != stability_before - 4 or int(state.get("active_unrest_weeks", 0)) != 2 or unrest_note == "":
		failures.append("Решение не отступать не продлило протест и не сняло недельную стабильность.")
	state.media_restricted = true
	state.active_unrest_reversal = "media_law"
	apply_state_flags({"unrest_reverse_policy": true, "unrest_resolved": true})
	if bool(state.get("media_restricted", false)) or int(state.get("active_unrest_level", 0)) != 0:
		failures.append("Уступка по свободе СМИ не сняла ограничения и активный протест.")
	selected_ministers.interior = "kovach"
	schedule_unrest({"cause": "новое ограничение вещания", "kind": "civic", "base_level": 1, "reversible": true, "reversal": "media"}, 0)
	var civic_event := take_unrest_event()
	if str(civic_event.get("right", {}).get("label", "")) != "Открыть публичные переговоры":
		failures.append("Второй ответ на протест не зависит от министра внутренних дел.")
	if failures.is_empty():
		print("UNREST_SMOKE_TEST: OK | strike_income=%.2f<%.2f | stability_loss=4 | minister=kovach | reversal=yes" % [strike_income, normal_income])
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("UNREST_SMOKE_TEST: " + failure)
		get_tree().quit(1)


func run_foreign_smoke_test() -> void:
	var failures: Array[String] = []
	start_game("Сид: 1991", 1991)
	var east_concession := foreign_concession_data("east")
	var west_concession := foreign_concession_data("west")
	if str(east_concession.get("title", "")) == "" or str(west_concession.get("title", "")) == "" or str(east_concession.get("title", "")) == str(west_concession.get("title", "")):
		failures.append("Уступки соседям не описаны как две разные конкретные сделки.")
	if neighbor_relation_band("east") != "средние" or neighbor_relation_band("west") != "средние":
		failures.append("Оба соседа должны начинать кампанию со средними отношениями.")
	state.east_relation = 1
	if neighbor_relation_band("east") != "натянутые":
		failures.append("Прямая категория отношений не показывает натянутое состояние.")
	state.east_relation = 3
	if neighbor_relation_band("east") != "партнёрские":
		failures.append("Прямая категория отношений не показывает партнёрское состояние.")
	state.east_relation = 0
	if neighbor_relation_band("east") != "враждебные":
		failures.append("Прямая категория отношений не показывает враждебное состояние.")
	var invasion_note := start_invasion_if_needed()
	if not bool(state.get("at_war", false)) or str(state.get("war_enemy", "")) != "east" or invasion_note == "":
		failures.append("Враждебные отношения не запускают вторжение Восточного Союза.")
	if not should_trigger_war_crisis() or str(build_war_crisis_event().get("title", "")) != "Вторжение":
		failures.append("Начало войны не создаёт обязательный кризисный доклад о вторжении.")
	var wartime_influence := int(state.get("influence", 0))
	var wartime_pending := pending_week_changes.size()
	perform_foreign_action("east", "mission")
	if int(state.get("influence", 0)) != wartime_influence or pending_week_changes.size() != wartime_pending or neighbor_relation_band("east", true) != "враждебные":
		failures.append("Во время войны всё ещё можно улучшить отношения с государством-противником.")
	queue_week_change("Проверка запрета военной дипломатии", {"east_commitment": 1})
	if projected_pending_value("east_relation") != 0 or projected_pending_value("west_relation") != 2 or pending_week_changes.size() != wartime_pending:
		failures.append("Заблокированное улучшение отношений с противником всё ещё портит отношения со вторым соседом.")
	start_game("Сид: 1991", 1991)
	state.at_war = true
	state.war_enemy = "west"
	var dummy := option("Проверка", "", {}, "")
	var western_event := event("Западная делегация", "diplomat", "#536f82", "Пакет модернизации", "Проверка", dummy, dummy)
	var eastern_event := event("Восточное посольство", "diplomat", "#8b6c4b", "Мороз без топлива", "Проверка", dummy, dummy)
	if not (western_event.get("_peace_required_with", []) as Array).has("west") or not event_blocked_by_current_war(western_event):
		failures.append("Западное событие не получает условие мира с Западной Федерацией.")
	if event_blocked_by_current_war(eastern_event):
		failures.append("Война с Западом ошибочно блокирует событие мирных отношений с Востоком.")
	var replacement := build_wartime_replacement_event(western_event)
	if str(replacement.get("title", "")) == "Пакет модернизации" or str(replacement.get("_wartime_replacement_for", "")) != "Пакет модернизации":
		failures.append("Несовместимое с войной событие не заменяется внутренним военным докладом.")
	state.foreign_followups = [
		{"kind": "western_reform_review", "due_week": 1},
		{"kind": "east_energy_demand", "due_week": 1}
	]
	remove_wartime_incompatible_followups()
	var remaining_followups: Array = state.get("foreign_followups", [])
	if remaining_followups.size() != 1 or str(remaining_followups[0].get("kind", "")) != "east_energy_demand":
		failures.append("Война не удаляет требование противника либо удаляет допустимое требование второго соседа.")
	if frontline_required_personnel(80) >= frontline_required_personnel(25):
		failures.append("Высокое качество армии не снижает минимальную численность фронта.")
	var personnel_before := int(state.get("army_personnel", 0))
	var equipment_before := int(state.get("army_equipment", 0))
	var war_result := process_war_week()
	if war_result.is_empty() or int(state.get("army_personnel", 0)) >= personnel_before or int(state.get("army_equipment", 0)) >= equipment_before or int(state.get("army_aircraft", 0)) >= 12:
		failures.append("Военная неделя не наносит потери людям, наземной технике и авиации.")
	state.army_personnel = 0
	if army_effectiveness() != 0:
		failures.append("При отсутствии людей фронтовая боеспособность должна падать до нуля.")
	start_game("Сид: 1991", 1991)
	state.east_relation = 1
	state.west_relation = 2
	var influence_before := int(state.get("influence", 0))
	perform_foreign_action("east", "mission")
	if projected_pending_value("east_relation") != 2 or projected_pending_value("west_relation") != 1 or int(state.get("influence", 0)) != influence_before - 1 or not foreign_action_used_this_week():
		failures.append("Дипломатическая миссия должна улучшать выбранные отношения, ухудшать противоположные и отнимать очко решения.")
	start_game("Сид: 1991", 1991)
	perform_foreign_action("east", "concession")
	resolve_pending_week_changes()
	if not bool(state.get("east_border_oil_concession", false)) or current_oil_output() != OIL_OUTPUT - 4:
		failures.append("Восточная уступка не уменьшила доступную добычу нефти на 4 единицы до конца кампании.")
	start_game("Сид: 1991", 1991)
	apply_state_flags({"east_energy_promise": true})
	var energy_income_found := false
	for income_item in weekly_income_breakdown():
		if str(income_item.get("title", "")) == "Восточная энергетическая скидка":
			energy_income_found = true
			break
	if not energy_income_found or agreement_weeks_left("east_energy_discount_until_week") != 9:
		failures.append("Энергетическая сделка не создаёт видимой временной недельной выгоды.")
	state.week = 4
	if not should_trigger_foreign_followup():
		failures.append("Восточная энергетическая скидка не приводит к отложенному требованию.")
	else:
		var energy_demand := take_foreign_followup_event()
		if str(energy_demand.get("title", "")) != "Цена зимней скидки" or not energy_demand.has("third"):
			failures.append("Отложенное энергетическое требование не собрано как полноценное событие с тремя решениями.")
	start_game("Сид: 1991", 1991)
	apply_state_flags({"east_energy_promise": true})
	apply_state_flags({"western_package": true})
	var followup_kinds: Array[String] = []
	for followup in state.get("foreign_followups", []):
		if followup is Dictionary:
			followup_kinds.append(str(followup.get("kind", "")))
	if "standards_conflict" not in followup_kinds or "western_reform_review" not in followup_kinds:
		failures.append("Несовместимые восточные и западные соглашения не создают отдельный конфликт стандартов.")
	apply_state_flags({"double_standards_started": true})
	var certification_cost_found := false
	for expense_item in weekly_nonbudget_expense_breakdown():
		if str(expense_item.get("title", "")) == "Двойная сертификация экспорта":
			certification_cost_found = true
			break
	if not certification_cost_found:
		failures.append("Попытка сохранить два торговых режима не создаёт недельных расходов.")
	var passports_event: Dictionary = {}
	for story_event in story_event_pool:
		if str(story_event.get("title", "")) == "Два паспорта":
			passports_event = story_event
			break
	var neutral_passport_effects: Dictionary = passports_event.get("third", {}).get("effects", {})
	var converted_passport_effects := convert_legacy_foreign_effects(neutral_passport_effects)
	if passports_event.is_empty() or converted_passport_effects.has("east_relation") or converted_passport_effects.has("west_relation"):
		failures.append("Независимый учёт в событии «Два паспорта» должен сохранять отношения с обоими соседями.")
	if failures.is_empty():
		print("FOREIGN_SMOKE_TEST: OK | relation=%s | front_high=%d | front_low=%d | losses=%d/%d" % [neighbor_relation_band("east", true), frontline_required_personnel(80), frontline_required_personnel(25), int(war_result.get("personnel_loss", 0)), int(war_result.get("equipment_loss", 0))])
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("FOREIGN_SMOKE_TEST: " + failure)
		get_tree().quit(1)


func run_election_smoke_test() -> void:
	var failures: Array[String] = []
	start_game("Сид: 1991", 1991)
	if str(current_event.get("title", "")) != "День после похорон" or not str(current_event.get("body", "")).contains("26 недель"):
		failures.append("Вступление не объясняет временное президентство и срок досрочных выборов.")
	state.week = 9
	state.election_nomination_shown = false
	var nomination := build_next_election_milestone_event()
	if str(nomination.get("title", "")) != "Кандидат временного президента" or not bool(state.get("election_nomination_shown", false)) or not nomination.has("third"):
		failures.append("На девятой неделе не создаётся обязательное событие выдвижения.")
	state.week = 18
	state.election_rules_shown = false
	var rules_event := build_next_election_milestone_event()
	if str(rules_event.get("title", "")) != "Кто будет считать" or not bool(state.get("election_rules_shown", false)) or not rules_event.has("third"):
		failures.append("На восемнадцатой неделе не создаётся событие о правилах подсчёта.")
	state.support = 48
	state.stability = 50
	state.clan_workers = 50
	state.clan_regions = 50
	state.clan_church = 50
	state.clan_oligarchs = 70
	state.authoritarian = 2
	state.media_restricted = true
	var fair_score := election_effective_score(false, "fair")
	var managed_score := election_effective_score(false, "managed")
	if managed_score <= fair_score:
		failures.append("Лояльная комиссия и подконтрольные СМИ не повышают официальный результат.")
	var final_event := election_event_template()
	if str(final_event.get("title", "")) != "Досрочные выборы" or not event_peace_requirements(final_event).is_empty():
		failures.append("Финальное голосование отсутствует или ошибочно блокируется войной.")
	state.at_war = true
	state.war_enemy = "west"
	state.enacted_laws = ["Чрезвычайные полномочия"]
	current_event = final_event.duplicate(true)
	customize_event_for_ministers()
	if str(current_event.get("third", {}).get("set", {}).get("election_method", "")) != "postponed":
		failures.append("Война и чрезвычайные полномочия не открывают перенос выборов.")
	state.at_war = false
	state.support = 70
	state.stability = 65
	state.clan_workers = 60
	state.clan_regions = 60
	state.clan_church = 55
	state.clan_oligarchs = 55
	state.election_method = "fair"
	if str(election_ending_data().get("title", "")) != "ИЗБРАННЫЙ ПРЕЗИДЕНТ":
		failures.append("Высокая честная поддержка не приводит к выборной победе.")
	state.support = 25
	state.stability = 55
	state.clan_workers = 45
	state.clan_regions = 45
	state.clan_church = 45
	state.clan_oligarchs = 45
	if str(election_ending_data().get("title", "")) != "МИРНАЯ ПЕРЕДАЧА ВЛАСТИ":
		failures.append("Честное поражение не приводит к мирной передаче власти.")
	if failures.is_empty():
		print("ELECTION_SMOKE_TEST: OK | fair=%d | managed=%d | milestones=2 | wartime_postponement=yes" % [fair_score, managed_score])
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("ELECTION_SMOKE_TEST: " + failure)
		get_tree().quit(1)


func run_parliament_smoke_test() -> void:
	var failures: Array[String] = []
	start_game("Сид: 1991", 1991)
	var nominal_government_seats := 0
	for faction_data in PARLIAMENT_FACTIONS:
		var faction: Dictionary = faction_data
		if str(faction.get("group", "")) == "Партия президента":
			nominal_government_seats += int(faction.get("seats", 0))
	if nominal_government_seats < PARLIAMENT_CONSTITUTIONAL_MAJORITY:
		failures.append("Президентская партия должна начинать с конституционным большинством.")
	var initial_vote := parliament_vote_forecast("minister", "grad")
	var repeated_vote := parliament_vote_forecast("minister", "grad")
	if int(initial_vote.get("yes", 0)) != int(repeated_vote.get("yes", -1)):
		failures.append("Одинаковая ситуация дала разные результаты парламентского прогноза.")
	change_budget_level("budget_infrastructure", 1)
	var accepted_budget_vote := parliament_vote_forecast("budget")
	if not bool(accepted_budget_vote.get("passed", false)):
		failures.append("Стартовый парламент неожиданно отклоняет инфраструктурную поправку.")
	var influence_before_budget := int(state.get("influence", 0))
	submit_budget_amendment()
	if budget_level("budget_infrastructure") != 2 or int(state.get("influence", 0)) != influence_before_budget - 1:
		failures.append("Одобренная бюджетная поправка не применилась или неверно списала очки.")
	start_game("Сид: 1991", 1991)
	state.support = 20
	state.army = 30
	state.clan_oligarchs = 0
	state.clan_church = 0
	state.clan_workers = 0
	state.clan_regions = 20
	state.authoritarian = 1
	state.committee_hearings_open = true
	change_budget_level("budget_debt", -1)
	var rejected_budget_vote := parliament_vote_forecast("budget")
	if bool(rejected_budget_vote.get("passed", true)):
		failures.append("Расколотый парламент должен отклонять опасное сокращение обслуживания долга.")
	var rejected_budget_influence := int(state.get("influence", 0))
	submit_budget_amendment()
	if budget_level("budget_debt") != 1 or int(state.get("influence", 0)) != rejected_budget_influence or budget_draft_cost() != 1:
		failures.append("После отклонения бюджет, очки или сохранённый черновик изменились.")
	var metal_before := int(state.get("metal_to_equipment", 0))
	change_resource_allocation("metal_to_equipment", 1, "economy")
	if int(state.get("metal_to_equipment", 0)) != metal_before + 1:
		failures.append("Парламент ошибочно блокирует оперативное распределение ресурсов.")
	var minister_influence := int(state.get("influence", 0))
	var oligarchs_before := int(state.get("clan_oligarchs", 0))
	var workers_before := int(state.get("clan_workers", 0))
	appoint_minister("economy", "grad")
	if str(selected_ministers.get("economy", "")) != "radan" or int(state.get("influence", 0)) != minister_influence:
		failures.append("Проваленная кандидатура сменила министра или списала очки.")
	if int(state.get("clan_oligarchs", 0)) != oligarchs_before or int(state.get("clan_workers", 0)) != workers_before:
		failures.append("Проваленная кандидатура применила реакцию групп.")
	var locked_influence := int(state.get("influence", 0))
	appoint_minister("defense", "yun")
	if str(selected_ministers.get("defense", "")) != "brother" or int(state.get("influence", 0)) != locked_influence:
		failures.append("Сюжетно закрытого министра удалось назначить через парламент.")
	start_game("Сид: 1991", 1991)
	var successful_minister_vote := parliament_vote_forecast("minister", "grad")
	appoint_minister("economy", "grad")
	if not bool(successful_minister_vote.get("passed", false)) or str(selected_ministers.get("economy", "")) != "grad" or int(state.get("influence", 0)) != weekly_influence_cap() - 2:
		failures.append("Одобренная парламентом кандидатура не была назначена.")
	start_game("Сид: 1991", 1991)
	state.support = 20
	state.army = 30
	state.clan_oligarchs = 0
	state.clan_church = 0
	state.clan_workers = 0
	state.clan_regions = 20
	state.committee_hearings_open = true
	var emergency_laws: Array = state.get("enacted_laws", [])
	emergency_laws.append("Чрезвычайные полномочия")
	state.enacted_laws = emergency_laws
	change_budget_level("budget_debt", -1)
	var override_budget_vote := parliament_vote_forecast("budget")
	if bool(override_budget_vote.get("passed", true)):
		failures.append("Для проверки чрезвычайного указа парламент должен оставаться против поправки.")
	var override_influence_before := int(state.get("influence", 0))
	submit_budget_amendment()
	if budget_level("budget_debt") != 0 or int(state.get("influence", 0)) != override_influence_before - 1:
		failures.append("Чрезвычайные полномочия не позволили утвердить отклоняемый парламентом бюджет.")
	var override_minister_vote := parliament_vote_forecast("minister", "grad")
	appoint_minister("economy", "grad")
	if bool(override_minister_vote.get("passed", true)) or str(selected_ministers.get("economy", "")) != "grad" or int(state.get("influence", 0)) != 0:
		failures.append("Чрезвычайные полномочия не позволили назначить отклоняемого парламентом министра.")
	if failures.is_empty():
		print("PARLIAMENT_SMOKE_TEST: OK | seats=%d | majority=%d | initial_minister=%d | accepted_budget=%d | rejected_budget=%d | emergency_override=yes" % [PARLIAMENT_TOTAL_SEATS, PARLIAMENT_MAJORITY, int(initial_vote.get("yes", 0)), int(accepted_budget_vote.get("yes", 0)), int(rejected_budget_vote.get("yes", 0))])
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("PARLIAMENT_SMOKE_TEST: " + failure)
		get_tree().quit(1)


func run_consequence_smoke_test() -> void:
	var failures: Array[String] = []
	start_game("Сид: 1991", 1991)
	var routine := amplify_decision_effects({"support": 1, "stability": -2, "clan_workers": 2}, "routine")
	if int(routine.get("support", 0)) != 2 or int(routine.get("stability", 0)) != -4 or int(routine.get("clan_workers", 0)) != 4:
		failures.append("Малые события не получили усиленные последствия.")
	var core := amplify_decision_effects({"support": 3, "clan_regions": -10}, "core")
	if int(core.get("support", 0)) != 5 or int(core.get("clan_regions", 0)) != -14:
		failures.append("Сюжетные решения не усиливаются в безопасном ограниченном диапазоне.")
	var urgent := amplify_decision_effects({"support": -4, "clan_workers": 6}, "urgent")
	if urgent != {"support": -4, "clan_workers": 6}:
		failures.append("Уже крупные срочные последствия были повторно умножены.")
	if not is_equal_approx(recruitment_speed_multiplier(20), 0.40) or not is_equal_approx(recruitment_speed_multiplier(65), 1.35) or not is_equal_approx(recruitment_speed_multiplier(80), 1.60):
		failures.append("Пороги поддержки войны неверно меняют скорость набора.")
	if war_fatigue_loss(2) != 1 or war_fatigue_loss(6) != 2 or war_fatigue_loss(10) != 3 or war_fatigue_loss(14) != 4:
		failures.append("Усталость от войны не усиливается по мере затягивания конфликта.")
	if not is_equal_approx(health_war_loss_multiplier(0), 1.25) or not is_equal_approx(health_war_loss_multiplier(2), 0.80) or monthly_health_migration_balance(0) != -8000 or monthly_health_migration_balance(2) != 8000:
		failures.append("Финансирование образования и медицины неверно влияет на миграцию или военные потери.")
	start_game("Сид: 1991", 1991)
	state.at_war = true
	state.war_support = 20
	state.recruitment_model = "mobilization"
	var low_support_recruitment := process_army_recruitment()
	if int(low_support_recruitment.get("evaders", 0)) <= 0 or int(low_support_recruitment.get("deserters", 0)) <= 0:
		failures.append("Низкая поддержка войны не создаёт уклонистов и дезертиров.")
	start_game("Сид: 1991", 1991)
	state.support = 99
	var capped := apply_effects({"support": 8})
	if int(state.get("support", 0)) != 100 or int(capped.get("support", 0)) != 1:
		failures.append("Экран результата не получает фактическое изменение после ограничения шкалы.")
	if clan_band(20) != "открытая враждебность" or clan_band(40) != "низкая поддержка" or clan_band(50) != "нейтральная позиция" or clan_band(60) != "высокая поддержка" or clan_band(80) != "критическая поддержка":
		failures.append("Пять состояний отношений групп имеют неверные границы.")
	if army_group_band(20) != "угроза переворота" or army_group_band(40) != "низкая лояльность" or army_group_band(50) != "неустойчивая лояльность" or army_group_band(65) != "высокая лояльность" or army_group_band(80) != "критическая лояльность":
		failures.append("Карточка армии имеет неверные диапазоны лояльности.")
	state.army = 65
	var guard_with_loyal_army := parliament_faction_base_score("guard")
	if army_loyalty_quality_modifier() != 5:
		failures.append("Высокая лояльность армии не повышает боеспособность.")
	state.army = 40
	var guard_with_disloyal_army := parliament_faction_base_score("guard")
	if army_loyalty_quality_modifier() != -7 or guard_with_loyal_army - guard_with_disloyal_army < 2:
		failures.append("Армия недостаточно влияет на боеспособность и Старую гвардию.")
	start_game("Сид: 1991", 1991)
	state.support = 70
	state.stability = 50
	process_weekly_budget_consequences(1)
	if int(state.get("stability", 0)) != 51:
		failures.append("Высокая поддержка не даёт +1 стабильность в неделю.")
	start_game("Сид: 1991", 1991)
	state.support = 40
	state.budget_social = 0
	update_social_protest_from_budget()
	if not bool(state.get("social_protest_pending", false)) or int(state.get("social_protest_due_week", 0)) != 2:
		failures.append("Сокращение социальных выплат при низкой поддержке не запланировало протесты.")
	state.week = 2
	if not should_trigger_social_protest():
		failures.append("Запланированный социальный протест не стал обязательным событием следующей недели.")
	var protest_required_before := events_required_this_week
	next_event()
	if str(current_event.get("title", "")) != "Пустые конверты" or events_required_this_week != protest_required_before + 1:
		failures.append("Протестный кризис не занял дополнительное место среди событий недели.")
	if str(current_event.get("source", "")) != "Марек Вольский" or str(current_event.get("right", {}).get("label", "")) != "Задержать организаторов":
		failures.append("Марек Вольский не предложил свой вариант решения социального протеста.")
	selected_ministers.interior = "kovach"
	current_event = social_protest_event.duplicate(true)
	customize_event_for_ministers()
	if str(current_event.get("source", "")) != "Ирина Ковач" or str(current_event.get("right", {}).get("label", "")) != "Признать совет протеста" or not bool(current_event.get("right", {}).get("set", {}).get("social_protest_civic_council", false)) or int(current_event.get("right", {}).get("effects", {}).get("army", 0)) != -2 or current_event.get("right", {}).get("effects", {}).has("money") or int(current_event.get("right", {}).get("effects", {}).get("stability", 0)) >= 0:
		failures.append("Ирина Ковач не предложила переговорный вариант социального протеста.")
	var kovach_with_brother := minister_initial_effects("interior", "kovach", minister_data("interior", "kovach"))
	selected_ministers.defense = "yun"
	current_event = social_protest_event.duplicate(true)
	customize_event_for_ministers()
	var kovach_without_brother := minister_initial_effects("interior", "kovach", minister_data("interior", "kovach"))
	if current_event.get("right", {}).get("effects", {}).has("army") or int(kovach_with_brother.get("army", 0)) >= 0 or kovach_without_brother.has("army"):
		failures.append("Либеральный подход Ковач вызывает недовольство армии без старшего брата во главе обороны.")
	selected_ministers.defense = "brother"
	selected_ministers.interior = "sava"
	current_event = social_protest_event.duplicate(true)
	customize_event_for_ministers()
	if str(current_event.get("source", "")) != "Антон Сава" or str(current_event.get("right", {}).get("label", "")) != "Передать спор регионам" or current_event.get("right", {}).get("effects", {}).has("money") or current_event.get("right", {}).get("effects", {}).has("corruption_tier") or not bool(current_event.get("right", {}).get("set", {}).get("regional_administration_disruption", false)):
		failures.append("Антон Сава не предложил региональный вариант решения социального протеста.")
	apply_state_flags({"social_budget_concession": true})
	state.week = 3
	if budget_level("budget_social") != 1 or not social_budget_reduction_locked() or social_budget_lock_weeks_left() != 4:
		failures.append("Уступка протестующим не вернула базовые выплаты или не заблокировала сокращение на месяц.")
	var spring_protest_template: Dictionary = {}
	for story_template in story_event_pool:
		if str(story_template.get("title", "")) == "Весна в столице":
			spring_protest_template = story_template
			break
	selected_ministers.defense = "brother"
	selected_ministers.interior = "kovach"
	current_event = spring_protest_template.duplicate(true)
	customize_event_for_ministers()
	if current_event.get("right", {}).get("effects", {}).has("money") or int(current_event.get("right", {}).get("effects", {}).get("stability", 0)) >= 0:
		failures.append("Ирина Ковач по-прежнему закрывает «Весну в столице» финансовой уступкой без политического дебафа.")
	selected_ministers.interior = "sava"
	current_event = spring_protest_template.duplicate(true)
	customize_event_for_ministers()
	if current_event.get("right", {}).get("effects", {}).has("money") or current_event.get("right", {}).get("effects", {}).has("corruption_tier") or not bool(current_event.get("right", {}).get("set", {}).get("regional_administration_disruption", false)):
		failures.append("Антон Сава закрывает «Весну в столице» без административного дебафа.")
	var liberal_army_options := 0
	selected_ministers.defense = "yun"
	for story_template in story_event_pool:
		for side in ["left", "right", "third"]:
			if not story_template.has(side):
				continue
			var template_option: Dictionary = story_template[side]
			if not bool(template_option.get("liberal_army_reaction", false)):
				continue
			liberal_army_options += 1
			if not (template_option.get("effects", {}) as Dictionary).has("army"):
				failures.append("Либеральное решение не содержит базовую реакцию армии при старшем брате.")
				continue
			current_event = story_template.duplicate(true)
			customize_event_for_ministers()
			if (current_event.get(side, {}).get("effects", {}) as Dictionary).has("army"):
				failures.append("После замены старшего брата либеральное решение всё ещё снижает отношение армии: %s." % str(template_option.get("label", "без названия")))
			selected_ministers.defense = "brother"
			customize_event_for_ministers()
			if not (current_event.get(side, {}).get("effects", {}) as Dictionary).has("army"):
				failures.append("После возвращения старшего брата реакция армии не восстановилась: %s." % str(template_option.get("label", "без названия")))
			selected_ministers.defense = "yun"
	if liberal_army_options < 1:
		failures.append("В сюжетном пуле не осталось решений, использующих общее правило реакции армии на либерализацию.")
	var operational_penalty_kept := false
	for story_template in story_event_pool:
		if str(story_template.get("title", "")) == "Самолёты с чужими кодами":
			current_event = story_template.duplicate(true)
			customize_event_for_ministers()
			operational_penalty_kept = (current_event.get("right", {}).get("effects", {}) as Dictionary).has("army")
			break
	if not operational_penalty_kept:
		failures.append("Смена брата ошибочно убрала практический штраф армии за отменённую закупку авиации.")
	start_game("Сид: 1991", 1991)
	if weekly_influence_cap() != 3:
		failures.append("Базовое финансирование аппарата должно давать 3 очка решений.")
	apply_state_flags({"regional_administration_disruption": true})
	state.week = int(state.get("week", 1)) + 1
	if weekly_influence_cap() != 2:
		failures.append("Передача протеста губернаторам не отняла одно очко решений на следующей неделе.")
	state.week = int(state.get("week", 1)) + 1
	if weekly_influence_cap() != 3:
		failures.append("Административный штраф Савы не завершился через одну неделю.")
	start_game("Сид: 1991", 1991)
	state.stability = 70
	if weekly_influence_cap() != 4:
		failures.append("Высокая стабильность не даёт дополнительное очко решений.")
	state.budget_admin = 0
	if weekly_influence_cap() != 3:
		failures.append("Сокращённый аппарат с высокой стабильностью должен давать 3 очка решений.")
	state.budget_admin = 2
	if weekly_influence_cap() != 5:
		failures.append("Приоритетный аппарат с высокой стабильностью должен давать 5 очков решений.")
	state.budget_admin = 1
	state.stability = 30
	if weekly_influence_cap() != 2:
		failures.append("Низкая стабильность не отнимает одно очко решений.")
	state.support = 50
	process_weekly_budget_consequences(1)
	if int(state.get("stability", 0)) != 30 or int(state.get("support", 0)) != 50:
		failures.append("Низкая стабильность по-прежнему пассивно снижает стабильность или поддержку.")
	state.clan_oligarchs = 65
	var center_supported := parliament_faction_base_score("center")
	state.clan_oligarchs = 20
	var center_hostile := parliament_faction_base_score("center")
	if center_supported - center_hostile < 3:
		failures.append("Олигархи недостаточно меняют позицию Президентского центра.")
	state.clan_oligarchs = 50
	state.support = 80
	var center_with_high_public_support := parliament_faction_base_score("center")
	state.support = 20
	if parliament_faction_base_score("center") != center_with_high_public_support:
		failures.append("Поддержка власти не должна менять позицию Президентского центра.")
	state.support = 50
	state.clan_oligarchs = 50
	state.clan_church = 80
	state.clan_workers = 50
	state.clan_regions = 50
	state.secular_education = false
	var church_effects := weekly_clan_effects()
	if int(church_effects.get("war_support", 0)) != 2 or not is_equal_approx(church_birth_rate_modifier(), 0.20):
		failures.append("Критическая поддержка Церкви не повышает поддержку войны и рождаемость.")
	state.secular_education = true
	church_effects = weekly_clan_effects()
	if int(church_effects.get("war_support", 0)) != 1 or not is_equal_approx(church_birth_rate_modifier(), 0.10):
		failures.append("Светское образование не ослабляет вдвое положительное влияние Церкви.")
	state.clan_church = 20
	if int(weekly_clan_effects().get("support", 0)) != -2:
		failures.append("Светское образование не ослабляет вдвое отрицательное влияние Церкви.")
	state.clan_church = 50
	state.secular_education = false
	state.clan_workers = 20
	if workers_public_support_effect() != -2 or int(weekly_clan_effects().get("support", 0)) != -2:
		failures.append("Враждебность профсоюзов не снижает поддержку власти.")
	state.clan_workers = 80
	if workers_public_support_effect() != 2 or int(weekly_clan_effects().get("support", 0)) != 2:
		failures.append("Критическая поддержка профсоюзов не повышает поддержку власти.")
	state.clan_workers = 50
	state.clan_regions = 80
	if regional_stability_effect() != 2 or int(weekly_clan_effects().get("stability", 0)) != 2:
		failures.append("Критическая поддержка регионов не укрепляет стабильность.")
	state.clan_regions = 20
	if regional_stability_effect() != -2 or int(weekly_clan_effects().get("stability", 0)) != -2:
		failures.append("Враждебность регионов не снижает стабильность.")
	state.army = 20
	if army_loyalty_quality_modifier() != -15:
		failures.append("Враждебность армии не снижает боеспособность.")
	if weekly_clan_effect_notes().is_empty():
		failures.append("В недельной сводке не объясняется действие группы.")
	state.media_restricted = false
	if int(apply_media_support_filter({"support": -9}).get("support", 0)) != -9:
		failures.append("Свободные СМИ ошибочно смягчают цену непопулярного решения.")
	state.media_restricted = true
	if int(apply_media_support_filter({"support": -9}).get("support", 0)) != -6:
		failures.append("Ограничение СМИ не смягчает потерю поддержки на треть.")
	start_game("Сид: 1991", 1991)
	state.budget_social = 0
	process_weekly_budget_consequences(1)
	if int(state.get("support", 0)) != 56 or int(state.get("clan_workers", 0)) != 45:
		failures.append("Сокращение социальной помощи не проявилось уже на следующей неделе.")
	start_game("Сид: 1991", 1991)
	state.support = 20
	if not main_stat_caption_color("support").is_equal_approx(RED):
		failures.append("Низкая поддержка не окрашивает название показателя в красный.")
	state.support = 75
	if not main_stat_caption_color("support").is_equal_approx(GREEN):
		failures.append("Высокая поддержка не окрашивает название показателя в зелёный.")
	state.support = 50
	queue_week_change("Тест цветового прогноза", {"support": -15})
	if not main_stat_caption_color("support").is_equal_approx(RED):
		failures.append("Опасное ожидаемое значение не окрашивает название показателя заранее.")
	pending_week_changes.clear()
	state.clan_oligarchs = 50
	state.clan_church = 50
	state.clan_workers = 50
	state.clan_regions = 50
	queue_week_change("Тест отложенного решения", {"support": -5}, {"deferred_test_flag": true})
	if int(state.get("support", 0)) != 50 or bool(state.get("deferred_test_flag", false)):
		failures.append("Решение изменило состояние страны до завершения недели.")
	update_interface()
	var projected_support_label: Label = stat_labels.get("support")
	if not is_instance_valid(projected_support_label) or projected_support_label.text != "45%" or not projected_support_label.get_theme_color("font_color").is_equal_approx(PENDING_BLUE):
		failures.append("Ожидаемая поддержка до конца недели не показана голубым цветом.")
	event_resolved = true
	events_resolved_this_week = events_required_this_week
	weekly_event_queue.clear()
	state.financial_slot_consumed = true
	advance_week()
	if int(state.get("support", 0)) != 45 or not bool(state.get("deferred_test_flag", false)) or not pending_week_changes.is_empty():
		failures.append("Отложенные последствия не применились при переходе недели.")
	start_game("Сид: 1991", 1991)
	begin_law("Антикоррупционное бюро", 3, 2)
	var spent_influence_after_law_start := int(state.get("influence", 0))
	cancel_active_law(false)
	if active_law != "" or law_progress != 0 or int(state.get("influence", 0)) != spent_influence_after_law_start:
		failures.append("Отмена закона не очищает проект либо ошибочно возвращает потраченные очки.")
	start_game("Сид: 1991", 1991)
	begin_law("Антикоррупционное бюро", 3, 2)
	if law_progress != 1 or int(state.get("influence", 0)) != weekly_influence_cap() - 2:
		failures.append("Первый этап выбранного закона не был оплачен сразу.")
	event_resolved = true
	events_resolved_this_week = events_required_this_week
	weekly_event_queue.clear()
	state.financial_slot_consumed = true
	advance_week()
	if law_progress != 2 or int(state.get("influence", 0)) != weekly_influence_cap() - 2:
		failures.append("Новая неделя не продвинула активный закон автоматически.")
	law_worked_this_week = false
	state.influence = weekly_influence_cap()
	var completed_law_note := progress_active_law_stage(false)
	if active_law != "" or not law_enacted("Антикоррупционное бюро") or not completed_law_note.contains("принят автоматически"):
		failures.append("Последний этап закона не завершился без повторного нажатия кнопки.")
	start_game("Сид: 1991", 1991)
	if emergency_powers_lock_reason() == "":
		failures.append("Чрезвычайные полномочия доступны в мирное время.")
	state.at_war = true
	state.stability = EMERGENCY_POWERS_MAX_STABILITY + 1
	if emergency_powers_lock_reason() == "":
		failures.append("Чрезвычайные полномочия доступны при устойчивой работе государства.")
	state.stability = EMERGENCY_POWERS_MAX_STABILITY
	if emergency_powers_lock_reason() != "":
		failures.append("Чрезвычайные полномочия не открылись во время войны при низкой стабильности.")
	begin_law("Чрезвычайные полномочия", 2, 1)
	state.at_war = false
	law_worked_this_week = false
	state.influence = weekly_influence_cap()
	var paused_emergency_progress := law_progress
	var paused_emergency_note := progress_active_law_stage(false)
	if law_progress != paused_emergency_progress or not paused_emergency_note.contains("приостановлена"):
		failures.append("Подготовка чрезвычайных полномочий продолжилась после окончания войны.")
	var emergency_effects := emergency_powers_effects()
	for group_key in ["clan_oligarchs", "clan_church", "clan_workers", "clan_regions"]:
		if int(emergency_effects.get(group_key, 0)) >= 0:
			failures.append("Чрезвычайные полномочия не ухудшают отношения с группой %s." % group_key)
	if int(emergency_effects.get("support", 0)) >= 0 or int(emergency_effects.get("army", 0)) <= 0:
		failures.append("Чрезвычайные полномочия должны снижать поддержку власти, но не отношение армии.")
	start_game("Сид: 1991", 1991)
	state.at_war = true
	state.stability = EMERGENCY_POWERS_MAX_STABILITY
	state.support = 49
	begin_law("Чрезвычайные полномочия", 1, 1)
	if not emergency_powers_override_active():
		failures.append("Принятые чрезвычайные полномочия не позволяют обходить парламент.")
	if int(state.get("support", 0)) > 40 or not bool(state.get("emergency_powers_protest_pending", false)) or not should_trigger_emergency_powers_protest():
		failures.append("Чрезвычайные полномочия при низкой итоговой поддержке не запланировали протест.")
	current_event = emergency_powers_protest_event.duplicate(true)
	customize_event_for_ministers()
	if str(current_event.get("right", {}).get("label", "")) != "Задержать координаторов":
		failures.append("Протест против чрезвычайных полномочий не учитывает министра внутренних дел.")
	current_event = social_protest_event.duplicate(true)
	customize_event_for_ministers()
	if str(current_event.get("third", {}).get("label", "")) != "Ввести комендантский час":
		failures.append("Чрезвычайные полномочия не изменили силовой вариант социального протеста.")
	current_event = spring_protest_template.duplicate(true)
	customize_event_for_ministers()
	if str(current_event.get("third", {}).get("label", "")) != "Изолировать площадь":
		failures.append("Чрезвычайные полномочия не открыли вариант изоляции студенческого протеста.")
	apply_state_flags({"emergency_powers_repealed": true})
	if emergency_powers_override_active():
		failures.append("Отмена чрезвычайных полномочий не вернула парламентский контроль.")
	if failures.is_empty():
		print("CONSEQUENCE_SMOKE_TEST: OK | deferred_week=yes | law_cancel=yes | routine=1→%d,−2→%d | clan_states=5 | parliament_swing=%d | emergency_law=override+protest+repeal | law_auto=yes" % [int(routine.get("support", 0)), int(routine.get("stability", 0)), center_supported - center_hostile])
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("CONSEQUENCE_SMOKE_TEST: " + failure)
		get_tree().quit(1)


func story_event_signature(sort_ids: bool) -> String:
	var story_ids: Array[String] = []
	for story_event in events:
		story_ids.append(str(story_event.get("_story_id", story_event.get("title", ""))))
	if sort_ids:
		story_ids.sort()
	return join_signature(story_ids)


func recurring_event_signature(sort_variants: bool) -> String:
	var variants: Array[String] = []
	for routine_event in recurring_events:
		variants.append(str(routine_event.get("_generation_key", "")))
	if sort_variants:
		variants.sort()
	return join_signature(variants)


func join_signature(parts: Array[String]) -> String:
	var signature := ""
	for variant in parts:
		if signature != "":
			signature += "||"
		signature += variant
	return signature


func option_effects_dominate(first: Dictionary, second: Dictionary) -> bool:
	var positive_metrics := ["money", "support", "stability", "army", "war_support", "clan_oligarchs", "clan_church", "clan_workers", "clan_regions"]
	var strict_advantage := false
	for key in positive_metrics:
		var first_value := float(first.get(key, 0.0))
		var second_value := float(second.get(key, 0.0))
		if first_value < second_value:
			return false
		if first_value > second_value:
			strict_advantage = true
	return strict_advantage


func greedy_immediate_side(event_data: Dictionary) -> String:
	var best_side := "left"
	var best_score := -INF
	var available_sides: Array[String] = ["left", "right"]
	if event_data.has("third"):
		available_sides.append("third")
	for side in available_sides:
		var candidate: Dictionary = event_data[side]
		if bool(candidate.get("unavailable", false)):
			continue
		var effects: Dictionary = candidate.get("effects", {})
		var money_effect := adjusted_money_transaction(float(effects.get("money", 0.0)), int(state.get("corruption_tier", 0)))
		var score := money_effect * (2.0 if float(state.get("money", 0.0)) < 35.0 else 0.7)
		score += float(effects.get("support", 0)) * 0.45
		score += float(effects.get("stability", 0)) * 0.65
		score += float(effects.get("army", 0)) * 0.30
		score -= float(effects.get("corruption_tier", 0)) * 5.0
		score -= float(effects.get("debt", 0)) * 0.03
		score -= float(effects.get("creditor_obligations", 0)) * 1.5
		if score > best_score:
			best_score = score
			best_side = str(side)
	return best_side


func adaptive_side(event_data: Dictionary) -> String:
	var best_side := "left"
	var best_score := -INF
	var available_sides: Array[String] = ["left", "right"]
	if event_data.has("third"):
		available_sides.append("third")
	var money_now := projected_pending_float("money")
	var support_now := projected_pending_value("support")
	var stability_now := projected_pending_value("stability")
	var army_now := projected_pending_value("army")
	var war_support_now := projected_pending_value("war_support")
	var at_war: bool = bool(state.get("at_war", false))
	for side in available_sides:
		var candidate: Dictionary = event_data[side]
		if bool(candidate.get("unavailable", false)):
			continue
		var effects: Dictionary = amplify_decision_effects(candidate.get("effects", {}), str(event_data.get("_kind", "general")))
		var money_effect := adjusted_money_transaction(float(effects.get("money", 0.0)), projected_corruption_tier())
		var money_weight := 8.0 if money_now < 18.0 else 5.0 if money_now < 30.0 else 2.0
		var support_weight := 5.0 if support_now <= 15 else 3.2 if support_now <= 30 else 1.4 if support_now <= 50 else 0.55
		var stability_weight := 4.5 if stability_now <= 15 else 2.8 if stability_now <= 38 else 1.2 if stability_now <= 52 else 0.55
		var army_weight := 4.0 if army_now <= 15 else 2.2 if army_now <= 38 else 0.9 if army_now <= 52 else 0.40
		var score := money_effect * money_weight
		score += float(effects.get("support", 0)) * support_weight
		score += float(effects.get("stability", 0)) * stability_weight
		score += float(effects.get("army", 0)) * army_weight
		var war_support_weight := 0.15
		if at_war:
			war_support_weight = 4.5 if war_support_now <= 15 else 3.0 if war_support_now <= 30 else 1.35
		score += float(effects.get("war_support", 0)) * war_support_weight
		score -= float(effects.get("corruption_tier", 0)) * 9.0
		score -= float(effects.get("debt", 0)) * 0.035
		score -= float(effects.get("creditor_obligations", 0)) * 2.0
		score += float(effects.get("east_relation", 0)) * 0.55
		score += float(effects.get("west_relation", 0)) * 0.55
		score += float(effects.get("army_aircraft", 0)) * 0.35
		score += float(effects.get("army_equipment", 0)) * 0.04
		for clan_key in ["clan_oligarchs", "clan_church", "clan_workers", "clan_regions"]:
			var clan_now := int(state.get(clan_key, 50))
			var clan_delta := int(effects.get(clan_key, 0))
			var clan_weight := 0.55 if clan_now <= 38 else 0.25
			score += float(clan_delta) * clan_weight
		if money_effect < 0.0 and money_now + money_effect <= maxf(8.0, weekly_actual_expenses()):
			score -= 30.0
		if at_war and war_support_now + int(effects.get("war_support", 0)) <= 0:
			score -= 200.0
		if support_now + int(effects.get("support", 0)) <= 0:
			score -= 200.0
		if stability_now + int(effects.get("stability", 0)) <= 0:
			score -= 200.0
		if army_now + int(effects.get("army", 0)) <= 0:
			score -= 200.0
		var flags: Dictionary = candidate.get("flags", {})
		if bool(flags.get("war_medical_priority", false)):
			score += 12.0
		if bool(flags.get("war_ammo_conservation", false)):
			score += 9.0
		if bool(flags.get("war_frontline_retreat", false)) and int(state.get("army_personnel", 0)) < frontline_required_personnel() + 10000:
			score += 10.0
		if score > best_score:
			best_score = score
			best_side = str(side)
	return best_side


func run_campaign_smoke_test() -> void:
	start_game("Сид: 1991", 1991)
	# Этот тест проверяет структуру 26-недельной очереди, а не сложность.
	# Запас исключает случайное поражение и оставляет баланс отдельному тесту.
	state.money = 500.0
	state.support = 75
	state.stability = 75
	state.army = 75
	var resolved_events := 0
	var last_resolved_title := ""
	var last_story_title := ""
	var resolved_by_kind := {"core": 0, "routine": 0, "urgent": 0}
	var closed_weeks := 0
	var minimum_events_in_week := 999
	var cycle_valid := true
	var safety_counter := 0
	while int(state.get("week", 1)) <= DEMO_WEEKS and not current_event.is_empty() and safety_counter < 150:
		safety_counter += 1
		if event_resolved:
			cycle_valid = false
			break
		last_resolved_title = str(current_event.get("_wartime_replacement_for", current_event.get("title", "")))
		var event_kind := str(current_event.get("_kind", ""))
		if not resolved_by_kind.has(event_kind):
			cycle_valid = false
			break
		if event_kind == "core":
			last_story_title = last_resolved_title
		var best_side := greedy_immediate_side(current_event)
		var picked: Dictionary = current_event[best_side]
		apply_effects(amplify_decision_effects(picked.get("effects", {}), str(current_event.get("_kind", "general"))))
		apply_option_flags(picked)
		# Структурный прогон не оценивает баланс: сохраняем запас после каждого
		# случайного выбора, чтобы новые пассивные эффекты групп не обрывали очередь.
		state.money = maxf(float(state.get("money", 0.0)), 500.0)
		state.support = maxi(int(state.get("support", 0)), 75)
		state.stability = maxi(int(state.get("stability", 0)), 75)
		state.army = maxi(int(state.get("army", 0)), 75)
		state.war_support = maxi(int(state.get("war_support", 0)), 75)
		state.army_personnel = maxi(int(state.get("army_personnel", 0)), 90000)
		state.army_equipment = maxi(int(state.get("army_equipment", 0)), 600)
		state.army_aircraft = maxi(int(state.get("army_aircraft", 0)), 30)
		event_resolved = true
		events_resolved_this_week += 1
		resolved_events += 1
		resolved_by_kind[event_kind] = int(resolved_by_kind[event_kind]) + 1
		if float(state.get("money", 0.0)) <= 0.0 or int(state.get("support", 0)) <= 0 or int(state.get("stability", 0)) <= 0 or int(state.get("army", 0)) <= 0:
			break
		if week_ready_for_new_week():
			minimum_events_in_week = mini(minimum_events_in_week, events_resolved_this_week)
			if events_resolved_this_week < EVENTS_PER_WEEK:
				cycle_valid = false
				break
			closed_weeks += 1
			advance_week()
		else:
			next_event()
	var baseline_events := DEMO_WEEKS * EVENTS_PER_WEEK
	var urgent_events := int(resolved_by_kind["urgent"])
	var survived := (
		cycle_valid
		and safety_counter < 150
		and resolved_events == baseline_events + urgent_events
		and int(resolved_by_kind["core"]) == DEMO_WEEKS
		and int(resolved_by_kind["routine"]) == DEMO_WEEKS * (EVENTS_PER_WEEK - 1)
		and urgent_events <= 40
		and closed_weeks == DEMO_WEEKS
		and minimum_events_in_week >= EVENTS_PER_WEEK
		and int(state.get("week", 0)) == DEMO_WEEKS + 1
		and last_story_title == "Досрочные выборы"
		and last_resolved_title == "Досрочные выборы"
		and float(state.get("money", 0.0)) > 0.0
		and int(state.get("support", 0)) > 0
		and int(state.get("stability", 0)) > 0
		and int(state.get("army", 0)) > 0
	)
	if survived:
		print("CAMPAIGN_SMOKE_TEST: OK | resolved=%d | core=%d | routine=%d | urgent=%d | min_week=%d | money=%.2f | support=%d | stability=%d" % [resolved_events, int(resolved_by_kind["core"]), int(resolved_by_kind["routine"]), urgent_events, minimum_events_in_week, float(state.get("money", 0.0)), int(state.get("support", 0)), int(state.get("stability", 0))])
		get_tree().quit(0)
	else:
		push_error("CAMPAIGN_SMOKE_TEST: stopped after %d events on week %d | core=%d routine=%d urgent=%d closed=%d last=%s" % [resolved_events, int(state.get("week", 0)), int(resolved_by_kind["core"]), int(resolved_by_kind["routine"]), urgent_events, closed_weeks, last_resolved_title])
		get_tree().quit(1)


func run_difficulty_smoke_test() -> void:
	var failures: Array[String] = []
	var test_seed := 1991
	for argument in OS.get_cmdline_user_args():
		if str(argument).begins_with("--test-seed="):
			test_seed = str(argument).trim_prefix("--test-seed=").to_int()
	start_game("Сид: %d" % test_seed, test_seed)
	var starting_delta := weekly_actual_income() - weekly_actual_expenses()
	if starting_delta > -0.80 or starting_delta < -2.20:
		failures.append("Стартовый недельный баланс должен быть умеренным дефицитом, а не профицитом или немедленной катастрофой.")
	for key in ["budget_social", "budget_health", "budget_admin", "budget_defense", "budget_debt", "budget_infrastructure"]:
		state[key] = 0
	var austerity_support_start := int(state.get("support", 0))
	var austerity_stability_start := int(state.get("stability", 0))
	var austerity_debt_start := float(state.get("debt", 0.0))
	for closed_week in range(1, 9):
		process_weekly_budget_consequences(closed_week)
	var austerity_support_end := int(state.get("support", 0))
	var austerity_stability_end := int(state.get("stability", 0))
	var austerity_debt_end := float(state.get("debt", 0.0))
	if austerity_support_start - austerity_support_end < 8:
		failures.append("Восемь недель сокращения социальной помощи почти не влияют на поддержку.")
	if austerity_stability_start - austerity_stability_end < 10:
		failures.append("Одновременное сокращение школ, больниц и инфраструктуры недостаточно опасно.")
	if austerity_debt_end - austerity_debt_start < 48.0:
		failures.append("Сокращённое обслуживание долга не накапливает обязательства каждую неделю.")
	start_game("Сид: %d" % test_seed, test_seed)
	state.east_relation = 0
	var eastern_response_cost := 0.0
	for item in weekly_nonbudget_expense_breakdown():
		if str(item.get("title", "")) == "Проверки Восточного Союза":
			eastern_response_cost = absf(float(item.get("amount", 0.0)))
	if eastern_response_cost < 2.49:
		failures.append("Враждебные отношения с Восточным Союзом не превращаются в видимое экономическое действие.")
	start_game("Сид: %d" % test_seed, test_seed)
	var resolved_events := 0
	var safety_counter := 0
	while int(state.get("week", 1)) <= DEMO_WEEKS and not current_event.is_empty() and safety_counter < 100:
		safety_counter += 1
		var picked_side := greedy_immediate_side(current_event)
		var picked: Dictionary = current_event[picked_side]
		apply_effects(amplify_decision_effects(picked.get("effects", {}), str(current_event.get("_kind", "general"))))
		apply_option_flags(picked)
		event_resolved = true
		events_resolved_this_week += 1
		resolved_events += 1
		if float(state.get("money", 0.0)) <= 0.0 or int(state.get("support", 0)) <= 0 or int(state.get("stability", 0)) <= 0 or int(state.get("army", 0)) <= 0:
			break
		if week_ready_for_new_week():
			advance_week()
		else:
			next_event()
		if float(state.get("money", 0.0)) <= 0.0 or int(state.get("support", 0)) <= 0 or int(state.get("stability", 0)) <= 0 or int(state.get("army", 0)) <= 0:
			break
	var naive_completed := int(state.get("week", 0)) > DEMO_WEEKS and resolved_events >= DEMO_WEEKS * EVENTS_PER_WEEK
	var naive_comfortable := (
		naive_completed
		and float(state.get("money", 0.0)) > 25.0
		and int(state.get("support", 0)) > 40
		and int(state.get("stability", 0)) > 25
		and int(state.get("army", 0)) > 40
	)
	if naive_comfortable:
		failures.append("Жадная стратегия по немедленной выгоде завершила кампанию с безопасным запасом по всем системам.")
	if int(state.get("week", 0)) < 10:
		failures.append("Жадная стратегия проигрывает слишком рано: сложность стала резкой, а не обучаемой.")
	if failures.is_empty():
		var naive_outcome := "критический финиш" if naive_completed else "поражение"
		print("DIFFICULTY_SMOKE_TEST: OK | seed=%d | start_balance=%+.2f | austerity_support=%d | austerity_stability=%d | austerity_debt=%.2f | naive=%s week=%d | resolved=%d" % [test_seed, starting_delta, austerity_support_end, austerity_stability_end, austerity_debt_end, naive_outcome, int(state.get("week", 0)), resolved_events])
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("DIFFICULTY_SMOKE_TEST: " + failure)
		get_tree().quit(1)


func configure_adaptive_test_budget() -> void:
	# Имитируем игрока, который читает прогноз: сохраняет базовые услуги,
	# временно экономит на аппарате и прекращает необязательный выпуск техники.
	# При снижении резерва он заранее переходит к экономии, потому что кризисный
	# выпуск или кредит доступны только один раз за всю кампанию.
	var at_war: bool = bool(state.get("at_war", false))
	var cash := float(state.get("money", 0.0))
	var reserve_mode := cash <= 40.0
	state.metal_to_equipment = current_metal_output() if at_war and (cash > 34.0 or int(state.get("army_equipment", 0)) < 180) else 0
	state.oil_to_army = mini(current_oil_output(), army_oil_need() if at_war else (0 if reserve_mode else ceili(float(army_oil_need()) * 0.75)))
	state.budget_admin = 0
	state.budget_social = 2 if int(state.get("support", 0)) <= 30 and cash > 26.0 else 1
	state.budget_health = 2 if (at_war and cash > 32.0) or int(state.get("stability", 0)) <= 30 else 1
	state.budget_infrastructure = 0 if reserve_mode else 2 if int(state.get("stability", 0)) <= 30 else 1
	state.budget_defense = 0 if reserve_mode and not at_war else 2 if (at_war and cash > 28.0) or int(state.get("army", 0)) <= 36 else 1
	state.budget_debt = 0 if cash <= 38.0 else 1


func run_adaptive_smoke_test() -> void:
	# Сид 77 фиксирует кампанию, в которой осмотрительный маршрут остаётся
	# проходимым без повторного доступа к экстренной эмиссии или кредиту.
	var test_seed := 77
	for argument in OS.get_cmdline_user_args():
		if str(argument).begins_with("--test-seed="):
			test_seed = str(argument).trim_prefix("--test-seed=").to_int()
	start_game("Сид: %d" % test_seed, test_seed)
	var resolved_events := 0
	var configured_week := 0
	var safety_counter := 0
	while int(state.get("week", 1)) <= DEMO_WEEKS and not current_event.is_empty() and safety_counter < 110:
		safety_counter += 1
		if configured_week != int(state.get("week", 1)):
			configured_week = int(state.get("week", 1))
			configure_adaptive_test_budget()
		var picked_side := adaptive_side(current_event)
		var picked: Dictionary = current_event[picked_side]
		var test_effects := amplify_decision_effects(picked.get("effects", {}), str(current_event.get("_kind", "general")))
		queue_week_change("Автотест: %s" % str(current_event.get("title", "Событие")), test_effects, picked.get("set", {}))
		event_resolved = true
		events_resolved_this_week += 1
		resolved_events += 1
		if week_ready_for_new_week():
			advance_week()
			if float(state.get("money", 0.0)) <= 0.0 or int(state.get("support", 0)) <= 0 or int(state.get("stability", 0)) <= 0 or int(state.get("army", 0)) <= 0:
				break
		else:
			next_event()
	var completed := (
		int(state.get("week", 0)) == DEMO_WEEKS + 1
		and resolved_events >= DEMO_WEEKS * EVENTS_PER_WEEK
		and float(state.get("money", 0.0)) > 0.0
		and int(state.get("support", 0)) > 0
		and int(state.get("stability", 0)) > 0
		and int(state.get("army", 0)) > 0
	)
	if completed:
		print("ADAPTIVE_SMOKE_TEST: OK | seed=%d | resolved=%d | money=%.2f | support=%d | stability=%d | army=%d | debt=%.2f" % [test_seed, resolved_events, float(state.get("money", 0.0)), int(state.get("support", 0)), int(state.get("stability", 0)), int(state.get("army", 0)), float(state.get("debt", 0.0))])
		get_tree().quit(0)
	else:
		push_error("ADAPTIVE_SMOKE_TEST: seed=%d stopped after %d events on week %d | money=%.2f support=%d stability=%d army=%d debt=%.2f | last=%s" % [test_seed, resolved_events, int(state.get("week", 0)), float(state.get("money", 0.0)), int(state.get("support", 0)), int(state.get("stability", 0)), int(state.get("army", 0)), float(state.get("debt", 0.0)), str(current_event.get("title", ""))])
		get_tree().quit(1)


func run_financial_crisis_smoke_test() -> void:
	var failures: Array[String] = []
	start_game("Сид: 1991", 1991)
	state.corruption_tier = 0
	var opening_money := float(state.get("money", 0.0))
	var opening_debt := float(state.get("debt", 0.0))
	var fund_option: Dictionary = financial_crisis_event.get("right", {})
	var austerity_option: Dictionary = creditor_review_event.get("left", {})
	if (austerity_option.get("effects", {}) as Dictionary).has("corruption_tier"):
		failures.append("Требования Международного фонда не должны снижать внутреннюю коррупцию.")
	apply_effects(fund_option.get("effects", {}))
	apply_option_flags(fund_option)
	if not is_equal_approx(float(state.get("money", 0.0)) - opening_money, 27.44) or not is_equal_approx(float(state.get("debt", 0.0)) - opening_debt, 40.0):
		failures.append("Кредит фонда неверно перечисляет деньги или снова создаёт несоразмерный основной долг.")
	if int(state.get("creditor_obligations", 0)) != 2 or not bool(state.get("creditor_review_pending", false)):
		failures.append("Кредит фонда не создал обязательные условия и будущую проверку кредиторов.")
	start_game("Сид: 1991", 1991)
	apply_state_flags({"printed_money": true})
	if int(state.get("emission_shock_weeks", 0)) != EMISSION_SHOCK_WEEKS or int(state.get("emission_shock_elapsed", -1)) != 0:
		failures.append("Печать денег не запускает шестинедельный инфляционный шок.")
	var emission_cost_found := false
	for expense in weekly_nonbudget_expense_breakdown():
		if str(expense.get("title", "")) == "Инфляционное удорожание после эмиссии" and is_equal_approx(float(expense.get("amount", 0.0)), -1.20):
			emission_cost_found = true
			break
	if not emission_cost_found:
		failures.append("Инфляционный шок не добавляет 1.20 млн к недельным расходам.")
	var emission_support_loss := 0
	for emission_week in range(EMISSION_SHOCK_WEEKS):
		var emission_result := process_emission_shock_week()
		emission_support_loss += int(emission_result.get("support_loss", 0))
	if int(state.get("emission_shock_weeks", -1)) != 0 or int(state.get("emission_shock_elapsed", 0)) != EMISSION_SHOCK_WEEKS:
		failures.append("Инфляционный шок не завершился ровно через шесть недель.")
	if emission_support_loss != 4:
		failures.append("За шесть недель эмиссия должна дважды отнять по 2 пункта поддержки.")
	for expense in weekly_nonbudget_expense_breakdown():
		if str(expense.get("title", "")) == "Инфляционное удорожание после эмиссии":
			failures.append("Удорожание после эмиссии не закончилось после шестой недели.")
			break
	start_game("Сид: 1991", 1991)
	state.corruption_tier = 0
	apply_effects(fund_option.get("effects", {}))
	apply_option_flags(fund_option)
	state.week = int(state.get("creditor_review_due_week", 0))
	event_resolved = true
	next_event()
	if str(current_event.get("title", "")) != "Условия кредитной линии" or str(current_event.get("_kind", "")) != "urgent":
		failures.append("Требования кредиторов не появились отдельным срочным докладом в назначенный срок.")
	var demand_key := str(state.get("creditor_demand_budget_key", ""))
	if demand_key not in CREDITOR_AUSTERITY_TARGETS:
		failures.append("Фонд не выбрал конкретную статью для четырёхнедельного сокращения.")
	var review_left: Dictionary = current_event.get("left", {})
	var review_right: Dictionary = current_event.get("right", {})
	var review_refusal: Dictionary = current_event.get("third", {})
	if not bool((review_left.get("set", {}) as Dictionary).get("creditor_austerity_accepted", false)):
		failures.append("Первый ответ фонду не запускает обязательное сокращение расходов.")
	if not bool((review_right.get("set", {}) as Dictionary).get("creditor_debt_priority_accepted", false)):
		failures.append("Второй ответ фонду не запускает приоритетное обслуживание долга.")
	var refusal_effects: Dictionary = review_refusal.get("effects", {})
	if float(refusal_effects.get("money", 0.0)) >= 0.0 or int(refusal_effects.get("debt", 0)) < 10 or int(refusal_effects.get("stability", 0)) > -8 or int(refusal_effects.get("creditor_obligations", 0)) < 1:
		failures.append("Отказ от требований фонда не создаёт обещанных серьёзных последствий.")
	apply_state_flags(review_left.get("set", {}))
	state.week = int(state.get("week", 1)) + 1
	if budget_level(demand_key) != 0 or not creditor_budget_lock_active(demand_key) or creditor_budget_lock_weeks_left() != 4 or creditor_budget_change_allowed(demand_key, 1):
		failures.append("Сокращённую фондом статью можно изменить раньше четырёх недель.")
	start_game("Сид: 1991", 1991)
	apply_state_flags({"creditor_debt_priority_accepted": true})
	state.week = int(state.get("week", 1)) + 1
	if budget_level("budget_debt") != 2 or not creditor_budget_lock_active("budget_debt") or creditor_budget_lock_weeks_left() != 4 or creditor_budget_change_allowed("budget_debt", 1):
		failures.append("Приоритет выплат долга не закреплён на четыре недели.")
	start_game("Сид: 1991", 1991)
	var story_queue_before := event_queue.size()
	var required_before := events_required_this_week
	# Создаём гарантированный кассовый разрыв при ещё положительной казне.
	# Коррупция не меняет расходы, поэтому для теста резко увеличиваем долг.
	state.debt = 10000.0
	state.money = 0.01
	state.financial_slot_consumed = false
	event_resolved = true
	events_resolved_this_week = 1
	if weekly_balance_forecast() > 0.0:
		failures.append("Тестовый сценарий не создал прогноз пустой казны.")
	if should_trigger_financial_crisis():
		failures.append("Событие «Счета к оплате» появилось раньше последних двух дней недели.")
	events_resolved_this_week = EVENTS_PER_WEEK
	weekly_event_queue.clear()
	next_event()
	if str(current_event.get("title", "")) != "Счета к оплате":
		failures.append("После трёх обычных докладов при пустом прогнозе не показано событие «Счета к оплате».")
	if str(current_event.get("_kind", "")) != "urgent":
		failures.append("Финансовый кризис не помечен как срочный дополнительный доклад.")
	if "два дня" not in str(current_event.get("body", "")):
		failures.append("Срочный доклад не объясняет, что до обязательных выплат осталось два дня.")
	if event_queue.size() != story_queue_before:
		failures.append("Условный кризис изменил будущую сюжетную очередь.")
	if events_required_this_week != required_before + 1 or events_resolved_this_week != EVENTS_PER_WEEK:
		failures.append("Финансовый кризис не увеличил недельный план с трёх до четырёх событий.")
	if not current_event.has("third") or str(current_event.get("third", {}).get("label", "")) != "Ничего не делать":
		failures.append("Третье решение финансового кризиса недоступно.")
	elif not (current_event["third"].get("effects", {}) as Dictionary).is_empty():
		failures.append("Бездействие ошибочно добавляет числовой эффект в расчёт недели.")
	if not bool(state.get("financial_crisis_shown", false)) or not bool(state.get("financial_slot_consumed", false)):
		failures.append("Показанный кризис не помечен использованным и может повториться.")
	state.financial_slot_consumed = false
	if should_trigger_financial_crisis():
		failures.append("Событие «Счета к оплате» повторно появилось после первого показа в той же кампании.")
	event_resolved = true
	events_resolved_this_week += 1
	if events_resolved_this_week != EVENTS_PER_WEEK + 1 or not weekly_event_queue.is_empty() or not week_ready_for_new_week():
		failures.append("Неделя с кризисом не завершилась после четырёх решений.")
	if failures.is_empty():
		print("FINANCIAL_CRISIS_SMOKE_TEST: OK | required=%d | resolved=%d | third_choice=yes | baseline_preserved=yes" % [events_required_this_week, events_resolved_this_week])
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("FINANCIAL_CRISIS_SMOKE_TEST: " + failure)
		get_tree().quit(1)


func run_scroll_smoke_test() -> void:
	var failures: Array[String] = []
	start_game("Сид: 1991", 1991)
	show_economy()
	await get_tree().process_frame
	await get_tree().process_frame
	active_overlay_scroll.scroll_vertical = 420
	await get_tree().process_frame
	var economy_target := active_overlay_scroll.scroll_vertical
	if economy_target <= 0:
		failures.append("Экономика не создала прокручиваемую область для теста.")
	var budget_icon_count := 0
	for node in overlay.find_children("BudgetIcon_*", "Button", true, false):
		if node is Button:
			budget_icon_count += 1
	if budget_icon_count != WEEKLY_BUDGET_LINES.size():
		failures.append("Экономика должна показывать шесть компактных кнопок регулируемых расходов.")
	show_budget_level_selector("budget_social", economy_target)
	await get_tree().process_frame
	await get_tree().process_frame
	var budget_level_count := 0
	for node in overlay.find_children("BudgetLevel_*", "PanelContainer", true, false):
		if node is PanelContainer:
			budget_level_count += 1
	if budget_level_count != 3:
		failures.append("Окно статьи бюджета должно одновременно показывать три уровня расходов.")
	set_budget_draft_level("budget_social", 2, economy_target)
	await get_tree().process_frame
	await get_tree().process_frame
	if draft_budget_level("budget_social") != 2 or not is_instance_valid(active_overlay_scroll) or absi(active_overlay_scroll.scroll_vertical - economy_target) > 2:
		failures.append("Выбор уровня не сохранился в черновике или сбросил позицию экономики.")
	change_resource_allocation("metal_to_equipment", 1, "economy")
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(active_overlay_scroll) or absi(active_overlay_scroll.scroll_vertical - economy_target) > 2:
		failures.append("Экономика потеряла позицию прокрутки после изменения ресурса.")
	var budget_target := active_overlay_scroll.scroll_vertical
	change_budget_level("budget_infrastructure", 1)
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(active_overlay_scroll) or absi(active_overlay_scroll.scroll_vertical - budget_target) > 2:
		failures.append("Экономика потеряла позицию прокрутки после изменения бюджета.")
	show_army()
	await get_tree().process_frame
	await get_tree().process_frame
	active_overlay_scroll.scroll_vertical = 300
	await get_tree().process_frame
	var army_target := active_overlay_scroll.scroll_vertical
	if army_target <= 0:
		failures.append("Армия не создала прокручиваемую область для теста.")
	change_resource_allocation("oil_to_army", 1, "army")
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(active_overlay_scroll) or absi(active_overlay_scroll.scroll_vertical - army_target) > 2:
		failures.append("Армия потеряла позицию прокрутки после изменения ресурса.")
	show_clans()
	await get_tree().process_frame
	await get_tree().process_frame
	active_overlay_scroll.scroll_vertical = 180
	await get_tree().process_frame
	var clans_target := active_overlay_scroll.scroll_vertical
	var army_group_card_found := false
	for node in overlay.find_children("*", "Label", true, false):
		var clan_label := node as Label
		if is_instance_valid(clan_label) and clan_label.text == "АРМИЯ И КОМАНДОВАНИЕ":
			army_group_card_found = true
			break
	if clans_target <= 0:
		failures.append("Вкладка внутренних групп не прокручивается до новой карточки армии.")
	if not army_group_card_found:
		failures.append("Во вкладке внутренних групп отсутствует карточка армии.")
	if failures.is_empty():
		print("SCROLL_SMOKE_TEST: OK | economy=%d | budget=%d | army=%d | clans=%d | army_card=yes" % [economy_target, budget_target, army_target, clans_target])
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("SCROLL_SMOKE_TEST: " + failure)
		get_tree().quit(1)


func run_result_flow_smoke_test() -> void:
	var failures: Array[String] = []
	start_game("Сид: 1991", 1991)
	for expected_resolved in range(1, EVENTS_PER_WEEK + 1):
		var previous_title := str(current_event.get("title", ""))
		choose_option("left")
		await get_tree().create_timer(0.20).timeout
		await get_tree().process_frame
		if not is_instance_valid(overlay):
			failures.append("После решения не появилось окно результата.")
			break
		var visible_buttons: Array[String] = []
		for node in overlay.find_children("*", "Button", true, false):
			var button := node as Button
			if is_instance_valid(button) and button.visible:
				visible_buttons.append(button.text)
		if visible_buttons != ["ПРОДОЛЖИТЬ"]:
			failures.append("Окно результата должно содержать только одну кнопку «ПРОДОЛЖИТЬ».")
			break
		continue_after_result()
		await get_tree().process_frame
		if is_instance_valid(overlay):
			failures.append("Кнопка «ПРОДОЛЖИТЬ» не закрыла окно результата.")
			break
		if expected_resolved < EVENTS_PER_WEEK:
			if event_resolved or str(current_event.get("title", "")) == previous_title:
				failures.append("Кнопка «ПРОДОЛЖИТЬ» не загрузила следующий доклад на основной экран.")
				break
		else:
			if not week_ready_for_new_week() or int(state.get("week", 0)) != 1:
				failures.append("После последнего результата игра должна вернуться к управлению, не начиная новую неделю сама.")
			if end_week_button.text.strip_edges() != "НОВАЯ НЕДЕЛЯ  →".strip_edges():
				failures.append("После последнего результата не выделена кнопка новой недели.")
	if failures.is_empty():
		print("RESULT_FLOW_SMOKE_TEST: OK | result_buttons=1 | continue_loads_next=yes | final_returns_to_management=yes")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("RESULT_FLOW_SMOKE_TEST: " + failure)
		get_tree().quit(1)


func run_save_smoke_test() -> void:
	var failures: Array[String] = []
	save_path_override = "user://campaign_save_smoke_test.json"
	var absolute_test_path := ProjectSettings.globalize_path(campaign_save_path())
	if FileAccess.file_exists(campaign_save_path()):
		DirAccess.remove_absolute(absolute_test_path)
	start_game("Сид: 1991", 1991)
	state.money = 77.25
	state.support = 73
	selected_ministers.economy = "grad"
	active_law = "Антикоррупционное бюро"
	law_progress = 1
	law_target = 3
	law_weekly_cost = 2
	budget_draft.budget_social = 2
	queue_week_change("Тест сохранения отложенного последствия", {"stability": -3})
	var saved_title := str(current_event.get("title", ""))
	var saved_queue_size := event_queue.size()
	var saved_pending_size := pending_week_changes.size()
	if not save_campaign(false) or not FileAccess.file_exists(campaign_save_path()):
		failures.append("Файл кампании не был создан.")
	state.money = 1.0
	state.support = 1
	selected_ministers.economy = "radan"
	active_law = ""
	event_queue.clear()
	pending_week_changes.clear()
	current_event.clear()
	if not load_campaign():
		failures.append("Сохранённую кампанию не удалось загрузить.")
	else:
		if not is_equal_approx(float(state.get("money", 0.0)), 77.25) or int(state.get("support", 0)) != 73:
			failures.append("Основные показатели восстановлены неверно.")
		if str(selected_ministers.get("economy", "")) != "grad" or active_law != "Антикоррупционное бюро" or law_progress != 1:
			failures.append("Министры или подготовка закона не восстановлены.")
		if draft_budget_level("budget_social") != 2:
			failures.append("Черновик бюджета не восстановлен.")
		if str(current_event.get("title", "")) != saved_title or event_queue.size() != saved_queue_size:
			failures.append("Текущий доклад или будущая очередь событий изменились после загрузки.")
		if pending_week_changes.size() != saved_pending_size:
			failures.append("Отложенные последствия недели не восстановлены из сохранения.")
	game_mode = "Железный режим"
	state.money = 66.0
	autosave_if_iron()
	state.money = 2.0
	if not load_campaign() or not is_equal_approx(float(state.get("money", 0.0)), 66.0) or not is_iron_mode():
		failures.append("Железное автосохранение не обновило единственный файл кампании.")
	if FileAccess.file_exists(campaign_save_path()):
		DirAccess.remove_absolute(absolute_test_path)
	save_path_override = ""
	if failures.is_empty():
		print("SAVE_SMOKE_TEST: OK | state=yes | event_queue=yes | budget_draft=yes | iron_autosave=yes")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("SAVE_SMOKE_TEST: " + failure)
		get_tree().quit(1)


func run_settings_smoke_test() -> void:
	var failures: Array[String] = []
	var tooltip_panel := theme.get_stylebox("panel", "TooltipPanel") as StyleBoxFlat
	if tooltip_panel == null or tooltip_panel.bg_color.a < 0.94:
		failures.append("Фон подсказки остаётся слишком прозрачным.")
	if audio_streams.size() < 7 or audio_players.size() != audio_streams.size():
		failures.append("Набор звуков интерфейса создан не полностью.")
	for sound_name in audio_streams.keys():
		var sound_stream := audio_streams[sound_name] as AudioStreamWAV
		if sound_stream == null or sound_stream.data.is_empty():
			failures.append("Звук %s не содержит аудиоданных." % str(sound_name))
	var bound_button_found := false
	for node in screen_layer.find_children("*", "BaseButton", true, false):
		if bool(node.get_meta("ui_audio_bound", false)):
			bound_button_found = true
			break
	if not bound_button_found:
		failures.append("Кнопки интерфейса не получили звуки наведения и нажатия.")
	var f4 := InputEventKey.new()
	f4.keycode = KEY_F4
	f4.pressed = true
	var f11 := InputEventKey.new()
	f11.keycode = KEY_F11
	f11.pressed = true
	var alt_f4 := InputEventKey.new()
	alt_f4.keycode = KEY_F4
	alt_f4.pressed = true
	alt_f4.alt_pressed = true
	if not is_fullscreen_shortcut(f4) or not is_fullscreen_shortcut(f11):
		failures.append("F4 или F11 не распознаны как переключатели полноэкранного режима.")
	if is_fullscreen_shortcut(alt_f4):
		failures.append("Alt+F4 не должен перехватываться настройкой экрана.")
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	show_overlay(VBoxContainer.new(), PAPER, true)
	_unhandled_input(escape)
	if is_instance_valid(overlay):
		failures.append("Esc не закрыл доступную для выхода вкладку.")
	show_overlay(VBoxContainer.new(), PAPER, false)
	_unhandled_input(escape)
	if not is_instance_valid(overlay):
		failures.append("Esc закрыл обязательное окно, которое нельзя пропускать.")
	close_overlay()
	var original_value := fullscreen_enabled
	set_fullscreen_enabled(not original_value, false)
	if fullscreen_enabled == original_value:
		failures.append("Настройка полноэкранного режима не переключилась.")
	set_fullscreen_enabled(original_value, false)
	if failures.is_empty():
		print("SETTINGS_SMOKE_TEST: OK | audio=7 | hover=yes | click=yes | menu_toggle=yes | F4=yes | F11=yes | Esc=closes_tabs | Alt+F4=reserved")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("SETTINGS_SMOKE_TEST: " + failure)
		get_tree().quit(1)


func style(color: Color, radius := 18, border_color := Color.TRANSPARENT, border_width := 0) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius
	box.border_width_left = border_width
	box.border_width_top = border_width
	box.border_width_right = border_width
	box.border_width_bottom = border_width
	box.border_color = border_color
	box.content_margin_left = 18
	box.content_margin_right = 18
	box.content_margin_top = 14
	box.content_margin_bottom = 14
	return box


func build_interface_theme() -> Theme:
	var interface_theme := Theme.new()
	var tooltip_background := Color("#171b20")
	tooltip_background.a = 0.97
	var tooltip_panel := style(tooltip_background, 10, Color("#b99c63"), 1)
	tooltip_panel.content_margin_left = 16
	tooltip_panel.content_margin_right = 16
	tooltip_panel.content_margin_top = 12
	tooltip_panel.content_margin_bottom = 12
	interface_theme.set_stylebox("panel", "TooltipPanel", tooltip_panel)
	interface_theme.set_color("font_color", "TooltipLabel", CREAM)
	interface_theme.set_color("font_shadow_color", "TooltipLabel", Color(0.0, 0.0, 0.0, 0.8))
	interface_theme.set_constant("shadow_offset_x", "TooltipLabel", 1)
	interface_theme.set_constant("shadow_offset_y", "TooltipLabel", 1)
	interface_theme.set_font_size("font_size", "TooltipLabel", 16)
	return interface_theme


func label(text_value := "", font_size := 22, color := CREAM, alignment := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var node := Label.new()
	node.text = text_value
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	node.horizontal_alignment = alignment
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return node


func add_hover_detail(control: Control, detail: String) -> void:
	if detail == "":
		return
	control.tooltip_text = detail
	control.mouse_default_cursor_shape = Control.CURSOR_HELP


func minister_data(slot: String, candidate_id := "") -> Dictionary:
	var wanted_id := candidate_id if candidate_id != "" else str(selected_ministers.get(slot, ""))
	for candidate in MINISTER_CANDIDATES.get(slot, []):
		if str(candidate.get("id", "")) == wanted_id:
			return candidate
	return {}


func current_minister_name(slot: String) -> String:
	var data := minister_data(slot)
	return str(data.get("name", "Вакансия"))


func brother_is_defense_minister() -> bool:
	return str(selected_ministers.get("defense", "brother")) == "brother"


func election_campaign_name(campaign: String) -> String:
	match campaign:
		"legacy":
			return "преемник курса отца"
		"reform":
			return "обновление республики"
		"independent":
			return "независимый президент"
	return "кандидат ещё не объявлен"


func election_rules_name(rules: String) -> String:
	match rules:
		"fair":
			return "независимая комиссия"
		"managed":
			return "лояльная комиссия"
		"negotiated":
			return "межпартийный контроль"
	return "ещё не определены"


func election_metric(key: String, projected: bool) -> int:
	return projected_pending_value(key) if projected else int(state.get(key, 0))


func election_honest_score(projected := true) -> int:
	var support_value := election_metric("support", projected)
	var stability_value := election_metric("stability", projected)
	var workers_value := election_metric("clan_workers", projected)
	var regions_value := election_metric("clan_regions", projected)
	var church_value := election_metric("clan_church", projected)
	var oligarch_value := election_metric("clan_oligarchs", projected)
	var score := (
		float(support_value) * 0.60
		+ float(stability_value) * 0.10
		+ float(workers_value) * 0.10
		+ float(regions_value) * 0.10
		+ float(church_value) * 0.05
		+ float(oligarch_value) * 0.05
	)
	match str(state.get("election_campaign", "")):
		"legacy":
			score += 2.0 if election_metric("army", projected) >= 60 else -1.0
		"reform":
			score += 3.0 if bool(state.get("parliament_free", false)) else 1.0
		"independent":
			score += 1.0
	return clampi(roundi(score), 5, 85)


func election_effective_score(projected := true, rules_override := "") -> int:
	var score := election_honest_score(projected)
	var rules := rules_override if rules_override != "" else str(state.get("election_rules", "undecided"))
	if rules == "negotiated":
		score += 2
	elif rules == "managed":
		score += 8
		if bool(state.get("media_restricted", false)):
			score += 6
		score += mini(6, int(state.get("authoritarian", 0)) * 2)
		if election_metric("clan_oligarchs", projected) >= 65:
			score += 3
	return clampi(score, 5, 92)


func election_acceptance_score() -> int:
	var clan_average := (
		int(state.get("clan_oligarchs", 50))
		+ int(state.get("clan_church", 50))
		+ int(state.get("clan_workers", 50))
		+ int(state.get("clan_regions", 50))
	) / 4.0
	return clampi(roundi(
		float(state.get("stability", 0)) * 0.40
		+ float(state.get("support", 0)) * 0.20
		+ float(state.get("army", 0)) * 0.15
		+ clan_average * 0.25
	), 0, 100)


func election_forecast_label(projected := true) -> String:
	var score := election_effective_score(projected)
	if score >= 56:
		return "вероятная победа"
	if score >= 47:
		return "исход неясен"
	return "вероятное поражение"


func election_forecast_color(projected := true) -> Color:
	var score := election_effective_score(projected)
	return GREEN if score >= 56 else GOLD if score >= 47 else RED


func election_forecast_tooltip(projected := true) -> String:
	var weeks_left := maxi(0, DEMO_WEEKS - int(state.get("week", 1)) + 1)
	var support_value := election_metric("support", projected)
	var stability_value := election_metric("stability", projected)
	var group_average := roundi(float(
		election_metric("clan_oligarchs", projected)
		+ election_metric("clan_church", projected)
		+ election_metric("clan_workers", projected)
		+ election_metric("clan_regions", projected)
	) / 4.0)
	var text := "До досрочных выборов: %d нед.\nПрогноз: %s.\n\nНа честный результат сильнее всего влияет поддержка власти; дополнительно учитываются стабильность, профсоюзы, регионы, Церковь и олигархи.\nТекущие ориентиры: поддержка %d%% • стабильность %d%% • средняя поддержка групп %d%%.\nКампания: %s. Правила: %s." % [weeks_left, election_forecast_label(projected), support_value, stability_value, group_average, election_campaign_name(str(state.get("election_campaign", ""))), election_rules_name(str(state.get("election_rules", "undecided")))]
	if str(state.get("election_rules", "")) == "managed":
		text += "\n\nЛояльная комиссия повышает официальный результат. Ограничение СМИ, авторитарный курс и поддержка олигархов усиливают административный ресурс, но не повышают реальную поддержку и могут сделать итог непризнанным."
	else:
		text += "\n\nТочная доля голосов будет раскрыта только после завершения кампании."
	return text


func minister_initial_effects(slot: String, candidate_id: String, candidate: Dictionary) -> Dictionary:
	var effects: Dictionary = (candidate.get("effects", {}) as Dictionary).duplicate(true)
	if slot == "interior" and candidate_id == "kovach" and brother_is_defense_minister():
		effects["army"] = -4
	return amplify_decision_effects(effects, "general")


func is_minister_locked(slot: String, candidate: Dictionary) -> bool:
	if slot == "defense" and bool(state.get("defense_alternatives_unlocked", false)):
		return false
	return bool(candidate.get("locked", false))


func empty_parliament_modifiers() -> Dictionary:
	return {"center": 0, "guard": 0, "regions": 0, "civic": 0}


func clan_position_modifier(value: int) -> int:
	if value >= CLAN_CRITICAL_HIGH_SUPPORT:
		return 2
	if value >= CLAN_HIGH_SUPPORT:
		return 1
	if value <= CLAN_CRITICAL_LOW_SUPPORT:
		return -2
	if value <= CLAN_LOW_SUPPORT:
		return -1
	return 0


func clan_parliament_reason(group_name: String, state_key: String) -> String:
	var value := int(state.get(state_key, 50))
	var modifier := clan_position_modifier(value)
	if modifier == 0:
		return "%s сохраняют нейтралитет (%d%%): +0." % [group_name, value]
	return "%s — %s (%d%%): %+d к позиции фракции." % [group_name, clan_band(value), value, modifier]


func parliament_faction_base_score(faction_key: String) -> int:
	var score := 0
	if faction_key == "center":
		score = 2
		score += clan_position_modifier(int(state.get("clan_oligarchs", 50)))
		if bool(state.get("committee_hearings_open", false)):
			score -= 1
	elif faction_key == "guard":
		score = 1
		score += clan_position_modifier(int(state.get("clan_church", 50)))
		if int(state.get("army", 0)) >= 65 or int(state.get("authoritarian", 0)) >= 2:
			score += 1
		if int(state.get("army", 0)) <= 40:
			score -= 1
		if bool(state.get("parliament_free", false)):
			score -= 1
		if bool(state.get("committee_closed", false)):
			score += 1
	elif faction_key == "regions":
		score += clan_position_modifier(int(state.get("clan_regions", 50)))
		if bool(state.get("committee_regional_deal", false)):
			score += 1
	elif faction_key == "civic":
		score = -1
		score += clan_position_modifier(int(state.get("clan_workers", 50)))
		if bool(state.get("parliament_free", false)):
			score += 1
		if bool(state.get("western_package", false)):
			score += 1
		if int(state.get("authoritarian", 0)) > 0 or bool(state.get("media_restricted", false)):
			score -= 1
	# Позиция группы может вывести базовую лояльность за обычный диапазон −2…+2.
	# Это не даёт больше 100% голосов, но позволяет группе смягчить неприятный ей проект.
	return score


func parliament_faction_reasons(faction_key: String) -> String:
	var reasons: Array[String] = []
	if faction_key == "center":
		reasons.append("Партийная дисциплина и наследие прежнего президента: +2.")
		reasons.append(clan_parliament_reason("Олигархи", "clan_oligarchs"))
		if bool(state.get("committee_hearings_open", false)):
			reasons.append("Открытые слушания раскололи дисциплину: −1.")
	elif faction_key == "guard":
		reasons.append("Верность курсу отца: +1.")
		reasons.append(clan_parliament_reason("Церковь Веры", "clan_church"))
		if int(state.get("army", 0)) >= 70 or int(state.get("authoritarian", 0)) >= 2:
			reasons.append("Сильная армия или жёсткий курс: +1.")
		if int(state.get("army", 0)) <= 40:
			reasons.append("Слабая поддержка армии: −1.")
		if bool(state.get("parliament_free", false)):
			reasons.append("Гражданский контроль ослабил старую гвардию: −1.")
		if bool(state.get("committee_closed", false)):
			reasons.append("Закрытие комитета укрепило дисциплину: +1.")
	elif faction_key == "regions":
		reasons.append("Региональный список начинает с нейтральной позиции.")
		reasons.append(clan_parliament_reason("Фермеры и губернаторы", "clan_regions"))
		if bool(state.get("committee_regional_deal", false)):
			reasons.append("Региональные поправки к слушаниям: +1.")
	elif faction_key == "civic":
		reasons.append("Изначальная оппозиция наследственной передаче власти: −1.")
		reasons.append(clan_parliament_reason("Рабочие и профсоюзы", "clan_workers"))
		if bool(state.get("parliament_free", false)):
			reasons.append("Гражданский контроль: +1.")
		if bool(state.get("western_package", false)):
			reasons.append("Обещание конкурентных выборов: +1.")
		if int(state.get("authoritarian", 0)) > 0 or bool(state.get("media_restricted", false)):
			reasons.append("Авторитарные меры или ограничения СМИ: −1.")
	return "\n".join(reasons)


func parliament_position_name(score: int) -> String:
	match clampi(score, -2, 2):
		-2:
			return "против"
		-1:
			return "скорее против"
		0:
			return "расколота"
		1:
			return "скорее поддерживает"
		_:
			return "лояльна"


func parliament_score_share(score: int) -> float:
	match clampi(score, -2, 2):
		-2:
			return 0.0
		-1:
			return 0.25
		0:
			return 0.5
		1:
			return 0.75
		_:
			return 1.0


func merge_parliament_modifiers(target: Dictionary, addition: Dictionary, scale := 1) -> void:
	for faction_key in target.keys():
		target[faction_key] = int(target.get(faction_key, 0)) + int(addition.get(faction_key, 0)) * scale


func budget_parliament_modifiers(key: String, direction: int) -> Dictionary:
	var increase := direction > 0
	if key == "budget_social":
		return {"center": 0, "guard": -1 if increase else 1, "regions": 1 if increase else -1, "civic": 2 if increase else -2}
	if key == "budget_health":
		return {"center": 0, "guard": 0, "regions": 1 if increase else -1, "civic": 2 if increase else -2}
	if key == "budget_admin":
		return {"center": 1 if increase else -1, "guard": 1 if increase else 0, "regions": 0 if increase else 1, "civic": -2 if increase else 2}
	if key == "budget_defense":
		return {"center": 0, "guard": 2 if increase else -2, "regions": 0, "civic": -2 if increase else 1}
	if key == "budget_debt":
		return {"center": 1 if increase else -2, "guard": 0 if increase else -1, "regions": 0, "civic": 1 if increase else -2}
	if key == "budget_infrastructure":
		return {"center": 0, "guard": 0, "regions": 2 if increase else -2, "civic": 1 if increase else -1}
	return empty_parliament_modifiers()


func minister_parliament_modifiers(candidate_id: String) -> Dictionary:
	var modifiers := {
		"radan": {"center": 0, "guard": -1, "regions": 0, "civic": 1},
		"grad": {"center": 0, "guard": 1, "regions": 0, "civic": -1},
		"sorec": {"center": 0, "guard": -1, "regions": 1, "civic": 2},
		"volsky": {"center": 0, "guard": 2, "regions": 0, "civic": -2},
		"kovach": {"center": 0, "guard": -2, "regions": 0, "civic": 2},
		"sava": {"center": 0, "guard": 0, "regions": 2, "civic": 0},
		"brother": {"center": 0, "guard": 2, "regions": 0, "civic": -2},
		"yun": {"center": 0, "guard": -2, "regions": 0, "civic": 2},
		"zukan": {"center": 0, "guard": 1, "regions": 1, "civic": -1},
		"narin": {"center": 1, "guard": 0, "regions": 0, "civic": 1},
		"varek": {"center": 0, "guard": -2, "regions": 0, "civic": 2},
		"kres": {"center": 0, "guard": 2, "regions": 0, "civic": -2}
	}
	return (modifiers.get(candidate_id, empty_parliament_modifiers()) as Dictionary).duplicate()


func budget_draft_modifiers() -> Dictionary:
	var modifiers := empty_parliament_modifiers()
	for item in WEEKLY_BUDGET_LINES:
		var key := str(item["key"])
		var delta := draft_budget_level(key) - budget_level(key)
		if delta != 0:
			merge_parliament_modifiers(modifiers, budget_parliament_modifiers(key, delta), absi(delta))
	return modifiers


func parliament_project_reason(proposal_type: String, proposal_id: String, faction_key: String) -> String:
	if proposal_type == "budget":
		var lines: Array[String] = []
		for item in WEEKLY_BUDGET_LINES:
			var key := str(item["key"])
			var delta := draft_budget_level(key) - budget_level(key)
			if delta == 0:
				continue
			var step_modifier := int(budget_parliament_modifiers(key, delta).get(faction_key, 0))
			if step_modifier != 0:
				lines.append("%s %s: %+d" % [str(item["title"]), "↑" if delta > 0 else "↓", step_modifier * absi(delta)])
		return "Влияние статей на фракцию: " + ("; ".join(lines) if not lines.is_empty() else "нейтрально") + "."
	if proposal_type == "minister":
		var modifier := int(minister_parliament_modifiers(proposal_id).get(faction_key, 0))
		return "Идеология, покровители и репутация кандидата: %+d." % modifier
	return "Проект не меняет позицию фракции."


func parliament_vote_forecast(proposal_type: String, proposal_id := "") -> Dictionary:
	var project_modifiers := empty_parliament_modifiers()
	if proposal_type == "budget":
		project_modifiers = budget_draft_modifiers()
	elif proposal_type == "minister":
		project_modifiers = minister_parliament_modifiers(proposal_id)
	var yes_votes := 0
	var rows: Array[Dictionary] = []
	var detail_lines: Array[String] = []
	for faction_data in PARLIAMENT_FACTIONS:
		var faction: Dictionary = faction_data
		var faction_key := str(faction["key"])
		var seats := int(faction["seats"])
		var base_score := parliament_faction_base_score(faction_key)
		var project_score := clampi(int(project_modifiers.get(faction_key, 0)), -2, 2)
		var final_score := clampi(base_score + project_score, -2, 2)
		var faction_votes := roundi(float(seats) * parliament_score_share(final_score))
		yes_votes += faction_votes
		rows.append({"key": faction_key, "title": str(faction["title"]), "seats": seats, "votes": faction_votes, "base": base_score, "project": project_score, "score": final_score})
		detail_lines.append("%s: %d из %d за • %s (текущая позиция %+d, проект %+d).\n%s\n%s" % [str(faction["title"]), faction_votes, seats, parliament_position_name(final_score), base_score, project_score, parliament_faction_reasons(faction_key), parliament_project_reason(proposal_type, proposal_id, faction_key)])
	var no_votes := PARLIAMENT_TOTAL_SEATS - yes_votes
	return {
		"yes": yes_votes,
		"no": no_votes,
		"passed": yes_votes >= PARLIAMENT_MAJORITY,
		"rows": rows,
		"detail": "Требуется %d голос из %d.\n\n%s" % [PARLIAMENT_MAJORITY, PARLIAMENT_TOTAL_SEATS, "\n\n".join(detail_lines)]
	}


func parliament_vote_summary(forecast: Dictionary) -> String:
	return "%d за / %d против • нужно %d" % [int(forecast.get("yes", 0)), int(forecast.get("no", 0)), PARLIAMENT_MAJORITY]


func record_parliament_vote(subject: String, forecast: Dictionary) -> void:
	var verdict := "ПРИНЯТО" if bool(forecast.get("passed", false)) else "ОТКЛОНЕНО"
	state.last_parliament_vote = "%s: %d за, %d против — %s." % [subject, int(forecast.get("yes", 0)), int(forecast.get("no", 0)), verdict]
	state.last_parliament_vote_detail = str(forecast.get("detail", ""))


func reset_budget_draft() -> void:
	budget_draft.clear()
	for item in WEEKLY_BUDGET_LINES:
		var key := str(item["key"])
		budget_draft[key] = budget_level(key)


func draft_budget_level(key: String) -> int:
	return clampi(int(budget_draft.get(key, budget_level(key))), 0, 2)


func budget_draft_cost() -> int:
	var cost := 0
	for item in WEEKLY_BUDGET_LINES:
		var key := str(item["key"])
		cost += absi(draft_budget_level(key) - budget_level(key))
	return cost


func clear_screen() -> void:
	for child in get_children():
		if bool(child.get_meta("persistent_audio", false)):
			continue
		child.queue_free()
	screen_layer = Control.new()
	screen_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(screen_layer)
	var backdrop := Backdrop.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen_layer.add_child(backdrop)


func menu_button(text_value: String) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(150, 62)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", CREAM)
	button.add_theme_stylebox_override("normal", style(Color("#283139"), 14, Color("#4c5c66"), 1))
	button.add_theme_stylebox_override("hover", style(Color("#34414a"), 14, GOLD, 1))
	button.add_theme_stylebox_override("pressed", style(Color("#1d2429"), 14, GOLD, 2))
	return button


func highlighted_new_week_button(text_value: String, danger := false) -> Button:
	var button := menu_button(text_value)
	apply_highlighted_week_style(button, danger)
	return button


func apply_highlighted_week_style(button: Button, danger := false) -> void:
	button.custom_minimum_size = Vector2(150, 72)
	button.add_theme_font_size_override("font_size", 20)
	if danger:
		button.add_theme_color_override("font_color", CREAM)
		button.add_theme_color_override("font_hover_color", CREAM)
		button.add_theme_stylebox_override("normal", style(Color("#74342f"), 14, Color("#e2b0a0"), 2))
		button.add_theme_stylebox_override("hover", style(Color("#8f4039"), 14, CREAM, 3))
		button.add_theme_stylebox_override("pressed", style(Color("#542521"), 14, RED, 3))
		button.tooltip_text = "При текущем прогнозе переход к новой неделе приведёт к немедленному дефолту."
	else:
		button.add_theme_color_override("font_color", INK)
		button.add_theme_color_override("font_hover_color", INK)
		button.add_theme_color_override("font_pressed_color", CREAM)
		button.add_theme_stylebox_override("normal", style(GOLD, 14, CREAM, 2))
		button.add_theme_stylebox_override("hover", style(CREAM, 14, GOLD, 3))
		button.add_theme_stylebox_override("pressed", style(Color("#8b744b"), 14, GOLD, 3))


func show_start_screen() -> void:
	clear_screen()
	game_root = screen_layer
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 72)
	margin.add_theme_constant_override("margin_right", 72)
	margin.add_theme_constant_override("margin_top", 64)
	margin.add_theme_constant_override("margin_bottom", 64)
	screen_layer.add_child(margin)
	var layout := HBoxContainer.new()
	layout.add_theme_constant_override("separation", 72)
	margin.add_child(layout)
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(820, 0)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 20)
	layout.add_child(left)
	left.add_child(label("ПОЛИТИЧЕСКАЯ ДРАМА • ПРОТОТИП", 17, GOLD))
	var title := label("НАСЛЕДНИК\nРЕСПУБЛИКИ", 76, CREAM)
	title.add_theme_constant_override("line_spacing", -10)
	left.add_child(title)
	var subtitle := label("Двадцать шесть недель между наследием отца, армией брата и двумя державами, которые не готовы уступить вас друг другу.", 25, Color("#cfc3aa"))
	subtitle.custom_minimum_size = Vector2(720, 0)
	left.add_child(subtitle)
	left.add_child(HSeparator.new())
	var intro_panel := PanelContainer.new()
	intro_panel.add_theme_stylebox_override("panel", style(Color("#20242a"), 24, Color(GOLD, 0.5), 1))
	left.add_child(intro_panel)
	intro_panel.add_child(label("Ваш отец — освободитель страны и первый президент — погиб при покушении. Незадолго до смерти он провёл ваше сомнительное назначение вице-президентом. Теперь вы временно исполняете обязанности главы государства: через 26 недель республика должна избрать президента. Казна почти пуста, брат контролирует армию, а два соседа требуют выбрать сторону.", 23, CREAM))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(spacer)
	left.add_child(label("Оригинальный минималистичный интерфейс • сухие доклады • последствия решений", 15, MUTED))
	var mode_panel := PanelContainer.new()
	mode_panel.custom_minimum_size = Vector2(520, 0)
	mode_panel.add_theme_stylebox_override("panel", style(Color("#1d2228"), 26, Color("#4c535a"), 1))
	layout.add_child(mode_panel)
	var mode_margin := MarginContainer.new()
	mode_margin.add_theme_constant_override("margin_left", 32)
	mode_margin.add_theme_constant_override("margin_right", 32)
	mode_margin.add_theme_constant_override("margin_top", 34)
	mode_margin.add_theme_constant_override("margin_bottom", 34)
	mode_panel.add_child(mode_margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	mode_margin.add_child(column)
	column.add_child(label("НАЧАТЬ КАМПАНИЮ", 28, CREAM, HORIZONTAL_ALIGNMENT_CENTER))
	column.add_child(label("Выберите правила сохранения и случайности.", 17, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var saved_campaign := read_save_data()
	var continue_button := menu_button("ПРОДОЛЖИТЬ")
	if saved_campaign.is_empty():
		continue_button.text = "ПРОДОЛЖИТЬ — НЕТ СОХРАНЕНИЯ"
		continue_button.disabled = true
	else:
		var saved_state: Dictionary = saved_campaign.get("state", {})
		continue_button.text = "ПРОДОЛЖИТЬ — НЕДЕЛЯ %d" % int(saved_state.get("week", 1))
		continue_button.tooltip_text = "%s • казна %.2f млн • сохранено %s" % [str(saved_campaign.get("game_mode", "Кампания")), float(saved_state.get("money", 0.0)), str(saved_campaign.get("saved_at", "дата неизвестна"))]
		continue_button.pressed.connect(load_campaign)
	column.add_child(continue_button)
	var panel_spacer := Control.new()
	panel_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(panel_spacer)
	var seed_row := HBoxContainer.new()
	seed_row.add_theme_constant_override("separation", 10)
	column.add_child(seed_row)
	var seed_input := LineEdit.new()
	seed_input.placeholder_text = "Сид, например 1991"
	seed_input.text = "1991"
	seed_input.custom_minimum_size = Vector2(0, 58)
	seed_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	seed_input.add_theme_font_size_override("font_size", 20)
	seed_input.add_theme_stylebox_override("normal", style(Color("#252a30"), 14, Color("#515861"), 1))
	seed_row.add_child(seed_input)
	var seed_button := menu_button("С СИДОМ")
	seed_button.pressed.connect(func(): start_game("Сид: " + seed_input.text, campaign_seed_from_text(seed_input.text)))
	seed_row.add_child(seed_button)
	var normal_button := menu_button("БЕЗ СИДА — НОВАЯ КАМПАНИЯ")
	normal_button.pressed.connect(func(): start_game("Без сида", fresh_campaign_seed()))
	column.add_child(normal_button)
	var iron_button := menu_button("ЖЕЛЕЗНЫЙ РЕЖИМ")
	iron_button.add_theme_stylebox_override("normal", style(Color("#4c2827"), 14, Color("#8e5048"), 1))
	iron_button.pressed.connect(func(): start_game("Железный режим", fresh_campaign_seed()))
	column.add_child(iron_button)
	var settings_button := menu_button("НАСТРОЙКИ")
	settings_button.pressed.connect(show_settings)
	column.add_child(settings_button)
	var achievements_button := menu_button("ДОСТИЖЕНИЯ • %d / %d" % [unlocked_achievement_count(), ENDING_ACHIEVEMENTS.size()])
	achievements_button.pressed.connect(show_achievements)
	column.add_child(achievements_button)
	column.add_child(label("Управление: мышь; A / D — основные решения; S / ↓ — третье; Esc — закрыть вкладку; F4 / F11 — полный экран", 14, MUTED, HORIZONTAL_ALIGNMENT_CENTER))


func fullscreen_status_text() -> String:
	return "Полноэкранный режим включён." if fullscreen_enabled else "Игра запущена в оконном режиме."


func fullscreen_toggle_button_text() -> String:
	return "ПЕРЕЙТИ В ОКОННЫЙ РЕЖИМ" if fullscreen_enabled else "ОТКРЫТЬ НА ВЕСЬ ЭКРАН"


func audio_status_text() -> String:
	return "Звуки интерфейса и событий включены." if audio_enabled else "Звуки отключены."


func audio_toggle_button_text() -> String:
	return "ВЫКЛЮЧИТЬ ЗВУКИ" if audio_enabled else "ВКЛЮЧИТЬ ЗВУКИ"


func show_settings() -> void:
	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(690, 0)
	content.add_theme_constant_override("separation", 18)
	content.add_child(label("НАСТРОЙКИ", 30, INK, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label("ЭКРАН", 15, Color("#8b6c4b"), HORIZONTAL_ALIGNMENT_CENTER))
	var status_label := label(fullscreen_status_text(), 21, Color("#4c4941"), HORIZONTAL_ALIGNMENT_CENTER)
	content.add_child(status_label)
	var fullscreen_button := menu_button(fullscreen_toggle_button_text())
	fullscreen_button.pressed.connect(toggle_fullscreen_from_settings.bind(fullscreen_button, status_label))
	content.add_child(fullscreen_button)
	content.add_child(label("Быстрое переключение: F4 или F11. Alt+F4 по-прежнему закрывает игру.", 15, Color("#6d6455"), HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(HSeparator.new())
	content.add_child(label("ЗВУК", 15, Color("#8b6c4b"), HORIZONTAL_ALIGNMENT_CENTER))
	var audio_status_label := label(audio_status_text(), 21, Color("#4c4941"), HORIZONTAL_ALIGNMENT_CENTER)
	content.add_child(audio_status_label)
	var audio_button := menu_button(audio_toggle_button_text())
	audio_button.pressed.connect(toggle_audio_from_settings.bind(audio_button, audio_status_label))
	content.add_child(audio_button)
	content.add_child(label("Наведение, нажатия, доклады, решения, предупреждения и новая неделя имеют разные сигналы.", 15, Color("#6d6455"), HORIZONTAL_ALIGNMENT_CENTER))
	var close := menu_button("ГОТОВО")
	close.pressed.connect(close_overlay)
	content.add_child(close)
	show_overlay(content, PAPER, true, 750)


func toggle_fullscreen_from_settings(toggle_button: Button, status_label: Label) -> void:
	toggle_fullscreen()
	toggle_button.text = fullscreen_toggle_button_text()
	status_label.text = fullscreen_status_text()


func toggle_audio_from_settings(toggle_button: Button, status_label: Label) -> void:
	audio_enabled = not audio_enabled
	save_display_settings()
	toggle_button.text = audio_toggle_button_text()
	status_label.text = audio_status_text()
	if audio_enabled:
		play_game_sound("decision")


func setup_audio() -> void:
	audio_streams = {
		"hover": make_ui_tone(620.0, 780.0, 0.040, 0.075, 0.10),
		"click": make_ui_tone(255.0, 145.0, 0.070, 0.17, 0.18),
		"report": make_ui_tone(280.0, 430.0, 0.145, 0.13, 0.12),
		"decision": make_ui_tone(410.0, 680.0, 0.190, 0.16, 0.20),
		"warning": make_ui_tone(205.0, 105.0, 0.280, 0.17, 0.24),
		"week": make_ui_tone(300.0, 590.0, 0.340, 0.15, 0.18),
		"ending": make_ui_tone(360.0, 115.0, 0.520, 0.17, 0.22)
	}
	for sound_name in audio_streams.keys():
		var player := AudioStreamPlayer.new()
		player.name = "Audio_%s" % str(sound_name)
		player.stream = audio_streams[sound_name]
		player.set_meta("persistent_audio", true)
		add_child(player)
		audio_players[sound_name] = player
	get_tree().node_added.connect(bind_audio_to_new_node)


func make_ui_tone(start_frequency: float, end_frequency: float, duration: float, amplitude: float, harmonic_mix: float) -> AudioStreamWAV:
	var mix_rate := 24000
	var sample_count := maxi(1, roundi(duration * float(mix_rate)))
	var sample_data := PackedByteArray()
	sample_data.resize(sample_count * 2)
	for sample_index in range(sample_count):
		var time := float(sample_index) / float(mix_rate)
		var progress := float(sample_index) / maxf(float(sample_count - 1), 1.0)
		var phase := TAU * (start_frequency * time + 0.5 * (end_frequency - start_frequency) * time * time / maxf(duration, 0.001))
		var attack := minf(1.0, progress * 28.0 + 0.08)
		var envelope := attack * pow(1.0 - progress, 2.4)
		var wave := sin(phase) + sin(phase * 2.0) * harmonic_mix
		wave /= 1.0 + harmonic_mix
		var encoded_sample := clampi(roundi(wave * envelope * amplitude * 32767.0), -32768, 32767)
		sample_data.encode_s16(sample_index * 2, encoded_sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.data = sample_data
	return stream


func bind_audio_to_new_node(node: Node) -> void:
	if node is BaseButton:
		call_deferred("bind_button_audio", node)


func bind_button_audio(button: BaseButton) -> void:
	if not is_instance_valid(button) or bool(button.get_meta("ui_audio_bound", false)):
		return
	button.set_meta("ui_audio_bound", true)
	button.mouse_entered.connect(play_button_hover.bind(button))
	button.button_down.connect(play_button_click.bind(button))


func play_button_hover(button: BaseButton) -> void:
	if is_instance_valid(button) and button.visible and not button.disabled:
		play_game_sound("hover")


func play_button_click(button: BaseButton) -> void:
	if is_instance_valid(button) and not button.disabled:
		play_game_sound("click")


func play_game_sound(sound_name: String) -> void:
	if not audio_enabled or DisplayServer.get_name() == "headless":
		return
	var player := audio_players.get(sound_name) as AudioStreamPlayer
	if not is_instance_valid(player):
		return
	player.stop()
	player.play()


func fresh_campaign_seed() -> int:
	var seed_rng := RandomNumberGenerator.new()
	seed_rng.randomize()
	return int(seed_rng.randi()) ^ int(Time.get_ticks_usec())


func campaign_seed_from_text(seed_text: String) -> int:
	var cleaned_seed := seed_text.strip_edges()
	if cleaned_seed.is_valid_int():
		return cleaned_seed.to_int()
	return cleaned_seed.hash()


func campaign_save_path() -> String:
	return save_path_override if save_path_override != "" else SAVE_PATH


func persistence_allowed() -> bool:
	if save_path_override != "":
		return true
	for argument in OS.get_cmdline_user_args():
		var arg := str(argument)
		if arg.contains("smoke-test") or arg.begins_with("--capture-"):
			return false
	return true


func achievement_definition(ending_title: String) -> Dictionary:
	for achievement in ENDING_ACHIEVEMENTS:
		if str(achievement.get("ending", "")) == ending_title:
			return (achievement as Dictionary).duplicate(true)
	return {}


func read_unlocked_achievements() -> Dictionary:
	if not persistence_allowed() or not FileAccess.file_exists(ACHIEVEMENTS_PATH):
		return {}
	var file := FileAccess.open(ACHIEVEMENTS_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return {}
	var stored: Variant = (parsed as Dictionary).get("unlocked", {})
	return (stored as Dictionary).duplicate(true) if stored is Dictionary else {}


func save_unlocked_achievements(unlocked: Dictionary) -> bool:
	if not persistence_allowed():
		return false
	var file := FileAccess.open(ACHIEVEMENTS_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({"version": 1, "unlocked": unlocked}, "\t"))
	file.flush()
	return true


func unlock_ending_achievement(ending_title: String) -> bool:
	if achievement_definition(ending_title).is_empty() or not persistence_allowed():
		return false
	var unlocked := read_unlocked_achievements()
	if unlocked.has(ending_title):
		return false
	unlocked[ending_title] = Time.get_datetime_string_from_system(false, true)
	return save_unlocked_achievements(unlocked)


func unlocked_achievement_count() -> int:
	var unlocked := read_unlocked_achievements()
	var count := 0
	for achievement in ENDING_ACHIEVEMENTS:
		if unlocked.has(str(achievement.get("ending", ""))):
			count += 1
	return count


func show_achievements() -> void:
	var unlocked := read_unlocked_achievements()
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(760, 650)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	scroll.add_child(content)
	content.add_child(label("ДОСТИЖЕНИЯ", 30, INK, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label("Открыто %d из %d. Каждая доступная концовка имеет отдельное достижение." % [unlocked_achievement_count(), ENDING_ACHIEVEMENTS.size()], 16, Color("#5f594d"), HORIZONTAL_ALIGNMENT_CENTER))
	for achievement in ENDING_ACHIEVEMENTS:
		var ending_title := str(achievement.get("ending", ""))
		var is_unlocked := unlocked.has(ending_title)
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", style(Color("#ded4bf") if is_unlocked else Color("#d2c9b7"), 12, GOLD if is_unlocked else Color("#938a7b"), 2 if is_unlocked else 1))
		content.add_child(card)
		var card_margin := MarginContainer.new()
		card_margin.add_theme_constant_override("margin_left", 16)
		card_margin.add_theme_constant_override("margin_right", 16)
		card_margin.add_theme_constant_override("margin_top", 12)
		card_margin.add_theme_constant_override("margin_bottom", 12)
		card.add_child(card_margin)
		var card_box := VBoxContainer.new()
		card_box.add_theme_constant_override("separation", 4)
		card_margin.add_child(card_box)
		card_box.add_child(label(("ОТКРЫТО • " if is_unlocked else "ЗАКРЫТО • ") + str(achievement.get("title", "Достижение")), 18, GREEN if is_unlocked else MUTED))
		card_box.add_child(label(str(achievement.get("description", "")), 15, INK if is_unlocked else Color("#625e56")))
		if is_unlocked:
			card_box.add_child(label("Концовка: %s • получено %s" % [ending_title.capitalize(), str(unlocked.get(ending_title, "дата неизвестна"))], 13, Color("#6f6557")))
	var close := menu_button("ВЕРНУТЬСЯ")
	close.pressed.connect(close_overlay)
	content.add_child(close)
	show_overlay(scroll, PAPER, true, 840)


func load_display_settings() -> void:
	fullscreen_enabled = false
	audio_enabled = true
	if not persistence_allowed() or not FileAccess.file_exists(SETTINGS_PATH):
		apply_fullscreen_mode()
		return
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		apply_fullscreen_mode()
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		fullscreen_enabled = bool((parsed as Dictionary).get("fullscreen", false))
		audio_enabled = bool((parsed as Dictionary).get("audio_enabled", true))
	apply_fullscreen_mode()


func save_display_settings() -> void:
	if not persistence_allowed():
		return
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify({"fullscreen": fullscreen_enabled, "audio_enabled": audio_enabled}, "\t"))
	file.flush()


func apply_fullscreen_mode() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var desired_mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen_enabled else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != desired_mode:
		DisplayServer.window_set_mode(desired_mode)


func set_fullscreen_enabled(enabled: bool, save_setting := true) -> void:
	fullscreen_enabled = enabled
	apply_fullscreen_mode()
	if save_setting:
		save_display_settings()


func toggle_fullscreen() -> void:
	set_fullscreen_enabled(not fullscreen_enabled)


func is_fullscreen_shortcut(event: InputEvent) -> bool:
	if not event is InputEventKey:
		return false
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return false
	var pressed_key := key_event.keycode if key_event.keycode != 0 else key_event.physical_keycode
	if pressed_key == KEY_F11:
		return true
	return pressed_key == KEY_F4 and not key_event.alt_pressed and not key_event.ctrl_pressed and not key_event.meta_pressed


func is_iron_mode() -> bool:
	return game_mode == "Железный режим"


func campaign_snapshot() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"saved_at": Time.get_datetime_string_from_system(false, true),
		"game_mode": game_mode,
		"state": state.duplicate(true),
		"selected_ministers": selected_ministers.duplicate(true),
		"budget_draft": budget_draft.duplicate(true),
		"active_law": active_law,
		"law_progress": law_progress,
		"law_target": law_target,
		"law_weekly_cost": law_weekly_cost,
		"law_worked_this_week": law_worked_this_week,
		"recruitment_changed_this_week": recruitment_changed_this_week,
		"pending_week_changes": pending_week_changes.duplicate(true),
		"event_resolved": event_resolved,
		"events_resolved_this_week": events_resolved_this_week,
		"events_required_this_week": events_required_this_week,
		"events": events.duplicate(true),
		"recurring_events": recurring_events.duplicate(true),
		"event_queue": event_queue.duplicate(true),
		"recurring_event_queue": recurring_event_queue.duplicate(true),
		"weekly_event_queue": weekly_event_queue.duplicate(true),
		"current_event": current_event.duplicate(true)
	}


func save_campaign(show_feedback := true) -> bool:
	if state.is_empty() or not persistence_allowed():
		return false
	var file := FileAccess.open(campaign_save_path(), FileAccess.WRITE)
	if file == null:
		if show_feedback and is_instance_valid(game_root):
			show_notice("Не удалось открыть файл сохранения.")
		return false
	file.store_string(JSON.stringify(campaign_snapshot(), "\t"))
	file.flush()
	if show_feedback and is_instance_valid(game_root):
		show_notice("Кампания сохранена. Продолжить её можно из главного меню.")
	return true


func read_save_data() -> Dictionary:
	if not FileAccess.file_exists(campaign_save_path()):
		return {}
	var file := FileAccess.open(campaign_save_path(), FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return {}
	var data: Dictionary = parsed
	if int(data.get("version", 0)) != SAVE_VERSION or not data.get("state", {}) is Dictionary:
		return {}
	return data


func dictionary_array_from_save(value: Variant) -> Array[Dictionary]:
	var restored: Array[Dictionary] = []
	if value is Array:
		for item in value:
			if item is Dictionary:
				restored.append((item as Dictionary).duplicate(true))
	return restored


func election_event_template() -> Dictionary:
	for story_event in story_event_pool:
		if str(story_event.get("title", "")) == "Досрочные выборы":
			return story_event.duplicate(true)
	return {}


func migrate_legacy_final_event(queue: Array[Dictionary]) -> void:
	var template := election_event_template()
	if template.is_empty():
		return
	for index in range(queue.size()):
		if str(queue[index].get("title", "")) != "Последняя развилка":
			continue
		var previous_kind := str(queue[index].get("_kind", ""))
		queue[index] = template.duplicate(true)
		if previous_kind != "":
			queue[index]["_kind"] = previous_kind


func legacy_relation_value(side: String) -> int:
	var pressure := int(state.get(side + "_pressure", 0))
	var commitments := int(state.get(side + "_commitment", 0))
	var neutrality_shield := floori(float(int(state.get("neutrality", 0))) / 2.0)
	var old_effective := maxi(0, pressure - commitments * 2 - neutrality_shield)
	if old_effective >= 10:
		return 0
	if old_effective >= 4:
		return 1
	if old_effective <= 1 and commitments >= 2:
		return 3
	return 2


func convert_legacy_foreign_effects(effects: Dictionary) -> Dictionary:
	var converted := effects.duplicate(true)
	var legacy_keys := ["east_pressure", "west_pressure", "east_commitment", "west_commitment", "neutrality"]
	var has_legacy := false
	for key in legacy_keys:
		if converted.has(key):
			has_legacy = true
			break
	if not has_legacy:
		return converted
	var east_intent := 0
	var west_intent := 0
	var east_pressure := int(converted.get("east_pressure", 0))
	var west_pressure := int(converted.get("west_pressure", 0))
	var east_commitment := int(converted.get("east_commitment", 0))
	var west_commitment := int(converted.get("west_commitment", 0))
	if east_pressure != 0:
		east_intent += -1 if east_pressure > 0 else 1
	if west_pressure != 0:
		west_intent += -1 if west_pressure > 0 else 1
	if east_commitment != 0:
		east_intent += 1 if east_commitment > 0 else -1
	if west_commitment != 0:
		west_intent += 1 if west_commitment > 0 else -1
	for key in legacy_keys:
		converted.erase(key)
	east_intent = signi(east_intent)
	west_intent = signi(west_intent)
	if bool(state.get("at_war", false)):
		var war_enemy := str(state.get("war_enemy", ""))
		if war_enemy == "east" and east_intent > 0:
			east_intent = 0
		elif war_enemy == "west" and west_intent > 0:
			west_intent = 0
	var east_can_improve := east_intent > 0 and projected_pending_value("east_relation") < 3
	var west_can_improve := west_intent > 0 and projected_pending_value("west_relation") < 3
	if east_intent > 0 and not east_can_improve:
		east_intent = 0
	if west_intent > 0 and not west_can_improve:
		west_intent = 0
	if east_can_improve:
		west_intent -= 1
	if west_can_improve:
		east_intent -= 1
	east_intent = clampi(east_intent, -1, 1)
	west_intent = clampi(west_intent, -1, 1)
	if east_intent != 0:
		converted["east_relation"] = clampi(int(converted.get("east_relation", 0)) + east_intent, -1, 1)
	if west_intent != 0:
		converted["west_relation"] = clampi(int(converted.get("west_relation", 0)) + west_intent, -1, 1)
	return converted


func relation_shift_effect(side: String, direction: int) -> Dictionary:
	if side not in ["east", "west"] or direction == 0:
		return {}
	if direction > 0 and bool(state.get("at_war", false)) and str(state.get("war_enemy", "")) == side:
		return {}
	var current := projected_pending_value(side + "_relation")
	if direction > 0:
		if current >= 3:
			return {}
		var opposite := "west" if side == "east" else "east"
		return {side + "_relation": 1, opposite + "_relation": -1}
	if current <= 0:
		return {}
	return {side + "_relation": -1}


func block_war_enemy_relation_improvement(effects: Dictionary) -> Dictionary:
	var protected_effects := effects.duplicate(true)
	if not bool(state.get("at_war", false)):
		return protected_effects
	var enemy := str(state.get("war_enemy", ""))
	if enemy not in ["east", "west"]:
		return protected_effects
	var relation_key := enemy + "_relation"
	if int(protected_effects.get(relation_key, 0)) > 0:
		protected_effects.erase(relation_key)
	return protected_effects


func normalize_loaded_pending_relations() -> void:
	for index in range(pending_week_changes.size()):
		var change: Dictionary = pending_week_changes[index]
		change["effects"] = convert_legacy_foreign_effects(change.get("effects", {}))
		pending_week_changes[index] = change


func normalize_loaded_state() -> void:
	var integer_keys := [
		"week", "campaign_seed", "support", "stability", "army", "war_support", "corruption_tier", "influence",
		"creditor_obligations", "creditor_review_due_week", "creditor_priority_weeks", "clan_oligarchs", "clan_church",
		"clan_workers", "clan_regions", "pop_children", "pop_employed", "pop_unemployed", "pop_pensioners", "pop_migrants",
		"army_personnel", "army_equipment", "army_aircraft", "metal_to_equipment", "oil_to_army", "metal_price_weeks",
		"oil_price_weeks", "budget_social", "budget_health", "budget_admin", "budget_defense", "budget_debt",
		"budget_infrastructure", "east_relation", "west_relation", "east_pressure", "west_pressure", "east_commitment", "west_commitment", "neutrality",
		"brother_trust", "authoritarian", "social_protest_due_week", "social_budget_lock_until_week", "regional_administration_penalty_until_week",
		"war_started_week", "war_weeks", "war_casualties", "war_pressure_next_week", "war_frontline_reductions",
		"war_medical_priority_until_week", "war_ammo_conservation_until_week", "foreign_action_week", "emission_shock_weeks", "emission_shock_elapsed",
		"creditor_budget_lock_level", "creditor_budget_lock_until_week", "east_energy_discount_until_week",
		"west_market_access_until_week", "double_standards_until_week", "active_unrest_level", "active_unrest_weeks"
	]
	for key in integer_keys:
		if state.has(key):
			state[key] = int(state[key])
	for key in ["money", "debt", "metal_price_factor", "oil_price_factor"]:
		if state.has(key):
			state[key] = float(state[key])
	var loaded_defaults := {
		"war_enemy": "", "war_started_week": 0, "war_weeks": 0, "war_casualties": 0,
		"war_crisis_pending": bool(state.get("at_war", false)), "war_crisis_shown": false,
		"war_pressure_next_week": maxi(WAR_PRESSURE_INTERVAL, int(state.get("war_weeks", 0)) + WAR_PRESSURE_INTERVAL),
		"war_frontline_reductions": 0, "war_medical_priority_until_week": 0, "war_ammo_conservation_until_week": 0,
		"foreign_action_week": 0, "east_concession_signed": false, "west_concession_signed": false,
		"east_border_oil_concession": false, "west_investment_arbitration": false,
		"east_wartime_aid_received": false, "west_wartime_aid_received": false,
		"last_war_report": "Война не началась.",
		"emission_shock_weeks": EMISSION_SHOCK_WEEKS if bool(state.get("printed_money", false)) else 0,
		"emission_shock_elapsed": 0,
		"creditor_demand_budget_key": "", "creditor_budget_lock_key": "",
		"creditor_budget_lock_level": -1, "creditor_budget_lock_until_week": 0,
		"east_energy_discount_until_week": 0, "west_market_access_until_week": 0,
		"double_standards_until_week": 0, "foreign_followups": [], "story_followups": [], "unrest_queue": [],
		"active_unrest_level": 0, "active_unrest_weeks": 0, "active_unrest_cause": "",
		"active_unrest_kind": "", "active_unrest_labor": false, "active_unrest_reversible": false,
		"active_unrest_reversal": "",
		"election_nomination_shown": int(state.get("week", 1)) >= 10,
		"election_rules_shown": int(state.get("week", 1)) >= 19,
		"election_campaign": "", "election_rules": "undecided", "election_method": ""
	}
	for key in loaded_defaults:
		if not state.has(key):
			state[key] = loaded_defaults[key]
	# Старые сохранения переводятся из накопительных очков в одну из четырёх
	# видимых категорий. После миграции старые числа больше не участвуют в расчётах.
	if not state.has("east_relation"):
		state.east_relation = legacy_relation_value("east")
	if not state.has("west_relation"):
		state.west_relation = legacy_relation_value("west")
	state.east_relation = clampi(int(state.get("east_relation", 2)), 0, 3)
	state.west_relation = clampi(int(state.get("west_relation", 2)), 0, 3)
	for legacy_key in ["east_pressure", "west_pressure", "east_commitment", "west_commitment", "neutrality"]:
		state.erase(legacy_key)
	if not state.get("foreign_followups", []) is Array:
		state.foreign_followups = []
	if not state.get("story_followups", []) is Array:
		state.story_followups = []
	if not state.get("unrest_queue", []) is Array:
		state.unrest_queue = []
	if bool(state.get("east_concession_signed", false)):
		state.east_border_oil_concession = true
	if bool(state.get("west_concession_signed", false)):
		state.west_investment_arbitration = true
	state.oil_to_army = clampi(int(state.get("oil_to_army", 0)), 0, current_oil_output())
	state.metal_to_equipment = clampi(int(state.get("metal_to_equipment", 0)), 0, current_metal_output())


func load_campaign() -> bool:
	var data := read_save_data()
	if data.is_empty():
		show_notice("Сохранение отсутствует, повреждено или создано несовместимой версией игры.")
		return false
	game_mode = str(data.get("game_mode", "Без сида"))
	state = (data.get("state", {}) as Dictionary).duplicate(true)
	normalize_loaded_state()
	selected_ministers = (data.get("selected_ministers", {}) as Dictionary).duplicate(true)
	budget_draft = (data.get("budget_draft", {}) as Dictionary).duplicate(true)
	active_law = str(data.get("active_law", ""))
	law_progress = int(data.get("law_progress", 0))
	law_target = int(data.get("law_target", 0))
	law_weekly_cost = int(data.get("law_weekly_cost", 1))
	law_worked_this_week = bool(data.get("law_worked_this_week", false))
	recruitment_changed_this_week = bool(data.get("recruitment_changed_this_week", false))
	pending_week_changes = dictionary_array_from_save(data.get("pending_week_changes", []))
	normalize_loaded_pending_relations()
	event_resolved = bool(data.get("event_resolved", false))
	events_resolved_this_week = int(data.get("events_resolved_this_week", 0))
	events_required_this_week = int(data.get("events_required_this_week", EVENTS_PER_WEEK))
	events = dictionary_array_from_save(data.get("events", []))
	recurring_events = dictionary_array_from_save(data.get("recurring_events", []))
	event_queue = dictionary_array_from_save(data.get("event_queue", []))
	recurring_event_queue = dictionary_array_from_save(data.get("recurring_event_queue", []))
	weekly_event_queue = dictionary_array_from_save(data.get("weekly_event_queue", []))
	current_event = (data.get("current_event", {}) as Dictionary).duplicate(true)
	migrate_legacy_final_event(events)
	migrate_legacy_final_event(event_queue)
	migrate_legacy_final_event(weekly_event_queue)
	if str(current_event.get("title", "")) == "Последняя развилка":
		var previous_kind := str(current_event.get("_kind", ""))
		current_event = election_event_template()
		if previous_kind != "" and not current_event.is_empty():
			current_event["_kind"] = previous_kind
	if not event_resolved and not current_event.is_empty() and event_blocked_by_current_war(current_event):
		current_event = build_wartime_replacement_event(current_event)
	build_game_screen()
	if check_terminal_state():
		return true
	if int(state.get("week", 1)) > DEMO_WEEKS:
		show_ending()
		return true
	if event_resolved and not week_ready_for_new_week():
		next_event()
	elif current_event.is_empty():
		next_event()
	else:
		display_current_event()
	return true


func autosave_if_iron() -> void:
	if is_iron_mode():
		save_campaign(false)


func start_game(mode: String, seed_value: int) -> void:
	game_mode = mode
	story_rng.seed = seed_value ^ STORY_SEED_SALT
	routine_rng.seed = seed_value ^ ROUTINE_SEED_SALT
	state = {
		"week": 1, "campaign_seed": seed_value, "money": 42.0, "support": 58, "stability": 42, "army": 52,
		"war_support": 24, "corruption_tier": 3, "influence": 3, "debt": 420.0,
		"creditor_obligations": 0, "creditor_review_pending": false,
		"creditor_review_due_week": 0, "creditor_review_shown": false, "creditor_priority_weeks": 0,
		"creditor_demand_budget_key": "", "creditor_budget_lock_key": "",
		"creditor_budget_lock_level": -1, "creditor_budget_lock_until_week": 0,
		"clan_oligarchs": 58, "clan_church": 61, "clan_workers": 47,
		"clan_regions": 50,
		"pop_children": 820000, "pop_employed": 2200000, "pop_unemployed": 240000,
		"pop_pensioners": 870000, "pop_migrants": 70000, "army_personnel": 50000,
		"recruitment_model": "mixed", "army_equipment": 300, "army_aircraft": 12,
		"metal_to_equipment": 2, "oil_to_army": 8, "at_war": false,
		"war_enemy": "", "war_started_week": 0, "war_weeks": 0, "war_casualties": 0,
		"war_crisis_pending": false, "war_crisis_shown": false, "war_pressure_next_week": WAR_PRESSURE_INTERVAL,
		"war_frontline_reductions": 0, "war_medical_priority_until_week": 0, "war_ammo_conservation_until_week": 0,
		"last_war_report": "Война не началась.", "foreign_action_week": 0,
		"east_concession_signed": false, "west_concession_signed": false,
		"east_border_oil_concession": false, "west_investment_arbitration": false,
		"east_wartime_aid_received": false, "west_wartime_aid_received": false,
		"military_threat": false, "metal_price_factor": 1.0, "metal_price_weeks": 0,
		"oil_price_factor": 1.0, "oil_price_weeks": 0,
		"budget_social": 1, "budget_health": 1, "budget_admin": 1,
		"budget_defense": 1, "budget_debt": 1, "budget_infrastructure": 1,
		"last_population_report": "Первый месячный пересчёт состоится на 4-й неделе.",
		"east_relation": 2, "west_relation": 2, "brother_trust": 2,
		"east_energy_discount_until_week": 0, "west_market_access_until_week": 0,
		"double_standards_until_week": 0, "foreign_followups": [], "story_followups": [],
		"unrest_queue": [], "active_unrest_level": 0, "active_unrest_weeks": 0,
		"active_unrest_cause": "", "active_unrest_kind": "", "active_unrest_labor": false,
		"active_unrest_reversible": false, "active_unrest_reversal": "",
		"printed_money": false, "emission_shock_weeks": 0, "emission_shock_elapsed": 0,
		"foreign_base": "", "parliament_free": false,
		"media_restricted": false,
		"social_protest_pending": false, "social_protest_due_week": 0,
		"emergency_powers_protest_pending": false, "emergency_powers_protest_due_week": 0,
		"social_budget_lock_until_week": 0, "regional_administration_penalty_until_week": 0,
		"authoritarian": 0,
		"election_nomination_shown": false, "election_rules_shown": false,
		"election_campaign": "", "election_rules": "undecided", "election_method": "",
		"last_parliament_vote": "",
		"last_parliament_vote_detail": "",
		"financial_slot_consumed": false, "financial_crisis_shown": false,
		"appointed_ministers": {"economy": ["radan"], "interior": ["volsky"], "defense": ["brother"], "foreign": ["narin"]},
		"last_weekly_report": {}, "enacted_laws": []
	}
	active_law = ""
	law_progress = 0
	law_target = 0
	law_weekly_cost = 1
	law_worked_this_week = false
	recruitment_changed_this_week = false
	pending_week_changes.clear()
	event_resolved = false
	events_resolved_this_week = 0
	events_required_this_week = EVENTS_PER_WEEK
	selected_ministers = {"economy": "radan", "interior": "volsky", "defense": "brother", "foreign": "narin"}
	reset_budget_draft()
	generate_story_campaign()
	build_recurring_event_database()
	prepare_event_queue()
	prepare_recurring_event_queue()
	build_game_screen()
	prepare_week_event_queue()
	next_event()
	autosave_if_iron()


func generate_story_campaign() -> void:
	events.clear()
	var selected_ids := {}
	for story_event in story_event_pool:
		if bool(story_event.get("_mandatory", false)):
			selected_ids[str(story_event.get("_story_id", ""))] = true
	var bucket_order: Array[String] = ["economy", "army", "society", "world"]
	var bucket_quotas := {"economy": 4, "army": 3, "society": 4, "world": 3}
	for bucket in bucket_order:
		var candidates: Array[Dictionary] = []
		for story_event in story_event_pool:
			if str(story_event.get("_bucket", "")) == bucket:
				candidates.append(story_event)
		for index in range(candidates.size() - 1, 0, -1):
			var swap_index := story_rng.randi_range(0, index)
			var swapped_event := candidates[index]
			candidates[index] = candidates[swap_index]
			candidates[swap_index] = swapped_event
		var quota := int(bucket_quotas[bucket])
		if candidates.size() < quota:
			push_error("В сюжетном пуле %s недостаточно событий для квоты %d." % [bucket, quota])
			continue
		for index in range(quota):
			selected_ids[str(candidates[index].get("_story_id", ""))] = true
	for story_event in story_event_pool:
		if selected_ids.has(str(story_event.get("_story_id", ""))):
			events.append(story_event.duplicate(true))
	if events.size() != DEMO_WEEKS:
		push_error("Сюжетная кампания должна содержать %d событий, получено %d." % [DEMO_WEEKS, events.size()])


func prepare_event_queue() -> void:
	event_queue.clear()
	for item in events:
		event_queue.append(item.duplicate(true))


func prepare_recurring_event_queue() -> void:
	recurring_event_queue.clear()
	for item in recurring_events:
		recurring_event_queue.append(item.duplicate(true))


func prepare_week_event_queue() -> void:
	weekly_event_queue.clear()
	events_required_this_week = EVENTS_PER_WEEK
	if event_queue.is_empty() or recurring_event_queue.size() < 2:
		return
	var core_event: Dictionary = event_queue.pop_front().duplicate(true)
	core_event["_kind"] = "core"
	var first_routine: Dictionary = recurring_event_queue.pop_front().duplicate(true)
	var second_routine: Dictionary = recurring_event_queue.pop_front().duplicate(true)
	first_routine["_kind"] = "routine"
	second_routine["_kind"] = "routine"
	if int(state.get("week", 1)) == DEMO_WEEKS:
		weekly_event_queue.append(first_routine)
		weekly_event_queue.append(second_routine)
		weekly_event_queue.append(core_event)
	else:
		weekly_event_queue.append(core_event)
		weekly_event_queue.append(first_routine)
		weekly_event_queue.append(second_routine)


func build_game_screen() -> void:
	clear_screen()
	game_root = Control.new()
	game_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen_layer.add_child(game_root)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side_name in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side_name, 22)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	game_root.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)
	var top := HBoxContainer.new()
	column.add_child(top)
	var game_title := label("НАСЛЕДНИК РЕСПУБЛИКИ", 23, CREAM)
	game_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(game_title)
	week_label = label("НЕДЕЛЯ 1", 19, PAPER, HORIZONTAL_ALIGNMENT_CENTER)
	week_label.custom_minimum_size = Vector2(330, 0)
	top.add_child(week_label)
	mode_label = label(game_mode.to_upper(), 14, GOLD, HORIZONTAL_ALIGNMENT_RIGHT)
	mode_label.custom_minimum_size = Vector2(300, 0)
	mode_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	top.add_child(mode_label)
	var workspace := HBoxContainer.new()
	workspace.add_theme_constant_override("separation", 16)
	workspace.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(workspace)

	var left_panel := PanelContainer.new()
	left_panel.custom_minimum_size = Vector2(300, 0)
	left_panel.add_theme_stylebox_override("panel", style(Color("#1c2025"), 18, Color("#343b43"), 1))
	workspace.add_child(left_panel)
	var left_box := VBoxContainer.new()
	left_box.add_theme_constant_override("separation", 8)
	left_panel.add_child(left_box)
	left_box.add_child(label("СОСТОЯНИЕ СТРАНЫ", 15, GOLD))
	var stats := GridContainer.new()
	stats.columns = 2
	stats.add_theme_constant_override("h_separation", 8)
	stats.add_theme_constant_override("v_separation", 8)
	left_box.add_child(stats)
	add_stat(stats, "money", "КАЗНА", "%.1f млн" % float(state.get("money", 0.0)), GOLD)
	add_stat(stats, "support", "ПОДДЕРЖКА", "58%", RED)
	add_stat(stats, "stability", "СТАБИЛЬН.", "42%", GREEN)
	add_stat(stats, "war_support", "ПОДД. ВОЙНЫ", "24%", BLUE)
	add_sidebar_summary_row(left_box, "unrest_status", "Протесты", "нет")
	add_sidebar_summary_row(left_box, "election_status", "Досрочные выборы", "через 26 нед.")
	left_box.add_child(HSeparator.new())
	left_box.add_child(label("ВНУТРЕННИЕ СИЛЫ", 13, GOLD))
	add_sidebar_summary_row(left_box, "clan_oligarchs", "Олигархи", "58%")
	add_sidebar_summary_row(left_box, "clan_church", "Церковь Веры", "61%")
	add_sidebar_summary_row(left_box, "clan_workers", "Профсоюзы", "47%")
	add_sidebar_summary_row(left_box, "clan_regions", "Регионы", "50%")
	add_sidebar_summary_row(left_box, "army_loyalty", "Армия", "52%")
	left_box.add_child(HSeparator.new())
	left_box.add_child(label("СОСЕДНИЕ ДЕРЖАВЫ", 13, GOLD))
	add_sidebar_summary_row(left_box, "east_relation", "Восточный Союз", neighbor_relation_band("east"))
	add_sidebar_summary_row(left_box, "west_relation", "Западная Федерация", neighbor_relation_band("west"))
	left_box.add_child(HSeparator.new())
	left_box.add_child(label("ВООРУЖЁННЫЕ СИЛЫ", 13, GOLD))
	add_sidebar_summary_row(left_box, "army_effectiveness", "Боеспособность", "%d%%" % army_effectiveness())
	add_sidebar_summary_row(left_box, "army_supply", "Снабжение", "%d%%" % army_supply())
	add_sidebar_summary_row(left_box, "army_personnel", "Личный состав", format_people(int(state.get("army_personnel", 0))))
	add_sidebar_summary_row(left_box, "army_assets", "Техника / авиация", "%d / %d" % [int(state.get("army_equipment", 0)), int(state.get("army_aircraft", 0))])

	var center_column := VBoxContainer.new()
	center_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_column.add_theme_constant_override("separation", 9)
	workspace.add_child(center_column)
	var report_row := HBoxContainer.new()
	center_column.add_child(report_row)
	var report_tag := label("● ЗАКРЫТЫЙ ДОКЛАД", 14, RED)
	report_tag.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	report_row.add_child(report_tag)
	card_panel = PanelContainer.new()
	# Центральная карточка не должна забирать высоту у кнопок решений.
	# Проект рисуется в логическом разрешении 1600×900, поэтому прежний
	# EXPAND_FILL выталкивал подсказки и нижнюю часть боковых панелей за экран.
	card_panel.size_flags_vertical = Control.SIZE_FILL
	card_panel.custom_minimum_size = Vector2(720, 610)
	card_panel.add_theme_stylebox_override("panel", style(PAPER, 22, Color("#9f9278"), 2))
	center_column.add_child(card_panel)
	var card_margin := MarginContainer.new()
	card_margin.add_theme_constant_override("margin_left", 24)
	card_margin.add_theme_constant_override("margin_right", 24)
	card_margin.add_theme_constant_override("margin_top", 18)
	card_margin.add_theme_constant_override("margin_bottom", 16)
	card_panel.add_child(card_margin)
	var card_column := VBoxContainer.new()
	card_column.add_theme_constant_override("separation", 7)
	card_margin.add_child(card_column)
	source_label = label("ИСТОЧНИК", 14, Color("#6d6455"), HORIZONTAL_ALIGNMENT_CENTER)
	card_column.add_child(source_label)
	portrait = PortraitArt.new()
	portrait.custom_minimum_size = Vector2(0, 170)
	portrait.size_flags_vertical = Control.SIZE_FILL
	card_column.add_child(portrait)
	title_label = label("ЗАГОЛОВОК", 31, INK, HORIZONTAL_ALIGNMENT_CENTER)
	card_column.add_child(title_label)
	card_column.add_child(HSeparator.new())
	var body_scroll := ScrollContainer.new()
	body_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	body_scroll.custom_minimum_size = Vector2(0, 120)
	card_column.add_child(body_scroll)
	body_label = label("Текст доклада", 19, Color("#34332f"), HORIZONTAL_ALIGNMENT_CENTER)
	body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	body_scroll.add_child(body_label)
	choice_grid = GridContainer.new()
	choice_grid.columns = 2
	choice_grid.add_theme_constant_override("h_separation", 10)
	choice_grid.add_theme_constant_override("v_separation", 6)
	center_column.add_child(choice_grid)
	left_button = choice_button(BLUE)
	left_button.pressed.connect(func(): choose_option("left"))
	choice_grid.add_child(left_button)
	right_button = choice_button(RED)
	right_button.pressed.connect(func(): choose_option("right"))
	choice_grid.add_child(right_button)
	third_button = choice_button(Color("#6f634b"))
	third_button.pressed.connect(func(): choose_option("third"))
	third_button.visible = false
	choice_grid.add_child(third_button)
	left_hint = label("Примерный эффект", 13, Color("#cfc3aa"), HORIZONTAL_ALIGNMENT_CENTER)
	left_hint.custom_minimum_size = Vector2(0, 36)
	choice_grid.add_child(left_hint)
	right_hint = label("Примерный эффект", 13, Color("#cfc3aa"), HORIZONTAL_ALIGNMENT_CENTER)
	right_hint.custom_minimum_size = Vector2(0, 36)
	choice_grid.add_child(right_hint)
	third_hint = label("Примерный эффект", 13, Color("#cfc3aa"), HORIZONTAL_ALIGNMENT_CENTER)
	third_hint.custom_minimum_size = Vector2(0, 36)
	third_hint.visible = false
	choice_grid.add_child(third_hint)

	var right_panel := PanelContainer.new()
	right_panel.custom_minimum_size = Vector2(330, 0)
	right_panel.add_theme_stylebox_override("panel", style(Color("#1c2025"), 18, Color("#343b43"), 1))
	workspace.add_child(right_panel)
	var right_box := VBoxContainer.new()
	right_box.add_theme_constant_override("separation", 8)
	right_panel.add_child(right_box)
	right_box.add_child(label("ПРЕЗИДЕНТСКИЙ АППАРАТ", 15, GOLD))
	influence_label = label("ОЧКИ РЕШЕНИЙ: 3 / 3", 19, CREAM)
	influence_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	right_box.add_child(influence_label)
	right_box.add_child(HSeparator.new())
	right_box.add_child(label("МИНИСТР ЭКОНОМИКИ", 12, MUTED))
	economy_name_label = label(current_minister_name("economy"), 18, PAPER)
	right_box.add_child(economy_name_label)
	right_box.add_child(label("МИНИСТР ВНУТРЕННИХ ДЕЛ", 12, MUTED))
	interior_name_label = label(current_minister_name("interior"), 18, PAPER)
	right_box.add_child(interior_name_label)
	right_box.add_child(label("МИНИСТР ОБОРОНЫ", 12, MUTED))
	defense_name_label = label(current_minister_name("defense"), 18, PAPER)
	right_box.add_child(defense_name_label)
	right_box.add_child(label("МИНИСТР ИНОСТРАННЫХ ДЕЛ", 12, MUTED))
	foreign_name_label = label(current_minister_name("foreign"), 18, PAPER)
	right_box.add_child(foreign_name_label)
	right_box.add_child(HSeparator.new())
	right_box.add_child(label("РАЗДЕЛЫ", 12, MUTED))
	var section_grid := GridContainer.new()
	section_grid.columns = 2
	section_grid.add_theme_constant_override("h_separation", 8)
	section_grid.add_theme_constant_override("v_separation", 8)
	right_box.add_child(section_grid)
	var ministers_button := small_button("ПРАВИТЕЛЬСТВО")
	ministers_button.pressed.connect(show_ministers)
	section_grid.add_child(ministers_button)
	var clans_button := small_button("КЛАНЫ")
	clans_button.pressed.connect(show_clans)
	section_grid.add_child(clans_button)
	var economy_button := small_button("ЭКОНОМИКА")
	economy_button.pressed.connect(show_economy)
	section_grid.add_child(economy_button)
	var army_button := small_button("АРМИЯ")
	army_button.pressed.connect(show_army)
	section_grid.add_child(army_button)
	var population_button := small_button("НАСЕЛЕНИЕ")
	population_button.pressed.connect(show_population)
	section_grid.add_child(population_button)
	var foreign_button := small_button("ВНЕШНЯЯ ПОЛИТИКА")
	foreign_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	foreign_button.pressed.connect(show_foreign_policy)
	section_grid.add_child(foreign_button)
	var report_button := small_button("СВОДКА")
	report_button.pressed.connect(show_weekly_report)
	section_grid.add_child(report_button)
	law_button = small_button("ПОДГОТОВИТЬ ЗАКОН")
	law_button.custom_minimum_size = Vector2(0, 54)
	law_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	law_button.pressed.connect(on_law_button_pressed)
	right_box.add_child(law_button)
	end_week_button = small_button("ДОКЛАД 1 / 3")
	end_week_button.disabled = true
	end_week_button.pressed.connect(on_week_action_pressed)
	right_box.add_child(end_week_button)
	var side_spacer := Control.new()
	side_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_box.add_child(side_spacer)
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 8)
	right_box.add_child(footer)
	var save_button := small_button("АВТОСОХРАНЕНИЕ" if is_iron_mode() else "СОХРАНИТЬ")
	save_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_button.disabled = is_iron_mode()
	save_button.tooltip_text = "Железный режим автоматически обновляет единственное сохранение после решений и не позволяет создать точку для отката." if is_iron_mode() else "Сохранить текущее состояние кампании. Недельное автосохранение также создаётся при переходе к новой неделе."
	if not is_iron_mode():
		save_button.pressed.connect(save_campaign.bind(true))
	footer.add_child(save_button)
	var settings_button := small_button("НАСТРОЙКИ")
	settings_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_button.tooltip_text = "Полноэкранный режим и горячие клавиши F4 / F11."
	settings_button.pressed.connect(show_settings)
	footer.add_child(settings_button)
	var restart_button := small_button("МЕНЮ")
	restart_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	restart_button.pressed.connect(show_start_screen)
	footer.add_child(restart_button)


func add_stat(parent: Container, key: String, caption: String, value: String, color: Color) -> void:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var stat_style := style(Color("#20242a"), 12, Color(color, 0.55), 1)
	stat_style.content_margin_left = 12
	stat_style.content_margin_right = 12
	stat_style.content_margin_top = 9
	stat_style.content_margin_bottom = 9
	panel.add_theme_stylebox_override("panel", stat_style)
	parent.add_child(panel)
	var box := VBoxContainer.new()
	panel.add_child(box)
	var caption_label := label(caption, 11, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(caption_label)
	var value_label := label(value, 19 if key == "money" else 21, CREAM, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(value_label)
	if key == "money":
		panel.tooltip_text = "Доступные деньги государства. Название краснеет, когда казны не хватает примерно на две недели текущих расходов или ближайший переход грозит дефолтом; зеленеет при запасе примерно на шесть недель."
	elif key == "support":
		panel.tooltip_text = "Общественная поддержка и фактическая легитимность президента. При 70% и выше она укрепляет стабильность на 1 каждую неделю. При низкой поддержке непопулярные решения могут вызвать отдельные протестные события; при 0% власть будет свергнута."
	elif key == "stability":
		panel.tooltip_text = "Способность центральной власти исполнять решения. При 70% и выше слаженная работа государства даёт +1 очко решений в начале недели. При 30% и ниже управленческий кризис отнимает 1 очко решений в начале недели; при 0% страна расколется."
	elif key == "war_support":
		panel.tooltip_text = "Готовность общества принять мобилизацию, потери и военные расходы. При 30% и ниже набор замедляется, во время войны появляются дезертиры, а расширение призыва вызывает протест. При 65% и выше набор ускоряется и во время войны растёт лояльность армии. При 0% воюющая страна капитулирует."
	stat_labels[key] = value_label
	stat_caption_labels[key] = caption_label


func add_sidebar_summary_row(parent: Container, key: String, caption: String, value: String) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 19)
	parent.add_child(row)
	var caption_label := label(caption, 13, MUTED)
	caption_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	caption_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	row.add_child(caption_label)
	var value_label := label(value, 14, CREAM, HORIZONTAL_ALIGNMENT_RIGHT)
	value_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	row.add_child(value_label)
	sidebar_summary_labels[key] = value_label


func update_sidebar_summary() -> void:
	if sidebar_summary_labels.is_empty():
		return
	var unrest_label: Label = sidebar_summary_labels.get("unrest_status")
	if is_instance_valid(unrest_label):
		var unrest_level := int(state.get("active_unrest_level", 0))
		if unrest_level <= 0:
			unrest_label.text = "нет"
			unrest_label.add_theme_color_override("font_color", CREAM)
			unrest_label.tooltip_text = "Активных протестов и забастовок нет. Непопулярные решения могут создать срочный доклад на следующей неделе."
		else:
			var labor := bool(state.get("active_unrest_labor", false))
			unrest_label.text = ("забастовка" if labor else "массовые" if unrest_level == 2 else "локальные" if unrest_level == 1 else "общенац.")
			unrest_label.add_theme_color_override("font_color", RED)
			unrest_label.tooltip_text = "%s\nПричина: %s\nКаждую неделю стабильность −%d.%s" % [unrest_level_title(unrest_level, labor).capitalize(), str(state.get("active_unrest_cause", "")), unrest_stability_loss(unrest_level), " Забастовка также уменьшает доходы от труда и производства." if labor else ""]
		unrest_label.mouse_default_cursor_shape = Control.CURSOR_HELP
	var election_label: Label = sidebar_summary_labels.get("election_status")
	if is_instance_valid(election_label):
		var weeks_left := maxi(0, DEMO_WEEKS - int(state.get("week", 1)) + 1)
		election_label.text = "на этой нед." if weeks_left <= 1 else "через %d нед." % weeks_left
		election_label.add_theme_color_override("font_color", RED if weeks_left <= 4 else GOLD if weeks_left <= 10 else CREAM)
		election_label.tooltip_text = election_forecast_tooltip(true)
		election_label.mouse_default_cursor_shape = Control.CURSOR_HELP
	var clan_titles := {
		"clan_oligarchs": "Олигархи",
		"clan_church": "Церковь Веры",
		"clan_workers": "Рабочие и профсоюзы",
		"clan_regions": "Фермеры и регионы"
	}
	for key in clan_titles:
		var current_value := int(state.get(key, 50))
		var value := projected_pending_value(key)
		var pending := value != current_value
		var value_label: Label = sidebar_summary_labels[key]
		value_label.text = "%d%%" % value
		value_label.add_theme_color_override("font_color", PENDING_BLUE if pending else GREEN if value >= CLAN_HIGH_SUPPORT else RED if value <= CLAN_LOW_SUPPORT else CREAM)
		value_label.tooltip_text = (pending_value_tooltip(str(clan_titles[key]), "%d%%" % current_value, "%d%%" % value) + "\n\nОжидаемое состояние: %s.\n%s" % [clan_band(value), clan_full_effect_description(key, value)]) if pending else "%s: %s.\n%s" % [str(clan_titles[key]), clan_band(value), clan_full_effect_description(key, value)]
		value_label.mouse_default_cursor_shape = Control.CURSOR_HELP
	for side in ["east", "west"]:
		var relation_key: String = str(side) + "_relation"
		var current_band := neighbor_relation_band(side)
		var projected_band := neighbor_relation_band(side, true)
		var relation_pending := current_band != projected_band
		var relation_label: Label = sidebar_summary_labels[relation_key]
		var war_suffix := " • ВОЙНА" if bool(state.get("at_war", false)) and str(state.get("war_enemy", "")) == side else ""
		relation_label.text = projected_band.to_upper() + war_suffix
		relation_label.add_theme_color_override("font_color", PENDING_BLUE if relation_pending else neighbor_relation_color(side))
		relation_label.tooltip_text = (pending_value_tooltip(neighbor_title(side), current_band, projected_band) + "\n\n" + neighbor_relation_explanation(side, true)) if relation_pending else neighbor_relation_explanation(side)
		relation_label.mouse_default_cursor_shape = Control.CURSOR_HELP
	var current_loyalty := int(state.get("army", 50))
	var loyalty := projected_pending_value("army")
	var loyalty_pending := loyalty != current_loyalty
	var loyalty_label: Label = sidebar_summary_labels["army_loyalty"]
	loyalty_label.text = "%d%%" % loyalty
	loyalty_label.add_theme_color_override("font_color", PENDING_BLUE if loyalty_pending else GREEN if loyalty >= 65 else RED if loyalty <= 40 else CREAM)
	loyalty_label.tooltip_text = (pending_value_tooltip("Лояльность армии", "%d%%" % current_loyalty, "%d%%" % loyalty) + "\n\n%s.\n%s" % [army_group_band(loyalty), army_group_effect_description(loyalty)]) if loyalty_pending else "%s.\n%s" % [army_group_band(loyalty), army_group_effect_description(loyalty)]
	loyalty_label.mouse_default_cursor_shape = Control.CURSOR_HELP
	var projected_army := projected_army_snapshot()
	var current_effectiveness := army_effectiveness()
	var effectiveness := int(projected_army["effectiveness"])
	var effectiveness_pending := effectiveness != current_effectiveness
	var effectiveness_label: Label = sidebar_summary_labels["army_effectiveness"]
	effectiveness_label.text = "%d%%" % effectiveness
	effectiveness_label.add_theme_color_override("font_color", PENDING_BLUE if effectiveness_pending else GREEN if effectiveness >= 70 else RED if effectiveness < 45 else CREAM)
	var effectiveness_detail := "Сводный показатель подготовки, обеспеченности техникой и авиацией, снабжения и морали."
	if bool(state.get("at_war", false)):
		effectiveness_detail += " Во время войны дополнительно учитывается покрытие фронта людьми: требуется %s, ожидается %s." % [format_people(int(projected_army.get("frontline_required", 0))), format_people(int(projected_army.get("personnel", 0)))]
	effectiveness_label.tooltip_text = (pending_value_tooltip("Боеспособность", "%d%%" % current_effectiveness, "%d%%" % effectiveness) + "\n\n" + effectiveness_detail) if effectiveness_pending else effectiveness_detail
	effectiveness_label.mouse_default_cursor_shape = Control.CURSOR_HELP
	var current_supply := army_supply()
	var supply := int(projected_army["supply"])
	var supply_pending := supply != current_supply
	var supply_label: Label = sidebar_summary_labels["army_supply"]
	supply_label.text = "%d%%" % supply
	supply_label.add_theme_color_override("font_color", PENDING_BLUE if supply_pending else GREEN if supply >= 75 else RED if supply < 50 else CREAM)
	supply_label.tooltip_text = (pending_value_tooltip("Снабжение армии", "%d%%" % current_supply, "%d%%" % supply) + "\n\nЗависит от доли недельной добычи нефти, направленной армии.") if supply_pending else "Зависит от доли недельной добычи нефти, направленной армии. Ниже 75% падает лояльность, ниже 50% дополнительно страдает стабильность."
	supply_label.mouse_default_cursor_shape = Control.CURSOR_HELP
	var current_personnel := int(state.get("army_personnel", 0))
	var projected_personnel := int(projected_army["personnel"])
	var personnel_label: Label = sidebar_summary_labels["army_personnel"]
	personnel_label.text = format_people(projected_personnel)
	personnel_label.add_theme_color_override("font_color", PENDING_BLUE if projected_personnel != current_personnel else CREAM)
	personnel_label.tooltip_text = (pending_value_tooltip("Военнослужащие", format_people(current_personnel), format_people(projected_personnel)) + "\n\nЦель выбранной модели: %s." % format_people(recruitment_target())) if projected_personnel != current_personnel else "Текущее число военнослужащих. Цель выбранной модели комплектования: %s." % format_people(recruitment_target())
	personnel_label.mouse_default_cursor_shape = Control.CURSOR_HELP
	var current_equipment := int(state.get("army_equipment", 0))
	var current_aircraft := int(state.get("army_aircraft", 0))
	var projected_equipment := int(projected_army["equipment"])
	var projected_aircraft := int(projected_army["aircraft"])
	var assets_pending := projected_equipment != current_equipment or projected_aircraft != current_aircraft
	var assets_label: Label = sidebar_summary_labels["army_assets"]
	assets_label.text = "%d / %d" % [projected_equipment, projected_aircraft]
	assets_label.add_theme_color_override("font_color", PENDING_BLUE if assets_pending else CREAM)
	assets_label.tooltip_text = (pending_value_tooltip("Техника / авиация", "%d / %d" % [current_equipment, current_aircraft], "%d / %d" % [projected_equipment, projected_aircraft]) + "\n\nПотребность ожидаемой армии: %d / %d. Авиацию республика не производит." % [int(projected_army["required_equipment"]), int(projected_army["required_aircraft"])]) if assets_pending else "Наземная техника / авиация. Потребность текущей армии: %d / %d. Авиацию республика не производит." % [army_required_equipment(), army_required_aircraft()]
	assets_label.mouse_default_cursor_shape = Control.CURSOR_HELP


func choice_button(color: Color) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 62)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", CREAM)
	button.add_theme_stylebox_override("normal", style(Color(color, 0.72), 16, color, 1))
	button.add_theme_stylebox_override("hover", style(Color(color, 0.92), 16, GOLD, 2))
	button.add_theme_stylebox_override("pressed", style(Color(color, 0.48), 16, PAPER, 2))
	return button


func small_button(text_value: String) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(0, 46)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_stylebox_override("normal", style(Color("#23282e"), 12, Color("#434a53"), 1))
	button.add_theme_stylebox_override("hover", style(Color("#303841"), 12, GOLD, 1))
	return button


func unrest_level_title(level: int, labor := false) -> String:
	if labor:
		match clampi(level, 1, 3):
			1:
				return "предупредительная забастовка"
			2:
				return "отраслевая забастовка"
			_:
				return "всеобщая забастовка"
	match clampi(level, 1, 3):
		1:
			return "локальные протесты"
		2:
			return "массовые протесты"
		_:
			return "общенациональные протесты"


func unrest_stability_loss(level: int) -> int:
	match clampi(level, 1, 3):
		1:
			return 2
		2:
			return 4
		_:
			return 7


func unrest_trigger_condition_met(data: Dictionary) -> bool:
	var condition := str(data.get("condition", "always"))
	if condition == "low_support":
		return int(state.get("support", 0)) <= 50
	if condition == "low_war_support":
		return int(state.get("war_support", 0)) <= 40
	if condition == "workers_low":
		return int(state.get("clan_workers", 0)) <= 40
	if condition == "regions_low":
		return int(state.get("clan_regions", 0)) <= 40
	return true


func calculate_unrest_level(data: Dictionary) -> int:
	var level := clampi(int(data.get("base_level", 1)), 1, 3)
	var support := int(state.get("support", 50))
	var stability := int(state.get("stability", 50))
	var kind := str(data.get("kind", "civic"))
	if support <= 40:
		level += 1
	if support <= 20 or stability <= 25:
		level += 1
	if kind == "labor" and int(state.get("clan_workers", 50)) <= 35:
		level += 1
	elif kind == "regional" and int(state.get("clan_regions", 50)) <= 35:
		level += 1
	if support >= 70 and stability >= 55:
		level -= 1
	return clampi(level, 1, 3)


func schedule_unrest(data: Dictionary, delay_weeks := 1) -> void:
	if data.is_empty() or not unrest_trigger_condition_met(data):
		return
	var queue: Array = state.get("unrest_queue", [])
	var due_week := mini(DEMO_WEEKS, int(state.get("week", 1)) + delay_weeks)
	var record := {
		"cause": str(data.get("cause", "непопулярное решение правительства")),
		"kind": str(data.get("kind", "civic")),
		"labor": bool(data.get("labor", str(data.get("kind", "")) == "labor")),
		"level": calculate_unrest_level(data),
		"reversible": bool(data.get("reversible", false)),
		"reversal": str(data.get("reversal", "")),
		"due_week": due_week
	}
	for queued in queue:
		if not queued is Dictionary or int(queued.get("due_week", -1)) != due_week:
			continue
		var causes := str(queued.get("cause", ""))
		if str(record.cause) not in causes:
			queued["cause"] = causes + "; " + str(record.cause)
		queued["level"] = mini(3, maxi(int(queued.get("level", 1)), int(record.level)) + 1)
		queued["labor"] = bool(queued.get("labor", false)) or bool(record.labor)
		if str(queued.get("kind", "")) != str(record.kind):
			queued["kind"] = "coalition"
		queued["reversible"] = bool(queued.get("reversible", false)) and bool(record.reversible)
		if str(queued.get("reversal", "")) != str(record.reversal):
			queued["reversal"] = ""
			queued["reversible"] = false
		state.unrest_queue = queue
		return
	queue.append(record)
	state.unrest_queue = queue


func due_unrest_indices() -> Array[int]:
	var indices: Array[int] = []
	var queue: Array = state.get("unrest_queue", [])
	for index in range(queue.size()):
		if queue[index] is Dictionary and int(queue[index].get("due_week", DEMO_WEEKS + 1)) <= int(state.get("week", 1)):
			indices.append(index)
	return indices


func should_trigger_unrest() -> bool:
	var final_story_resolved := event_resolved and int(state.get("week", 1)) == DEMO_WEEKS and str(current_event.get("title", "")) == "Досрочные выборы"
	return not final_story_resolved and not due_unrest_indices().is_empty()


func activate_unrest(record: Dictionary) -> void:
	state.active_unrest_level = maxi(int(state.get("active_unrest_level", 0)), int(record.get("level", 1)))
	state.active_unrest_weeks = maxi(int(state.get("active_unrest_weeks", 0)), 1)
	state.active_unrest_cause = str(record.get("cause", "непопулярное решение правительства"))
	state.active_unrest_kind = str(record.get("kind", "civic"))
	state.active_unrest_labor = bool(record.get("labor", false))
	state.active_unrest_reversible = bool(record.get("reversible", false))
	state.active_unrest_reversal = str(record.get("reversal", ""))


func clear_active_unrest() -> void:
	state.active_unrest_level = 0
	state.active_unrest_weeks = 0
	state.active_unrest_cause = ""
	state.active_unrest_kind = ""
	state.active_unrest_labor = false
	state.active_unrest_reversible = false
	state.active_unrest_reversal = ""


func reverse_active_unrest_policy() -> void:
	match str(state.get("active_unrest_reversal", "")):
		"media", "media_law":
			state.media_restricted = false
			var enacted: Array = state.get("enacted_laws", [])
			enacted.erase("Ограничение СМИ")
			state.enacted_laws = enacted
		"radio_blackout":
			state.border_broadcast_blackout = false
		"channel_closure":
			state.eastern_channel_closed = false
		"language":
			state.state_language_only = false
		"passports":
			state.foreign_passports_banned = false


func active_unrest_snapshot() -> Dictionary:
	if int(state.get("active_unrest_level", 0)) <= 0 or int(state.get("active_unrest_weeks", 0)) <= 0:
		return {}
	return {
		"level": int(state.get("active_unrest_level", 0)),
		"weeks": int(state.get("active_unrest_weeks", 0)),
		"cause": str(state.get("active_unrest_cause", "")),
		"labor": bool(state.get("active_unrest_labor", false))
	}


func process_active_unrest_week(snapshot: Dictionary) -> String:
	if snapshot.is_empty():
		return ""
	var level := int(snapshot.get("level", 1))
	var stability_loss := unrest_stability_loss(level)
	apply_effects({"stability": -stability_loss})
	var note := "%s из-за решения «%s»: стабильность −%d." % [unrest_level_title(level, bool(snapshot.get("labor", false))).capitalize(), str(snapshot.get("cause", "")), stability_loss]
	if bool(snapshot.get("labor", false)):
		note += " Не вышедшие на работу граждане уменьшили налоговые и производственные доходы."
	if int(state.get("active_unrest_weeks", 0)) > 0:
		state.active_unrest_weeks = int(state.get("active_unrest_weeks", 0)) - 1
		if int(state.get("active_unrest_weeks", 0)) <= 0:
			clear_active_unrest()
	return note


func build_unrest_event(record: Dictionary) -> Dictionary:
	var level := int(record.get("level", 1))
	var labor := bool(record.get("labor", false))
	var cause := str(record.get("cause", "непопулярное решение правительства"))
	var kind := str(record.get("kind", "civic"))
	var title := "Улица не согласна"
	if labor:
		title = "Смена не началась"
	elif kind == "regional":
		title = "Площади приграничья"
	elif kind == "antiwar":
		title = "Повестки на площади"
	var body := "Решение «%s» вызвало %s. Пока конфликт не закрыт, страна будет терять стабильность каждую неделю." % [cause, unrest_level_title(level, labor)]
	if labor:
		body += " Часть работников не вышла на смены: налоги, государственные предприятия и при тяжёлой забастовке экспорт уже дают меньше дохода."
	var reversible := bool(record.get("reversible", false))
	var first_label := "Отменить спорную меру" if reversible else "Предложить компенсации"
	var first_hint := "Первоначальная выгода будет потеряна • протест прекратится • потребуются уступки и расходы" if reversible else "Решение останется в силе • расходы и уступки затронутой группе прекратят протест"
	var first_effects := {"money": -5, "support": 3, "stability": 3}
	if labor:
		first_label = "Принять требования рабочих"
		first_effects = {"money": -8, "support": 3, "stability": 3, "clan_workers": 10}
	elif kind == "regional":
		first_effects["clan_regions"] = 10
	elif kind == "antiwar":
		first_label = "Ввести отсрочки и компенсации"
		first_effects["money"] = -6
		first_effects["war_support"] = -2
	else:
		first_effects["clan_workers"] = 4
	var first := option(first_label, first_hint, first_effects, "Правительство пошло на уступки. Организаторы объявили требования частично выполненными и начали разбирать лагеря, но прежнюю выгоду спорного решения сохранить полностью не удалось.", {"unrest_resolved": true, "unrest_reverse_policy": reversible})
	var interior_id := str(selected_ministers.get("interior", "volsky"))
	var second: Dictionary
	if interior_id == "kovach":
		var effects := {"support": 3, "stability": -2, "war_support": -2}
		effects["clan_workers" if labor else "clan_regions" if kind == "regional" else "clan_workers"] = 6
		if brother_is_defense_minister():
			effects["army"] = -2
		second = option("Открыть публичные переговоры", "Протест прекратится • его представители получат трибуну • порядок временно пострадает", effects, "Ирина Ковач признала переговорный комитет и открыла заседания для прессы. Улицы освободили, но организаторы получили постоянную политическую трибуну.", {"unrest_resolved": true, "unrest_civic_council": true})
	elif interior_id == "sava":
		second = option("Разделить переговоры по регионам", "Центральный протест прекратится • губернаторы усилятся • центр потеряет одно очко решений на следующей неделе", {"stability": 3, "clan_regions": 8, "clan_workers": -4 if labor else 0}, "Антон Сава передал требования отдельным губернаторам. Общая коалиция распалась, однако местные администрации получили новые полномочия и начали торговаться с центром самостоятельно.", {"unrest_resolved": true, "regional_administration_disruption": true})
	else:
		second = option("Задержать координаторов", "Протест быстро прекратится • поддержка и затронутая группа резко отвернутся • авторитаризм усилится", {"support": -4, "stability": 4, "army": 1, "clan_workers": -9 if labor else -6, "clan_regions": -6 if kind == "regional" else 0, "authoritarian": 1}, "Марек Вольский задержал координаторов и перекрыл доступ к площадям. Организованное движение распалось, но конфликт превратился в спор о политических репрессиях.", {"unrest_resolved": true, "unrest_organizers_detained": true})
	var third := option("Не менять курс", "Первоначальная выгода сохранится • протест продлится ещё две недели • стабильность и доходы при забастовке продолжат падать", {"support": -2}, "Президент отказался от уступок. Правительство сохранило спорное решение, а организаторы объявили, что протест и остановка работы продолжатся.", {"unrest_continue": true})
	return event(current_minister_name("interior"), "official", "#a9473f", title, body, first, second, third)


func take_unrest_event() -> Dictionary:
	var queue: Array = state.get("unrest_queue", [])
	var due := due_unrest_indices()
	if due.is_empty():
		return {}
	var merged: Dictionary = (queue[due[0]] as Dictionary).duplicate(true)
	for offset in range(1, due.size()):
		var other: Dictionary = queue[due[offset]]
		merged.cause = str(merged.get("cause", "")) + "; " + str(other.get("cause", ""))
		merged.level = mini(3, maxi(int(merged.get("level", 1)), int(other.get("level", 1))) + 1)
		merged.labor = bool(merged.get("labor", false)) or bool(other.get("labor", false))
		merged.reversible = bool(merged.get("reversible", false)) and bool(other.get("reversible", false))
		if str(merged.get("kind", "")) != str(other.get("kind", "")):
			merged.kind = "coalition"
		if str(merged.get("reversal", "")) != str(other.get("reversal", "")):
			merged.reversal = ""
			merged.reversible = false
	for offset in range(due.size() - 1, -1, -1):
		queue.remove_at(due[offset])
	state.unrest_queue = queue
	activate_unrest(merged)
	return build_unrest_event(merged)


func schedule_foreign_followup(kind: String, delay_weeks: int) -> void:
	var queue: Array = state.get("foreign_followups", [])
	for queued in queue:
		if queued is Dictionary and str(queued.get("kind", "")) == kind:
			return
	queue.append({"kind": kind, "due_week": mini(DEMO_WEEKS, int(state.get("week", 1)) + delay_weeks)})
	state.foreign_followups = queue


func due_foreign_followup_index() -> int:
	var queue: Array = state.get("foreign_followups", [])
	var selected := -1
	var selected_week := DEMO_WEEKS + 1
	for index in range(queue.size()):
		if not queue[index] is Dictionary:
			continue
		var due_week := int(queue[index].get("due_week", DEMO_WEEKS + 1))
		if due_week <= int(state.get("week", 1)) and due_week < selected_week:
			selected = index
			selected_week = due_week
	return selected


func should_trigger_foreign_followup() -> bool:
	var final_story_resolved := event_resolved and int(state.get("week", 1)) == DEMO_WEEKS and str(current_event.get("title", "")) == "Досрочные выборы"
	return not final_story_resolved and due_foreign_followup_index() >= 0


func take_foreign_followup_event() -> Dictionary:
	var queue: Array = state.get("foreign_followups", [])
	var index := due_foreign_followup_index()
	if index < 0 or index >= queue.size():
		return {}
	var kind := str(queue[index].get("kind", ""))
	queue.remove_at(index)
	state.foreign_followups = queue
	return build_foreign_followup_event(kind)


func schedule_story_followup(kind: String, delay_weeks: int) -> void:
	var queue: Array = state.get("story_followups", [])
	for queued in queue:
		if queued is Dictionary and str(queued.get("kind", "")) == kind:
			return
	queue.append({"kind": kind, "due_week": mini(DEMO_WEEKS, int(state.get("week", 1)) + delay_weeks)})
	state.story_followups = queue


func due_story_followup_index() -> int:
	var queue: Array = state.get("story_followups", [])
	var selected := -1
	var selected_week := DEMO_WEEKS + 1
	for index in range(queue.size()):
		if not queue[index] is Dictionary:
			continue
		var due_week := int(queue[index].get("due_week", DEMO_WEEKS + 1))
		if due_week <= int(state.get("week", 1)) and due_week < selected_week:
			selected = index
			selected_week = due_week
	return selected


func should_trigger_story_followup() -> bool:
	var final_story_resolved := event_resolved and int(state.get("week", 1)) == DEMO_WEEKS and str(current_event.get("title", "")) == "Досрочные выборы"
	return not final_story_resolved and due_story_followup_index() >= 0


func take_story_followup_event() -> Dictionary:
	var queue: Array = state.get("story_followups", [])
	var index := due_story_followup_index()
	if index < 0 or index >= queue.size():
		return {}
	var kind := str(queue[index].get("kind", ""))
	queue.remove_at(index)
	state.story_followups = queue
	return build_story_followup_event(kind)


func remove_wartime_incompatible_followups() -> void:
	if not bool(state.get("at_war", false)):
		return
	var foreign_queue: Array = state.get("foreign_followups", [])
	for index in range(foreign_queue.size() - 1, -1, -1):
		if not foreign_queue[index] is Dictionary:
			continue
		var foreign_event := build_foreign_followup_event(str(foreign_queue[index].get("kind", "")))
		if not foreign_event.is_empty() and event_blocked_by_current_war(foreign_event):
			foreign_queue.remove_at(index)
	state.foreign_followups = foreign_queue
	var story_queue: Array = state.get("story_followups", [])
	for index in range(story_queue.size() - 1, -1, -1):
		if not story_queue[index] is Dictionary:
			continue
		var story_event := build_story_followup_event(str(story_queue[index].get("kind", "")))
		if not story_event.is_empty() and event_blocked_by_current_war(story_event):
			story_queue.remove_at(index)
	state.story_followups = story_queue


func build_story_followup_event(kind: String) -> Dictionary:
	match kind:
		"reception_tape":
			var tape_body := "Экспертиза нашла на записи голос начальника президентской охраны, но монтаж не позволяет доказать, кто собрал разговор. Теперь дело касается не только покушения, но и того, кто контролирует следствие."
			if bool(state.get("tape_seized", false)):
				tape_body = "Изъятая запись появилась сразу на семи зарубежных сайтах. В копии слышен голос начальника президентской охраны, а метаданные указывают на монтаж внутри государственного учреждения. Попытка закрыть историю сама стала частью истории."
			elif bool(state.get("tape_published_raw", false)):
				tape_body = "После публикации полной записи три лаборатории дали три заключения: подлинная, смонтированная и непригодная для анализа. Каждая партия выбрала удобную экспертизу, а начальник охраны требует закрыть дело как политическое."
			return event("Следственная комиссия", "official", "#a9473f", "Запись без оригинала", tape_body,
				option("Создать парламентскую комиссию", "Расследование выйдет из-под контроля президента • потребуются деньги • парламент и общество получат доверие", {"money": -5, "support": 5, "stability": -4, "clan_oligarchs": -6}, "Депутаты получили доступ к журналам охраны и вызвали чиновников в прямой эфир. Дело стало медленнее, зато уничтожить его одним приказом теперь невозможно.", {"tape_parliamentary_commission": true}),
				option("Уволить начальника охраны", "Скандал получит виновного • порядок частично вернётся • доказательства против более влиятельных фигур останутся без проверки", {"support": -2, "stability": 5, "army": -3}, "Начальника охраны отправили в отставку до суда. Телевидение показало пустой кабинет, а следователи обнаружили, что журнал посетителей исчез за час до опечатывания.", {"security_chief_sacrificed": true}),
				option("Объявить запись операцией соседа", "Сторонники сплотятся • отношения с Востоком рухнут • при низкой поддержке начнутся протесты против сокрытия", {"support": 3, "stability": -3, "east_pressure": 5, "war_support": 4, "authoritarian": 1}, "Правительство назвало запись частью восточной информационной операции. Сторонники собрались у дворца, но журналисты ответили публикацией новых фрагментов.", {"tape_foreign_operation": true, "unrest": {"cause": "закрытие дела о записи под предлогом иностранной операции", "kind": "civic", "base_level": 1, "condition": "low_support", "reversible": false}}))
		"election_protocols":
			var protocol_body := "На центральную площадь принесли копии участковых протоколов. В официальной сводке явка выше числа выданных бюллетеней в семнадцати округах. Силовики ещё не вмешались, но ночная смена двух заводов уже не вышла на работу."
			if bool(state.get("protocol_recount", false)):
				protocol_body = "Выборочный пересчёт подтвердил ошибки в одних округах и нашёл запечатанные пачки в других. Комиссия просит либо расширить проверку на всю страну, либо признать нарушения техническими."
			elif bool(state.get("protocol_scans", false)):
				protocol_body = "После публикации сканов добровольцы собрали параллельный подсчёт. Он не меняет победителя, но лишает президентский центр конституционного большинства. Депутаты требуют решить, считать ли этот подсчёт юридическим основанием."
			return event("Центральная избирательная комиссия", "official", "#668269", "Три разные явки", protocol_body,
				liberal_option("Переголосовать в спорных округах", "Дорого и неспокойно • результат получит доверие • брат сочтёт это уступкой улице", {"money": -7, "support": 6, "stability": -5, "clan_workers": 6, "army": -3}, "В семнадцати округах назначили повторное голосование с независимыми комиссиями. Правящая партия сохранила первое место, но потеряла несколько гарантированных кресел.", "Дорого и неспокойно • результат получит доверие • большинство станет менее послушным", "В семнадцати округах назначили повторное голосование с независимыми комиссиями. Правящая партия сохранила первое место, но потеряла несколько гарантированных кресел.", {"election_rerun": true, "parliament_free": true}),
				option("Признать расхождения техническими", "Большинство сохранится • порядок временно укрепится • протест и забастовка возможны при слабой власти", {"support": -6, "stability": 4, "clan_workers": -8, "authoritarian": 1}, "Комиссия утвердила итог одним постановлением. Парламент сохранил большинство, а заводские комитеты объявили, что будут считать голоса уже на проходных.", {"protocols_certified": true, "unrest": {"cause": "утверждение спорных избирательных протоколов", "kind": "labor", "labor": true, "base_level": 2, "condition": "low_support", "reversible": false}}),
				option("Признать параллельный подсчёт", "Президентский центр потеряет часть контроля • парламент станет конкурентнее • улица успокоится не сразу", {"support": 4, "stability": -3, "clan_regions": 6, "clan_oligarchs": -5}, "ЦИК признала опубликованные сканы основанием для корректировки мандатов. Несколько лояльных депутатов лишились мест, зато протестующие начали убирать палатки.", {"parallel_count_recognized": true, "parliament_free": true}))
		"heating_debt":
			var heating_body := "Теплосети четыре недели продавали тепло дешевле себестоимости. Поставщики требуют погасить накопленный долг до следующей поставки, а мэры предупреждают: одинаковое решение для столицы и бедных промышленных городов расколет регионы."
			if bool(state.get("targeted_tariff_support", false)):
				heating_body = "Адресные субсидии дошли до большинства получателей, но реестр пропустил тысячи арендаторов и жителей общежитий. Одновременно теплосети требуют компенсацию разницы в тарифе за первый месяц реформы."
			elif bool(state.get("industrial_cross_subsidy", false)):
				heating_body = "Комбинаты оплатили городское тепло, а затем включили доплату в себестоимость металла. Два завода остановили экспортные линии и требуют отменить перекрёстную субсидию либо разрешить сокращения."
			return event("Энергетическая комиссия", "official", "#c7a96b", "Долг теплосетей", heating_body,
				option("Погасить долг из казны", "Тепло и порядок сохранятся • казна и долг пострадают • другие города потребуют того же", {"money": -12, "debt": 6, "support": 4, "stability": 4, "clan_regions": 5}, "Казначейство закрыло счета теплосетей. Поставки возобновились, а на следующий день ещё девять мэров прислали собственные ведомости долгов.", {"heating_debt_bailed_out": true}),
				option("Передать долг муниципалитетам", "Центр сэкономит • губернаторы получат право вводить местные сборы • регионы усилятся и станут неравнее", {"support": -3, "stability": 1, "debt": 9, "clan_regions": 10}, "Города выпустили облигации и ввели разные коммунальные сборы. Богатые районы рассчитались сразу, бедные заложили доходы на несколько лет.", {"municipal_heating_bonds": true}),
				option("Отключить убыточные промышленные линии", "Поставки населению сохранятся • экспорт и рабочие места пострадают • вероятна забастовка", {"money": 3, "support": -4, "stability": -4, "clan_workers": -10, "pop_employed": -8000, "pop_unemployed": 8000}, "Газ перенаправили с заводов в городские котельные. В квартирах стало теплее, но заводские проходные закрылись, и профсоюзы объявили общую смену протеста.", {"industry_heat_cut": true, "unrest": {"cause": "остановка промышленных линий ради отопления городов", "kind": "labor", "labor": true, "base_level": 2, "condition": "workers_low", "reversible": false}}))
		"constitutional_court":
			return event("Председатель парламента", "official", "#8b6c4b", "Решение, которого нет", "Суд так и не собрал кворум, а государственные органы исполняют противоположные толкования одного закона. Банки требуют подписи судей, антикоррупционная служба — продолжения расследований, губернаторы ждут, кто первым уступит.",
				option("Согласовать замену судей", "Потребуется сделка с фракциями • работа государства восстановится • олигархи получат влияние на часть назначений", {"money": -3, "stability": 6, "support": -2, "clan_oligarchs": 7}, "Коалиция назначила новых судей по квотам. Кворум появился, но у каждого нового кресла теперь есть парламентский покровитель.", {"court_compromise": true}),
				option("Исполнять закон без решения суда", "Реформа продолжится быстро • президент создаст опасный прецедент • протест возможен при слабой поддержке", {"support": 3, "stability": -4, "authoritarian": 1, "clan_oligarchs": -6}, "Правительство приказало учреждениям игнорировать отсутствие решения. Расследования продолжились, а судьи заявили, что президент сам определил границы конституции.", {"court_ignored": true, "unrest": {"cause": "исполнение закона в обход конституционного суда", "kind": "civic", "base_level": 1, "condition": "low_support", "reversible": false}}),
				option("Вынести спор на референдум", "Дорого и медленно • общество получит последнее слово • кампания ещё сильнее расколет страну", {"money": -8, "support": 4, "stability": -6, "clan_regions": 5}, "Вопрос превратили в общенациональный плебисцит. Государственные органы временно вернулись к старым правилам, а обе стороны начали кампанию как новые выборы.", {"constitutional_referendum": true}))
		"faith_schism":
			return event("Совет общин Веры", "official", "#8b6c4b", "Два предстоятеля", "После церковного собора обе стороны назначили своих предстоятелей. В приграничье одна и та же община получила два указа на храм, школу и кладбище. Полиция просит единое правило до первого воскресного богослужения.",
				option("Пусть голосуют прихожане", "Регионы сами поделят храмы • потребуются наблюдатели • церковь потеряет единый центр", {"money": -4, "stability": -2, "clan_regions": 8, "clan_church": -5, "neutrality": 2}, "У дверей храмов поставили урны и списки прихожан. Большинство общин определилось мирно, но несколько деревень получили по две религиозные администрации.", {"parish_votes": true}),
				option("Отдать приоритет независимой церкви", "Национальная церковь укрепится • Восток и часть верующих ответят • возможны региональные протесты", {"support": 4, "stability": -5, "clan_church": 7, "clan_regions": -7, "east_pressure": 5, "war_support": 3}, "Реестр автоматически признал независимую церковь владельцем спорных зданий. В столице зазвонили колокола, а на восточной границе несколько общин заперлись внутри храмов.", {"national_faith_priority": true, "unrest": {"cause": "передача спорных храмов независимой церкви", "kind": "regional", "base_level": 1, "condition": "regions_low", "reversible": false}}),
				option("Заморозить имущество обеих сторон", "Столкновения будут отложены • богослужения ограничат • верующие и церковь отвернутся от власти", {"stability": 4, "support": -4, "clan_church": -10, "authoritarian": 1}, "Полиция опечатала спорные здания до решения суда. Драки прекратились, но воскресные службы прошли на улицах перед закрытыми дверями.", {"faith_property_frozen": true}))
		"volunteer_command":
			var volunteer_body := "На учениях командир добровольческого батальона отказался подчиниться кадровому полковнику и предъявил прямое письмо губернатора. Военные требуют единого командования, добровольцы напоминают, что получили оружие, когда регулярная армия не могла закрыть границу."
			if bool(state.get("volunteers_disarmed", false)):
				volunteer_body = "После разоружения часть добровольцев не сдала оружие и создала ветеранские союзы в трёх городах. Они требуют амнистии и права войти в резерв единым подразделением, а полиция предупреждает о тайных складах."
			elif bool(state.get("volunteers_regional", false)):
				volunteer_body = "Территориальные отряды подчиняются губернаторам и отказываются передавать технику армейскому штабу. На карте обороны появились хорошо вооружённые районы, которые президент не может быстро перебросить."
			return event("Совет обороны", "military", "#536f82", "Чей приказ последний", volunteer_body,
				option("Единое командование после проверки", "Потребуются деньги и время • армия получит управляемый резерв • часть добровольцев уйдёт", {"money": -6, "army": 6, "stability": 2, "army_personnel": 1800, "war_support": 3}, "Каждый доброволец прошёл проверку и подписал индивидуальный контракт. Батальон потерял собственное название, но появился в армейском расписании.", {"volunteers_vetted": true}),
				option("Сделать батальон президентской гвардией", "Президент получит личную силу • армия и порядок пострадают • авторитаризм усилится", {"support": -3, "stability": -4, "army": -7, "war_support": 5, "authoritarian": 1}, "Батальон присягнул лично президенту и занял базу у столицы. Добровольцы довольны статусом, а генеральный штаб больше не включает их в общие планы.", {"presidential_guard_battalion": true}),
				option("Амнистия в обмен на роспуск", "Оружие вернётся на склады • поддержка войны и армия ослабнут • гражданский порядок укрепится", {"support": 3, "stability": 6, "army": -5, "war_support": -7, "army_personnel": -1200}, "Участники сдали тяжёлое оружие и получили амнистию. Большинство разошлось, но их командиры сразу зарегистрировали политическое движение ветеранов.", {"volunteer_party_formed": true}))
	return {}


func build_foreign_followup_event(kind: String) -> Dictionary:
	match kind:
		"east_energy_demand":
			return event("Посольство Восточного Союза", "diplomat", "#8b6c4b", "Цена зимней скидки", "Отопительный сезон пережит благодаря восточной скидке. Теперь посол требует закрепить плату: заморозить западные переговоры либо передать восточному консорциуму долю магистрального трубопровода. Отказ немедленно отменит льготную цену.",
				option("Заморозить западные переговоры", "Энергетическая скидка продлится • Запад усилит давление • свобода внешнего курса сузится", {"money": 4, "support": -3, "east_commitment": 1, "west_pressure": 5, "west_commitment": -1}, "Правительство объявило техническую паузу в западных переговорах. Восток продлил скидку, а западная делегация отозвала часть экспертов.", {"western_talks_frozen": true, "extend_east_energy_discount": true}),
				option("Отдать долю трубопровода", "Казна получит аванс • поставки сохранятся • Восток получит постоянный инфраструктурный рычаг", {"money": 8, "stability": 2, "east_commitment": 2, "west_pressure": 3, "clan_oligarchs": 6}, "Восточный консорциум перечислил аванс и получил место в управлении трубопроводом. Топливо подешевело, но любое обслуживание магистрали теперь требует согласования с соседом.", {"eastern_pipeline_share": true, "extend_east_energy_discount": true}),
				option("Отказаться от требований", "Скидка закончится • поддержка независимого курса вырастет • Восток усилит торговое давление", {"support": 5, "stability": -4, "east_pressure": 6, "clan_regions": -5}, "Президент назвал скидку политическим залогом. Восток вернул рыночную цену и начал внеплановые проверки топливных составов.", {"east_discount_cancelled": true}))
		"western_reform_review":
			return event("Западная комиссия", "diplomat", "#536f82", "Второй транш", "Первый транш пакета модернизации израсходован. Западная Федерация откроет следующий этап доступа к рынку только после аудита государственных компаний и прозрачных закупок. Можно просить переходный период или заморозить соглашение.",
				option("Провести аудит и открыть закупки", "Расходы и конфликт с олигархами • коррупция снизится • доступ к западному рынку продлится", {"money": -5, "support": 4, "corruption_tier": -1, "clan_oligarchs": -10, "west_commitment": 1, "east_pressure": 2}, "Реестры контрактов опубликовали, а первые тендеры открыли иностранным участникам. Несколько владельцев госпредприятий потеряли договоры, зато западный рынок остался открыт.", {"western_reforms_completed": true, "extend_west_market_access": true}),
				option("Выпросить переходный период", "Обе системы временно сохранятся • появятся двойные расходы • отношения с обоими соседями останутся натянутыми", {"money": -3, "stability": 2, "east_pressure": 1, "west_pressure": 1, "clan_oligarchs": -3}, "Комиссия дала отсрочку. Заводы начали вести два комплекта документации и оплачивать две сертификации, сохранив доступ к обоим рынкам лишь временно.", {"double_standards_started": true}),
				option("Заморозить соглашение", "Придётся вернуть часть аванса • старые элиты укрепятся • Запад остановит доступ к рынку", {"money": -7, "support": -3, "west_pressure": 5, "clan_oligarchs": 7}, "Правительство остановило аудит и вернуло неиспользованную часть транша. Директора госпредприятий сохранили контроль, а западная таможня вернула обычные тарифы.", {"western_package_frozen": true}))
		"passport_protection_demand":
			return event("Восточное консульство", "diplomat", "#668269", "Список соотечественников", "Восточный Союз требует признать в приграничных районах совет владельцев его паспортов и консультироваться с ним по полиции, школам и земле. Губернаторы предупреждают: запрет расколет города, а признание создаст параллельное представительство.",
				option("Признать совет владельцев паспортов", "Регион временно успокоится • Восток получит постоянный политический рычаг • армия будет недовольна", {"stability": 5, "support": -4, "army": -3, "east_commitment": 2, "clan_regions": 8, "war_support": -3}, "Совет получил официальный кабинет и право участвовать в слушаниях. Забастовки прекратились, но восточный посол теперь называет его голосом региона.", {"passport_council_recognized": true}),
				option("Запретить иностранные паспорта", "Поддержка и военные настроения вырастут • регион и отношения с Востоком резко ухудшатся • начнутся региональные протесты", {"support": 6, "stability": -7, "east_pressure": 6, "war_support": 5, "clan_regions": -10}, "Документы объявили недействительными для государственных услуг. У консульства выросли очереди, в приграничье начались забастовки, а Восток заявил о преследовании своих граждан.", {"foreign_passports_banned": true, "military_threat": true, "unrest": {"cause": "запрет иностранных паспортов", "kind": "regional", "base_level": 2, "reversible": true, "reversal": "passports"}}),
				option("Позвать международных наблюдателей", "Потребуются деньги • спор останется открытым • нейтральность и доверие регионов укрепятся", {"money": -5, "stability": 1, "neutrality": 3, "east_pressure": 2, "clan_regions": 3}, "Наблюдатели начали сверять списки жителей и случаи давления. Ни одна сторона не получила полного контроля, а окончательное решение отложили.", {"passport_monitoring_mission": true}))
		"east_media_demand":
			return event("Национальный совет вещания", "official", "#536f82", "Редакционная линия", "После покупки крупнейшего телеканала его новый владелец требует считать заявления Восточного Союза официальной позицией второй стороны и предоставить его советникам доступ к политическим эфирам. Отказ грозит остановкой финансирования канала.",
				option("Гарантировать равный эфир", "Канал продолжит работу • Восток получит устойчивое влияние на повестку • общество станет спокойнее, но поддержка снизится", {"support": -3, "stability": 3, "east_commitment": 1}, "Восточные представители получили постоянные места в эфирах. Канал сохранил штат, но каждое пограничное событие теперь обсуждается как спор двух равноправных версий.", {"east_editorial_access": true}),
				option("Раскрыть иностранное финансирование", "Расходы на новый контроль • поддержка вырастет • владелец и Восток ответят", {"money": -3, "support": 4, "stability": -2, "east_pressure": 4, "clan_oligarchs": -5}, "Все иностранные платежи телеканала опубликовали. Часть рекламодателей ушла, зато зрители увидели происхождение редакционных указаний.", {"foreign_media_transparency": true}),
				option("Отключить канал", "Порядок быстро восстановится • поддержка и регионы пострадают • ограничение вещания вызовет протест", {"support": -5, "stability": 5, "east_pressure": 5, "clan_regions": -5, "authoritarian": 1}, "Передатчики опечатали, а частоты замолчали. Слухи временно исчезли из эфира и переместились в подпольные сети.", {"eastern_channel_closed": true, "unrest": {"cause": "отключение крупнейшего телеканала", "kind": "civic", "base_level": 2, "reversible": true, "reversal": "channel_closure"}}))
		"standards_conflict":
			return event("Торговая палата", "diplomat", "#c7a96b", "Две печати на одном ящике", "Заводы одновременно обещали сохранить восточные технические нормы и перейти на западные. Обе системы требуют исключительности: без выбора грузы будут проходить двойную сертификацию, а часть оборудования придётся переделывать дважды.",
				option("Перейти на западный стандарт", "Крупные расходы сейчас • западный рынок останется открыт • Восток закроет часть старых контрактов", {"money": -8, "support": 2, "west_commitment": 2, "east_pressure": 5, "clan_oligarchs": -5, "clan_workers": 3}, "Заводы начали замену линий и получили западные сертификаты. Новые рынки открылись, но восточные заказчики расторгли старые договоры.", {"western_standard_chosen": true, "extend_west_market_access": true}),
				option("Сохранить восточный стандарт", "Казна получит аванс и старые заводы сохранят заказы • Запад остановит интеграцию", {"money": 6, "stability": 2, "east_commitment": 2, "west_pressure": 5, "clan_oligarchs": 7, "clan_workers": -2}, "Восточные заказчики продлили контракты и внесли аванс. Западная комиссия закрыла ускоренный доступ к своему рынку.", {"eastern_standard_chosen": true, "western_package_frozen": true}),
				option("Оплачивать две сертификации", "Оба рынка останутся доступны временно • шесть недель повышенных расходов • нейтральность укрепится", {"money": -2, "stability": -2, "neutrality": 3}, "Экспортёры завели два комплекта чертежей и две лаборатории. Поставки продолжаются в обе стороны, но каждая партия стала дороже.", {"double_standards_started": true}))
	return {}


func next_event() -> void:
	if check_terminal_state():
		return
	if int(state.week) > DEMO_WEEKS:
		show_ending()
		return
	remove_wartime_incompatible_followups()
	if should_trigger_war_crisis():
		current_event = build_war_crisis_event()
		current_event["_kind"] = "urgent"
		state.war_crisis_pending = false
		state.war_crisis_shown = true
		events_required_this_week += 1
	elif should_trigger_war_pressure():
		current_event = build_war_pressure_event()
		current_event["_kind"] = "urgent"
		state.war_pressure_next_week = int(state.get("war_pressure_next_week", WAR_PRESSURE_INTERVAL)) + WAR_PRESSURE_INTERVAL
		events_required_this_week += 1
	elif should_trigger_election_milestone():
		current_event = build_next_election_milestone_event()
		current_event["_kind"] = "urgent"
		events_required_this_week += 1
	elif should_trigger_emergency_powers_protest():
		current_event = emergency_powers_protest_event.duplicate(true)
		current_event["_kind"] = "urgent"
		state.emergency_powers_protest_pending = false
		events_required_this_week += 1
	elif should_trigger_social_protest():
		current_event = social_protest_event.duplicate(true)
		current_event["_kind"] = "urgent"
		state.social_protest_pending = false
		events_required_this_week += 1
	elif should_trigger_unrest():
		current_event = take_unrest_event()
		current_event["_kind"] = "urgent"
		events_required_this_week += 1
	elif should_trigger_story_followup():
		current_event = take_story_followup_event()
		current_event["_kind"] = "urgent"
		events_required_this_week += 1
	elif should_trigger_foreign_followup():
		current_event = take_foreign_followup_event()
		current_event["_kind"] = "urgent"
		events_required_this_week += 1
	elif should_trigger_creditor_review():
		current_event = creditor_review_event.duplicate(true)
		current_event["_kind"] = "urgent"
		state.creditor_review_pending = false
		state.creditor_review_shown = true
		events_required_this_week += 1
	elif should_trigger_financial_crisis():
		current_event = financial_crisis_event.duplicate(true)
		current_event["_kind"] = "urgent"
		state.financial_slot_consumed = true
		state.financial_crisis_shown = true
		events_required_this_week += 1
	elif weekly_event_queue.is_empty():
		update_interface()
		return
	else:
		var queued_event: Dictionary = weekly_event_queue.pop_front().duplicate(true)
		current_event = build_wartime_replacement_event(queued_event) if event_blocked_by_current_war(queued_event) else queued_event
	event_resolved = false
	customize_event_for_ministers()
	display_current_event()


func display_current_event() -> void:
	update_interface()
	if current_event.is_empty():
		return
	play_game_sound("report")
	source_label.text = str(current_event["source"]).to_upper()
	title_label.text = str(current_event["title"]).to_upper()
	body_label.text = str(current_event["body"])
	left_button.text = str(current_event["left"]["label"]).to_upper()
	right_button.text = str(current_event["right"]["label"]).to_upper()
	left_hint.text = str(current_event["left"]["hint"])
	right_hint.text = str(current_event["right"]["hint"])
	var has_third := current_event.has("third") and not (current_event["third"] as Dictionary).is_empty()
	choice_grid.columns = 3 if has_third else 2
	third_button.visible = has_third
	third_hint.visible = has_third
	if has_third:
		third_button.text = str(current_event["third"]["label"]).to_upper()
		third_hint.text = str(current_event["third"]["hint"])
	portrait.setup(str(current_event["role"]), Color(str(current_event["accent"])))
	left_button.disabled = event_resolved or bool(current_event["left"].get("unavailable", false))
	right_button.disabled = event_resolved or bool(current_event["right"].get("unavailable", false))
	third_button.disabled = event_resolved or not has_third or (has_third and bool(current_event["third"].get("unavailable", false)))


func should_trigger_financial_crisis() -> bool:
	# После финальной развилки кампания уже подводит итог: новый срочный доклад
	# не должен вклиниваться после последнего сюжетного решения.
	var final_story_resolved := (
		event_resolved
		and int(state.get("week", 1)) == DEMO_WEEKS
		and str(current_event.get("title", "")) == "Досрочные выборы"
	)
	# Внутри недели отдельные дни не разыгрываются. Поэтому доклад появляется
	# последним, после трёх обычных событий: сюжетно это два дня до расчётного дня.
	var two_days_before_payment := (
		events_resolved_this_week >= EVENTS_PER_WEEK
		and weekly_event_queue.is_empty()
	)
	return (
		not final_story_resolved
		and two_days_before_payment
		and not bool(state.get("financial_crisis_shown", false))
		and not bool(state.get("financial_slot_consumed", false))
		and not financial_crisis_event.is_empty()
		and weekly_balance_forecast() <= FINANCIAL_CRISIS_RESERVE
	)


func should_trigger_creditor_review() -> bool:
	var final_story_resolved := (
		event_resolved
		and int(state.get("week", 1)) == DEMO_WEEKS
		and str(current_event.get("title", "")) == "Досрочные выборы"
	)
	return (
		not final_story_resolved
		and bool(state.get("creditor_review_pending", false))
		and int(state.get("week", 1)) >= int(state.get("creditor_review_due_week", DEMO_WEEKS + 1))
		and not creditor_review_event.is_empty()
	)


func should_trigger_social_protest() -> bool:
	var final_story_resolved := (
		event_resolved
		and int(state.get("week", 1)) == DEMO_WEEKS
		and str(current_event.get("title", "")) == "Досрочные выборы"
	)
	return (
		not final_story_resolved
		and bool(state.get("social_protest_pending", false))
		and int(state.get("week", 1)) >= int(state.get("social_protest_due_week", DEMO_WEEKS + 1))
		and not social_protest_event.is_empty()
	)


func should_trigger_emergency_powers_protest() -> bool:
	var final_story_resolved := (
		event_resolved
		and int(state.get("week", 1)) == DEMO_WEEKS
		and str(current_event.get("title", "")) == "Досрочные выборы"
	)
	return (
		not final_story_resolved
		and bool(state.get("emergency_powers_protest_pending", false))
		and int(state.get("week", 1)) >= int(state.get("emergency_powers_protest_due_week", DEMO_WEEKS + 1))
		and not emergency_powers_protest_event.is_empty()
	)


func should_trigger_election_milestone() -> bool:
	var current_week := int(state.get("week", 1))
	return (
		(current_week >= 9 and not bool(state.get("election_nomination_shown", false)))
		or (current_week >= 18 and not bool(state.get("election_rules_shown", false)))
	)


func build_next_election_milestone_event() -> Dictionary:
	if int(state.get("week", 1)) >= 9 and not bool(state.get("election_nomination_shown", false)):
		state.election_nomination_shown = true
		return event("Президентский центр", "official", "#8b6c4b", "Кандидат временного президента", "До досрочных выборов осталось меньше пяти месяцев. Партия отца готова выдвинуть исполняющего обязанности президента, но требует определиться, кем вы идёте к избирателям: продолжателем семейного курса, реформатором внутри старой системы или независимым кандидатом без партийной кассы.",
			option("Принять наследство отца", "Армия и Церковь поддержат кампанию • часть рабочих увидит продолжение семейной власти", {"support": 2, "army": 4, "clan_church": 5, "clan_workers": -4}, "Съезд выдвинул президента под портретом отца. Старая гвардия получила знакомого кандидата, а оппозиция назвала выборы оформлением наследства.", {"election_campaign": "legacy"}),
			liberal_option("Обещать обновление", "Поддержка и профсоюзы укрепятся • брат настроит армию против разрыва с курсом отца", {"support": 4, "army": -4, "clan_workers": 5, "clan_church": -3}, "Президент принял выдвижение, но пообещал демонтировать наиболее жёсткие порядки отца. Молодые активисты пришли в штаб, а брат отказался появляться на съезде.", "Поддержка и профсоюзы укрепятся • сторонники старого курса будут недовольны", "Президент принял выдвижение, но пообещал демонтировать наиболее жёсткие порядки отца. Молодые активисты пришли в штаб, а сторонники старого курса покинули первые ряды.", {"election_campaign": "reform"}),
			option("Идти независимо", "Партийная касса и олигархи отдалятся • регионы получат больше влияния • кампания станет менее управляемой", {"support": 1, "stability": -2, "clan_oligarchs": -7, "clan_regions": 6}, "Президент отказался выступать кандидатом одной партии и начал собирать подписи. Губернаторы предложили местные штабы, но казначей президентского центра закрыл доступ к партийной кассе.", {"election_campaign": "independent"}))
	if int(state.get("week", 1)) >= 18 and not bool(state.get("election_rules_shown", false)):
		state.election_rules_shown = true
		return event("Центральная избирательная комиссия", "official", "#536f82", "Кто будет считать", "Парламент должен утвердить порядок досрочных выборов. Независимая комиссия повысит доверие к результату, лояльный состав даст аппарату возможность исправлять неудобные протоколы, а межпартийный контроль заставит власть делить каждую комиссию с губернаторами и оппозицией.",
			liberal_option("Независимая комиссия", "Доверие к выборам и поддержка вырастут • аппарат и старые покровители потеряют контроль • брат будет недоволен", {"support": 4, "stability": -3, "army": -2, "clan_oligarchs": -6}, "Судьи, учителя и общественные организации получили большинство в комиссии. Аппарат лишился гарантированного подсчёта, зато оппозиция согласилась заранее признать проверяемый результат.", "Доверие к выборам и поддержка вырастут • аппарат и старые покровители потеряют контроль", "Судьи, учителя и общественные организации получили большинство в комиссии. Аппарат лишился гарантированного подсчёта, зато оппозиция согласилась заранее признать проверяемый результат.", {"election_rules": "fair"}),
			option("Сохранить лояльную комиссию", "Официальный результат получит административное преимущество • поддержка упадёт • олигархи и аппарат укрепятся", {"support": -5, "stability": 3, "clan_oligarchs": 7, "authoritarian": 1}, "Большинство комиссии сохранили чиновники, назначенные ещё отцом. Они обещали порядок и быстрый подсчёт, а наблюдатели начали собирать параллельные протоколы.", {"election_rules": "managed", "unrest": {"cause": "сохранение подконтрольной избирательной комиссии", "kind": "civic", "base_level": 1, "condition": "low_support", "reversible": false}}),
			option("Разделить комиссии", "Потребуются деньги и переговоры • регионы и профсоюзы получат контроль • небольшой перевес останется у власти", {"money": -5, "stability": 2, "clan_workers": 5, "clan_regions": 5, "clan_oligarchs": -3}, "Каждый участок получил представителей президента, оппозиции и местной власти. Подсчёт станет медленнее и дороже, зато подменить протокол без свидетелей будет трудно.", {"election_rules": "negotiated"}))
	return {}


func should_trigger_war_crisis() -> bool:
	return (
		bool(state.get("at_war", false))
		and bool(state.get("war_crisis_pending", false))
		and not bool(state.get("war_crisis_shown", false))
	)


func should_trigger_war_pressure() -> bool:
	return (
		bool(state.get("at_war", false))
		and bool(state.get("war_crisis_shown", false))
		and int(state.get("war_weeks", 0)) >= int(state.get("war_pressure_next_week", WAR_PRESSURE_INTERVAL))
	)


func pending_extra_report_count() -> int:
	return (
		(1 if should_trigger_war_crisis() else 0)
		+ (1 if should_trigger_war_pressure() else 0)
		+ (1 if should_trigger_election_milestone() else 0)
		+ (1 if should_trigger_emergency_powers_protest() else 0)
		+ (1 if should_trigger_social_protest() else 0)
		+ (1 if should_trigger_unrest() else 0)
		+ (1 if should_trigger_story_followup() else 0)
		+ (1 if should_trigger_foreign_followup() else 0)
		+ (1 if should_trigger_creditor_review() else 0)
		+ (1 if should_trigger_financial_crisis() else 0)
	)


func week_ready_for_new_week() -> bool:
	return (
		event_resolved
		and events_resolved_this_week >= events_required_this_week
		and weekly_event_queue.is_empty()
		and not should_trigger_war_crisis()
		and not should_trigger_war_pressure()
		and not should_trigger_election_milestone()
		and not should_trigger_emergency_powers_protest()
		and not should_trigger_social_protest()
		and not should_trigger_unrest()
		and not should_trigger_story_followup()
		and not should_trigger_foreign_followup()
		and not should_trigger_creditor_review()
		and not should_trigger_financial_crisis()
	)


func continue_to_next_event() -> void:
	if not event_resolved or week_ready_for_new_week():
		return
	close_overlay()
	next_event()


func continue_after_result() -> void:
	if not event_resolved:
		return
	close_overlay()
	if week_ready_for_new_week():
		# После последнего доклада игрок возвращается к обычному экрану,
		# где отдельно выделена кнопка перехода к новой неделе.
		update_interface()
		return
	next_event()


func on_week_action_pressed() -> void:
	if week_ready_for_new_week():
		request_end_week()
	elif event_resolved:
		continue_to_next_event()


func customize_event_for_ministers() -> void:
	var event_title := str(current_event["title"])
	if event_title in ["Счета к оплате", "Пустующие цеха", "Красные каски"]:
		current_event["source"] = current_minister_name("economy")
	elif event_title in ["Некомплект гарнизонов", "Коробки передач", "Самолёты с чужими кодами"]:
		current_event["source"] = current_minister_name("defense")
	elif event_title == "Бутылка из погреба":
		var defense_name := current_minister_name("defense")
		var is_brother := brother_is_defense_minister()
		current_event["body"] = "— Господин президент, тут неловкое дело, — повар показывает пустую ячейку в погребе. — %s ночью унёс бутылку отцовского вина. Сказал охране: «Министру обороны нужнее». В накладной её нет, а персонал уже спорит, считается ли это приказом." % ("Ваш брат" if is_brother else defense_name)
		current_event["left"]["result"] = "%s получил официальный выговор и вернул бутылку через адъютанта. История быстро разошлась по аппарату: гражданская прислуга увидела, что министр не стоит выше правил, а штаб — что президент готов унижать своего военного руководителя из-за личного проступка." % defense_name
		current_event["right"]["result"] = "Вы велели повару закрыть журнал и больше не поднимать вопрос. %s сохранил лицо перед штабом, но персонал резиденции понял, что для высших чиновников правила действуют иначе." % defense_name
	elif event_title == "Ужин остывает":
		if bool(state.get("at_war", false)):
			current_event["body"] = "— Ты снова назвал потери допустимыми, — говорит жена, снимая с ужина уже остывшее блюдо. — Для штаба это строка в докладе, а соседка получила похоронное письмо. Ты сегодня останешься дома или опять будешь убеждать страну, что фронт держится?"
		elif bool(state.get("media_restricted", false)):
			current_event["body"] = "— Газеты напечатали твою речь слово в слово, — жена кладёт на стол три одинаковые первые полосы. — Но люди не стали от этого верить тебе больше. Ты поужинаешь со мной или снова поедешь объяснять по телевидению, почему молчание называется порядком?"
		elif int(state.get("authoritarian", 0)) >= 2:
			current_event["body"] = "— Охрана сегодня проверила даже мои письма, — жена отодвигает нетронутую тарелку. — Ты говоришь, что жёсткость временная, но дом уже живёт как министерство. Останешься на ужин или у тебя снова совещание о дисциплине?"
		elif int(state.get("support", 50)) <= 40:
			current_event["body"] = "— На рынке меня впервые проводили молча, — говорит жена, пока ужин остывает. — Я не прошу тебя быть популярным. Я хочу понять, слышишь ли ты людей за окнами. Сегодня останешься дома или ответишь им очередным обращением?"
		else:
			current_event["body"] = "— Я уже третий раз разогреваю ужин, — говорит жена, закрывая папку с вашей новой речью. — Страна переживёт один вечер без президента. Вопрос только в том, переживёшь ли ты вечер без страны."
	if event_title == "Счета к оплате":
		current_event["source"] = current_minister_name("economy")
		var forecast := weekly_balance_forecast()
		# Экстренный источник должен действительно закрывать уже известный кассовый
		# разрыв. Чем глубже военный дефицит, тем больше выпуск или кредит — и тем
		# тяжелее сопутствующая цена. В подсказке показывается сумма после коррупции.
		var income_multiplier := 1.0 - float(corruption_transaction_rate(projected_corruption_tier())) / 100.0
		var required_net := maxf(4.0, -forecast + 4.0)
		var required_gross := ceili(required_net / maxf(0.01, income_multiplier))
		var emission_amount := maxi(21, required_gross)
		var credit_amount := maxi(28, required_gross)
		var credit_debt := maxi(40, ceili(float(credit_amount) * 1.43))
		current_event["left"] = option("Напечатать деньги", "Казна +%.2f млн • без нового долга и внешних условий • шестинедельный инфляционный шок" % adjusted_money_transaction(emission_amount, projected_corruption_tier()), {"money": emission_amount, "support": -4, "stability": -1}, "Центральный банк выпустил новые деньги. Выплаты проведены. Следующие шесть недель государственные контракты будут обходиться на 1.20 млн дороже; на третьей и шестой неделе инфляционного шока поддержка власти снизится ещё на 2 пункта.", {"printed_money": true})
		current_event["right"] = option("Кредит фонда", "Казна +%.2f млн • долг +%d млн • меньше немедленный удар по поддержке • внешние условия" % [adjusted_money_transaction(credit_amount, projected_corruption_tier()), credit_debt], {"money": credit_amount, "debt": credit_debt, "creditor_obligations": 2, "support": -2}, "Международный фонд перечислил чрезвычайный транш. Республика получила деньги на ближайшие выплаты, признала новый долг и согласилась на проверку условий кредитной линии.", {"fund_debt": true})
		var economy_id := str(selected_ministers.get("economy", "radan"))
		if economy_id == "grad":
			current_event["body"] = "До обязательных выплат осталось два дня. При неизменном бюджете казна к расчётному дню составит %.2f млн. Министр-государственник предлагает выпуск денег либо чрезвычайный сбор с сырьевых компаний." % forecast
			var levy_amount := maxi(19, required_gross)
			current_event["right"] = option("Сырьевой сбор", "Казна +%.2f млн • бизнес, порядок и элиты пострадают" % adjusted_money_transaction(levy_amount, projected_corruption_tier()), {"money": levy_amount, "support": -4, "stability": -1, "corruption_tier": 1, "clan_oligarchs": -15}, "Правительство изъяло часть экспортной выручки. Выплаты проведены, а владельцы месторождений начали искать союзников в парламенте.", {"emergency_resource_levy": true})
		elif economy_id == "sorec":
			current_event["body"] = "До обязательных выплат осталось два дня. При неизменном бюджете казна к расчётному дню составит %.2f млн. Министр предлагает временное соглашение с профсоюзами и крупным бизнесом: заморозить часть выплат, а недостающую сумму собрать авансами." % forecast
			var agreement_amount := maxi(20, required_gross)
			var agreement_debt := maxi(30, ceili(float(agreement_amount) * 1.35))
			current_event["right"] = option("Трёхстороннее соглашение", "Казна +%.2f млн • долг +%d млн • профсоюзы поддержат" % [adjusted_money_transaction(agreement_amount, projected_corruption_tier()), agreement_debt], {"money": agreement_amount, "debt": agreement_debt, "support": 1, "clan_workers": 7, "clan_oligarchs": -5}, "Профсоюзы согласились отложить индексацию, а крупнейшие компании внесли налоговый аванс. Сделка дала время, но отложенные выплаты стали государственным долгом, и обе стороны ждут уступок.", {"deferred_social_obligations": true})
		else:
			current_event["body"] = "До обязательных выплат осталось два дня. Казначейство предупреждает: при неизменном бюджете к расчётному дню в казне будет %.2f млн. Без нового источника денег выплаты сорвутся." % forecast
			if bool(state.get("fund_access_closed", false)):
				current_event["body"] += " После прошлого отказа Международный фонд закрыл резервную кредитную линию."
				current_event["right"] = option("Кредит фонда недоступен", "Резервная линия закрыта после отказа выполнять условия прошлого займа", {}, "Фонд отказался возобновлять кредитование.")
				current_event["right"]["unavailable"] = true
	elif event_title == "Условия кредитной линии":
		var demand_key := str(state.get("creditor_demand_budget_key", ""))
		if demand_key == "":
			demand_key = choose_creditor_austerity_target()
			state.creditor_demand_budget_key = demand_key
		var demand_title := budget_title(demand_key)
		var current_level := budget_level(demand_key)
		var austerity_reaction := budget_reaction_for_change(demand_key, -current_level)
		austerity_reaction["creditor_obligations"] = -1
		current_event["body"] = "После чрезвычайного транша фонд требует выбрать одно из условий. Первый вариант — сократить статью «%s» до минимального уровня и не повышать её четыре недели. Второй — перевести обслуживание долга в приоритет и удерживать его там четыре недели. Отказ означает штраф, ужесточение условий и закрытие резервной кредитной линии." % demand_title
		current_event["left"] = option("Сократить: %s" % demand_title, "Статья станет минимальной на четыре недели • экономия и обычные последствия сокращения начнутся в конце недели", austerity_reaction, "Правительство подписало программу сокращений. Статья «%s» переведена на минимальный уровень и останется там четыре недели." % demand_title, {"creditor_austerity_accepted": true})
		current_event["right"] = option("Приоритет выплат долга", "Обслуживание долга станет приоритетным на четыре недели • свободных денег станет меньше • долг будет сокращаться", {"creditor_obligations": -1}, "Казначейство подписало обязательный график платежей. Обслуживание долга получило приоритет на четыре недели.", {"creditor_debt_priority_accepted": true})
		current_event["third"] = option("Отказаться от требований", "Штраф 10 млн • долг +12 млн • стабильность резко снизится • условия кредиторов станут максимальными", {"money": -10, "support": 4, "stability": -10, "debt": 12, "creditor_obligations": 1, "clan_oligarchs": -10}, "Президент отказался выполнять требования фонда. Кредиторы начислили штраф, закрыли резервную линию и предупредили банки о риске работы с республикой. Выступление подняло поддержку суверенного курса, но вызвало отток капитала и кризис доверия.", {"creditor_terms_refused": true, "fund_access_closed": true})
	elif event_title == "Пустые конверты":
		current_event["source"] = current_minister_name("interior")
		var interior_id := str(selected_ministers.get("interior", "volsky"))
		if interior_id == "kovach":
			current_event["body"] = "После сокращения пенсий и пособий колонны перекрыли центр столицы. Ирина Ковач предлагает официально признать избранный протестующими социальный совет и дать ему право участвовать в публичных слушаниях. Денег это не потребует, но улица получит постоянную политическую трибуну."
			var kovach_protest_effects := {"support": 4, "stability": -3, "war_support": -3, "clan_workers": 8}
			if brother_is_defense_minister():
				kovach_protest_effects["army"] = -2
			var kovach_protest_hint := "Новых расходов нет • поддержка и профсоюзы вырастут • стабильность и поддержка войны снизятся"
			var kovach_protest_result := "Правительство признало социальный совет и предоставило ему время на парламентских слушаниях. Колонны освободили дороги, но сохранили палаточный лагерь перед парламентом и превратились в постоянную публичную оппозицию."
			if brother_is_defense_minister():
				kovach_protest_hint += " • брат увидит уступку улице"
				kovach_protest_result += " Штаб под руководством брата назвал соглашение поощрением уличного давления."
			current_event["right"] = option("Признать совет протеста", kovach_protest_hint, kovach_protest_effects, kovach_protest_result, {"social_protest_civic_council": true})
		elif interior_id == "sava":
			current_event["body"] = "После сокращения пенсий и пособий колонны перекрыли центр столицы. Антон Сава предлагает передать разбор жалоб губернаторам и признать их единственными переговорщиками от регионов. Денег никто не получит: расчёт сделан на раскол общего движения на десятки местных споров."
			current_event["right"] = option("Передать спор регионам", "Новых расходов нет • столица быстро успокоится и губернаторы усилятся • профсоюзы расколются • на следующей неделе −1 очко решений", {"support": -3, "stability": 5, "clan_workers": -7, "clan_regions": 10}, "Губернаторы объявили себя единственными представителями областей и развезли колонны по домам обещаниями отдельных комиссий. Столица очистилась, но национальный профсоюз раскололся, а аппарат президента на следующую неделю увяз в согласовании десятков региональных требований.", {"social_protest_governor_deal": true, "regional_administration_disruption": true})
		else:
			current_event["body"] = "После сокращения пенсий и пособий колонны перекрыли центр столицы. Марек Вольский предлагает не атаковать всю толпу, а ночью задержать координаторов и перекрыть профсоюзные штабы."
			current_event["right"] = option("Задержать организаторов", "Новых расходов не будет • порядок частично восстановится • поддержка и профсоюзы отвернутся", {"support": -3, "stability": 3, "army": 1, "clan_workers": -8, "authoritarian": 1}, "Полиция задержала координаторов до рассвета и заблокировала профсоюзные кассы. Часть колонн рассыпалась без командования, но оставшиеся участники назвали протест политическим и потребовали освобождения арестованных.", {"social_protest_organizers_detained": true})
		if law_enacted("Чрезвычайные полномочия"):
			current_event["third"] = option("Ввести комендантский час", "Полиция получит законные полномочия • порядок восстановится быстрее • поддержка и профсоюзы отвернутся", {"support": -5, "stability": 6, "army": 2, "war_support": -1, "clan_workers": -10, "authoritarian": 1}, "Правительство ввело комендантский час по уже принятому закону. Полиция перекрыла районы, поэтапно вытеснила колонны и избежала массового штурма площади. Протест прекратился быстрее, но профсоюзы объявили чрезвычайные полномочия постоянным оружием против них.", {"social_protest_suppressed": true, "emergency_curfew_used": true})
	elif event_title == "Парламент за ограждением":
		current_event["source"] = current_minister_name("interior")
		var interior_id := str(selected_ministers.get("interior", "volsky"))
		if interior_id == "kovach":
			current_event["body"] = "После передачи президенту права действовать без голосования у парламента собралась широкая коалиция противников закона. Ирина Ковач предлагает не отменять полномочия немедленно, а допустить конституционных судей и представителей протестующих к контролю за каждым чрезвычайным указом."
			current_event["right"] = liberal_option("Допустить гражданский контроль", "Поддержка и гражданские группы укрепятся • порядок и свобода указов уменьшатся • брат будет недоволен", {"support": 3, "stability": -3, "army": -3, "clan_oligarchs": 3, "clan_church": 4, "clan_workers": 6, "clan_regions": 4}, "Указы сохранили силу, но каждый из них теперь публикуется с заключением судей и наблюдателей. Протестующие освободили площадь, а брат обвинил МВД в добровольном отказе от чрезвычайной власти.", "Поддержка и гражданские группы укрепятся • порядок и свобода указов уменьшатся", "Указы сохранили силу, но каждый из них теперь публикуется с заключением судей и наблюдателей. Протестующие освободили площадь, а гражданское руководство армии приняло новый порядок контроля.", {"emergency_civic_oversight": true})
		elif interior_id == "sava":
			current_event["body"] = "После передачи президенту права действовать без голосования у парламента собралась широкая коалиция противников закона. Антон Сава предлагает сохранить чрезвычайные полномочия центра, но дать губернаторам право не исполнять указы до консультации с регионами."
			current_event["right"] = option("Дать регионам отсрочку", "Порядок частично вернётся и регионы усилятся • поддержка снизится • на следующей неделе −1 очко решений", {"support": -2, "stability": 4, "clan_oligarchs": -2, "clan_church": -2, "clan_workers": -4, "clan_regions": 9}, "Губернаторы увели региональные колонны с площади в обмен на право задерживать чрезвычайные указы. Коалиция распалась, но президентский аппарат на следующую неделю погряз в отдельных согласованиях.", {"emergency_regional_exemptions": true, "regional_administration_disruption": true})
		else:
			current_event["body"] = "После передачи президенту права действовать без голосования у парламента собралась широкая коалиция противников закона. Марек Вольский предлагает ночью задержать координационный комитет, пока разные группы не успели создать единое руководство."
			current_event["right"] = option("Задержать координаторов", "Порядок восстановится • поддержка и гражданские группы отвернутся • армия одобрит силу", {"support": -5, "stability": 5, "army": 2, "clan_oligarchs": -3, "clan_church": -4, "clan_workers": -8, "clan_regions": -4, "authoritarian": 1}, "Полиция задержала координаторов и очистила проходы к министерствам. Чрезвычайный закон сохранился, но разрозненные гражданские группы впервые создали общий подпольный комитет против президентских указов.", {"emergency_powers_protest_suppressed": true})
	elif event_title == "Весна в столице":
		current_event["source"] = current_minister_name("interior")
		var interior_id := str(selected_ministers.get("interior", "volsky"))
		if interior_id == "kovach":
			current_event["body"] = "Студенты требуют раскрыть материалы о покушении и провести досрочные выборы. Министр предлагает допустить митинг либо отправить посредников для переговоров с организаторами."
			var kovach_spring_effects := {"stability": -2, "support": 3, "war_support": -2, "clan_workers": 4}
			if brother_is_defense_minister():
				kovach_spring_effects["army"] = -2
			var kovach_spring_result := "Посредники добились свободного прохода по улицам в обмен на официальное признание студенческого комитета и публичные слушания о ходе расследования. Насилия не произошло, но комитет получил постоянную трибуну для давления на власть."
			if brother_is_defense_minister():
				kovach_spring_result += " Армейское командование брата назвало это уступкой улице."
			current_event["right"] = option("Признать комитет", "Новых расходов нет • поддержка и профсоюзы вырастут • стабильность и поддержка войны снизятся" + (" • брат будет недоволен" if brother_is_defense_minister() else ""), kovach_spring_effects, kovach_spring_result)
		elif interior_id == "sava":
			current_event["body"] = "Губернаторы сообщают, что к столичным студентам собираются присоединиться региональные колонны. Министр предлагает договориться с местными лидерами до их прибытия."
			current_event["right"] = option("Закрыть выезд колонн", "Новых расходов нет • столица успокоится и губернаторы усилятся • поддержка снизится • на следующей неделе −1 очко решений", {"stability": 5, "support": -2, "clan_regions": 7}, "Губернаторы отменили автобусы, задержали местных координаторов административными проверками и объявили, что сами представят требования регионов. Колонны остались дома, но аппарат президента на следующую неделю оказался занят согласованием требований усилившихся региональных властей.", {"regional_administration_disruption": true})
		if law_enacted("Чрезвычайные полномочия"):
			current_event["third"] = option("Изолировать площадь", "Чрезвычайный закон позволит избежать штурма • порядок восстановится • поддержка и профсоюзы снизятся", {"stability": 8, "support": -7, "army": 3, "war_support": -1, "clan_workers": -6, "authoritarian": 1}, "Полиция оцепила площадь по чрезвычайному закону, отключила транспорт и выпускала участников небольшими группами после проверки документов. Массового штурма не произошло, но студенческие организации объявили, что мирный протест теперь фактически запрещён.", {"emergency_square_isolation": true})
	elif event_title == "Досрочные выборы":
		var rules := str(state.get("election_rules", "undecided"))
		if rules not in ["fair", "managed", "negotiated"]:
			rules = "fair"
		var forecast := election_forecast_label(true)
		current_event["body"] = "Двадцать шесть недель временного президентства закончились. Вы шли на выборы как «%s», подсчёт подготовлен по модели «%s». Текущий прогноз — %s, но точная доля голосов станет известна только после закрытия участков. Последний выбор определит, какой результат республика назовёт законным." % [election_campaign_name(str(state.get("election_campaign", ""))), election_rules_name(rules), forecast]
		current_event["left"] = option("Признать итог комиссии", "Подсчёт пройдёт по ранее выбранным правилам • прогноз: %s • поражение приведёт к мирной передаче власти" % forecast, {}, "Президент приказал не вмешиваться в передачу протоколов и публично обязался признать итог комиссии.", {"election_method": rules})
		current_event["right"] = option("Использовать весь аппарат", "Административный ресурс повысит официальный результат • поддержка и доверие к процедуре снизятся • итог могут не признать", {"support": -5, "stability": -4, "clan_oligarchs": 6, "authoritarian": 1}, "Администрации получили целевые показатели явки, государственные каналы — единую сетку эфира, а председатели комиссий — звонки из президентской канцелярии.", {"election_method": "managed"})
		if bool(state.get("at_war", false)) and emergency_powers_override_active():
			current_event["third"] = option("Перенести выборы", "Доступно только из-за войны и чрезвычайных полномочий • голосование не состоится • реакция зависит от поддержки власти и войны", {"support": -6, "stability": -6, "army": 4, "war_support": -3, "clan_oligarchs": -5, "clan_church": -5, "clan_workers": -8, "clan_regions": -6, "authoritarian": 1}, "Президент отложил голосование до окончания войны, сославшись на чрезвычайный закон. Избирательные комиссии закрылись, а парламент и улица начали спорить, существует ли у временного президента мандат после назначенной даты.", {"election_method": "postponed"})
		else:
			current_event["third"] = option("Объявить победу заранее", "Поражение в протоколах станет невозможным • страна, группы и улица могут не признать новый мандат", {"support": -9, "stability": -8, "army": 3, "clan_oligarchs": -6, "clan_church": -6, "clan_workers": -10, "clan_regions": -8, "authoritarian": 1}, "Государственное телевидение объявило победу президента до поступления половины протоколов. Оппозиция потребовала от комиссии и армии решить, существует ли после этого законный результат.", {"election_method": "rigged"})
	elif str(current_event["role"]) == "diplomat":
		current_event["source"] = current_minister_name("foreign")
		var foreign_id := str(selected_ministers.get("foreign", "narin"))
		if event_title == "Обвинение без доказательств" and foreign_id == "kres":
			current_event["left"] = option("Обвинить Запад", "Поддержка и военные настроения вырастут • порядок и отношения с Западом пострадают", {"support": 5, "stability": -4, "west_pressure": 6, "east_commitment": 1, "war_support": 6}, "Вы обвинили Западную Федерацию в убийстве отца. Восточный Союз немедленно предложил совместное расследование, у западного посольства начались стычки, а делегация покинула страну.", {"accused_west": true})
		elif event_title == "Обвинение без доказательств" and foreign_id == "varek":
			current_event["left"]["effects"]["west_commitment"] = 2
			current_event["left"]["effects"]["east_pressure"] = 7
	customize_liberal_army_reactions()


func customize_liberal_army_reactions() -> void:
	for side in ["left", "right", "third"]:
		if not current_event.has(side):
			continue
		var option_data: Dictionary = current_event[side]
		if not bool(option_data.get("liberal_army_reaction", false)):
			continue
		var effects: Dictionary = (option_data.get("effects", {}) as Dictionary).duplicate(true)
		if brother_is_defense_minister():
			effects["army"] = int(option_data.get("liberal_army_effect", effects.get("army", 0)))
			option_data["hint"] = str(option_data.get("hint_with_brother", option_data.get("hint", "")))
			option_data["result"] = str(option_data.get("result_with_brother", option_data.get("result", "")))
		else:
			effects.erase("army")
			option_data["hint"] = str(option_data.get("hint_without_brother", option_data.get("hint", "")))
			option_data["result"] = str(option_data.get("result_without_brother", option_data.get("result", "")))
		option_data["effects"] = effects
		current_event[side] = option_data


func option_effects_for_current_ministers(option_data: Dictionary) -> Dictionary:
	var effects: Dictionary = (option_data.get("effects", {}) as Dictionary).duplicate(true)
	if bool(option_data.get("liberal_army_reaction", false)):
		if brother_is_defense_minister():
			effects["army"] = int(option_data.get("liberal_army_effect", effects.get("army", 0)))
		else:
			effects.erase("army")
	if int(effects.get("east_pressure", 0)) > 0:
		if bool(state.get("east_editorial_access", false)):
			effects["support"] = int(effects.get("support", 0)) - 2
		if bool(state.get("media_resilience_program", false)) and int(effects.get("stability", 0)) < 0:
			effects["stability"] = mini(0, int(effects.get("stability", 0)) + 2)
	return apply_media_support_filter(effects)


func apply_media_support_filter(effects: Dictionary) -> Dictionary:
	var filtered: Dictionary = effects.duplicate(true)
	var support_change := int(filtered.get("support", 0))
	if bool(state.get("media_restricted", false)) and support_change < 0:
		# Подконтрольные СМИ смягчают общественную реакцию на решения президента,
		# но не отменяют цену непопулярного шага полностью.
		filtered["support"] = -maxi(1, ceili(float(absi(support_change)) * 2.0 / 3.0))
	return filtered


func choose_option(side: String) -> void:
	if current_event.is_empty() or event_resolved or not current_event.has(side):
		return
	if bool((current_event[side] as Dictionary).get("unavailable", false)):
		return
	left_button.disabled = true
	right_button.disabled = true
	third_button.disabled = true
	var option: Dictionary = current_event[side]
	var previous_corruption_tier := projected_corruption_tier()
	var original_effects := option_effects_for_current_ministers(option)
	var decision_effects := amplify_decision_effects(original_effects, str(current_event.get("_kind", "general")))
	var change_source := "Доклад «%s»: %s" % [str(current_event.get("title", "Событие")), str(option.get("label", "решение"))]
	var applied_effects := queue_week_change(change_source, decision_effects, option.get("set", {}))
	event_resolved = true
	events_resolved_this_week += 1
	update_interface()
	autosave_if_iron()
	# Пока карточка результата проходит короткую анимацию, боковой переход
	# остаётся недоступен и не может перескочить на следующий доклад раньше окна.
	end_week_button.disabled = true
	show_result(str(option["result"]), decision_effects, applied_effects, side, previous_corruption_tier)


func apply_option_flags(option_data: Dictionary) -> void:
	apply_state_flags(option_data.get("set", {}))


func apply_state_flags(option_flags: Dictionary) -> void:
	for flag in option_flags.keys():
		if str(flag) in ["unrest", "unrest_resolved", "unrest_reverse_policy", "unrest_continue", "war_frontline_retreat", "war_medical_priority", "war_ammo_conservation"]:
			continue
		state[flag] = option_flags[flag]
	if bool(option_flags.get("war_frontline_retreat", false)):
		state.war_frontline_reductions = mini(3, int(state.get("war_frontline_reductions", 0)) + 1)
	if bool(option_flags.get("war_medical_priority", false)):
		state.war_medical_priority_until_week = int(state.get("week", 1)) + 3
	if bool(option_flags.get("war_ammo_conservation", false)):
		state.war_ammo_conservation_until_week = int(state.get("week", 1)) + 3
	if bool(state.get("east_border_oil_concession", false)):
		state.oil_to_army = mini(int(state.get("oil_to_army", 0)), current_oil_output())
	if option_flags.get("unrest", {}) is Dictionary and not (option_flags.get("unrest", {}) as Dictionary).is_empty():
		schedule_unrest(option_flags.get("unrest", {}))
	if bool(option_flags.get("unrest_reverse_policy", false)):
		reverse_active_unrest_policy()
	if bool(option_flags.get("unrest_resolved", false)):
		clear_active_unrest()
	if bool(option_flags.get("unrest_continue", false)):
		state.active_unrest_weeks = 3
		state.active_unrest_level = maxi(1, int(state.get("active_unrest_level", 1)))
	if bool(option_flags.get("printed_money", false)):
		state.emission_shock_weeks = EMISSION_SHOCK_WEEKS
		state.emission_shock_elapsed = 0
	if bool(option_flags.get("fund_debt", false)) and not bool(state.get("creditor_review_shown", false)):
		state.creditor_review_pending = true
		state.creditor_review_due_week = mini(DEMO_WEEKS, int(state.get("week", 1)) + 1)
		if str(state.get("creditor_demand_budget_key", "")) == "":
			state.creditor_demand_budget_key = choose_creditor_austerity_target()
	if bool(option_flags.get("creditor_austerity_accepted", false)):
		var austerity_key := str(state.get("creditor_demand_budget_key", "budget_social"))
		state.creditor_budget_lock_key = austerity_key
		state.creditor_budget_lock_level = 0
		state.creditor_budget_lock_until_week = int(state.get("week", 1)) + CREDITOR_BUDGET_LOCK_WEEKS
		state[austerity_key] = 0
		budget_draft[austerity_key] = 0
		state.last_budget_change = "По условиям фонда статья «%s» сокращена до минимума на четыре недели." % budget_title(austerity_key)
		update_social_protest_from_budget()
	if bool(option_flags.get("creditor_debt_priority_accepted", false)):
		state.creditor_budget_lock_key = "budget_debt"
		state.creditor_budget_lock_level = 2
		state.creditor_budget_lock_until_week = int(state.get("week", 1)) + CREDITOR_BUDGET_LOCK_WEEKS
		state.budget_debt = 2
		budget_draft["budget_debt"] = 2
		state.last_budget_change = "По условиям фонда обслуживание долга переведено в приоритет на четыре недели."
	if bool(option_flags.get("social_budget_concession", false)):
		state.budget_social = 1
		state.social_budget_lock_until_week = int(state.get("week", 1)) + 4
		state.social_protest_pending = false
	if bool(option_flags.get("regional_administration_disruption", false)):
		state.regional_administration_penalty_until_week = int(state.get("week", 1)) + 1
	if bool(option_flags.get("east_energy_promise", false)):
		state.east_energy_discount_until_week = int(state.get("week", 1)) + 8
		schedule_foreign_followup("east_energy_demand", 3)
	if bool(option_flags.get("extend_east_energy_discount", false)):
		state.east_energy_discount_until_week = int(state.get("week", 1)) + 6
	if bool(option_flags.get("east_discount_cancelled", false)):
		state.east_energy_discount_until_week = 0
	if bool(option_flags.get("western_package", false)):
		state.west_market_access_until_week = int(state.get("week", 1)) + 8
		schedule_foreign_followup("western_reform_review", 3)
	if bool(option_flags.get("extend_west_market_access", false)):
		state.west_market_access_until_week = int(state.get("week", 1)) + 8
	if bool(option_flags.get("western_package_frozen", false)) or bool(option_flags.get("eastern_standard_chosen", false)):
		state.west_market_access_until_week = 0
	if bool(option_flags.get("double_standards_started", false)):
		state.double_standards_until_week = int(state.get("week", 1)) + 6
	if bool(option_flags.get("passport_policy_pending", false)):
		schedule_foreign_followup("passport_protection_demand", 3)
	if bool(option_flags.get("eastern_media_sale", false)):
		schedule_foreign_followup("east_media_demand", 3)
	if bool(option_flags.get("tape_authentication", false)) or bool(option_flags.get("tape_published_raw", false)) or bool(option_flags.get("tape_seized", false)):
		schedule_story_followup("reception_tape", 2)
	if bool(option_flags.get("protocol_recount", false)) or bool(option_flags.get("protocol_certified", false)) or bool(option_flags.get("protocol_scans", false)):
		schedule_story_followup("election_protocols", 2)
	if bool(option_flags.get("tariff_freeze", false)) or bool(option_flags.get("targeted_tariff_support", false)) or bool(option_flags.get("industrial_cross_subsidy", false)):
		schedule_story_followup("heating_debt", 3)
	if bool(option_flags.get("court_compliance", false)) or bool(option_flags.get("court_replacement", false)) or bool(option_flags.get("court_delay", false)):
		schedule_story_followup("constitutional_court", 2)
	if bool(option_flags.get("faith_independence", false)) or bool(option_flags.get("faith_east_link", false)) or bool(option_flags.get("faith_neutrality", false)):
		schedule_story_followup("faith_schism", 3)
	if bool(option_flags.get("volunteers_integrated", false)) or bool(option_flags.get("volunteers_disarmed", false)) or bool(option_flags.get("volunteers_regional", false)):
		schedule_story_followup("volunteer_command", 2)
	var east_system_link := bool(state.get("east_energy_promise", false)) or bool(state.get("eastern_pipeline_share", false)) or bool(state.get("joint_eastern_customs", false))
	var west_system_link := bool(state.get("western_package", false)) or bool(state.get("western_grid_standard", false))
	if east_system_link and west_system_link and not bool(state.get("standards_conflict_scheduled", false)):
		state.standards_conflict_scheduled = true
		schedule_foreign_followup("standards_conflict", 5)
	if bool(option_flags.get("social_protest_suppressed", false)):
		state.social_protest_pending = false
	if bool(option_flags.get("emergency_powers_repealed", false)):
		var enacted_laws: Array = state.get("enacted_laws", [])
		enacted_laws.erase("Чрезвычайные полномочия")
		state.enacted_laws = enacted_laws
		state.emergency_powers_protest_pending = false


func projected_corruption_tier() -> int:
	var tier := int(state.get("corruption_tier", 0))
	for change in pending_week_changes:
		var effects: Dictionary = change.get("effects", {})
		if effects.has("corruption_tier"):
			tier = clampi(tier + int(effects.get("corruption_tier", 0)), 0, CORRUPTION_LABELS.size() - 1)
	return tier


func projected_pending_value(key: String) -> int:
	var value := int(state.get(key, 0))
	for change in pending_week_changes:
		var effects: Dictionary = change.get("effects", {})
		if not effects.has(key):
			continue
		value += int(effects.get(key, 0))
		if key in ["support", "stability", "army", "war_support", "clan_oligarchs", "clan_church", "clan_workers", "clan_regions"]:
			value = clampi(value, 0, 100)
		elif key in ["pop_children", "pop_employed", "pop_unemployed", "pop_pensioners", "pop_migrants", "army_personnel", "army_equipment", "army_aircraft"]:
			value = maxi(0, value)
		elif key == "corruption_tier":
			value = clampi(value, 0, CORRUPTION_LABELS.size() - 1)
		elif key == "creditor_obligations":
			value = clampi(value, 0, CREDITOR_OBLIGATION_LABELS.size() - 1)
		elif key in ["east_relation", "west_relation"]:
			value = clampi(value, 0, 3)
	return value


func projected_pending_float(key: String) -> float:
	if key == "money":
		return snappedf(float(state.get("money", 0.0)) + projected_pending_money_delta(), 0.01)
	var value := float(state.get(key, 0.0))
	for change in pending_week_changes:
		var effects: Dictionary = change.get("effects", {})
		if effects.has(key):
			value += float(effects.get(key, 0.0))
	if key == "debt":
		value = maxf(0.0, value)
	return snappedf(value, 0.01)


func has_pending_integer_change(key: String) -> bool:
	return projected_pending_value(key) != int(state.get(key, 0))


func has_pending_float_change(key: String) -> bool:
	return not is_equal_approx(projected_pending_float(key), float(state.get(key, 0.0)))


func pending_value_tooltip(title: String, current_value: String, projected_value: String) -> String:
	return "%s\nСейчас: %s\nПосле уже принятых решений в конце недели: %s\n\nГолубое значение ещё не применено." % [title, current_value, projected_value]


func projected_army_snapshot() -> Dictionary:
	var personnel := projected_pending_value("army_personnel")
	var equipment := projected_pending_value("army_equipment")
	var aircraft := projected_pending_value("army_aircraft")
	var war_support := projected_pending_value("war_support")
	var required_equipment := maxi(1, ceili(float(personnel) / 1000.0 * 8.0))
	var required_aircraft := maxi(1, ceili(float(personnel) / 2500.0))
	var oil_need := maxi(1,
		ceili(float(personnel) / 15000.0)
		+ ceili(float(equipment) / 150.0)
		+ ceili(float(aircraft) / 6.0)
	)
	var supply := clampi(roundi(float(state.get("oil_to_army", 0)) / float(oil_need) * 100.0), 0, 100)
	var morale := clampi(roundi(45.0 + float(war_support) * 0.35), 35, 80)
	var equipment_coverage := minf(100.0, float(equipment) / float(required_equipment) * 100.0)
	var aviation_coverage := minf(100.0, float(aircraft) / float(required_aircraft) * 100.0)
	var quality := clampi(roundi(
		float(army_training()) * 0.30
		+ equipment_coverage * 0.30
		+ aviation_coverage * 0.15
		+ float(supply) * 0.20
		+ float(morale) * 0.05
		+ float(army_loyalty_quality_modifier(projected_pending_value("army")))
	), 0, 100)
	var shortened_front := mini(3, maxi(0, int(state.get("war_frontline_reductions", 0)))) * WAR_SHORTENED_FRONT_REDUCTION
	var frontline_required := maxi(35000, roundi(110000.0 - float(quality) * 750.0) - shortened_front)
	var effectiveness := quality
	if bool(state.get("at_war", false)):
		effectiveness = clampi(roundi(float(quality) * clampf(float(personnel) / float(maxi(frontline_required, 1)), 0.0, 1.0)), 0, 100)
	return {
		"personnel": personnel,
		"equipment": equipment,
		"aircraft": aircraft,
		"oil_need": oil_need,
		"supply": supply,
		"morale": morale,
		"effectiveness": effectiveness,
		"quality": quality,
		"frontline_required": frontline_required,
		"required_equipment": required_equipment,
		"required_aircraft": required_aircraft
	}


func projected_total_population() -> int:
	var total := 0
	for key in ["pop_children", "pop_employed", "pop_unemployed", "pop_pensioners", "pop_migrants", "army_personnel"]:
		total += projected_pending_value(key)
	return total


func preview_deferred_effects(effects: Dictionary) -> Dictionary:
	var normalized := convert_legacy_foreign_effects(effects)
	var preview := normalized.duplicate(true)
	var transaction_tier := projected_corruption_tier()
	for key_variant in normalized.keys():
		var key := str(key_variant)
		if key == "money":
			preview[key] = adjusted_money_transaction(float(normalized[key_variant]), transaction_tier)
			continue
		var before := projected_pending_value(key)
		var after := before + int(normalized[key_variant])
		if key in ["support", "stability", "army", "war_support", "clan_oligarchs", "clan_church", "clan_workers", "clan_regions"]:
			after = clampi(after, 0, 100)
		elif key in ["pop_children", "pop_employed", "pop_unemployed", "pop_pensioners", "pop_migrants", "army_personnel", "army_equipment", "army_aircraft"]:
			after = maxi(0, after)
		elif key == "corruption_tier":
			after = clampi(after, 0, CORRUPTION_LABELS.size() - 1)
		elif key == "creditor_obligations":
			after = clampi(after, 0, CREDITOR_OBLIGATION_LABELS.size() - 1)
		elif key in ["east_relation", "west_relation"]:
			after = clampi(after, 0, 3)
		preview[key] = after - before
	return preview


func queue_week_change(source: String, effects: Dictionary, option_flags: Dictionary = {}) -> Dictionary:
	var normalized := block_war_enemy_relation_improvement(convert_legacy_foreign_effects(effects))
	var preview := preview_deferred_effects(normalized)
	if not normalized.is_empty() or not option_flags.is_empty():
		pending_week_changes.append({
			"source": source,
			"effects": normalized.duplicate(true),
			"flags": option_flags.duplicate(true)
		})
	return preview


func projected_pending_money_delta() -> float:
	var total := 0.0
	var tier := int(state.get("corruption_tier", 0))
	for change in pending_week_changes:
		var effects: Dictionary = change.get("effects", {})
		if effects.has("money"):
			total += adjusted_money_transaction(float(effects.get("money", 0.0)), tier)
		if effects.has("corruption_tier"):
			tier = clampi(tier + int(effects.get("corruption_tier", 0)), 0, CORRUPTION_LABELS.size() - 1)
	return snappedf(total, 0.01)


func resolve_pending_week_changes() -> Dictionary:
	var notes: Array[String] = []
	var decision_income := 0.0
	var decision_expenses := 0.0
	for change in pending_week_changes:
		var source := str(change.get("source", "Решение"))
		var effects: Dictionary = change.get("effects", {})
		var flags: Dictionary = change.get("flags", {})
		var previous_corruption_tier := int(state.get("corruption_tier", 0))
		var applied: Dictionary = apply_effects(effects) if not effects.is_empty() else {}
		if not flags.is_empty():
			apply_state_flags(flags)
		if applied.has("money"):
			var money_change := float(applied.get("money", 0.0))
			if money_change >= 0.0:
				decision_income += money_change
			else:
				decision_expenses += absf(money_change)
		if not effects.is_empty():
			notes.append("%s — %s." % [source, effects_to_text(effects, applied, previous_corruption_tier)])
			var group_transition := clan_transition_text(applied)
			if group_transition != "":
				notes.append(group_transition)
		elif not flags.is_empty():
			notes.append("%s — решение вступило в силу." % source)
	pending_week_changes.clear()
	return {"notes": notes, "income": snappedf(decision_income, 0.01), "expenses": snappedf(decision_expenses, 0.01)}


func amplified_signed_effect(value: int, multiplier: float, cap: int) -> int:
	if value == 0:
		return 0
	var direction := 1 if value > 0 else -1
	return direction * mini(cap, ceili(float(absi(value)) * multiplier))


func amplify_decision_effects(effects: Dictionary, decision_kind := "general") -> Dictionary:
	var amplified := effects.duplicate(true)
	if decision_kind == "urgent":
		return convert_legacy_foreign_effects(amplified)
	var stat_multiplier := 1.5
	var stat_cap := 12
	var clan_multiplier := 2.0
	var clan_cap := 18
	var foreign_multiplier := 1.25
	var foreign_cap := 10
	if decision_kind == "routine":
		stat_multiplier = 1.75
		stat_cap = 10
		clan_multiplier = 2.0
		clan_cap = 14
		foreign_multiplier = 1.25
		foreign_cap = 8
	elif decision_kind == "core":
		stat_multiplier = 1.35
		stat_cap = 16
		clan_multiplier = 1.35
		clan_cap = 18
		foreign_multiplier = 1.15
		foreign_cap = 10
	for key in effects.keys():
		var key_name := str(key)
		var value := int(effects[key])
		if key_name in ["support", "stability", "army", "war_support"]:
			amplified[key] = amplified_signed_effect(value, stat_multiplier, stat_cap)
		elif key_name in ["clan_oligarchs", "clan_church", "clan_workers", "clan_regions"]:
			amplified[key] = amplified_signed_effect(value, clan_multiplier, clan_cap)
		elif key_name in ["east_pressure", "west_pressure", "east_commitment", "west_commitment", "neutrality"]:
			amplified[key] = amplified_signed_effect(value, foreign_multiplier, foreign_cap)
	return convert_legacy_foreign_effects(amplified)


func apply_effects(effects: Dictionary) -> Dictionary:
	var normalized := block_war_enemy_relation_improvement(convert_legacy_foreign_effects(effects))
	var applied := normalized.duplicate()
	var transaction_tier := int(state.corruption_tier)
	var before_values: Dictionary = {}
	for key in normalized.keys():
		if key == "money":
			var adjusted_amount := adjusted_money_transaction(float(normalized[key]), transaction_tier)
			state.money = snappedf(float(state.get("money", 0.0)) + adjusted_amount, 0.01)
			applied[key] = adjusted_amount
		else:
			before_values[key] = state.get(key, 0)
			state[key] = int(state.get(key, 0)) + int(normalized[key])
	for key in ["support", "stability", "army", "war_support", "clan_oligarchs", "clan_church", "clan_workers", "clan_regions"]:
		state[key] = clampi(int(state[key]), 0, 100)
	for key in ["pop_children", "pop_employed", "pop_unemployed", "pop_pensioners", "pop_migrants", "army_personnel", "army_equipment", "army_aircraft"]:
		if state.has(key):
			state[key] = maxi(0, int(state[key]))
	for key in ["east_relation", "west_relation"]:
		if state.has(key):
			state[key] = clampi(int(state[key]), 0, 3)
	state.corruption_tier = clampi(int(state.corruption_tier), 0, CORRUPTION_LABELS.size() - 1)
	state.creditor_obligations = clampi(int(state.get("creditor_obligations", 0)), 0, CREDITOR_OBLIGATION_LABELS.size() - 1)
	# Возвращаем фактическое изменение после ограничений 0…100, иначе экран
	# результата мог обещать +8 при реальном росте, например, только с 98 до 100.
	for key in before_values.keys():
		applied[key] = int(state.get(key, 0)) - int(before_values[key])
	return applied


func clan_parliament_faction_title(key: String) -> String:
	match key:
		"clan_oligarchs":
			return "Президентский центр"
		"clan_church":
			return "Старая гвардия"
		"clan_workers":
			return "Гражданская коалиция"
		"clan_regions":
			return "Региональный список"
	return "связанная фракция"


func clan_weekly_effect_description(key: String, value: int) -> String:
	if value > CLAN_LOW_SUPPORT and value < CLAN_HIGH_SUPPORT:
		return "постоянного недельного эффекта нет"
	var critical_high := value >= CLAN_CRITICAL_HIGH_SUPPORT
	var high := value >= CLAN_HIGH_SUPPORT
	var critical_low := value <= CLAN_CRITICAL_LOW_SUPPORT
	match key:
		"clan_oligarchs":
			var gross := 3.0 if critical_high else 1.5 if high else -4.0 if critical_low else -2.0
			var actual := adjusted_money_transaction(gross, int(state.get("corruption_tier", 0)))
			return "казна %+.2f млн каждую неделю" % actual
		"clan_church":
			if critical_high:
				return "поддержка войны +%d каждую неделю; рождаемость +%d%%" % [church_war_support_effect(value), roundi(church_birth_rate_modifier(value) * 100.0)]
			if high:
				if bool(state.get("secular_education", false)):
					return "поддержка войны +1 раз в две недели; рождаемость +%d%%" % roundi(church_birth_rate_modifier(value) * 100.0)
				var war_effect := church_war_support_effect(value)
				return "поддержка войны +%d каждую неделю; рождаемость +%d%%" % [war_effect, roundi(church_birth_rate_modifier(value) * 100.0)]
			if critical_low:
				return "поддержка власти %d каждую неделю" % church_public_support_effect(value)
			return "поддержка власти %d каждую неделю" % church_public_support_effect(value)
		"clan_workers":
			return "поддержка власти %+d каждую неделю" % workers_public_support_effect(value)
		"clan_regions":
			return "стабильность %+d каждую неделю" % regional_stability_effect(value)
	return "постоянного недельного эффекта нет"


func clan_full_effect_description(key: String, value: int) -> String:
	var modifier := clan_position_modifier(value)
	var influence_note := "; светское образование уменьшает общественные эффекты Церкви вдвое" if key == "clan_church" and bool(state.get("secular_education", false)) else ""
	return "%s%s; фракция «%s» получает %+d к позиции на голосованиях" % [clan_weekly_effect_description(key, value), influence_note, clan_parliament_faction_title(key), modifier]


func clan_transition_text(applied_effects: Dictionary) -> String:
	var titles := {
		"clan_oligarchs": "Олигархи",
		"clan_church": "Церковь Веры",
		"clan_workers": "Рабочие и профсоюзы",
		"clan_regions": "Фермеры и регионы"
	}
	var lines: Array[String] = []
	for key in titles.keys():
		if not applied_effects.has(key):
			continue
		var current_value := int(state.get(key, 50))
		var old_value := current_value - int(applied_effects.get(key, 0))
		if clan_band(old_value) == clan_band(current_value):
			continue
		lines.append("%s: %s → %s. Теперь %s." % [titles[key], clan_band(old_value), clan_band(current_value), clan_full_effect_description(key, current_value)])
	return "\n".join(lines)


func show_result(result_text: String, original_effects: Dictionary, applied_effects: Dictionary, side: String, previous_corruption_tier: int) -> void:
	var tint := BLUE if side == "left" else RED if side == "right" else GOLD
	var card_tilt := -0.025 if side == "left" else 0.025 if side == "right" else 0.0
	var tween := create_tween().set_parallel(true)
	tween.tween_property(card_panel, "rotation", card_tilt, 0.14)
	tween.tween_property(card_panel, "modulate", Color(tint, 0.8), 0.14)
	await tween.finished
	card_panel.rotation = 0
	card_panel.modulate = Color.WHITE
	play_game_sound("decision")
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 18)
	content.add_child(label("РЕШЕНИЕ ПРИНЯТО", 17, tint, HORIZONTAL_ALIGNMENT_CENTER))
	var result := label(result_text, 24, INK, HORIZONTAL_ALIGNMENT_CENTER)
	result.size_flags_vertical = Control.SIZE_EXPAND_FILL
	result.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	content.add_child(result)
	var effects_copy := effects_to_text(original_effects, applied_effects, previous_corruption_tier, true)
	var effects_label := label("БУДЕТ ПРИМЕНЕНО ПРИ ПЕРЕХОДЕ НЕДЕЛИ\n" + effects_copy + ("  ⓘ" if original_effects.has("money") else ""), 18, Color("#5a5143"), HORIZONTAL_ALIGNMENT_CENTER)
	if original_effects.has("money"):
		effects_label.tooltip_text = transaction_tooltip("Денежное последствие решения", float(original_effects.get("money", 0.0)), previous_corruption_tier, "Если решение приносит деньги, категория коррупции урезает поступление. Расходы она не увеличивает.")
	content.add_child(effects_label)
	var ready_for_new_week := week_ready_for_new_week()
	var pending_extra_reports := pending_extra_report_count()
	var displayed_required := events_required_this_week + pending_extra_reports
	content.add_child(label("СОБЫТИЯ НЕДЕЛИ: %d / %d" % [events_resolved_this_week, displayed_required], 15, Color("#6f3e37"), HORIZONTAL_ALIGNMENT_CENTER))
	if ready_for_new_week and weekly_balance_forecast() <= 0.0:
		content.add_child(label("ВНИМАНИЕ: переход к новой неделе опустошит казну и немедленно завершит кампанию.", 16, RED, HORIZONTAL_ALIGNMENT_CENTER))
	elif pending_extra_reports > 0:
		content.add_child(label("Подготовлен срочный дополнительный доклад до завершения этой недели.", 16, RED, HORIZONTAL_ALIGNMENT_CENTER))
	var continue_button := menu_button("ПРОДОЛЖИТЬ")
	continue_button.pressed.connect(continue_after_result)
	content.add_child(continue_button)
	show_overlay(content, PAPER, false)
	update_week_action_button()


func effects_to_text(original_effects: Dictionary, applied_effects: Dictionary, previous_corruption_tier: int, deferred_preview := false) -> String:
	var names := {
		"money": "Казна", "support": "Поддержка власти", "stability": "Стабильность",
		"army": "Лояльность армии", "war_support": "Поддержка войны", "corruption_tier": "Коррупция",
		"authoritarian": "Авторитарный курс",
		"clan_oligarchs": "Олигархи", "clan_church": "Церковь Веры",
		"clan_workers": "Рабочие и профсоюзы", "clan_regions": "Фермеры и регионы",
		"debt": "Государственный долг", "creditor_obligations": "Обязательства перед кредиторами", "pop_children": "Дети",
		"pop_employed": "Работающие", "pop_unemployed": "Безработные",
		"pop_pensioners": "Пенсионеры", "pop_migrants": "Мигранты и беженцы",
		"army_personnel": "Военнослужащие", "army_equipment": "Наземная техника",
		"army_aircraft": "Авиация", "east_relation": "Восточный Союз",
		"west_relation": "Западная Федерация"
	}
	var parts: Array[String] = []
	for key in original_effects.keys():
		if names.has(key):
			if key == "money":
				var requested_amount := float(original_effects[key])
				var actual_amount := float(applied_effects.get(key, requested_amount))
				if actual_amount > 0.0:
					parts.append("Казна +%.2f млн" % actual_amount)
				elif actual_amount < 0.0:
					parts.append("Казна %.2f млн" % actual_amount)
				continue
			var value := int(applied_effects.get(key, original_effects[key]))
			if key == "corruption_tier":
				var current_tier := clampi(previous_corruption_tier + value, 0, CORRUPTION_LABELS.size() - 1) if deferred_preview else int(state.corruption_tier)
				if previous_corruption_tier != current_tier:
					parts.append("Коррупция: %s → %s (потери доходов: %d%% → %d%%)" % [
						corruption_level(previous_corruption_tier),
						corruption_level(current_tier),
						corruption_transaction_rate(previous_corruption_tier),
						corruption_transaction_rate(current_tier)
					])
				elif value != 0:
					parts.append("Коррупция остаётся на уровне «%s» — потери доходов %d%%" % [corruption_level(current_tier), corruption_transaction_rate(current_tier)])
				continue
			if key == "creditor_obligations":
				var current_level := clampi(int(state.get("creditor_obligations", 0)) + value, 0, CREDITOR_OBLIGATION_LABELS.size() - 1) if deferred_preview else int(state.get("creditor_obligations", 0))
				var previous_level := clampi(current_level - int(applied_effects.get(key, original_effects[key])), 0, CREDITOR_OBLIGATION_LABELS.size() - 1)
				parts.append("Международные кредиторы: %s → %s" % [creditor_obligation_level(previous_level), creditor_obligation_level(current_level)])
				continue
			if key in ["east_relation", "west_relation"]:
				var current_relation := projected_pending_value(key) if deferred_preview else int(state.get(key, 2))
				var previous_relation := clampi(current_relation - value, 0, 3)
				var relation_labels := ["враждебные", "натянутые", "средние", "партнёрские"]
				if previous_relation != current_relation:
					parts.append("%s: %s → %s" % [names[key], relation_labels[previous_relation], relation_labels[current_relation]])
				continue
			var population_keys := ["pop_children", "pop_employed", "pop_unemployed", "pop_pensioners", "pop_migrants", "army_personnel"]
			if key in population_keys:
				parts.append("%s %s%s" % [names[key], "+" if value > 0 else "−" if value < 0 else "", format_people(absi(value))])
			elif key == "debt":
				parts.append("%s %s%d млн" % [names[key], "+" if value > 0 else "", value])
			else:
				parts.append("%s %s%d" % [names[key], "+" if value > 0 else "", value])
	return " • ".join(parts) if not parts.is_empty() else "Числовых изменений нет."


func corruption_level(value: int) -> String:
	return CORRUPTION_LABELS[clampi(value, 0, CORRUPTION_LABELS.size() - 1)]


func creditor_obligation_level(value: int) -> String:
	return CREDITOR_OBLIGATION_LABELS[clampi(value, 0, CREDITOR_OBLIGATION_LABELS.size() - 1)]


func creditor_oversight_cost(value_override := -1) -> float:
	var value := int(state.get("creditor_obligations", 0)) if value_override < 0 else value_override
	return CREDITOR_OVERSIGHT_COSTS[clampi(value, 0, CREDITOR_OVERSIGHT_COSTS.size() - 1)]


func corruption_transaction_rate(value: int) -> int:
	return CORRUPTION_TRANSACTION_RATES[clampi(value, 0, CORRUPTION_TRANSACTION_RATES.size() - 1)]


func adjusted_money_transaction(amount: float, corruption_tier: int) -> float:
	if amount <= 0.0:
		return snappedf(amount, 0.01)
	var rate := float(corruption_transaction_rate(corruption_tier)) / 100.0
	return snappedf(amount * (1.0 - rate), 0.01)


func transaction_tooltip(title: String, gross_amount: float, corruption_tier: int, calculation := "") -> String:
	var rate := corruption_transaction_rate(corruption_tier)
	var final_amount := adjusted_money_transaction(gross_amount, corruption_tier)
	var lines: Array[String] = [title]
	if calculation != "":
		lines.append(calculation)
	if gross_amount > 0.0:
		lines.append("Доход до коррупции: %.2f млн" % gross_amount)
		lines.append("Коррупция «%s»: доход −%d%%" % [corruption_level(corruption_tier), rate])
	elif gross_amount < 0.0:
		lines.append("Базовый расход: %.2f млн" % absf(gross_amount))
		lines.append("Коррупция «%s»: расходы и цены не изменяет" % corruption_level(corruption_tier))
	else:
		lines.append("Сумма: 0.00 млн")
	lines.append("Итого: %.2f млн" % absf(final_amount))
	return "\n".join(lines)


func budget_breakdown_tooltip(item: Dictionary, corruption_tier: int) -> String:
	var key := str(item.get("key", ""))
	var raw_need := budget_base_amount(key)
	var level := budget_level(key)
	var level_multiplier := budget_level_multiplier(level)
	var planned := budget_amount_by_key(key)
	var final_amount := absf(adjusted_money_transaction(-planned, corruption_tier))
	return "%s\n%s\n%s\nБазовая потребность: %.2f млн\nУровень «%s»: ×%.2f = %.2f млн\nКоррупция «%s»: на расходы и цены не влияет\nИтого: %.2f млн в неделю" % [
		str(item.get("title", "Расход")), str(item.get("impact", "")), budget_level_consequence_text(key, level), raw_need,
		BUDGET_LEVEL_NAMES[level], level_multiplier, planned, corruption_level(corruption_tier),
		final_amount
	]


func budget_level_consequence_text(key: String, level: int) -> String:
	if key == "budget_social":
		return ["Последствие: каждую неделю −2 к поддержке и −2 к профсоюзам.", "Последствие: покрывает текущую потребность без постоянного бонуса или штрафа.", "Последствие: раз в 2 недели +1 к поддержке и +3 к профсоюзам."][level]
	if key == "budget_health":
		return ["Последствие: −2 к стабильности каждую неделю; раз в месяц мигранты −8 тыс.; людские потери на войне +25%.", "Последствие: покрывает текущую потребность без постоянного бонуса, миграционного сдвига или поправки к потерям.", "Последствие: раз в 2 недели +1 к стабильности; раз в месяц мигранты +8 тыс.; людские потери на войне −20%."][level]
	if key == "budget_admin":
		var base_points: int = [2, 3, 4][level]
		var stability_note := " Высокая стабильность даёт ещё +1 очко." if high_stability_influence_bonus() > 0 else " Низкая стабильность отнимает 1 очко." if low_stability_influence_penalty() > 0 else " При стабильности 70 и выше добавится ещё +1 очко, при 30 и ниже будет отнято 1."
		return "Последствие: %d очк. решений в начале недели.%s" % [base_points, stability_note]
	if key == "budget_defense":
		return ["Последствие: −1 к лояльности армии каждую неделю и ещё −1 по чётным неделям либо при угрозе.", "Последствие: покрывает текущую потребность без постоянного бонуса или штрафа.", "Последствие: раз в 2 недели +2 к лояльности армии."][level]
	if key == "budget_debt":
		return ["Последствие: долг растёт на 8 млн каждую неделю; действующие условия международных кредиторов становятся жёстче.", "Последствие: обязательный платёж без изменения основного долга.", "Последствие: долг сокращается на 6 млн каждую неделю; каждая четвёртая неделя ослабляет условия международных кредиторов."][level]
	if key == "budget_infrastructure":
		return ["Последствие: каждую неделю −2 к регионам; по чётным неделям ещё −1 к стабильности.", "Последствие: покрывает текущую потребность без постоянного бонуса или штрафа.", "Последствие: раз в 2 недели +3 к регионам и +1 к стабильности."][level]
	return ""


func total_population() -> int:
	return int(state.get("pop_children", 0)) + int(state.get("pop_employed", 0)) + int(state.get("pop_unemployed", 0)) + int(state.get("pop_pensioners", 0)) + int(state.get("pop_migrants", 0)) + int(state.get("army_personnel", 0))


func format_people(value: int) -> String:
	if value >= 1000000:
		return "%.2f млн" % (float(value) / 1000000.0)
	return "%d тыс." % roundi(float(value) / 1000.0)


func recruitment_target() -> int:
	var adult_citizens := int(state.get("pop_employed", 0)) + int(state.get("pop_unemployed", 0)) + int(state.get("army_personnel", 0))
	var model := str(state.get("recruitment_model", "mixed"))
	var share := 0.03
	if model == "contract":
		share = 0.015 + float(state.get("war_support", 0)) * 0.00015
	elif model == "universal":
		share = 0.05
	elif model == "mobilization":
		share = 0.09
	return maxi(1000, roundi(float(adult_citizens) * share))


func recruitment_speed_multiplier(war_support_override := -1) -> float:
	var value := int(state.get("war_support", 0)) if war_support_override < 0 else war_support_override
	if value >= WAR_SUPPORT_CRITICAL_HIGH:
		return 1.60
	if value >= WAR_SUPPORT_HIGH:
		return 1.35
	if value <= 15:
		return 0.20
	if value <= WAR_SUPPORT_LOW:
		return 0.40
	return 1.0


func wartime_desertion_rate(war_support_override := -1) -> float:
	var value := int(state.get("war_support", 0)) if war_support_override < 0 else war_support_override
	if value <= 0 or value > WAR_SUPPORT_LOW:
		return 0.0
	return 0.008 if value <= 15 else 0.004


func war_fatigue_loss(war_week_override := -1) -> int:
	var war_week := int(state.get("war_weeks", 0)) + 1 if war_week_override < 0 else maxi(1, war_week_override)
	if war_week <= 3:
		return 1
	if war_week <= 7:
		return 2
	if war_week <= 11:
		return 3
	return 4


func war_personnel_attrition_multiplier(war_week_override := -1) -> float:
	var war_week := int(state.get("war_weeks", 0)) + 1 if war_week_override < 0 else maxi(1, war_week_override)
	return 1.0 + float(mini(war_week - 1, 15)) * 0.04


func war_equipment_attrition_multiplier(war_week_override := -1) -> float:
	var war_week := int(state.get("war_weeks", 0)) + 1 if war_week_override < 0 else maxi(1, war_week_override)
	return 1.0 + float(mini(war_week - 1, 15)) * 0.05


func temporary_war_medical_multiplier() -> float:
	return 0.75 if int(state.get("week", 1)) <= int(state.get("war_medical_priority_until_week", 0)) else 1.0


func temporary_ammo_conservation_multiplier() -> float:
	return 0.65 if int(state.get("week", 1)) <= int(state.get("war_ammo_conservation_until_week", 0)) else 1.0


func health_war_loss_multiplier(level_override := -1) -> float:
	var level := budget_level("budget_health") if level_override < 0 else clampi(level_override, 0, 2)
	return [1.25, 1.0, 0.80][level]


func monthly_health_migration_balance(level_override := -1) -> int:
	var level := budget_level("budget_health") if level_override < 0 else clampi(level_override, 0, 2)
	return [-8000, 0, 8000][level]


func army_required_equipment() -> int:
	return maxi(1, ceili(float(state.get("army_personnel", 0)) / 1000.0 * 8.0))


func army_required_aircraft() -> int:
	return maxi(1, ceili(float(state.get("army_personnel", 0)) / 2500.0))


func army_oil_need() -> int:
	return maxi(1,
		ceili(float(state.get("army_personnel", 0)) / 15000.0)
		+ ceili(float(state.get("army_equipment", 0)) / 150.0)
		+ ceili(float(state.get("army_aircraft", 0)) / 6.0)
	)


func army_supply() -> int:
	return clampi(roundi(float(state.get("oil_to_army", 0)) / float(army_oil_need()) * 100.0), 0, 100)


func army_training() -> int:
	var model: Dictionary = RECRUITMENT_MODELS.get(str(state.get("recruitment_model", "mixed")), RECRUITMENT_MODELS["mixed"])
	return int(model.get("training", 60))


func army_morale() -> int:
	return clampi(roundi(45.0 + float(state.get("war_support", 0)) * 0.35), 35, 80)


func army_quality_effectiveness() -> int:
	var equipment_coverage := minf(100.0, float(state.get("army_equipment", 0)) / float(army_required_equipment()) * 100.0)
	var aviation_coverage := minf(100.0, float(state.get("army_aircraft", 0)) / float(army_required_aircraft()) * 100.0)
	return clampi(roundi(
		float(army_training()) * 0.30
		+ equipment_coverage * 0.30
		+ aviation_coverage * 0.15
		+ float(army_supply()) * 0.20
		+ float(army_morale()) * 0.05
		+ float(army_loyalty_quality_modifier())
	), 0, 100)


func frontline_required_personnel(quality := -1) -> int:
	var effective_quality := army_quality_effectiveness() if quality < 0 else clampi(quality, 0, 100)
	# Хорошо обученная и полностью оснащённая армия способна держать тот же фронт
	# меньшим числом людей. Даже при идеальном качестве требуется минимум 35 тысяч.
	var shortened_front := mini(3, maxi(0, int(state.get("war_frontline_reductions", 0)))) * WAR_SHORTENED_FRONT_REDUCTION
	return maxi(35000, roundi(110000.0 - float(effective_quality) * 750.0) - shortened_front)


func army_effectiveness() -> int:
	var quality := army_quality_effectiveness()
	if not bool(state.get("at_war", false)):
		return quality
	var required := frontline_required_personnel(quality)
	var personnel_coverage := clampf(float(state.get("army_personnel", 0)) / float(maxi(required, 1)), 0.0, 1.0)
	return clampi(roundi(float(quality) * personnel_coverage), 0, 100)


func army_base_cost() -> float:
	var model: Dictionary = RECRUITMENT_MODELS.get(str(state.get("recruitment_model", "mixed")), RECRUITMENT_MODELS["mixed"])
	var personnel_cost := float(state.get("army_personnel", 0)) / 1000.0 * float(model.get("rate", 0.014))
	return snappedf(0.4 + personnel_cost + float(state.get("army_equipment", 0)) * 0.0005 + float(state.get("army_aircraft", 0)) * 0.01 + production_order_cost(), 0.01)


func army_budget_breakdown_tooltip(corruption_tier: int) -> String:
	var model: Dictionary = RECRUITMENT_MODELS.get(str(state.get("recruitment_model", "mixed")), RECRUITMENT_MODELS["mixed"])
	var personnel_cost := float(state.get("army_personnel", 0)) / 1000.0 * float(model.get("rate", 0.014))
	var equipment_cost := float(state.get("army_equipment", 0)) * 0.0005
	var aviation_cost := float(state.get("army_aircraft", 0)) * 0.01
	var orders_cost := production_order_cost()
	var raw_total := army_base_cost()
	var level := budget_level("budget_defense")
	var planned := budget_amount_by_key("budget_defense")
	var final_amount := absf(adjusted_money_transaction(-planned, corruption_tier))
	return "Почему оборона стоит именно столько:\nПостоянные службы: 0.40 млн\nЛичный состав (%s): %.2f млн\nСодержание наземной техники: %.2f млн\nСодержание импортной авиации: %.2f млн\nЗаказ наземной техники: %.2f млн\nПотребность до уровня бюджета: %.2f млн\nУровень «%s»: ×%.2f = %.2f млн\nКоррупция «%s»: на расходы и цены не влияет\nИтого: %.2f млн" % [
		str(model.get("title", "Смешанная")), personnel_cost, equipment_cost, aviation_cost,
		orders_cost, raw_total, BUDGET_LEVEL_NAMES[level], budget_level_multiplier(level), planned,
		corruption_level(corruption_tier), final_amount
	]


func production_order_cost() -> float:
	return snappedf(float(state.get("metal_to_equipment", 0)) * 0.15, 0.01)


func equipment_order_final_cost(corruption_tier: int) -> float:
	var planned := production_order_cost() * budget_level_multiplier(budget_level("budget_defense"))
	return absf(adjusted_money_transaction(-planned, corruption_tier))


func equipment_lost_export_income(corruption_tier: int) -> float:
	var forgone_gross := float(state.get("metal_to_equipment", 0)) * current_metal_price()
	return adjusted_money_transaction(forgone_gross, corruption_tier)


func equipment_balance_load(corruption_tier: int) -> float:
	return snappedf(equipment_order_final_cost(corruption_tier) + equipment_lost_export_income(corruption_tier), 0.01)


func equipment_production_tooltip(corruption_tier: int) -> String:
	return "Почему выпуск и нагрузка на баланс именно такие:\nВыделено металла: %d из %d%s\nБазовый выпуск: 2 ед. техники на 1 ед. металла\nФинансирование обороны «%s»: выпуск ×%.2f\nВыпуск: %d ед.\nПрямой расход по заказу после уровня бюджета: %.2f млн (коррупция его не увеличивает)\nУпущенный доход от экспорта металла после потерь от коррупции: %.2f млн\nОбщая нагрузка на недельный баланс: %.2f млн" % [
		int(state.get("metal_to_equipment", 0)), current_metal_output(),
		" (приватизация забирает 2 ед. добычи)" if bool(state.get("raw_sector_privatized", false)) else "",
		BUDGET_LEVEL_NAMES[budget_level("budget_defense")], production_factor(), equipment_production_per_week(),
		equipment_order_final_cost(corruption_tier), equipment_lost_export_income(corruption_tier), equipment_balance_load(corruption_tier)
	]


func budget_level(key: String) -> int:
	return clampi(int(state.get(key, 1)), 0, 2)


func choose_creditor_austerity_target() -> String:
	var candidates: Array[String] = []
	for key_variant in CREDITOR_AUSTERITY_TARGETS:
		var key := str(key_variant)
		if budget_level(key) > 0:
			candidates.append(key)
	if candidates.is_empty():
		for key_variant in CREDITOR_AUSTERITY_TARGETS:
			candidates.append(str(key_variant))
	var selector := absi(int(state.get("campaign_seed", 0)) + int(state.get("week", 1)) * 37)
	return candidates[selector % candidates.size()]


func creditor_budget_lock_active(key := "") -> bool:
	var lock_key := str(state.get("creditor_budget_lock_key", ""))
	if lock_key == "" or int(state.get("week", 1)) > int(state.get("creditor_budget_lock_until_week", 0)):
		return false
	return key == "" or key == lock_key


func creditor_budget_lock_weeks_left() -> int:
	if not creditor_budget_lock_active():
		return 0
	return int(state.get("creditor_budget_lock_until_week", 0)) - int(state.get("week", 1)) + 1


func creditor_budget_required_level(key: String) -> int:
	if not creditor_budget_lock_active(key):
		return -1
	return clampi(int(state.get("creditor_budget_lock_level", -1)), 0, 2)


func creditor_budget_change_allowed(key: String, level: int) -> bool:
	var required := creditor_budget_required_level(key)
	return required < 0 or level == required


func creditor_budget_lock_message(key: String) -> String:
	var required := creditor_budget_required_level(key)
	if required < 0:
		return ""
	return "Условие Международного фонда: статья должна оставаться на уровне «%s» ещё %d нед." % [BUDGET_LEVEL_NAMES[required], creditor_budget_lock_weeks_left()]


func enforce_creditor_budget_lock() -> void:
	if not creditor_budget_lock_active():
		return
	var lock_key := str(state.get("creditor_budget_lock_key", ""))
	var required := creditor_budget_required_level(lock_key)
	if lock_key == "" or required < 0:
		return
	state[lock_key] = required
	budget_draft[lock_key] = required


func social_budget_reduction_locked() -> bool:
	return int(state.get("week", 1)) <= int(state.get("social_budget_lock_until_week", 0))


func social_budget_lock_weeks_left() -> int:
	if not social_budget_reduction_locked():
		return 0
	return int(state.get("social_budget_lock_until_week", 0)) - int(state.get("week", 1)) + 1


func budget_level_multiplier(level: int) -> float:
	return [0.70, 1.0, 1.40][clampi(level, 0, 2)]


func budget_base_amount(key: String) -> float:
	if key == "budget_social":
		return (
			float(state.get("pop_pensioners", 0)) / 1000000.0 * 1.20
			+ float(state.get("pop_unemployed", 0)) / 1000000.0 * 0.90
			+ float(state.get("pop_children", 0)) / 1000000.0 * 0.30
			+ float(state.get("pop_migrants", 0)) / 1000000.0 * 0.50
		)
	if key == "budget_health":
		return float(total_population()) / 1000000.0 * 0.35
	if key == "budget_admin":
		return 0.85
	if key == "budget_defense":
		return army_base_cost()
	if key == "budget_debt":
		return maxf(0.5, snappedf(float(state.get("debt", 0.0)) * 0.006, 0.01))
	if key == "budget_infrastructure":
		return 0.55
	return 0.0


func budget_amount_by_key(key: String) -> float:
	return snappedf(budget_base_amount(key) * budget_level_multiplier(budget_level(key)), 0.01)


func budget_final_for_level(key: String, level: int, corruption_tier: int) -> float:
	var planned := snappedf(budget_base_amount(key) * budget_level_multiplier(level), 0.01)
	return absf(adjusted_money_transaction(-planned, corruption_tier))


func budget_line_amount(title: String) -> float:
	for item in WEEKLY_BUDGET_LINES:
		if str(item["title"]) == title:
			return budget_amount_by_key(str(item["key"]))
	return 0.0


func weekly_budget_total() -> float:
	var total := 0.0
	for item in WEEKLY_BUDGET_LINES:
		total += budget_amount_by_key(str(item["key"]))
	return snappedf(total, 0.01)


func neighbor_title(side: String) -> String:
	return "Восточный Союз" if side == "east" else "Западная Федерация"


func neighbor_relation_band(side: String, projected := false) -> String:
	var relation := projected_pending_value(side + "_relation") if projected else int(state.get(side + "_relation", 2))
	return ["враждебные", "натянутые", "средние", "партнёрские"][clampi(relation, 0, 3)]


func neighbor_relation_color(side: String, projected := false) -> Color:
	match neighbor_relation_band(side, projected):
		"враждебные":
			return RED
		"натянутые":
			return Color("#d19a63")
		"партнёрские":
			return GREEN
	return CREAM


func neighbor_relation_explanation(side: String, projected := false) -> String:
	var band := neighbor_relation_band(side, projected)
	var response := "Обычные дипломатические контакты продолжаются. Улучшение этих отношений на одну категорию ухудшит отношения с другим соседом на одну категорию."
	if band == "партнёрские":
		response = "Сосед готов обсуждать военную помощь и долгосрочные соглашения. Выше этой категории отношения подняться не могут."
	elif band == "натянутые":
		response = "Сосед усиливает требования, проверки и экономические меры. Следующее ухудшение приведёт к вторжению при переходе недели."
	elif band == "враждебные":
		response = "Дипломатические механизмы исчерпаны. Если война ещё не началась, вторжение произойдёт при переходе недели."
	return "%s: отношения %s. %s" % [neighbor_title(side), band, response]


func agreement_weeks_left(until_key: String) -> int:
	return maxi(0, int(state.get(until_key, 0)) - int(state.get("week", 1)) + 1)


func foreign_concession_data(side: String) -> Dictionary:
	if side == "east":
		return {
			"title": "Приграничная нефтяная концессия",
			"button": "ОТДАТЬ НЕФТЯНОЕ МЕСТОРОЖДЕНИЕ",
			"effect": "Добыча нефти навсегда −4 ед. в неделю",
			"detail": "Государственная компания Восточного Союза получает исключительное право добывать нефть в приграничном Рудненском районе до конца кампании. Республика получает аванс, но четыре единицы недельной добычи больше нельзя направлять армии или продавать.",
			"result": "Правительство передало Восточному Союзу право добычи нефти в Рудненском районе. Казна получит аванс, а доступная недельная добыча навсегда уменьшится на 4 единицы."
		}
	return {
		"title": "Протокол инвестиционного арбитража",
		"button": "АРБИТРАЖНЫЙ ПРОТОКОЛ",
		"effect": "Постоянное юридическое сопровождение −0.60 млн в неделю",
		"detail": "Споры компаний Западной Федерации с правительством передаются в международный арбитраж по западным правилам до конца кампании. Казна получает грант, но каждую неделю оплачивает обязательный аудит, юридическое сопровождение и резерв возможных исков.",
		"result": "Правительство подписало западный арбитражный протокол. Казна получит грант, а обязательное сопровождение будет стоить 0.60 млн каждую неделю до конца кампании."
	}


func active_foreign_dependencies() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if agreement_weeks_left("east_energy_discount_until_week") > 0:
		result.append({"title": "Восточная энергетическая скидка", "effect": "+1.40 млн валовой выгоды в неделю", "detail": "Льготная цена действует ещё %d нед. Восточный Союз использует поставки как рычаг для новых политических требований." % agreement_weeks_left("east_energy_discount_until_week"), "color": GOLD})
	if agreement_weeks_left("west_market_access_until_week") > 0:
		result.append({"title": "Ускоренный доступ к западному рынку", "effect": "+1.20 млн валового дохода в неделю", "detail": "Доступ действует ещё %d нед. Продление зависит от выполнения институциональных и торговых условий Западной Федерации." % agreement_weeks_left("west_market_access_until_week"), "color": BLUE})
	if bool(state.get("east_border_oil_concession", false)):
		var east_concession := foreign_concession_data("east")
		result.append({"title": str(east_concession["title"]), "effect": str(east_concession["effect"]), "detail": str(east_concession["detail"]), "color": GOLD})
	if bool(state.get("west_investment_arbitration", false)):
		var west_concession := foreign_concession_data("west")
		result.append({"title": str(west_concession["title"]), "effect": str(west_concession["effect"]), "detail": str(west_concession["detail"]), "color": BLUE})
	if agreement_weeks_left("double_standards_until_week") > 0:
		result.append({"title": "Двойная сертификация", "effect": "−1.60 млн в неделю", "detail": "Ещё %d нед. республика оплачивает совместимость с двумя несовместимыми торговыми системами." % agreement_weeks_left("double_standards_until_week"), "color": RED})
	if bool(state.get("joint_eastern_customs", false)):
		result.append({"title": "Восточные инспекторы на таможне", "effect": "+0.60 млн валового дохода в неделю", "detail": "Совместный режим ускоряет согласованные грузы, но Восточный Союз имеет доступ к базе перевозчиков и может выборочно останавливать торговлю.", "color": GOLD})
	if bool(state.get("eastern_pipeline_share", false)):
		result.append({"title": "Восточная доля в трубопроводе", "effect": "Поставки стабильнее, разрыв договора опаснее", "detail": "Иностранный консорциум участвует в управлении магистралью. Ремонт и изменение маршрута требуют согласования.", "color": GOLD})
	if bool(state.get("eastern_turbine_service", false)):
		result.append({"title": "Восточное обслуживание гидроэлектростанции", "effect": "Сеть зависит от иностранных специалистов и деталей", "detail": "Восточная бригада имеет постоянный технический доступ к крупнейшей станции и хранит часть документации у себя.", "color": GOLD})
	if bool(state.get("western_grid_standard", false)):
		result.append({"title": "Западный стандарт энергосети", "effect": "Старая восточная система постепенно несовместима", "detail": "Переделка снижает зависимость от восточных деталей, но связывает следующие ремонты с западными поставщиками.", "color": BLUE})
	if str(state.get("foreign_base", "")) != "":
		result.append({"title": "Западный учебный центр", "effect": "Армия связана с западной подготовкой", "detail": "Инструкторы улучшают совместимость и военную помощь, но Восток рассматривает центр как угрозу, а быстрый разрыв ударит по армии.", "color": BLUE})
	if bool(state.get("passport_council_recognized", false)):
		result.append({"title": "Совет владельцев восточных паспортов", "effect": "Параллельное представительство приграничья", "detail": "Совет участвует в обсуждении полиции, школ и земли и обращается напрямую к восточному посольству.", "color": GOLD})
	elif bool(state.get("passport_monitoring_mission", false)):
		result.append({"title": "Миссия по иностранным паспортам", "effect": "Спор заморожен под внешним наблюдением", "detail": "Наблюдатели фиксируют выдачу документов и давление на жителей, но окончательный статус не решён.", "color": GREEN})
	if bool(state.get("east_editorial_access", false)):
		result.append({"title": "Восточный доступ к телеэфиру", "effect": "Пограничные кризисы получают вторую официальную версию", "detail": "Советники связанного с Востоком владельца имеют постоянный доступ к политическим передачам крупнейшего канала.", "color": GOLD})
	if bool(state.get("west_labor_mobility", false)):
		result.append({"title": "Западный режим трудовой мобильности", "effect": "+0.80 млн переводов в неделю", "detail": "Безработица ниже и семьи получают переводы, но часть трудоспособного и мобилизационного резерва покинула страну.", "color": BLUE})
	if bool(state.get("east_media_silence_pact", false)):
		result.append({"title": "Негласное соглашение о вещании", "effect": "Восток прекращает помехи в обмен на молчание", "detail": "Правительство обязалось не выносить будущие инциденты с вещанием на международные площадки.", "color": GOLD})
	if bool(state.get("eastern_aircraft_supply", false)):
		result.append({"title": "Восточное обслуживание авиации", "effect": "Четыре самолёта зависят от восточных запчастей", "detail": "Республика не производит авиацию. Поставщик может остановить обслуживание при внешнеполитическом конфликте.", "color": GOLD})
	elif bool(state.get("western_aircraft_contract", false)):
		result.append({"title": "Западное обслуживание авиации", "effect": "Шесть самолётов зависят от западных запчастей", "detail": "Республика не производит авиацию. Контракт связывает боеготовность с отношениями с Западной Федерацией.", "color": BLUE})
	var followups: Array = state.get("foreign_followups", [])
	if not followups.is_empty():
		var nearest_week := DEMO_WEEKS
		var valid_count := 0
		for pending in followups:
			if pending is Dictionary:
				valid_count += 1
				nearest_week = mini(nearest_week, int(pending.get("due_week", DEMO_WEEKS)))
		if valid_count > 0:
			result.append({"title": "Ожидаются внешние требования", "effect": "%d треб. • ближайшее на %d-й неделе" % [valid_count, nearest_week], "detail": "Ранее принятые конкретные соглашения дают соседям повод предъявить новые условия. Точная форма каждого требования проявится отдельным докладом.", "color": RED})
	return result


func hostile_neighbor_for_invasion() -> String:
	var hostile: Array[String] = []
	for side in ["east", "west"]:
		if neighbor_relation_band(side) == "враждебные":
			hostile.append(side)
	if hostile.is_empty():
		return ""
	if hostile.size() == 1:
		return hostile[0]
	return "east"


func build_war_crisis_event() -> Dictionary:
	var enemy := str(state.get("war_enemy", "east"))
	var other := "west" if enemy == "east" else "east"
	var enemy_name := neighbor_title(enemy)
	var other_name := neighbor_title(other)
	var report := str(state.get("last_war_report", "Первые сообщения с границы ещё уточняются."))
	var required := frontline_required_personnel()
	var personnel := int(state.get("army_personnel", 0))
	var body := "На рассвете войска государства «%s» пересекли границу и атаковали пограничные части. Дипломатические отношения больше не действуют: республика находится в состоянии войны. Генеральный штаб требует немедленно выбрать, чем закрыть первый разрыв фронта.\n\n%s\n\nДля удержания линии при текущем качестве армии требуется не менее %s военнослужащих; в строю осталось %s." % [enemy_name, report, format_people(required), format_people(personnel)]
	var mobilization := option(
		"Начать экстренную мобилизацию",
		"25 тыс. человек перейдут из гражданской экономики в армию • поддержка, стабильность и поддержка войны снизятся • лояльность штаба вырастет",
		{"pop_employed": -20000, "pop_unemployed": -5000, "army_personnel": 25000, "support": -6, "stability": -3, "war_support": -4, "army": 4},
		"Правительство объявило экстренную мобилизацию. Военкоматы получили списки работающих и безработных, предприятия лишились части смен, а первые пополнения направились к линии фронта без полного цикла подготовки.",
		{"recruitment_model": "mobilization", "war_emergency_mobilization": true}
	)
	var procurement := option(
		"Закупить вооружение через посредников",
		"Крупные расходы • +35 наземной техники и +2 самолёта • командование и оборонные подрядчики укрепятся • численность армии не изменится",
		{"money": -16, "army_equipment": 35, "army_aircraft": 2, "army": 3, "clan_oligarchs": 4},
		"Казначейство оплатило чрезвычайные контракты через нейтральных посредников. Колонны техники уже идут к фронту, а два подержанных самолёта прибыли вместе с иностранными экипажами инструкторов.",
		{"war_emergency_procurement": true}
	)
	var aid_effects := {"army_equipment": 22, "army_aircraft": 3, "support": -4, "war_support": 3}
	merge_numeric_effects(aid_effects, relation_shift_effect(other, 1))
	var aid := option(
		"Просить помощи у государства «%s»" % other_name,
		"Военная техника и авиация поступят без оплаты • отношения улучшатся • зависимость от второго соседа и политическая цена войны усилятся",
		aid_effects,
		"Правительство официально запросило военную помощь. Государство «%s» открыло склады и передало первую партию техники, потребовав публично признать его главным гарантом независимости республики." % other_name,
		{other + "_wartime_aid_received": true, "war_emergency_foreign_aid": other}
	)
	if neighbor_relation_band(other) in ["враждебные", "натянутые"]:
		aid["unavailable"] = true
		aid["hint"] = "НЕДОСТУПНО: отношения с государством «%s» слишком плохи для срочной военной помощи." % other_name
	return event("СОВЕТ ОБОРОНЫ", "military", "#a9473f", "Вторжение", body, mobilization, procurement, aid)


func build_war_pressure_event() -> Dictionary:
	var war_week := int(state.get("war_weeks", 0))
	var enemy := str(state.get("war_enemy", "east"))
	var other := "west" if enemy == "east" else "east"
	var enemy_name := neighbor_title(enemy)
	var other_name := neighbor_title(other)
	var situation := "Идёт %d-я неделя войны с государством «%s». Боеспособность — %d%%, личный состав — %s, поддержка войны — %d%%.\n\n%s" % [war_week, enemy_name, army_effectiveness(), format_people(int(state.get("army_personnel", 0))), int(state.get("war_support", 0)), str(state.get("last_war_report", "Штаб уточняет потери."))]
	if war_week <= 3:
		return event("СОВЕТ ОБОРОНЫ", "military", "#a9473f", "Тонкая линия", situation + "\n\nПротивник давит сразу на три приграничных города. Генштаб может удерживать каждый населённый пункт только ценой техники, сократить линию фронта либо раздать оружие территориальным батальонам.",
			option("Удерживать все города", "Крупные расходы и потери техники • поддержка войны и приграничья укрепятся", {"money": -8, "army_equipment": -10, "war_support": 4, "clan_regions": 6, "army": 2}, "Резервы разошлись по трём дорогам. Города остались под флагом республики, но ремонтные роты уже разбирают последние исправные машины на запчасти."),
			option("Сократить линию фронта", "Часть территории будет оставлена • фронту навсегда потребуется меньше людей • общество и регионы ответят резко", {"support": -7, "stability": -5, "war_support": -4, "clan_regions": -10, "army": 4}, "Армия отошла за реку и взорвала мосты. Новую линию удерживать проще, но жители оставленных районов увидели государственные флаги только на уходящих машинах.", {"war_frontline_retreat": true}),
			option("Вооружить территориальные батальоны", "Армия получит 8 тыс. человек • единое командование ослабнет • начнутся протесты против призыва", {"pop_employed": -4000, "pop_unemployed": -4000, "army_personnel": 8000, "army": -5, "war_support": -3, "clan_regions": 8}, "Губернаторы получили оружие и списки добровольцев. На фронте стало больше людей, однако часть батальонов принимает приказы только от местных администраций.", {"unrest": {"cause": "вооружение территориальных батальонов", "kind": "antiwar", "base_level": 1, "reversible": false}}))
	if war_week <= 7:
		return event("ГЕНЕРАЛЬНЫЙ ШТАБ", "military", "#a9473f", "Ротация, которой нет", situation + "\n\nПередовые бригады находятся в окопах без смены. Командиры требуют оплачиваемую ротацию, правительство может оставить части на позициях либо вызвать новую волну резервистов.",
			option("Провести полную ротацию", "Большие расходы и дополнительный износ техники • лояльность армии и поддержка укрепятся", {"money": -9, "army_equipment": -4, "army": 6, "support": 2, "war_support": 2}, "Бригады вывели с позиций, выплатили задержанные надбавки и заменили свежими частями. Железные дороги встали под воинскими эшелонами, но солдаты впервые за месяцы увидели семьи."),
			option("Отменить ротацию", "Казна и резерв сохранятся • армия и общественная готовность продолжать войну резко упадут", {"army": -8, "war_support": -5, "support": -3}, "Приказ о смене отменили за ночь. Части остались на позициях, а командиры начали скрывать число самовольных уходов, чтобы не получить обвинение в потере управления."),
			option("Призвать десять тысяч резервистов", "Фронт получит людей • экономика, профсоюзы и поддержка войны пострадают • начнётся антивоенный протест", {"pop_employed": -5000, "pop_unemployed": -5000, "army_personnel": 10000, "support": -5, "war_support": -6, "clan_workers": -7, "stability": -2}, "Повестки отправили на заводы и биржи труда. Новые батальоны закрыли ротацию, но рабочие комитеты объявили, что правительство заменяет военную стратегию бесконечным набором людей.", {"unrest": {"cause": "новая волна призыва резервистов", "kind": "antiwar", "base_level": 2, "reversible": false}}))
	if war_week <= 11:
		var foreign_supply_effects := {"money": -11, "army_equipment": 16, "army_aircraft": 2, "support": -3}
		merge_numeric_effects(foreign_supply_effects, relation_shift_effect(other, 1))
		return event("ВОЕННО-ПРОМЫШЛЕННАЯ КОМИССИЯ", "official", "#8b6c4b", "Снарядный голод", situation + "\n\nСклады расходуют боеприпасы быстрее заводского выпуска. Можно перевести гражданские предприятия на военные заказы, купить срочную партию у государства «%s» либо приказать армии экономить огонь." % other_name,
			option("Перевести заводы на военные рельсы", "Армия получит 22 единицы техники • потребуются деньги • рабочие ответят тяжёлой забастовкой", {"money": -7, "army_equipment": 22, "support": -4, "stability": -3, "clan_workers": -12}, "Гражданские заказы сняли с линий, смены продлили без согласования. Первые машины ушли на фронт, а проходные крупнейших предприятий утром оказались закрыты рабочими.", {"unrest": {"cause": "принудительный перевод заводов на военные рельсы", "kind": "labor", "labor": true, "base_level": 2, "reversible": false}}),
			option("Купить иностранную партию", "Очень крупные расходы • техника и два самолёта • отношения с оставшимся соседом улучшатся ценой зависимости", foreign_supply_effects, "Груз прибыл без опознавательных знаков. Республика получила машины и самолёты, а военная миссия государства «%s» — постоянный кабинет рядом с оперативным штабом." % other_name, {"foreign_wartime_supply": other}),
			option("Ввести лимит боеприпасов", "На три недели потери техники уменьшатся на 35% • лояльность армии и поддержка войны упадут", {"army": -6, "war_support": -5}, "Артиллерии разрешили отвечать только после подтверждения цели двумя наблюдателями. Склады перестали пустеть, но пехота считает, что правительство экономит металл ценой её жизней.", {"war_ammo_conservation": true}))
	if war_week <= 15:
		return event("ВОЕННО-МЕДИЦИНСКАЯ СЛУЖБА", "official", "#536f82", "Коридор для раненых", situation + "\n\nГоспитали переполнены, санитарные эшелоны стоят вместе с военными. Можно оплатить приоритетную эвакуацию, вернуть легкораненых в строй либо засекретить списки потерь и освободить гражданские больницы приказом.",
			option("Оплатить медицинский коридор", "Очень крупные расходы • на три недели людские потери уменьшатся на 25% • поддержка войны немного восстановится", {"money": -11, "support": 3, "war_support": 4}, "Отдельные санитарные поезда получили зелёный коридор, а гражданские клиники — военные авансы. Раненых стали вывозить быстрее, но казначейство предупредило, что такой режим невозможно оплачивать постоянно.", {"war_medical_priority": true}),
			option("Вернуть легкораненых в строй", "Армия немедленно получит 5 тыс. человек • лояльность, поддержка и порядок пострадают", {"army_personnel": 5000, "army": -7, "support": -4, "stability": -2, "war_support": -4}, "Медицинские комиссии переписали категории годности. Пять тысяч человек вернулись в части, многие — с незажившими ранами и публичными письмами к семьям."),
			option("Засекретить списки потерь", "Поддержка власти резко упадёт • военные настроения временно укрепятся • авторитарный курс и протест усилятся", {"support": -8, "stability": 3, "war_support": 3, "authoritarian": 1}, "Больницы перестали сообщать фамилии, а похороны провели без прессы. На несколько дней сводки стали спокойнее, затем родственники собрали собственный список и вышли к министерству.", {"unrest": {"cause": "засекречивание списков военных потерь", "kind": "antiwar", "base_level": 2, "reversible": false}}))
	return event("СТАВКА ВЕРХОВНОГО КОМАНДОВАНИЯ", "military", "#a9473f", "Последний резерв", situation + "\n\nОбычные резервы исчерпаны. Ставка предлагает общую мобилизацию, новый отход с оставлением ещё одного района либо снятие частей с охраны тыла и критической инфраструктуры.",
		option("Объявить общую мобилизацию", "Армия получит 20 тыс. человек • экономика и все общественные показатели рухнут • начнутся крупные протесты", {"pop_employed": -15000, "pop_unemployed": -5000, "army_personnel": 20000, "support": -9, "stability": -5, "war_support": -8, "army": 5, "clan_workers": -8}, "Военкоматы получили право останавливать транспорт и проверять документы. Фронт пополнился, но заводы потеряли смены, а города заполнили семьи мобилизованных.", {"unrest": {"cause": "общая мобилизация после истощения резервов", "kind": "antiwar", "base_level": 3, "reversible": false}}),
		option("Оставить ещё один район", "Фронту навсегда потребуется на 8 тыс. меньше людей • поддержка, стабильность и регионы понесут катастрофический удар", {"support": -10, "stability": -7, "war_support": -6, "clan_regions": -14, "army": 5}, "Армия отошла на следующую естественную преграду. Карта фронта стала короче, а карта контролируемой республики — ещё меньше; колонны беженцев движутся к столице.", {"war_frontline_retreat": true}),
		option("Снять гарнизоны с тыла", "Фронт получит 7 тыс. человек • лояльность штаба, порядок и регионы резко ослабнут", {"pop_employed": -7000, "army_personnel": 7000, "army": -10, "stability": -6, "clan_regions": -10, "war_support": -3}, "Охрану мостов, складов и электростанций отправили на передовую. Генштаб получил людей, а губернаторы начали создавать собственные караулы без разрешения центра."))


func start_invasion_if_needed() -> String:
	if bool(state.get("at_war", false)):
		return ""
	if neighbor_relation_band("east") == "натянутые" or neighbor_relation_band("west") == "натянутые":
		state.military_threat = true
	var enemy := hostile_neighbor_for_invasion()
	if enemy == "":
		return ""
	state.at_war = true
	state.military_threat = true
	state.war_enemy = enemy
	state.war_started_week = int(state.get("week", 1))
	state.war_weeks = 0
	state.war_crisis_pending = true
	state.war_crisis_shown = false
	state.war_pressure_next_week = WAR_PRESSURE_INTERVAL
	state.war_frontline_reductions = 0
	state.war_medical_priority_until_week = 0
	state.war_ammo_conservation_until_week = 0
	var dependency_note := ""
	if enemy == "east" and bool(state.get("eastern_aircraft_supply", false)):
		var grounded_east := mini(2, int(state.get("army_aircraft", 0)))
		state.army_aircraft = maxi(0, int(state.get("army_aircraft", 0)) - grounded_east)
		dependency_note = " Восточные техники заблокировали обслуживание: %d самолёта выведены из строя." % grounded_east
	elif enemy == "west" and bool(state.get("western_aircraft_contract", false)):
		var grounded_west := mini(3, int(state.get("army_aircraft", 0)))
		state.army_aircraft = maxi(0, int(state.get("army_aircraft", 0)) - grounded_west)
		dependency_note = " Западный поставщик отозвал коды обслуживания: %d самолёта выведены из строя." % grounded_west
	state.last_war_report = "%s начал вторжение после перехода отношений во враждебное состояние.%s" % [neighbor_title(enemy), dependency_note]
	return "%s разорвал дипломатические гарантии и начал вторжение. Республика вступила в войну.%s" % [neighbor_title(enemy), dependency_note]


func process_war_week() -> Dictionary:
	if not bool(state.get("at_war", false)):
		return {}
	var quality := army_quality_effectiveness()
	var combat_effectiveness := army_effectiveness()
	var required := frontline_required_personnel(quality)
	var personnel_before := int(state.get("army_personnel", 0))
	var shortage_ratio := clampf(float(required - personnel_before) / float(maxi(required, 1)), 0.0, 1.0)
	var enemy := str(state.get("war_enemy", "east"))
	var war_week := int(state.get("war_weeks", 0)) + 1
	var duration_personnel_multiplier := war_personnel_attrition_multiplier(war_week)
	var duration_equipment_multiplier := war_equipment_attrition_multiplier(war_week)
	var medical_multiplier := health_war_loss_multiplier() * temporary_war_medical_multiplier()
	var personnel_loss_before_medicine := maxi(0, roundi(650.0 + float(100 - combat_effectiveness) * 22.0 + shortage_ratio * 2600.0))
	var personnel_loss := mini(personnel_before, maxi(0, roundi(float(personnel_loss_before_medicine) * medical_multiplier * duration_personnel_multiplier)))
	var equipment_before := int(state.get("army_equipment", 0))
	var equipment_loss_base := 1.0 + float(100 - combat_effectiveness) / 22.0 + shortage_ratio * 4.0
	var equipment_loss := mini(equipment_before, maxi(0, roundi(equipment_loss_base * duration_equipment_multiplier * temporary_ammo_conservation_multiplier())))
	state.war_weeks = war_week
	var aircraft_before := int(state.get("army_aircraft", 0))
	var aircraft_loss := 1 if aircraft_before > 0 else 0
	if combat_effectiveness < 35 and aircraft_before - aircraft_loss > 0:
		aircraft_loss += 1
	if combat_effectiveness <= 10 and aircraft_before - aircraft_loss > 0:
		aircraft_loss += 1
	aircraft_loss = mini(aircraft_before, aircraft_loss)
	state.army_personnel = personnel_before - personnel_loss
	state.army_equipment = equipment_before - equipment_loss
	state.army_aircraft = aircraft_before - aircraft_loss
	state.war_casualties = int(state.get("war_casualties", 0)) + personnel_loss
	var fatigue_loss := war_fatigue_loss(war_week)
	var political_effects := {"war_support": -fatigue_loss}
	var high_support_note := ""
	if int(state.get("war_support", 0)) >= WAR_SUPPORT_HIGH:
		political_effects["army"] = 1
		high_support_note = " Высокая поддержка войны укрепила лояльность армии на 1."
	if shortage_ratio > 0.0:
		political_effects["stability"] = -1 if shortage_ratio < 0.25 else -2
		political_effects["support"] = -1
	apply_effects(political_effects)
	var coverage_percent := clampi(roundi(float(personnel_before) / float(maxi(required, 1)) * 100.0), 0, 100)
	var escalation_note := " Истощение войны: людские потери ×%.2f, потери техники ×%.2f, поддержка войны −%d." % [duration_personnel_multiplier, duration_equipment_multiplier * temporary_ammo_conservation_multiplier(), fatigue_loss]
	var medicine_note := " Медицинское обеспечение: ×%.2f к людским потерям." % medical_multiplier
	var report := "%s • неделя войны %d. Боеспособность перед боями: %d%%. Фронту требовалось %s, имелось %s (%d%%). Потери: %s военнослужащих, %d техники, %d авиации.%s%s%s" % [neighbor_title(enemy), int(state.get("war_weeks", 0)), combat_effectiveness, format_people(required), format_people(personnel_before), coverage_percent, format_people(personnel_loss), equipment_loss, aircraft_loss, escalation_note, medicine_note, high_support_note]
	state.last_war_report = report
	return {
		"note": report,
		"personnel_loss": personnel_loss,
		"equipment_loss": equipment_loss,
		"aircraft_loss": aircraft_loss,
		"required": required,
		"effectiveness": combat_effectiveness
	}


func neighbor_response_cost(side: String, projected := false) -> float:
	match neighbor_relation_band(side, projected):
		"враждебные":
			return 2.50
		"натянутые":
			return 0.75
	return 0.0


func emission_shock_weeks_remaining() -> int:
	var remaining := int(state.get("emission_shock_weeks", 0))
	if remaining > 0:
		return remaining
	for change in pending_week_changes:
		var flags: Dictionary = change.get("flags", {})
		if bool(flags.get("printed_money", false)):
			return EMISSION_SHOCK_WEEKS
	return 0


func process_emission_shock_week() -> Dictionary:
	var remaining := int(state.get("emission_shock_weeks", 0))
	if remaining <= 0:
		return {}
	state.emission_shock_elapsed = int(state.get("emission_shock_elapsed", 0)) + 1
	var elapsed := int(state.get("emission_shock_elapsed", 0))
	var support_loss := 2 if elapsed % 3 == 0 else 0
	state.emission_shock_weeks = remaining - 1
	var note := "Инфляционное удорожание после эмиссии добавило к недельным счетам 1.20 млн; осталось %d нед." % int(state.get("emission_shock_weeks", 0))
	if support_loss > 0:
		note += " Третья неделя инфляционного шока: поддержка власти −2."
	return {"support_loss": support_loss, "note": note}


func weekly_nonbudget_expense_breakdown(projected := false) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var east_cost := neighbor_response_cost("east", projected)
	if east_cost > 0.0:
		result.append({
			"title": "Проверки Восточного Союза",
			"amount": -east_cost,
			"calculation": "Простой составов, хранение грузов и объездные маршруты из-за текущей категории отношений с Восточным Союзом."
		})
	var west_cost := neighbor_response_cost("west", projected)
	if west_cost > 0.0:
		result.append({
			"title": "Западная страховая надбавка",
			"amount": -west_cost,
			"calculation": "Банки и перевозчики Западной Федерации повысили страховые и расчётные сборы из-за текущей категории отношений."
		})
	if bool(state.get("west_investment_arbitration", false)):
		result.append({
			"title": "Сопровождение западного арбитража",
			"amount": -0.60,
			"calculation": "Постоянная цена арбитражного протокола: обязательный аудит, юридическое сопровождение и резерв внешних исков. Коррупция эту сумму не увеличивает."
		})
	var emission_weeks := emission_shock_weeks_remaining()
	if emission_weeks > 0:
		result.append({
			"title": "Инфляционное удорожание после эмиссии",
			"amount": -1.20,
			"calculation": "После чрезвычайной эмиссии государственные контракты в течение шести недель стоят на 1.20 млн дороже. С учётом текущей недели осталось платежей: %d. Коррупция эту сумму не увеличивает." % emission_weeks
		})
	var oversight_value := projected_pending_value("creditor_obligations") if projected else int(state.get("creditor_obligations", 0))
	var oversight_cost := creditor_oversight_cost(oversight_value)
	if oversight_cost > 0.0:
		result.append({
			"title": "Надзор международных кредиторов",
			"amount": -oversight_cost,
			"calculation": "Комиссии за резервную кредитную линию, обязательный аудит и сопровождение соглашения. Текущая категория обязательств: «%s»." % creditor_obligation_level(int(state.get("creditor_obligations", 0)))
		})
	if int(state.get("week", 1)) <= int(state.get("double_standards_until_week", 0)):
		result.append({
			"title": "Двойная сертификация экспорта",
			"amount": -1.60,
			"calculation": "Переходный период сохраняет доступ к восточному и западному рынкам, но требует двух комплектов документации, испытаний и маркировки. Коррупция эту сумму не увеличивает."
		})
	if bool(state.get("eastern_turbine_service", false)) and neighbor_relation_band("east") in ["натянутые", "враждебные"]:
		result.append({"title": "Задержка восточного обслуживания станции", "amount": -0.80, "calculation": "При натянутых отношениях восточный подрядчик задерживает детали и удалённые допуски крупнейшей гидроэлектростанции."})
	if bool(state.get("western_grid_standard", false)) and neighbor_relation_band("west") in ["натянутые", "враждебные"]:
		result.append({"title": "Задержка западных сетевых компонентов", "amount": -0.60, "calculation": "При натянутых отношениях западные поставщики требуют страховую предоплату за совместимые узлы энергосети."})
	return result


func weekly_action_notes() -> Array[String]:
	var notes: Array[String] = []
	var east_cost := neighbor_response_cost("east")
	if east_cost > 0.0:
		notes.append("Восточный Союз продолжил пограничные проверки; простой и объезды стоили казне %.2f млн." % east_cost)
	var west_cost := neighbor_response_cost("west")
	if west_cost > 0.0:
		notes.append("Западные банки и перевозчики сохранили повышенные сборы; казна потеряла %.2f млн." % west_cost)
	var oversight_cost := creditor_oversight_cost()
	if oversight_cost > 0.0:
		notes.append("Условия международной кредитной линии стоили казне %.2f млн." % oversight_cost)
	if int(state.get("week", 1)) <= int(state.get("double_standards_until_week", 0)):
		notes.append("Совместимость с двумя торговыми системами обошлась казне в 1.60 млн.")
	if int(state.get("regional_administration_penalty_until_week", 0)) > int(state.get("week", 1)):
		notes.append("Губернаторы перехватили разбор протестных требований: на следующей неделе центральное правительство получит на 1 очко решений меньше.")
	var army_loyalty := int(state.get("army", 0))
	if army_loyalty >= 80:
		notes.append("Лояльность армии не ниже 80%: согласованность штаба повышает боеспособность на 10 п.п.")
	elif army_loyalty >= 65:
		notes.append("Лояльность армии не ниже 65%: командование повышает боеспособность на 5 п.п.")
	elif army_loyalty <= 20:
		notes.append("Лояльность армии не выше 20%: саботаж штаба снижает боеспособность на 15 п.п.")
	elif army_loyalty <= 40:
		notes.append("Лояльность армии не выше 40%: формальное исполнение приказов снижает боеспособность на 7 п.п.")
	return notes


func exported_oil() -> int:
	return maxi(0, current_oil_output() - int(state.get("oil_to_army", 0)))


func current_oil_output() -> int:
	var privatization_loss := PRIVATIZED_OIL_OUTPUT_LOSS if bool(state.get("raw_sector_privatized", false)) else 0
	return maxi(0, OIL_OUTPUT - privatization_loss - (4 if bool(state.get("east_border_oil_concession", false)) else 0))


func current_metal_output() -> int:
	return maxi(0, METAL_OUTPUT - (PRIVATIZED_METAL_OUTPUT_LOSS if bool(state.get("raw_sector_privatized", false)) else 0))


func oil_output_reduction_note() -> String:
	var notes: Array[String] = []
	if bool(state.get("raw_sector_privatized", false)):
		notes.append("приватизация −%d" % PRIVATIZED_OIL_OUTPUT_LOSS)
	if bool(state.get("east_border_oil_concession", false)):
		notes.append("восточная концессия −4")
	return "без постоянных потерь добычи" if notes.is_empty() else ", ".join(notes)


func exported_metal() -> int:
	return maxi(0, current_metal_output() - int(state.get("metal_to_equipment", 0)))


func current_oil_price() -> float:
	return snappedf(OIL_PRICE * float(state.get("oil_price_factor", 1.0)), 0.01)


func current_metal_price() -> float:
	return snappedf(METAL_PRICE * float(state.get("metal_price_factor", 1.0)), 0.01)


func weekly_income_breakdown(strike_level_override := -1) -> Array[Dictionary]:
	var strike_level := strike_level_override
	if strike_level < 0:
		strike_level = int(state.get("active_unrest_level", 0)) if bool(state.get("active_unrest_labor", false)) else 0
	strike_level = clampi(strike_level, 0, 3)
	var labor_tax_multiplier := 1.0
	var state_enterprise_multiplier := 1.0
	var export_multiplier := 1.0
	if strike_level == 1:
		labor_tax_multiplier = 0.90
		state_enterprise_multiplier = 0.75
	elif strike_level == 2:
		labor_tax_multiplier = 0.80
		state_enterprise_multiplier = 0.75
	elif strike_level >= 3:
		labor_tax_multiplier = 0.65
		state_enterprise_multiplier = 0.50
		export_multiplier = 0.80
	var strike_suffix := ""
	if strike_level > 0:
		strike_suffix = " После влияния состояния «%s»." % unrest_level_title(strike_level, true)
	var result: Array[Dictionary] = [
		{"title": "Налоги работающих", "amount": snappedf(float(state.get("pop_employed", 0)) / 1000000.0 * 2.0 * labor_tax_multiplier, 0.01), "calculation": "%s работающих × 2.00 млн за 1 млн человек × %.0f%%%s" % [format_people(int(state.get("pop_employed", 0))), labor_tax_multiplier * 100.0, strike_suffix]},
		{"title": "Налог на бизнес", "amount": 1.0, "calculation": "Текущая базовая ставка налога на бизнес"},
		{"title": "Государственные предприятия", "amount": snappedf(0.5 * state_enterprise_multiplier, 0.01), "calculation": "Перечисляемая прибыль государственных предприятий × %.0f%%%s" % [state_enterprise_multiplier * 100.0, strike_suffix]},
		{"title": "Пошлины", "amount": 0.4, "calculation": "Текущие импортные и экспортные пошлины"},
		{"title": "Экспорт нефти", "amount": snappedf(float(exported_oil()) * current_oil_price() * export_multiplier, 0.01), "calculation": "%d ед. на экспорт × %.2f млн за единицу × %.0f%%%s" % [exported_oil(), current_oil_price(), export_multiplier * 100.0, strike_suffix]},
		{"title": "Экспорт металлов", "amount": snappedf(float(exported_metal()) * current_metal_price() * export_multiplier, 0.01), "calculation": "%d ед. на экспорт × %.2f млн за единицу × %.0f%%%s" % [exported_metal(), current_metal_price(), export_multiplier * 100.0, strike_suffix]}
	]
	if int(state.get("week", 1)) <= int(state.get("east_energy_discount_until_week", 0)) and neighbor_relation_band("east") != "враждебные":
		result.append({"title": "Восточная энергетическая скидка", "amount": 1.40, "calculation": "Льготная цена импортного топлива высвобождает 1.40 млн в неделю. Как и прочие поступления, итоговая выгода уменьшается текущей коррупцией."})
	if int(state.get("week", 1)) <= int(state.get("west_market_access_until_week", 0)) and neighbor_relation_band("west") != "враждебные":
		result.append({"title": "Доступ к западному рынку", "amount": 1.20, "calculation": "Ускоренный таможенный режим и новые экспортные квоты дают 1.20 млн в неделю до потерь от коррупции."})
	if bool(state.get("west_labor_mobility", false)) and neighbor_relation_band("west") != "враждебные":
		result.append({"title": "Переводы работающих за рубежом", "amount": 0.80, "calculation": "Работающие в Западной Федерации граждане переводят деньги семьям: 0.80 млн в неделю до потерь от коррупции."})
	if bool(state.get("joint_eastern_customs", false)) and neighbor_relation_band("east") != "враждебные":
		result.append({"title": "Ускоренный восточный транзит", "amount": 0.60, "calculation": "Совместные инспекторы ускоряют согласованные грузы и дают 0.60 млн в неделю, но сохраняют доступ Восточного Союза к таможенной базе."})
	return result


func weekly_actual_income(strike_level_override := -1) -> float:
	var total := 0.0
	var tier := int(state.get("corruption_tier", 0))
	for item in weekly_income_breakdown(strike_level_override):
		total += adjusted_money_transaction(float(item["amount"]), tier)
	var clan_flow := weekly_clan_money_flow()
	if clan_flow > 0.0:
		total += adjusted_money_transaction(clan_flow, tier)
	return snappedf(total, 0.01)


func weekly_actual_expenses() -> float:
	var total := 0.0
	var tier := int(state.get("corruption_tier", 0))
	for item in WEEKLY_BUDGET_LINES:
		total += absf(adjusted_money_transaction(-budget_amount_by_key(str(item["key"])), tier))
	for item in weekly_nonbudget_expense_breakdown():
		total += absf(adjusted_money_transaction(float(item.get("amount", 0.0)), tier))
	var clan_flow := weekly_clan_money_flow()
	if clan_flow < 0.0:
		total += absf(adjusted_money_transaction(clan_flow, tier))
	return snappedf(total, 0.01)


func weekly_balance_forecast() -> float:
	# Решения применяются до недельного расчёта, поэтому прогноз обязан учитывать
	# будущую категорию коррупции и будущую позицию олигархов, а не только их
	# текущие значения. Иначе интерфейс мог обещать остаток, после чего казна всё
	# равно уходила в минус при закрытии недели.
	var projected_tier := projected_corruption_tier()
	var projected_income := 0.0
	for item in weekly_income_breakdown():
		projected_income += adjusted_money_transaction(float(item.get("amount", 0.0)), projected_tier)
	var projected_expenses := 0.0
	for budget_item in WEEKLY_BUDGET_LINES:
		projected_expenses += budget_amount_by_key(str(budget_item.get("key", "")))
	for expense_item in weekly_nonbudget_expense_breakdown(true):
		projected_expenses += absf(float(expense_item.get("amount", 0.0)))
	var projected_clan_flow := weekly_clan_money_flow(projected_pending_value("clan_oligarchs"))
	if projected_clan_flow >= 0.0:
		projected_income += adjusted_money_transaction(projected_clan_flow, projected_tier)
	else:
		projected_expenses += absf(projected_clan_flow)
	return snappedf(float(state.get("money", 0.0)) + projected_pending_money_delta() + projected_income - projected_expenses, 0.01)


func weekly_money_breakdown_tooltip(corruption_tier: int, strike_level_override := -1) -> String:
	var sections: Array[String] = ["Коррупция «%s»: доходы −%d%%; расходы и цены не изменяются.", "ДОХОДЫ"]
	sections[0] = sections[0] % [corruption_level(corruption_tier), corruption_transaction_rate(corruption_tier)]
	for item in weekly_income_breakdown(strike_level_override):
		sections.append("%s: +%.2f млн" % [str(item.get("title", "Доход")), adjusted_money_transaction(float(item.get("amount", 0.0)), corruption_tier)])
	var clan_flow := weekly_clan_money_flow()
	if clan_flow > 0.0:
		sections.append("Бонус олигархов: +%.2f млн" % adjusted_money_transaction(clan_flow, corruption_tier))
	sections.append("РАСХОДЫ")
	for item in WEEKLY_BUDGET_LINES:
		sections.append("%s: −%.2f млн" % [str(item.get("title", "Расход")), absf(adjusted_money_transaction(-budget_amount_by_key(str(item.get("key", ""))), corruption_tier))])
	for item in weekly_nonbudget_expense_breakdown():
		sections.append("%s: −%.2f млн" % [str(item.get("title", "Внешние издержки")), absf(adjusted_money_transaction(float(item.get("amount", 0.0)), corruption_tier))])
	if clan_flow < 0.0:
		sections.append("Давление олигархов: −%.2f млн" % absf(adjusted_money_transaction(clan_flow, corruption_tier)))
	sections.append("Полная формула каждой статьи доступна при наведении во вкладке «Экономика».")
	return "\n".join(sections)


func weekly_influence_cap() -> int:
	var administration_points := 2 if budget_level("budget_admin") == 0 else 4 if budget_level("budget_admin") == 2 else 3
	return maxi(0, administration_points + high_stability_influence_bonus() - low_stability_influence_penalty() - regional_administration_influence_penalty())


func high_stability_influence_bonus() -> int:
	return 1 if int(state.get("stability", 0)) >= 70 else 0


func low_stability_influence_penalty() -> int:
	return 1 if int(state.get("stability", 0)) <= 30 else 0


func regional_administration_influence_penalty() -> int:
	return 1 if int(state.get("week", 1)) <= int(state.get("regional_administration_penalty_until_week", 0)) else 0


func clan_band(value: int) -> String:
	if value >= CLAN_CRITICAL_HIGH_SUPPORT:
		return "критическая поддержка"
	if value >= CLAN_HIGH_SUPPORT:
		return "высокая поддержка"
	if value <= CLAN_CRITICAL_LOW_SUPPORT:
		return "открытая враждебность"
	if value <= CLAN_LOW_SUPPORT:
		return "низкая поддержка"
	return "нейтральная позиция"


func weekly_clan_money_flow(value_override := -1) -> float:
	var value := int(state.get("clan_oligarchs", 50)) if value_override < 0 else value_override
	if value >= CLAN_CRITICAL_HIGH_SUPPORT:
		return 3.0
	if value >= CLAN_HIGH_SUPPORT:
		return 1.5
	if value <= CLAN_CRITICAL_LOW_SUPPORT:
		return -4.0
	if value <= CLAN_LOW_SUPPORT:
		return -2.0
	return 0.0


func workers_public_support_effect(value_override := -1) -> int:
	var value := int(state.get("clan_workers", 50)) if value_override < 0 else value_override
	if value >= CLAN_CRITICAL_HIGH_SUPPORT:
		return 2
	if value >= CLAN_HIGH_SUPPORT:
		return 1
	if value <= CLAN_CRITICAL_LOW_SUPPORT:
		return -2
	if value <= CLAN_LOW_SUPPORT:
		return -1
	return 0


func regional_stability_effect(value_override := -1) -> int:
	var value := int(state.get("clan_regions", 50)) if value_override < 0 else value_override
	if value >= CLAN_CRITICAL_HIGH_SUPPORT:
		return 2
	if value >= CLAN_HIGH_SUPPORT:
		return 1
	if value <= CLAN_CRITICAL_LOW_SUPPORT:
		return -2
	if value <= CLAN_LOW_SUPPORT:
		return -1
	return 0


func church_influence_scale() -> float:
	return 0.5 if bool(state.get("secular_education", false)) else 1.0


func church_war_support_effect(value_override := -1) -> int:
	var value := int(state.get("clan_church", 50)) if value_override < 0 else value_override
	var base := 2 if value >= CLAN_CRITICAL_HIGH_SUPPORT else 1 if value >= CLAN_HIGH_SUPPORT else 0
	if base == 1 and bool(state.get("secular_education", false)):
		# Половина одного целого пункта отыгрывается как +1 раз в две недели.
		return 1 if int(state.get("week", 1)) % 2 == 0 else 0
	return floori(float(base) * church_influence_scale())


func church_public_support_effect(value_override := -1) -> int:
	var value := int(state.get("clan_church", 50)) if value_override < 0 else value_override
	var base := -4 if value <= CLAN_CRITICAL_LOW_SUPPORT else -2 if value <= CLAN_LOW_SUPPORT else 0
	return roundi(float(base) * church_influence_scale())


func church_birth_rate_modifier(value_override := -1) -> float:
	var value := int(state.get("clan_church", 50)) if value_override < 0 else value_override
	var base := 0.20 if value >= CLAN_CRITICAL_HIGH_SUPPORT else 0.10 if value >= CLAN_HIGH_SUPPORT else 0.0
	return base * church_influence_scale()


func weekly_clan_effects() -> Dictionary:
	var effects: Dictionary = {}
	var church_war_support := church_war_support_effect()
	var church_public_support := church_public_support_effect()
	if church_war_support != 0:
		effects["war_support"] = church_war_support
	if church_public_support != 0:
		effects["support"] = church_public_support
	var workers_support := workers_public_support_effect()
	if workers_support != 0:
		effects["support"] = int(effects.get("support", 0)) + workers_support
	var regions_stability := regional_stability_effect()
	if regions_stability != 0:
		effects["stability"] = regions_stability
	return effects


func weekly_clan_effect_notes() -> Array[String]:
	var notes: Array[String] = []
	var oligarch_flow := weekly_clan_money_flow()
	if oligarch_flow > 0.0:
		notes.append("Олигархи предоставили капитал и налоговые авансы: казна +%.2f млн." % adjusted_money_transaction(oligarch_flow, int(state.get("corruption_tier", 0))))
	elif oligarch_flow < 0.0:
		notes.append("Олигархи задержали платежи и вывели капитал: казна −%.2f млн." % absf(oligarch_flow))
	var church := int(state.get("clan_church", 50))
	if church >= CLAN_CRITICAL_HIGH_SUPPORT:
		notes.append("Церковь благословила государственный курс: поддержка войны +%d; её влияние повышает месячную рождаемость на %d%%." % [church_war_support_effect(church), roundi(church_birth_rate_modifier(church) * 100.0)])
	elif church >= CLAN_HIGH_SUPPORT:
		var war_effect := church_war_support_effect(church)
		if war_effect > 0:
			notes.append("Церковь поддержала государственный курс: поддержка войны +%d; её влияние повышает месячную рождаемость на %d%%." % [war_effect, roundi(church_birth_rate_modifier(church) * 100.0)])
		else:
			notes.append("Церковь поддержала семьи прихожан: месячная рождаемость +%d%%; после светского образования бонус поддержки войны приходит раз в две недели." % roundi(church_birth_rate_modifier(church) * 100.0))
	elif church <= CLAN_CRITICAL_LOW_SUPPORT:
		notes.append("Церковь объявила власть враждебной Вере: поддержка власти %d." % church_public_support_effect(church))
	elif church <= CLAN_LOW_SUPPORT:
		notes.append("Церковь ведёт кампанию против решений президента: поддержка власти %d." % church_public_support_effect(church))
	var workers := int(state.get("clan_workers", 50))
	var workers_support := workers_public_support_effect(workers)
	if workers_support > 0:
		notes.append("Профсоюзы публично поддержали социальный курс правительства: поддержка власти +%d." % workers_support)
	elif workers_support < 0:
		notes.append("Профсоюзы ведут кампанию против правительства: поддержка власти %d." % workers_support)
	var regions := int(state.get("clan_regions", 50))
	var region_stability := regional_stability_effect(regions)
	if region_stability > 0:
		notes.append("Губернаторы удерживают порядок и исполняют решения центра: стабильность +%d." % region_stability)
	elif region_stability < 0:
		notes.append("Конфликт губернаторов с центром расшатывает управление на местах: стабильность %d." % region_stability)
	return notes


func army_loyalty_quality_modifier(value_override := -1) -> int:
	var loyalty := int(state.get("army", 50)) if value_override < 0 else value_override
	if loyalty >= 80:
		return 10
	if loyalty >= 65:
		return 5
	if loyalty <= 20:
		return -15
	if loyalty <= 40:
		return -7
	return 0


func army_group_band(value: int) -> String:
	if value >= 80:
		return "критическая лояльность"
	if value >= 65:
		return "высокая лояльность"
	if value <= 20:
		return "угроза переворота"
	if value <= 40:
		return "низкая лояльность"
	return "неустойчивая лояльность"


func army_parliament_modifier(value: int) -> int:
	if value >= 65:
		return 1
	if value <= 40:
		return -1
	return 0


func army_group_effect_description(value: int) -> String:
	var weekly_effect := "постоянного недельного эффекта нет"
	if value >= 80:
		weekly_effect = "боеспособность +10 п.п."
	elif value >= 65:
		weekly_effect = "боеспособность +5 п.п."
	elif value <= 20:
		weekly_effect = "боеспособность −15 п.п."
	elif value <= 40:
		weekly_effect = "боеспособность −7 п.п."
	var parliament_modifier := army_parliament_modifier(value)
	var parliament_effect := "Старая гвардия не получает модификатора от армии"
	if parliament_modifier > 0:
		parliament_effect = "Старая гвардия получает +1 к позиции; этот бонус не складывается с бонусом жёсткого курса"
	elif parliament_modifier < 0:
		parliament_effect = "Старая гвардия получает −1 к позиции"
	return "%s; %s" % [weekly_effect, parliament_effect]


func transfer_population(from_key: String, to_key: String, requested: int) -> int:
	var moved := mini(maxi(requested, 0), maxi(int(state.get(from_key, 0)), 0))
	state[from_key] = int(state.get(from_key, 0)) - moved
	state[to_key] = int(state.get(to_key, 0)) + moved
	return moved


func process_army_recruitment() -> Dictionary:
	var current := int(state.get("army_personnel", 0))
	var target := recruitment_target()
	var model: Dictionary = RECRUITMENT_MODELS.get(str(state.get("recruitment_model", "mixed")), RECRUITMENT_MODELS["mixed"])
	var base_speed := int(model.get("speed", 6000))
	var speed_multiplier := recruitment_speed_multiplier()
	var speed := maxi(1, roundi(float(base_speed) * speed_multiplier))
	var difference := target - current
	var recruited := 0
	var demobilized := 0
	var evaders := 0
	if difference > 0:
		var requested := mini(difference, speed)
		if speed_multiplier < 1.0:
			evaders = maxi(0, mini(difference, base_speed) - requested)
		var from_unemployed := transfer_population("pop_unemployed", "army_personnel", requested)
		var remaining := requested - from_unemployed
		if remaining > 0:
			transfer_population("pop_employed", "army_personnel", remaining)
		recruited = int(state.get("army_personnel", 0)) - current
	elif difference < 0:
		demobilized = mini(-difference, speed)
		state.army_personnel = current - demobilized
		var to_work := roundi(float(demobilized) * 0.8)
		state.pop_employed = int(state.get("pop_employed", 0)) + to_work
		state.pop_unemployed = int(state.get("pop_unemployed", 0)) + demobilized - to_work
	var deserters := 0
	var desertion_rate := wartime_desertion_rate()
	if bool(state.get("at_war", false)) and desertion_rate > 0.0:
		var mobilization_multiplier := 1.5 if str(state.get("recruitment_model", "mixed")) == "mobilization" else 1.0
		var duration_multiplier := 1.0 + float(mini(int(state.get("war_weeks", 0)), 12)) * 0.05
		deserters = mini(int(state.get("army_personnel", 0)), maxi(100, roundi(float(state.get("army_personnel", 0)) * desertion_rate * mobilization_multiplier * duration_multiplier)))
		state.army_personnel = int(state.get("army_personnel", 0)) - deserters
		state.pop_unemployed = int(state.get("pop_unemployed", 0)) + deserters
	var notes: Array[String] = []
	if speed_multiplier > 1.0 and recruited > 0:
		notes.append("Высокая поддержка войны ускорила набор до %d%% обычного темпа." % roundi(speed_multiplier * 100.0))
	if evaders > 0:
		notes.append("Из-за низкой поддержки войны от призыва уклонились %s потенциальных новобранцев." % format_people(evaders))
	if deserters > 0:
		notes.append("Из частей дезертировали %s военнослужащих; они вернулись в группу безработных." % format_people(deserters))
	return {
		"change": int(state.get("army_personnel", 0)) - current,
		"recruited": recruited,
		"demobilized": demobilized,
		"evaders": evaders,
		"deserters": deserters,
		"note": " ".join(notes)
	}


func production_factor() -> float:
	return [0.5, 1.0, 1.25][budget_level("budget_defense")]


func equipment_production_per_week() -> int:
	return maxi(0, roundi(float(state.get("metal_to_equipment", 0)) * 2.0 * production_factor()))


func process_military_production() -> Dictionary:
	var equipment_gain := equipment_production_per_week()
	state.army_equipment = int(state.get("army_equipment", 0)) + equipment_gain
	return {"equipment": equipment_gain}


func process_weekly_budget_consequences(closed_week: int) -> Array[String]:
	var effects: Dictionary = {}
	var notes: Array[String] = []
	if int(state.get("support", 0)) >= 70:
		effects["stability"] = int(effects.get("stability", 0)) + 1
		notes.append("Поддержка власти не ниже 70%: общественное спокойствие укрепило стабильность на 1.")
	if budget_level("budget_social") == 0:
		effects["support"] = int(effects.get("support", 0)) - 2
		effects["clan_workers"] = int(effects.get("clan_workers", 0)) - 2
		notes.append("Сокращение социальной помощи: поддержка власти −2.")
		notes.append("Профсоюзы выступили против сокращения социальной помощи: отношение −2.")
	elif budget_level("budget_social") == 2 and closed_week % 2 == 0:
		effects["support"] = int(effects.get("support", 0)) + 1
		effects["clan_workers"] = int(effects.get("clan_workers", 0)) + 3
		notes.append("Приоритетная социальная помощь: поддержка власти +1.")
		notes.append("Профсоюзы поддержали расширение социальной помощи: отношение +3.")
	if budget_level("budget_health") == 0:
		effects["stability"] = int(effects.get("stability", 0)) - 2
		notes.append("Недофинансирование школ и больниц: стабильность −2.")
	elif budget_level("budget_health") == 2 and closed_week % 2 == 0:
		effects["stability"] = int(effects.get("stability", 0)) + 1
		notes.append("Приоритет школ и больниц: стабильность +1.")
	if budget_level("budget_defense") == 0:
		var defense_loss := 1 + (1 if bool(state.get("military_threat", false)) or closed_week % 2 == 0 else 0)
		effects["army"] = int(effects.get("army", 0)) - defense_loss
		notes.append("Сокращённое финансирование армии: лояльность командования −%d." % defense_loss)
	elif budget_level("budget_defense") == 2 and closed_week % 2 == 0:
		effects["army"] = int(effects.get("army", 0)) + 2
		notes.append("Приоритетное финансирование армии: лояльность штаба +2.")
	if budget_level("budget_infrastructure") == 0:
		effects["clan_regions"] = int(effects.get("clan_regions", 0)) - 2
		if closed_week % 2 == 0:
			effects["stability"] = int(effects.get("stability", 0)) - 1
		notes.append("Регионы недовольны отложенными ремонтами: отношение −2.")
		if closed_week % 2 == 0:
			notes.append("Накопившиеся проблемы с инфраструктурой: стабильность −1.")
	elif budget_level("budget_infrastructure") == 2 and closed_week % 2 == 0:
		effects["clan_regions"] = int(effects.get("clan_regions", 0)) + 3
		effects["stability"] = int(effects.get("stability", 0)) + 1
		notes.append("Регионы поддержали программу приоритетных ремонтов: отношение +3.")
		notes.append("Приоритетные ремонты повысили устойчивость инфраструктуры: стабильность +1.")
	if budget_level("budget_debt") == 0:
		state.creditor_priority_weeks = 0
		state.debt = snappedf(float(state.get("debt", 0.0)) + 8.0, 0.01)
		notes.append("Недоплата кредиторам прибавила 8 млн к долгу.")
		if int(state.get("creditor_obligations", 0)) > 0:
			var previous_obligations := int(state.get("creditor_obligations", 0))
			state.creditor_obligations = mini(CREDITOR_OBLIGATION_LABELS.size() - 1, previous_obligations + 1)
			if int(state.get("creditor_obligations", 0)) != previous_obligations:
				notes.append("Нарушение условий займа ужесточило режим международных кредиторов до категории «%s»." % creditor_obligation_level(int(state.get("creditor_obligations", 0))))
	elif budget_level("budget_debt") == 2:
		state.debt = maxf(0.0, snappedf(float(state.get("debt", 0.0)) - 6.0, 0.01))
		notes.append("Приоритетное обслуживание сократило долг на 6 млн.")
		if int(state.get("creditor_obligations", 0)) > 0:
			state.creditor_priority_weeks = int(state.get("creditor_priority_weeks", 0)) + 1
			if int(state.get("creditor_priority_weeks", 0)) >= 4:
				state.creditor_obligations = int(state.get("creditor_obligations", 0)) - 1
				state.creditor_priority_weeks = 0
				notes.append("Четыре недели приоритетных выплат смягчили условия международных кредиторов до категории «%s»." % creditor_obligation_level(int(state.get("creditor_obligations", 0))))
		else:
			state.creditor_priority_weeks = 0
	else:
		state.creditor_priority_weeks = 0
	var supply := army_supply()
	if supply < 75:
		effects["army"] = int(effects.get("army", 0)) - 2
		notes.append("Снабжение армии ниже 75%: лояльность командования −2.")
	if supply < 50:
		effects["stability"] = int(effects.get("stability", 0)) - 2
		notes.append("Снабжение армии ниже 50%: стабильность −2.")
	if int(state.get("brother_trust", 0)) <= 0:
		effects["army"] = int(effects.get("army", 0)) - 1
		effects["stability"] = int(effects.get("stability", 0)) - 1
		notes.append("Старший брат открыто спорит с президентом: армия −1, стабильность −1.")
	if not effects.is_empty():
		apply_effects(effects)
	return notes


func process_population_month() -> void:
	var population_before := total_population()
	var birth_modifier := church_birth_rate_modifier()
	var births := maxi(0, roundi(float(population_before) * 0.00065 * (1.0 + birth_modifier)))
	var mature := mini(int(state.get("pop_children", 0)), roundi(float(state.get("pop_children", 0)) / 216.0))
	var adult_civilians := int(state.get("pop_employed", 0)) + int(state.get("pop_unemployed", 0))
	var unemployment_share := float(state.get("pop_unemployed", 0)) / maxf(float(adult_civilians), 1.0)
	var mature_unemployed := roundi(float(mature) * unemployment_share)
	state.pop_children = int(state.get("pop_children", 0)) - mature + births
	state.pop_employed = int(state.get("pop_employed", 0)) + mature - mature_unemployed
	state.pop_unemployed = int(state.get("pop_unemployed", 0)) + mature_unemployed
	adult_civilians = int(state.get("pop_employed", 0)) + int(state.get("pop_unemployed", 0))
	var retirement := mini(adult_civilians, roundi(float(adult_civilians) * 0.00175))
	var retired_from_work := mini(int(state.get("pop_employed", 0)), roundi(float(retirement) * float(state.get("pop_employed", 0)) / maxf(float(adult_civilians), 1.0)))
	var retired_from_unemployed := mini(int(state.get("pop_unemployed", 0)), retirement - retired_from_work)
	state.pop_employed = int(state.get("pop_employed", 0)) - retired_from_work
	state.pop_unemployed = int(state.get("pop_unemployed", 0)) - retired_from_unemployed
	state.pop_pensioners = int(state.get("pop_pensioners", 0)) + retired_from_work + retired_from_unemployed
	var employed_deaths := mini(int(state.get("pop_employed", 0)), roundi(float(state.get("pop_employed", 0)) * 0.00015))
	var unemployed_deaths := mini(int(state.get("pop_unemployed", 0)), roundi(float(state.get("pop_unemployed", 0)) * 0.00015))
	var pensioner_deaths := mini(int(state.get("pop_pensioners", 0)), roundi(float(state.get("pop_pensioners", 0)) * 0.0055))
	state.pop_employed = int(state.get("pop_employed", 0)) - employed_deaths
	state.pop_unemployed = int(state.get("pop_unemployed", 0)) - unemployed_deaths
	state.pop_pensioners = int(state.get("pop_pensioners", 0)) - pensioner_deaths
	var migration_balance := monthly_health_migration_balance()
	if migration_balance < 0:
		migration_balance = -mini(int(state.get("pop_migrants", 0)), absi(migration_balance))
	state.pop_migrants = int(state.get("pop_migrants", 0)) + migration_balance
	for key in ["pop_children", "pop_employed", "pop_unemployed", "pop_pensioners", "pop_migrants", "army_personnel"]:
		state[key] = maxi(0, int(state.get(key, 0)))
	var population_after := total_population()
	var church_birth_note := ""
	if birth_modifier > 0.0:
		church_birth_note = " (влияние Церкви +%d%%)" % roundi(birth_modifier * 100.0)
	state.last_population_report = "Месяц: родилось %s%s • достигли взрослого возраста %s • вышли на пенсию %s • естественная убыль %s • миграционный баланс %s%s • итог %s" % [
		format_people(births), church_birth_note, format_people(mature), format_people(retirement), format_people(employed_deaths + unemployed_deaths + pensioner_deaths),
		"+" if migration_balance >= 0 else "−", format_people(absi(migration_balance)),
		("+" if population_after - population_before >= 0 else "−") + format_people(absi(population_after - population_before))
	]


func request_end_week() -> void:
	if not week_ready_for_new_week():
		show_notice("Сначала нужно рассмотреть все доклады этой недели.")
		return
	advance_week()


func advance_week() -> void:
	if not week_ready_for_new_week():
		return
	close_overlay()
	var closed_week := int(state.get("week", 1))
	var opening_snapshot := weekly_report_snapshot()
	var opening_money := float(state.get("money", 0.0))
	var opening_population := total_population()
	var unrest_snapshot := active_unrest_snapshot()
	var strike_level_for_week := int(unrest_snapshot.get("level", 0)) if bool(unrest_snapshot.get("labor", false)) else 0
	var decision_resolution := resolve_pending_week_changes()
	enforce_creditor_budget_lock()
	var invasion_note := start_invasion_if_needed()
	var recruitment_result := process_army_recruitment()
	var production := process_military_production()
	var war_result := process_war_week()
	var actual_income := weekly_actual_income(strike_level_for_week) + float(decision_resolution.get("income", 0.0))
	var actual_expenses := weekly_actual_expenses() + float(decision_resolution.get("expenses", 0.0))
	var transaction_tier := int(state.corruption_tier)
	var money_tooltip := weekly_money_breakdown_tooltip(transaction_tier, strike_level_for_week)
	if float(decision_resolution.get("income", 0.0)) > 0.0 or float(decision_resolution.get("expenses", 0.0)) > 0.0:
		money_tooltip += "\n\nОТЛОЖЕННЫЕ РЕШЕНИЯ\nПоступления: +%.2f млн\nРасходы: −%.2f млн" % [float(decision_resolution.get("income", 0.0)), float(decision_resolution.get("expenses", 0.0))]
	for income_item in weekly_income_breakdown(strike_level_for_week):
		state.money = snappedf(float(state.money) + adjusted_money_transaction(float(income_item["amount"]), transaction_tier), 0.01)
	for budget_item in WEEKLY_BUDGET_LINES:
		state.money = snappedf(float(state.money) + adjusted_money_transaction(-budget_amount_by_key(str(budget_item["key"])), transaction_tier), 0.01)
	for expense_item in weekly_nonbudget_expense_breakdown():
		state.money = snappedf(float(state.money) + adjusted_money_transaction(float(expense_item.get("amount", 0.0)), transaction_tier), 0.01)
	var clan_money := weekly_clan_money_flow()
	var clan_notes := weekly_clan_effect_notes()
	if not is_zero_approx(clan_money):
		state.money = snappedf(float(state.money) + adjusted_money_transaction(clan_money, transaction_tier), 0.01)
	var passive_effects := weekly_clan_effects()
	var emission_result := process_emission_shock_week()
	if int(emission_result.get("support_loss", 0)) > 0:
		passive_effects["support"] = int(passive_effects.get("support", 0)) - int(emission_result.get("support_loss", 0))
	if not passive_effects.is_empty():
		apply_effects(passive_effects)
	var consequence_notes: Array[String] = []
	var report_sections: Dictionary = {
		"decisions": [],
		"finance": [],
		"society": [],
		"groups": [],
		"security": [],
		"foreign": []
	}
	for decision_note in decision_resolution.get("notes", []):
		add_weekly_report_note(consequence_notes, report_sections, "decisions", str(decision_note))
	if invasion_note != "":
		add_weekly_report_note(consequence_notes, report_sections, "security", invasion_note)
	if str(recruitment_result.get("note", "")) != "":
		add_weekly_report_note(consequence_notes, report_sections, "security", str(recruitment_result.get("note", "")))
	if not war_result.is_empty():
		add_weekly_report_note(consequence_notes, report_sections, "security", str(war_result.get("note", "")))
	var unrest_note := process_active_unrest_week(unrest_snapshot)
	if unrest_note != "":
		add_weekly_report_note(consequence_notes, report_sections, "society", unrest_note)
	for action_note in weekly_action_notes():
		var action_text := str(action_note)
		add_weekly_report_note(consequence_notes, report_sections, weekly_report_note_category(action_text), action_text)
	if not emission_result.is_empty():
		add_weekly_report_note(consequence_notes, report_sections, "finance", str(emission_result.get("note", "")))
	for clan_note in clan_notes:
		add_weekly_report_note(consequence_notes, report_sections, "groups", str(clan_note))
	for budget_note in process_weekly_budget_consequences(closed_week):
		var budget_text := str(budget_note)
		add_weekly_report_note(consequence_notes, report_sections, weekly_report_note_category(budget_text), budget_text)
	var monthly_report := ""
	if closed_week % 4 == 0:
		process_population_month()
		monthly_report = str(state.get("last_population_report", ""))
	for resource in ["metal", "oil"]:
		var weeks_key: String = str(resource) + "_price_weeks"
		var factor_key: String = str(resource) + "_price_factor"
		if int(state.get(weeks_key, 0)) > 0:
			state[weeks_key] = int(state.get(weeks_key, 0)) - 1
			if int(state.get(weeks_key, 0)) <= 0:
				state[factor_key] = 1.0
	state.last_weekly_report = {
		"week": closed_week,
		"opening_money": opening_money,
		"income": actual_income,
		"expenses": actual_expenses,
		"closing_money": float(state.get("money", 0.0)),
		"money_tooltip": money_tooltip,
		"recruited": int(recruitment_result.get("change", 0)),
		"recruitment": recruitment_result.duplicate(true),
		"equipment": int(production.get("equipment", 0)),
		"war": war_result.duplicate(true),
		"population_delta": total_population() - opening_population,
		"monthly": monthly_report,
		"consequences": consequence_notes,
		"sections": report_sections
	}
	state.week = closed_week + 1
	state.influence = weekly_influence_cap()
	reset_budget_draft()
	state.financial_slot_consumed = false
	law_worked_this_week = false
	recruitment_changed_this_week = false
	events_resolved_this_week = 0
	events_required_this_week = EVENTS_PER_WEEK
	event_resolved = false
	var law_note := progress_active_law_stage(false)
	if law_note != "":
		add_weekly_report_note(consequence_notes, report_sections, "decisions", law_note)
		state.last_weekly_report["consequences"] = consequence_notes
		state.last_weekly_report["sections"] = report_sections
	state.last_weekly_report["closing_money"] = float(state.get("money", 0.0))
	state.last_weekly_report["population_delta"] = total_population() - opening_population
	state.last_weekly_report["totals"] = weekly_report_total_lines(opening_snapshot)
	if check_terminal_state():
		save_campaign(false)
		return
	if int(state.get("week", 1)) <= DEMO_WEEKS:
		prepare_week_event_queue()
	next_event()
	save_campaign(false)
	if int(state.get("week", 1)) <= DEMO_WEEKS and is_instance_valid(game_root):
		show_weekly_report()


func add_weekly_report_note(all_notes: Array[String], sections: Dictionary, category: String, note: String) -> void:
	if note.strip_edges() == "":
		return
	all_notes.append(note)
	var category_notes: Array = sections.get(category, [])
	category_notes.append(note)
	sections[category] = category_notes


func weekly_report_note_category(note: String) -> String:
	var lowered := note.to_lower()
	for marker in ["восточ", "запад", "сосед", "международ", "сертификац", "тамож", "погранич", "внешн"]:
		if lowered.contains(marker):
			return "foreign"
	for marker in ["арм", "штаб", "командован", "боеспособ", "войн", "фронт", "вторжен", "снабжен", "авиац", "мобилизац"]:
		if lowered.contains(marker):
			return "security"
	for marker in ["церков", "олигарх", "профсоюз", "регион", "губернатор", "внутренн", "группа"]:
		if lowered.contains(marker):
			return "groups"
	for marker in ["казн", "расход", "доход", "долг", "кредит", "инфляц", "эмисс", "платеж", "бюджет", "миллион", "млн"]:
		if lowered.contains(marker):
			return "finance"
	for marker in ["поддерж", "стабиль", "протест", "забастов", "обществен", "социальн", "школ", "больниц"]:
		if lowered.contains(marker):
			return "society"
	return "decisions"


func weekly_report_sections(report: Dictionary) -> Dictionary:
	var stored = report.get("sections", {})
	if stored is Dictionary and not (stored as Dictionary).is_empty():
		return (stored as Dictionary).duplicate(true)
	var sections: Dictionary = {"decisions": [], "finance": [], "society": [], "groups": [], "security": [], "foreign": []}
	for legacy_note in report.get("consequences", []):
		var note := str(legacy_note)
		var category := weekly_report_note_category(note)
		var category_notes: Array = sections.get(category, [])
		category_notes.append(note)
		sections[category] = category_notes
	return sections


func weekly_report_snapshot() -> Dictionary:
	var snapshot: Dictionary = {}
	for key in [
		"money", "debt", "support", "stability", "war_support",
		"clan_oligarchs", "clan_church", "clan_workers", "clan_regions",
		"army", "army_personnel", "army_equipment", "army_aircraft",
		"pop_children", "pop_employed", "pop_unemployed", "pop_pensioners", "pop_migrants",
		"east_relation", "west_relation", "corruption_tier", "creditor_obligations"
	]:
		snapshot[key] = state.get(key, 0)
	snapshot["total_population"] = total_population()
	return snapshot


func weekly_report_total_lines(opening: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	var finance_parts: Array[String] = []
	var money_delta := snappedf(float(state.get("money", 0.0)) - float(opening.get("money", 0.0)), 0.01)
	var debt_delta := snappedf(float(state.get("debt", 0.0)) - float(opening.get("debt", 0.0)), 0.01)
	if not is_zero_approx(money_delta):
		finance_parts.append("казна %+.2f млн" % money_delta)
	if not is_zero_approx(debt_delta):
		finance_parts.append("долг %+.2f млн" % debt_delta)
	if not finance_parts.is_empty():
		lines.append("Финансы: " + " • ".join(finance_parts))
	var country_parts: Array[String] = []
	for entry in [
		["support", "поддержка власти"],
		["stability", "стабильность"],
		["war_support", "поддержка войны"]
	]:
		var delta := int(state.get(str(entry[0]), 0)) - int(opening.get(str(entry[0]), 0))
		if delta != 0:
			country_parts.append("%s %+d" % [str(entry[1]), delta])
	if not country_parts.is_empty():
		lines.append("Страна: " + " • ".join(country_parts))
	var group_parts: Array[String] = []
	for entry in [
		["clan_oligarchs", "олигархи"],
		["clan_church", "Церковь"],
		["clan_workers", "профсоюзы"],
		["clan_regions", "регионы"],
		["army", "армия"]
	]:
		var delta := int(state.get(str(entry[0]), 0)) - int(opening.get(str(entry[0]), 0))
		if delta != 0:
			group_parts.append("%s %+d" % [str(entry[1]), delta])
	if not group_parts.is_empty():
		lines.append("Группы: " + " • ".join(group_parts))
	var population_parts: Array[String] = []
	var population_delta := total_population() - int(opening.get("total_population", total_population()))
	if population_delta != 0:
		population_parts.append("всего %s%s" % ["+" if population_delta > 0 else "−", format_people(absi(population_delta))])
	for entry in [
		["pop_employed", "занятые"],
		["pop_unemployed", "безработные"],
		["pop_pensioners", "пенсионеры"],
		["pop_children", "дети"],
		["pop_migrants", "мигранты"]
	]:
		var delta := int(state.get(str(entry[0]), 0)) - int(opening.get(str(entry[0]), 0))
		if delta != 0:
			population_parts.append("%s %s%s" % [str(entry[1]), "+" if delta > 0 else "−", format_people(absi(delta))])
	if not population_parts.is_empty():
		lines.append("Население: " + " • ".join(population_parts))
	var army_parts: Array[String] = []
	for entry in [
		["army_personnel", "личный состав", true],
		["army_equipment", "техника", false],
		["army_aircraft", "авиация", false]
	]:
		var delta := int(state.get(str(entry[0]), 0)) - int(opening.get(str(entry[0]), 0))
		if delta != 0:
			army_parts.append("%s %s%s" % [str(entry[1]), "+" if delta > 0 else "−", format_people(absi(delta)) if bool(entry[2]) else str(absi(delta))])
	if not army_parts.is_empty():
		lines.append("Вооружённые силы: " + " • ".join(army_parts))
	var relation_parts: Array[String] = []
	for side_variant in ["east", "west"]:
		var side := str(side_variant)
		var key: String = side + "_relation"
		var before := int(opening.get(key, int(state.get(key, 2))))
		var after := int(state.get(key, 2))
		if before != after:
			relation_parts.append("%s: %s → %s" % [neighbor_title(side), ["враждебные", "натянутые", "средние", "партнёрские"][clampi(before, 0, 3)], ["враждебные", "натянутые", "средние", "партнёрские"][clampi(after, 0, 3)]])
	if not relation_parts.is_empty():
		lines.append("Отношения: " + " • ".join(relation_parts))
	var institution_parts: Array[String] = []
	var old_corruption := int(opening.get("corruption_tier", int(state.get("corruption_tier", 0))))
	var new_corruption := int(state.get("corruption_tier", 0))
	if old_corruption != new_corruption:
		institution_parts.append("коррупция: %s → %s" % [corruption_level(old_corruption), corruption_level(new_corruption)])
	var old_creditors := int(opening.get("creditor_obligations", int(state.get("creditor_obligations", 0))))
	var new_creditors := int(state.get("creditor_obligations", 0))
	if old_creditors != new_creditors:
		institution_parts.append("кредиторы: %s → %s" % [creditor_obligation_level(old_creditors), creditor_obligation_level(new_creditors)])
	if not institution_parts.is_empty():
		lines.append("Институты: " + " • ".join(institution_parts))
	if lines.is_empty():
		lines.append("Числовые показатели за неделю не изменились.")
	return lines


func weekly_report_panel(title_text: String, lines: Array, accent: Color, tooltip := "") -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", style(Color("#d8cdb5"), 13, accent, 2))
	if tooltip != "":
		add_hover_detail(panel, tooltip)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	panel.add_child(box)
	box.add_child(label(title_text, 17, accent))
	for line_text in lines:
		var line := label("• " + str(line_text), 15, Color("#4c4941"))
		line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		box.add_child(line)
	return panel


func show_weekly_report() -> void:
	var report: Dictionary = state.get("last_weekly_report", {})
	if report.is_empty():
		show_notice("Первая недельная сводка появится после завершения текущего хода.")
		return
	play_game_sound("week")
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(920, 660)
	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(890, 0)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	scroll.add_child(content)
	content.add_child(label("СВОДКА ЗА %d-Ю НЕДЕЛЮ" % int(report.get("week", 0)), 28, INK, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label("Главные итоги вынесены наверх; подробности решений распределены ниже по категориям.", 14, Color("#6f6557"), HORIZONTAL_ALIGNMENT_CENTER))
	var total_lines: Array = report.get("totals", [])
	if not total_lines.is_empty():
		content.add_child(weekly_report_panel("СУММАРНО ЗА НЕДЕЛЮ", total_lines, Color("#6f3e37")))
	var overview := GridContainer.new()
	overview.columns = 2
	overview.add_theme_constant_override("h_separation", 12)
	overview.add_theme_constant_override("v_separation", 12)
	content.add_child(overview)
	var money_change := float(report.get("closing_money", 0.0)) - float(report.get("opening_money", 0.0))
	var money_lines: Array = [
		"Казна: %.2f → %.2f млн (%+.2f)" % [float(report.get("opening_money", 0.0)), float(report.get("closing_money", 0.0)), money_change],
		"Доходы +%.2f млн • расходы −%.2f млн" % [float(report.get("income", 0.0)), float(report.get("expenses", 0.0))],
		"Государственный долг: %.2f млн" % float(state.get("debt", 0.0))
	]
	overview.add_child(weekly_report_panel("ФИНАНСЫ  ⓘ", money_lines, GOLD, str(report.get("money_tooltip", ""))))
	var recruited := int(report.get("recruited", 0))
	var personnel_line := "Принято %s" % format_people(recruited) if recruited > 0 else "Демобилизовано %s" % format_people(absi(recruited)) if recruited < 0 else "Численность без изменений"
	var army_lines: Array = [
		personnel_line + " • техника +%d" % int(report.get("equipment", 0)),
		"Личный состав: %s" % format_people(int(state.get("army_personnel", 0))),
		"Боеспособность %d%% • снабжение %d%%" % [army_effectiveness(), army_supply()]
	]
	var recruitment_detail: Dictionary = report.get("recruitment", {})
	if int(recruitment_detail.get("evaders", 0)) > 0:
		army_lines.append("Уклонились от призыва: %s" % format_people(int(recruitment_detail.get("evaders", 0))))
	if int(recruitment_detail.get("deserters", 0)) > 0:
		army_lines.append("Дезертировали: %s" % format_people(int(recruitment_detail.get("deserters", 0))))
	overview.add_child(weekly_report_panel("АРМИЯ", army_lines, BLUE))
	var sections := weekly_report_sections(report)
	var section_order: Array[Dictionary] = [
		{"key": "decisions", "title": "ПРИНЯТЫЕ РЕШЕНИЯ", "color": Color("#6f3e37")},
		{"key": "finance", "title": "ФИНАНСЫ И БЮДЖЕТ", "color": GOLD},
		{"key": "society", "title": "ОБЩЕСТВО И РЕАКЦИЯ НА ФИНАНСИРОВАНИЕ", "color": GREEN},
		{"key": "groups", "title": "КЛАНЫ И ВНУТРЕННИЕ ГРУППЫ", "color": Color("#7c6688")},
		{"key": "security", "title": "АРМИЯ И БЕЗОПАСНОСТЬ", "color": RED},
		{"key": "foreign", "title": "ВНЕШНЯЯ ПОЛИТИКА", "color": BLUE}
	]
	for section_data in section_order:
		var lines: Array = sections.get(str(section_data["key"]), [])
		if lines.is_empty():
			continue
		content.add_child(weekly_report_panel(str(section_data["title"]), lines, section_data["color"]))
	if str(report.get("monthly", "")) != "":
		content.add_child(weekly_report_panel("НАСЕЛЕНИЕ", [str(report.get("monthly", ""))], Color("#7c6688")))
	var close := menu_button("ПЕРЕЙТИ К ДОКЛАДУ НОВОЙ НЕДЕЛИ")
	close.pressed.connect(close_overlay)
	content.add_child(close)
	show_overlay(scroll, PAPER, false, 980)


func update_projected_main_stat(key: String, title: String, is_money := false) -> void:
	if not stat_labels.has(key):
		return
	var value_label: Label = stat_labels[key]
	if is_money:
		var current_money := float(state.get(key, 0.0))
		var projected_money := projected_pending_float(key)
		var changed := not is_equal_approx(current_money, projected_money)
		value_label.text = "%.1f млн" % projected_money
		value_label.add_theme_color_override("font_color", PENDING_BLUE if changed else CREAM)
		value_label.tooltip_text = pending_value_tooltip(title, "%.2f млн" % current_money, "%.2f млн" % projected_money) if changed else ""
	else:
		var current_value := int(state.get(key, 0))
		var projected_value := projected_pending_value(key)
		var changed := current_value != projected_value
		value_label.text = "%d%%" % projected_value
		value_label.add_theme_color_override("font_color", PENDING_BLUE if changed else CREAM)
		value_label.tooltip_text = pending_value_tooltip(title, "%d%%" % current_value, "%d%%" % projected_value) if changed else ""
	value_label.mouse_default_cursor_shape = Control.CURSOR_HELP if value_label.tooltip_text != "" else Control.CURSOR_ARROW


func main_stat_caption_color(key: String) -> Color:
	match key:
		"money":
			var projected_money := projected_pending_float("money")
			var weekly_expenses := maxf(weekly_actual_expenses(), 0.01)
			if weekly_balance_forecast() <= 0.0 or projected_money <= weekly_expenses * 2.0:
				return RED
			if projected_money >= weekly_expenses * 6.0:
				return GREEN
		"support":
			var support_value := projected_pending_value("support")
			if support_value <= 40:
				return RED
			if support_value >= 70:
				return GREEN
		"stability":
			var stability_value := projected_pending_value("stability")
			if stability_value <= 30:
				return RED
			if stability_value >= 70:
				return GREEN
		"war_support":
			var war_value := projected_pending_value("war_support")
			if war_value <= 30:
				return RED
			if war_value >= 65:
				return GREEN
	return Color.WHITE


func update_main_stat_caption_colors() -> void:
	for key in ["money", "support", "stability", "war_support"]:
		if not stat_caption_labels.has(key):
			continue
		var caption_label: Label = stat_caption_labels[key]
		caption_label.add_theme_color_override("font_color", main_stat_caption_color(key))


func update_interface() -> void:
	if not is_instance_valid(week_label):
		return
	var displayed_required := events_required_this_week + pending_extra_report_count()
	var report_number := mini(events_resolved_this_week + 1, displayed_required)
	week_label.text = "НЕДЕЛЯ %d • ДОКЛАД %d/%d" % [int(state.week), report_number, displayed_required]
	update_projected_main_stat("money", "Казна", true)
	update_projected_main_stat("support", "Поддержка власти")
	update_projected_main_stat("stability", "Стабильность")
	update_projected_main_stat("war_support", "Поддержка войны")
	update_main_stat_caption_colors()
	update_sidebar_summary()
	influence_label.text = "ОЧКИ РЕШЕНИЙ: %d / %d" % [int(state.influence), weekly_influence_cap()]
	influence_label.tooltip_text = "Финансирование государственного аппарата даёт %d очк. в неделю.%s" % [
		2 if budget_level("budget_admin") == 0 else 4 if budget_level("budget_admin") == 2 else 3,
		(" Высокая стабильность добавляет ещё +1." if high_stability_influence_bonus() > 0 else " При стабильности 70 и выше государство получит ещё +1.")
		+ (" Низкая стабильность отнимает 1." if low_stability_influence_penalty() > 0 else "")
		+ (" Передача протеста губернаторам отнимает 1 очко решений на этой неделе." if regional_administration_influence_penalty() > 0 else "")
	]
	if active_law != "":
		law_button.text = "%s • %d/%d • АВТО −%d ОР/НЕД." % [active_law.to_upper(), law_progress, law_target, law_weekly_cost]
		law_button.tooltip_text = "Подготовка продвигается автоматически при переходе к новой неделе. Нажмите, чтобы посмотреть прогресс или отменить незавершённый законопроект."
	elif law_worked_this_week:
		law_button.text = "ЗАКОН ПРИНЯТ • НОВЫЙ СО СЛЕДУЮЩЕЙ НЕДЕЛИ"
		law_button.tooltip_text = "Аппарат уже завершил законодательный этап на этой неделе. Новый проект можно начать после перехода к следующей неделе."
	else:
		law_button.text = "ПОДГОТОВИТЬ ЗАКОН"
		law_button.tooltip_text = "Выберите законопроект."
	economy_name_label.text = current_minister_name("economy")
	interior_name_label.text = current_minister_name("interior")
	defense_name_label.text = current_minister_name("defense")
	foreign_name_label.text = current_minister_name("foreign")
	update_week_action_button()


func update_week_action_button() -> void:
	if not is_instance_valid(end_week_button):
		return
	var displayed_required := events_required_this_week + pending_extra_report_count()
	end_week_button.tooltip_text = ""
	if week_ready_for_new_week():
		end_week_button.text = "НОВАЯ НЕДЕЛЯ  →"
		end_week_button.disabled = false
		apply_highlighted_week_style(end_week_button, weekly_balance_forecast() <= 0.0)
	elif event_resolved:
		end_week_button.text = "ПРОДОЛЖИТЬ"
		end_week_button.disabled = false
		end_week_button.custom_minimum_size = Vector2(0, 58)
		end_week_button.add_theme_font_size_override("font_size", 15)
		end_week_button.add_theme_color_override("font_color", CREAM)
		end_week_button.add_theme_color_override("font_hover_color", CREAM)
		end_week_button.add_theme_stylebox_override("normal", style(Color("#314856"), 12, BLUE, 2))
		end_week_button.add_theme_stylebox_override("hover", style(Color("#3d596a"), 12, GOLD, 2))
		end_week_button.add_theme_stylebox_override("pressed", style(Color("#263944"), 12, CREAM, 2))
	else:
		end_week_button.text = "ДОКЛАД %d / %d" % [mini(events_resolved_this_week + 1, displayed_required), displayed_required]
		end_week_button.disabled = true
		end_week_button.custom_minimum_size = Vector2(0, 52)
		end_week_button.add_theme_font_size_override("font_size", 13)
		end_week_button.add_theme_color_override("font_disabled_color", Color("#7f8284"))
		end_week_button.add_theme_stylebox_override("disabled", style(Color("#20252a"), 12, Color("#363d44"), 1))


func on_law_button_pressed() -> void:
	if active_law != "":
		show_active_law_controls()
		return
	if law_worked_this_week:
		show_notice("Аппарат уже завершил законодательный этап на этой неделе. Новый законопроект можно начать после перехода к следующей неделе.")
		return
	if int(state.influence) < 1:
		show_notice("Для начала подготовки требуется хотя бы 1 очко решений.")
		return
	show_law_selection()


func show_active_law_controls() -> void:
	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(720, 0)
	content.add_theme_constant_override("separation", 16)
	content.add_child(label("ЗАКОНОПРОЕКТ В РАБОТЕ", 27, INK, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label(active_law, 22, Color("#6f3e37"), HORIZONTAL_ALIGNMENT_CENTER))
	var progress_text := "Готово этапов: %d из %d. Следующий этап будет автоматически выполнен при переходе к новой неделе и потребует %d очк. решений." % [law_progress, law_target, law_weekly_cost]
	var progress_color := Color("#4c4941")
	if active_law == "Чрезвычайные полномочия":
		var lock_reason := emergency_powers_lock_reason()
		if lock_reason != "":
			progress_text = "Готово этапов: %d из %d. Подготовка приостановлена: %s" % [law_progress, law_target, lock_reason]
			progress_color = RED
		else:
			progress_text += " Условия сохраняются: идёт война, стабильность не выше %d%%." % EMERGENCY_POWERS_MAX_STABILITY
	content.add_child(label(progress_text, 17, progress_color, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label("Законопроект можно отменить до завершения. Уже выполненные этапы и потраченные очки решений будут потеряны без возврата.", 15, RED, HORIZONTAL_ALIGNMENT_CENTER))
	var cancel_law_button := menu_button("ОТМЕНИТЬ ЗАКОНОПРОЕКТ")
	cancel_law_button.pressed.connect(cancel_active_law)
	content.add_child(cancel_law_button)
	var back := menu_button("ОСТАВИТЬ В РАБОТЕ")
	back.pressed.connect(close_overlay)
	content.add_child(back)
	show_overlay(content, PAPER, true, 780)


func cancel_active_law(show_feedback := true) -> void:
	if active_law == "":
		return
	var cancelled_name := active_law
	var cancelled_progress := law_progress
	active_law = ""
	law_progress = 0
	law_target = 0
	law_weekly_cost = 1
	close_overlay()
	update_interface()
	autosave_if_iron()
	if show_feedback:
		show_notice("Законопроект «%s» отменён. Потеряно выполненных этапов: %d; потраченные очки решений не возвращены." % [cancelled_name, cancelled_progress])


func law_enacted(law_name: String) -> bool:
	var enacted: Array = state.get("enacted_laws", [])
	return law_name in enacted


func emergency_powers_override_active() -> bool:
	return law_enacted("Чрезвычайные полномочия")


func emergency_powers_lock_reason() -> String:
	if not bool(state.get("at_war", false)):
		return "Чрезвычайные полномочия доступны только во время официально идущей войны."
	if int(state.get("stability", 0)) > EMERGENCY_POWERS_MAX_STABILITY:
		return "Даже во время войны чрезвычайные полномочия доступны только при стабильности не выше %d%%." % EMERGENCY_POWERS_MAX_STABILITY
	return ""


func emergency_powers_effects() -> Dictionary:
	return {
		"support": -6,
		"stability": 6,
		"army": 5,
		"clan_oligarchs": -7,
		"clan_church": -7,
		"clan_workers": -7,
		"clan_regions": -7
	}


func show_law_selection() -> void:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(820, 620)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	scroll.add_child(content)
	content.add_child(label("ПОДГОТОВКА ЗАКОНА", 27, INK, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label("Можно вести только один законопроект. Первый этап оплачивается сразу, остальные автоматически — в начале новых недель. При нехватке очков работа приостанавливается, но не отменяется.", 17, Color("#4c4941"), HORIZONTAL_ALIGNMENT_CENTER))
	if not law_enacted("Антикоррупционное бюро"):
		add_law_option(content, "Антикоррупционное бюро", 3, 2, "Снизит коррупцию на одну категорию, но встревожит элиты.")
	if not bool(state.media_restricted):
		add_law_option(content, "Ограничение СМИ", 2, 1, "Снизит будущие потери поддержки от непопулярных решений примерно на треть, но сразу вызовет политический кризис.")
	else:
		content.add_child(label("Ограничение СМИ уже действует.", 16, RED, HORIZONTAL_ALIGNMENT_CENTER))
	if not law_enacted("Чрезвычайные полномочия"):
		add_law_option(content, "Чрезвычайные полномочия", 2, 1, "Только при войне и стабильности ≤60%. Укрепит порядок и армию, но снизит поддержку и отношения со всеми гражданскими группами.", emergency_powers_lock_reason())
	if str(selected_ministers.get("economy", "radan")) == "radan" and not bool(state.get("raw_sector_privatized", false)):
		add_law_option(content, "Приватизация сырьевого сектора", 3, 1, "Даст быстрые деньги и влияние бизнесу, но навсегда уменьшит доступную добычу нефти и металлов на 2 ед.; коррупционный риск вырастет.")
	if str(selected_ministers.get("economy", "radan")) == "grad" and not bool(state.get("strategic_industry_nationalized", false)):
		add_law_option(content, "Национализация стратегической промышленности", 3, 1, "Усилит контроль над производством, но потребует компенсаций.")
	if not bool(state.get("land_cooperation", false)):
		add_law_option(content, "Земельная кооперация", 2, 1, "Потребует вложений и постепенно укрепит фермеров и регионы.")
	if not bool(state.get("secular_education", false)):
		add_law_option(content, "Светское образование", 2, 1, "Ослабит вдвое и бонусы, и штрафы общественного влияния Церкви, но вызовет конфликт с её иерархами.")
	var cancel := menu_button("ЗАКРЫТЬ")
	cancel.pressed.connect(close_overlay)
	content.add_child(cancel)
	show_overlay(scroll, PAPER, true, 880)


func add_law_option(parent: VBoxContainer, law_name: String, weeks: int, weekly_cost: int, hint: String, locked_reason := "") -> void:
	var button := Button.new()
	button.text = "%s • %d нед. • %d очк. за этап\n%s%s" % [law_name, weeks, weekly_cost, hint, "\nНЕДОСТУПНО: " + locked_reason if locked_reason != "" else ""]
	button.custom_minimum_size = Vector2(0, 82)
	button.add_theme_font_size_override("font_size", 16)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.add_theme_stylebox_override("normal", style(Color("#d8cdb5"), 12, Color("#887b64"), 1))
	button.add_theme_color_override("font_color", INK)
	button.disabled = int(state.get("influence", 0)) < weekly_cost or locked_reason != ""
	button.tooltip_text = locked_reason if locked_reason != "" else hint
	button.pressed.connect(begin_law.bind(law_name, weeks, weekly_cost))
	parent.add_child(button)


func begin_law(law_name: String, weeks: int, weekly_cost: int) -> void:
	if active_law != "":
		show_notice("Сначала завершите уже выбранный законопроект.")
		return
	if law_name == "Чрезвычайные полномочия":
		var lock_reason := emergency_powers_lock_reason()
		if lock_reason != "":
			show_notice(lock_reason)
			return
	if law_worked_this_week:
		show_notice("Аппарат уже завершил законодательный этап на этой неделе.")
		return
	if int(state.get("influence", 0)) < weekly_cost:
		show_notice("Для первого этапа требуется %d очк. решений." % weekly_cost)
		return
	active_law = law_name
	law_target = weeks
	law_weekly_cost = weekly_cost
	law_progress = 0
	law_worked_this_week = false
	close_overlay()
	progress_active_law_stage(true)


func progress_active_law_stage(show_completion_notice := false) -> String:
	if active_law == "":
		return ""
	if law_worked_this_week:
		return ""
	if active_law == "Чрезвычайные полномочия":
		var lock_reason := emergency_powers_lock_reason()
		if lock_reason != "":
			update_interface()
			return "Подготовка закона «%s» приостановлена: %s" % [active_law, lock_reason]
	if int(state.get("influence", 0)) < law_weekly_cost:
		update_interface()
		return "Подготовка закона «%s» приостановлена на этапе %d/%d: нужно %d очк. решений, доступно %d." % [active_law, law_progress, law_target, law_weekly_cost, int(state.get("influence", 0))]
	var law_name := active_law
	var stage_cost := law_weekly_cost
	state.influence = int(state.get("influence", 0)) - stage_cost
	law_progress += 1
	law_worked_this_week = true
	if law_progress >= law_target:
		return finish_law(show_completion_notice)
	update_interface()
	autosave_if_iron()
	return "Подготовка закона «%s» автоматически продвинута до этапа %d/%d; списано %d очк. решений." % [law_name, law_progress, law_target, stage_cost]


func finish_law(show_completion_notice := true) -> String:
	var completed := active_law
	var law_effects: Dictionary = {}
	var previous_corruption_tier := int(state.get("corruption_tier", 0))
	if completed == "Антикоррупционное бюро":
		law_effects = {"corruption_tier": -1, "support": 3, "clan_oligarchs": -10}
	elif completed == "Ограничение СМИ":
		law_effects = {"support": -6, "stability": 5, "army": 3, "west_pressure": 3, "authoritarian": 1, "clan_oligarchs": 7}
		state.media_restricted = true
	elif completed == "Чрезвычайные полномочия":
		law_effects = emergency_powers_effects()
		state.authoritarian = int(state.authoritarian) + 1
	elif completed == "Приватизация сырьевого сектора":
		law_effects = {"money": 35, "corruption_tier": 1, "clan_oligarchs": 15, "clan_workers": -8, "support": -2}
		state.raw_sector_privatized = true
		state.oil_to_army = mini(int(state.get("oil_to_army", 0)), current_oil_output())
		state.metal_to_equipment = mini(int(state.get("metal_to_equipment", 0)), current_metal_output())
	elif completed == "Национализация стратегической промышленности":
		law_effects = {"money": -20, "clan_oligarchs": -18, "clan_workers": 10, "army": 3, "stability": 2}
		state.strategic_industry_nationalized = true
	elif completed == "Земельная кооперация":
		law_effects = {"money": -8, "support": 3, "clan_regions": 12, "clan_oligarchs": -3}
		state.land_cooperation = true
	elif completed == "Светское образование":
		law_effects = {"support": 3, "clan_church": -18, "clan_workers": 5, "west_commitment": 1}
		state.secular_education = true
	law_effects = amplify_decision_effects(law_effects, "general")
	if completed != "Ограничение СМИ":
		law_effects = apply_media_support_filter(law_effects)
	var applied_effects := apply_effects(law_effects)
	var enacted: Array = state.get("enacted_laws", [])
	if not completed in enacted:
		enacted.append(completed)
	state.enacted_laws = enacted
	if completed == "Ограничение СМИ":
		schedule_unrest({"cause": "принятие закона об ограничении СМИ", "kind": "civic", "base_level": 2, "reversible": true, "reversal": "media_law"}, 0)
	elif completed == "Приватизация сырьевого сектора":
		schedule_unrest({"cause": "приватизация сырьевого сектора без трудовых гарантий", "kind": "labor", "labor": true, "base_level": 1, "reversible": false, "condition": "workers_low"}, 0)
	if completed == "Чрезвычайные полномочия" and int(state.get("support", 0)) <= 40:
		state.emergency_powers_protest_pending = true
		state.emergency_powers_protest_due_week = int(state.get("week", 1))
	active_law = ""
	law_progress = 0
	law_target = 0
	law_weekly_cost = 1
	update_interface()
	autosave_if_iron()
	var exact_effects := effects_to_text(law_effects, applied_effects, previous_corruption_tier)
	if completed == "Приватизация сырьевого сектора":
		exact_effects += " • доступная добыча нефти −%d ед. и металлов −%d ед. до конца кампании" % [PRIVATIZED_OIL_OUTPUT_LOSS, PRIVATIZED_METAL_OUTPUT_LOSS]
	var law_tooltip := transaction_tooltip("Денежный эффект закона", float(law_effects.get("money", 0.0)), previous_corruption_tier, "Категория коррупции урезает только положительное поступление от закона; стоимость закона не повышается.") if law_effects.has("money") else ""
	if show_completion_notice:
		if check_terminal_state():
			return "Закон «%s» принят: %s" % [completed, exact_effects]
		show_notice("Закон «%s» принят.\n\nТочные видимые последствия: %s%s" % [completed, exact_effects, "  ⓘ" if law_tooltip != "" else ""], law_tooltip)
	return "Закон «%s» принят автоматически: %s" % [completed, exact_effects]


func foreign_action_used_this_week() -> bool:
	return int(state.get("foreign_action_week", 0)) == int(state.get("week", 1))


func show_foreign_policy() -> void:
	var viewport_size := get_viewport_rect().size
	var overlay_width := minf(1040.0, maxf(680.0, viewport_size.x - 80.0))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, minf(650.0, maxf(420.0, viewport_size.y - 110.0)))
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	scroll.add_child(content)
	content.add_child(label("МЕЖДУНАРОДНАЯ ПОЛИТИКА", 30, INK, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label("У каждого соседа одна из четырёх категорий отношений. Улучшение отношений с одним блоком сразу ухудшает отношения с другим; одновременно поднять оба выше средних нельзя. Враждебные отношения приводят к вторжению при завершении недели.", 15, Color("#4c4941"), HORIZONTAL_ALIGNMENT_CENTER))
	if str(state.get("last_foreign_action", "")) != "":
		content.add_child(label(str(state.get("last_foreign_action", "")), 14, BLUE, HORIZONTAL_ALIGNMENT_CENTER))
	var war_panel := PanelContainer.new()
	war_panel.add_theme_stylebox_override("panel", style(Color("#d8cdb5"), 14, RED if bool(state.get("at_war", false)) else GREEN, 2))
	content.add_child(war_panel)
	var war_box := VBoxContainer.new()
	war_box.add_theme_constant_override("separation", 6)
	war_panel.add_child(war_box)
	if bool(state.get("at_war", false)):
		var quality := army_quality_effectiveness()
		var required := frontline_required_personnel(quality)
		var personnel := int(state.get("army_personnel", 0))
		war_box.add_child(label("ВОЙНА С %s" % neighbor_title(str(state.get("war_enemy", "east"))).to_upper(), 20, RED))
		war_box.add_child(label("Неделя войны: %d • боеспособность фронта: %d%% • качество армии: %d%%" % [int(state.get("war_weeks", 0)), army_effectiveness(), quality], 16, INK))
		war_box.add_child(label("Для удержания фронта нужно не меньше %s военнослужащих; сейчас %s. Чем выше подготовка, техника, авиация и снабжение, тем меньше людей требуется." % [format_people(required), format_people(personnel)], 15, RED if personnel < required else GREEN))
		war_box.add_child(label("Общие военные потери: %s. Последний доклад: %s" % [format_people(int(state.get("war_casualties", 0))), str(state.get("last_war_report", ""))], 14, Color("#5f594d")))
	else:
		war_box.add_child(label("МИРНОЕ ВРЕМЯ", 20, GREEN))
		war_box.add_child(label("При переходе отношений с любым соседом во враждебное состояние начнётся вторжение. До конца недели дипломатическая миссия ещё может улучшить отношения на одну категорию.", 15, Color("#5f594d")))
	var action_status := "Внешнеполитическое действие этой недели уже использовано." if foreign_action_used_this_week() else "Доступно одно внешнеполитическое действие на этой неделе."
	content.add_child(label(action_status, 14, RED if foreign_action_used_this_week() else Color("#6f3e37"), HORIZONTAL_ALIGNMENT_CENTER))
	var dependencies := active_foreign_dependencies()
	var dependency_panel := PanelContainer.new()
	dependency_panel.add_theme_stylebox_override("panel", style(Color("#d8cdb5"), 14, GOLD if not dependencies.is_empty() else Color("#92846c"), 2))
	content.add_child(dependency_panel)
	var dependency_box := VBoxContainer.new()
	dependency_box.add_theme_constant_override("separation", 7)
	dependency_panel.add_child(dependency_box)
	dependency_box.add_child(label("ДЕЙСТВУЮЩИЕ СОГЛАШЕНИЯ И ЗАВИСИМОСТИ", 17, Color("#6f3e37")))
	if dependencies.is_empty():
		dependency_box.add_child(label("Иностранные договоры пока не ограничивают решения правительства.", 14, Color("#5f594d")))
	else:
		for dependency in dependencies:
			var dependency_label := label("• %s — %s  ⓘ" % [str(dependency.get("title", "Соглашение")), str(dependency.get("effect", ""))], 14, dependency.get("color", INK))
			dependency_label.tooltip_text = str(dependency.get("detail", ""))
			dependency_box.add_child(dependency_label)
	var grid := GridContainer.new()
	grid.columns = 2 if overlay_width >= 820.0 else 1
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	content.add_child(grid)
	add_neighbor_policy_card(grid, "east")
	add_neighbor_policy_card(grid, "west")
	var close := menu_button("ВЕРНУТЬСЯ К ДОКЛАДУ")
	close.pressed.connect(close_overlay)
	content.add_child(close)
	show_overlay(scroll, PAPER, true, overlay_width)
	scroll.scroll_vertical = 0
	scroll.set_deferred("scroll_vertical", 0)


func add_neighbor_policy_card(parent: Container, side: String) -> void:
	var current_band := neighbor_relation_band(side)
	var projected_band := neighbor_relation_band(side, true)
	var pending := current_band != projected_band
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", style(Color("#d8cdb5"), 14, neighbor_relation_color(side, true), 2))
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	box.add_child(label(neighbor_title(side).to_upper(), 21, INK))
	var relation_text := "ОТНОШЕНИЯ: %s" % projected_band.to_upper()
	if pending:
		relation_text += " • после недели"
	var relation_label := label(relation_text, 16, PENDING_BLUE if pending else neighbor_relation_color(side, true))
	relation_label.tooltip_text = neighbor_relation_explanation(side, true)
	box.add_child(relation_label)
	box.add_child(label("Недельные внешние издержки из-за текущих отношений: %.2f млн." % neighbor_response_cost(side, true), 14, Color("#5f594d")))
	var enemy_at_war := bool(state.get("at_war", false)) and str(state.get("war_enemy", "")) == side
	if enemy_at_war:
		box.add_child(label("С этим государством идёт война. Обычные дипломатические действия недоступны.", 14, RED))
	var mission_cost := 2 if str(selected_ministers.get("foreign", "narin")) == "narin" else 3
	var mission := foreign_policy_button("МИССИЯ • −%d МЛН • 1 ОЧК." % mission_cost)
	mission.disabled = foreign_action_used_this_week() or int(state.get("influence", 0)) < 1 or enemy_at_war or projected_pending_value(side + "_relation") >= 3
	mission.tooltip_text = "Отношения с государством-противником нельзя улучшать, пока продолжается война." if enemy_at_war else "Дипломатическая миссия улучшит отношения с этим соседом на одну категорию и ухудшит отношения с другим на одну категорию при завершении недели. Расход составит ровно %d млн; коррупция его не увеличивает.%s" % [mission_cost, " С министром Леей Нарин миссия дешевле на 1 млн." if mission_cost == 2 else ""]
	mission.pressed.connect(perform_foreign_action.bind(side, "mission"))
	box.add_child(mission)
	var concession_income := adjusted_money_transaction(10.0, projected_corruption_tier())
	var concession_data := foreign_concession_data(side)
	var concession := foreign_policy_button("%s • +%.2f МЛН • 1 ОЧК." % [str(concession_data["button"]), concession_income])
	concession.disabled = foreign_action_used_this_week() or int(state.get("influence", 0)) < 1 or enemy_at_war or bool(state.get(side + "_concession_signed", false))
	var permanent_cost := "Доступная добыча нефти: −4 ед. в неделю до конца кампании" if side == "east" else "Недельные расходы: −0.60 млн до конца кампании"
	concession.tooltip_text = "%s\n\nПОСЛЕДСТВИЯ ПРИ ЗАВЕРШЕНИИ НЕДЕЛИ\nКазна: +%.2f млн\nПоддержка власти: −2\n%s\nОтношения с этим соседом улучшатся на одну категорию, с другим — ухудшатся на одну категорию\nЦена действия: 1 очко решений\n\n%s" % [str(concession_data["detail"]), concession_income, permanent_cost, transaction_tooltip("Доход от соглашения", 10.0, projected_corruption_tier(), "Разовый платёж 10 млн до потерь от коррупции")]
	if enemy_at_war:
		concession.tooltip_text = "Экономические уступки государству-противнику недоступны, пока продолжается война."
	concession.pressed.connect(perform_foreign_action.bind(side, "concession"))
	box.add_child(concession)
	var aid := foreign_policy_button("ВОЕННАЯ ПОМОЩЬ • 1 ОЧК.")
	var partner := neighbor_relation_band(side, true) == "партнёрские"
	var aid_received := bool(state.get(side + "_wartime_aid_received", false))
	aid.disabled = foreign_action_used_this_week() or int(state.get("influence", 0)) < 1 or not bool(state.get("at_war", false)) or enemy_at_war or not partner or aid_received
	aid.tooltip_text = "Только партнёрский сосед, не участвующий во вторжении, может один раз передать 24 единицы наземной техники и 2 самолёта. Политическая цена — снижение поддержки власти."
	aid.pressed.connect(perform_foreign_action.bind(side, "aid"))
	box.add_child(aid)


func foreign_policy_button(text_value: String) -> Button:
	var button := menu_button(text_value)
	button.custom_minimum_size = Vector2(0, 62)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return button


func perform_foreign_action(side: String, action: String) -> void:
	if side not in ["east", "west"] or foreign_action_used_this_week() or int(state.get("influence", 0)) < 1:
		show_notice("Внешнеполитическое действие на этой неделе недоступно.")
		return
	var enemy_at_war := bool(state.get("at_war", false)) and str(state.get("war_enemy", "")) == side
	var effects: Dictionary = {}
	var flags: Dictionary = {}
	var description := ""
	if action == "mission":
		if enemy_at_war or projected_pending_value(side + "_relation") >= 3:
			show_notice("Дипломатическая миссия сейчас не сможет изменить положение.")
			return
		var mission_cost := 2 if str(selected_ministers.get("foreign", "narin")) == "narin" else 3
		effects = {"money": -mission_cost}
		merge_numeric_effects(effects, relation_shift_effect(side, 1))
		description = "Миссия в государство «%s» улучшит отношения на одну категорию; другой сосед отреагирует ухудшением отношений." % neighbor_title(side)
	elif action == "concession":
		if enemy_at_war or bool(state.get(side + "_concession_signed", false)):
			show_notice("Эта экономическая уступка недоступна.")
			return
		var concession_data := foreign_concession_data(side)
		effects = {"money": 10, "support": -2}
		merge_numeric_effects(effects, relation_shift_effect(side, 1))
		flags[side + "_concession_signed"] = true
		flags["east_border_oil_concession" if side == "east" else "west_investment_arbitration"] = true
		description = str(concession_data["result"])
	elif action == "aid":
		if not bool(state.get("at_war", false)) or enemy_at_war or neighbor_relation_band(side, true) != "партнёрские" or bool(state.get(side + "_wartime_aid_received", false)):
			show_notice("Военная помощь этого соседа сейчас недоступна.")
			return
		effects = {"army_equipment": 24, "army_aircraft": 2, "support": -2}
		flags[side + "_wartime_aid_received"] = true
		description = "%s согласился передать военную помощь; техника поступит при завершении недели." % neighbor_title(side)
	else:
		return
	effects = apply_media_support_filter(effects)
	state.influence = int(state.get("influence", 0)) - 1
	state.foreign_action_week = int(state.get("week", 1))
	queue_week_change("Внешняя политика: %s" % neighbor_title(side), effects, flags)
	state.last_foreign_action = description
	update_interface()
	autosave_if_iron()
	show_foreign_policy()


func show_clans() -> void:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(980, 620)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	scroll.add_child(content)
	content.add_child(label("КЛАНЫ И ВНУТРЕННИЕ ГРУППЫ", 30, INK, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label("Отношения имеют пять состояний. Армия показана здесь как отдельный центр силы; подробное снабжение и производство остаются во вкладке «Армия». Наведите мышь для всех порогов. ⓘ", 16, Color("#4c4941"), HORIZONTAL_ALIGNMENT_CENTER))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	content.add_child(grid)
	add_clan_card(grid, "clan_oligarchs", "ОЛИГАРХИ")
	add_clan_card(grid, "clan_church", "ЦЕРКОВЬ ВЕРЫ")
	add_clan_card(grid, "clan_workers", "РАБОЧИЕ И ПРОФСОЮЗЫ")
	add_clan_card(grid, "clan_regions", "ФЕРМЕРЫ И РЕГИОНЫ")
	add_army_group_card(content)
	var close := menu_button("ВЕРНУТЬСЯ К ДОКЛАДУ")
	close.pressed.connect(close_overlay)
	content.add_child(close)
	show_overlay(scroll, PAPER, true, 1040)


func add_clan_card(parent: Container, key: String, title: String) -> void:
	var current_value := int(state.get(key, 50))
	var value := projected_pending_value(key)
	var pending := value != current_value
	var status_color := GREEN if value >= CLAN_HIGH_SUPPORT else RED if value <= CLAN_LOW_SUPPORT else Color("#6f5b32")
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(470, 128)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", style(Color("#d8cdb5"), 14, Color(status_color, 0.8), 2))
	var detail := "КРИТИЧЕСКАЯ ПОДДЕРЖКА — %d–100%%\n%s\n\nВЫСОКАЯ ПОДДЕРЖКА — %d–%d%%\n%s\n\nНЕЙТРАЛЬНАЯ ПОЗИЦИЯ — %d–%d%%\n%s\n\nНИЗКАЯ ПОДДЕРЖКА — %d–%d%%\n%s\n\nОТКРЫТАЯ ВРАЖДЕБНОСТЬ — 0–%d%%\n%s" % [
		CLAN_CRITICAL_HIGH_SUPPORT,
		clan_full_effect_description(key, CLAN_CRITICAL_HIGH_SUPPORT),
		CLAN_HIGH_SUPPORT,
		CLAN_CRITICAL_HIGH_SUPPORT - 1,
		clan_full_effect_description(key, CLAN_HIGH_SUPPORT),
		CLAN_LOW_SUPPORT + 1,
		CLAN_HIGH_SUPPORT - 1,
		clan_full_effect_description(key, 50),
		CLAN_CRITICAL_LOW_SUPPORT + 1,
		CLAN_LOW_SUPPORT,
		clan_full_effect_description(key, CLAN_LOW_SUPPORT),
		CLAN_CRITICAL_LOW_SUPPORT,
		clan_full_effect_description(key, CLAN_CRITICAL_LOW_SUPPORT)
	]
	if pending:
		detail = pending_value_tooltip(title.capitalize(), "%d%%" % current_value, "%d%%" % value) + "\n\n" + detail
	add_hover_detail(panel, detail)
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 5)
	panel.add_child(box)
	var title_text := label(title, 16, Color("#6f3e37"))
	add_hover_detail(title_text, detail)
	box.add_child(title_text)
	var value_text := label("%d%% • %s  ⓘ" % [value, clan_band(value)], 22, PENDING_BLUE if pending else INK)
	add_hover_detail(value_text, detail)
	box.add_child(value_text)
	var active_text := ("ПОСЛЕ НЕДЕЛИ: " if pending else "СЕЙЧАС: ") + clan_full_effect_description(key, value)
	var active_label := label(active_text, 14, PENDING_BLUE if pending else status_color)
	add_hover_detail(active_label, detail)
	box.add_child(active_label)


func add_army_group_card(parent: Container) -> void:
	var current_value := int(state.get("army", 50))
	var value := projected_pending_value("army")
	var pending := value != current_value
	var status_color := GREEN if value >= 65 else RED if value <= 40 else Color("#6f5b32")
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(470, 128)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", style(Color("#d8cdb5"), 14, Color(status_color, 0.8), 2))
	var detail := "КРИТИЧЕСКАЯ ЛОЯЛЬНОСТЬ — 80–100%%\n%s\n\nВЫСОКАЯ ЛОЯЛЬНОСТЬ — 65–79%%\n%s\n\nНЕУСТОЙЧИВАЯ ЛОЯЛЬНОСТЬ — 41–64%%\n%s\n\nНИЗКАЯ ЛОЯЛЬНОСТЬ — 21–40%%\n%s\n\nУГРОЗА ПЕРЕВОРОТА — 0–20%%\n%s\n\nЛояльность отражает политическое отношение командования. Численность, техника, авиация, призыв, производство и снабжение находятся в отдельной вкладке «Армия»." % [
		army_group_effect_description(80),
		army_group_effect_description(65),
		army_group_effect_description(50),
		army_group_effect_description(40),
		army_group_effect_description(20)
	]
	if pending:
		detail = pending_value_tooltip("Лояльность армии", "%d%%" % current_value, "%d%%" % value) + "\n\n" + detail
	add_hover_detail(panel, detail)
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 5)
	panel.add_child(box)
	var title_text := label("АРМИЯ И КОМАНДОВАНИЕ", 16, Color("#6f3e37"))
	add_hover_detail(title_text, detail)
	box.add_child(title_text)
	var value_text := label("%d%% • %s  ⓘ" % [value, army_group_band(value)], 22, PENDING_BLUE if pending else INK)
	add_hover_detail(value_text, detail)
	box.add_child(value_text)
	var active_label := label(("ПОСЛЕ НЕДЕЛИ: " if pending else "СЕЙЧАС: ") + army_group_effect_description(value), 14, PENDING_BLUE if pending else status_color)
	add_hover_detail(active_label, detail)
	box.add_child(active_label)


func show_economy(scroll_position := 0) -> void:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(980, 650)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 13)
	scroll.add_child(content)
	content.add_child(label("ЭКОНОМИКА И БЮДЖЕТ", 30, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var tier := int(state.get("corruption_tier", 0))
	var rate := corruption_transaction_rate(tier)
	var actual_income := weekly_actual_income()
	var actual_expenses := weekly_actual_expenses()
	var weekly_delta := actual_income - actual_expenses
	var forecast := weekly_balance_forecast()
	var summary := PanelContainer.new()
	summary.add_theme_stylebox_override("panel", style(Color("#d8cdb5"), 14, Color("#92846c"), 1))
	content.add_child(summary)
	var summary_box := VBoxContainer.new()
	summary_box.add_theme_constant_override("separation", 5)
	summary.add_child(summary_box)
	summary_box.add_child(label("КАЗНА: %.2f млн • ГОСДОЛГ: %.2f млн" % [float(state.get("money", 0.0)), float(state.get("debt", 0.0))], 23, INK))
	var projected_money := projected_pending_float("money")
	var projected_debt := projected_pending_float("debt")
	var projected_tier := projected_corruption_tier()
	var current_creditor_level := int(state.get("creditor_obligations", 0))
	var projected_creditor_level := projected_pending_value("creditor_obligations")
	var economy_pending := (
		not is_equal_approx(projected_money, float(state.get("money", 0.0)))
		or not is_equal_approx(projected_debt, float(state.get("debt", 0.0)))
		or projected_tier != tier
		or projected_creditor_level != current_creditor_level
	)
	if economy_pending:
		var pending_economy := label("ПОСЛЕ ПРИНЯТЫХ РЕШЕНИЙ: казна %.2f млн • долг %.2f млн • коррупция %s • кредиторы %s  ⓘ" % [projected_money, projected_debt, corruption_level(projected_tier), creditor_obligation_level(projected_creditor_level)], 16, PENDING_BLUE)
		pending_economy.tooltip_text = "Голубые значения уже зафиксированы решениями этой недели, но будут применены только при переходе к следующей. Регулярные недельные доходы, расходы и пороговые эффекты рассчитываются отдельно."
		summary_box.add_child(pending_economy)
	var corruption_info := label("Коррупция: %s ⓘ" % corruption_level(tier), 16, Color("#5f594d"))
	corruption_info.tooltip_text = "Категория урезает все поступления в казну на %d%%. Расходы, стоимость решений и рыночные цены она не увеличивает. Коррупция не снимает отдельную фиксированную сумму и не уменьшает очки решений." % rate
	summary_box.add_child(corruption_info)
	var creditor_level := int(state.get("creditor_obligations", 0))
	var creditor_info := label("Международные кредиторы: %s ⓘ" % creditor_obligation_level(creditor_level), 16, Color("#5f594d"))
	var creditor_detail := "Текущие комиссии и надзор: %.2f млн в неделю. Сокращённое обслуживание долга ужесточает условия на одну категорию. Четыре недели подряд приоритетных выплат смягчают их на одну категорию." % creditor_oversight_cost()
	if bool(state.get("creditor_review_pending", false)):
		creditor_detail += "\nПроверка условий кредитной линии назначена на %d-ю неделю." % int(state.get("creditor_review_due_week", 0))
	if creditor_budget_lock_active():
		creditor_detail += "\n" + creditor_budget_lock_message(str(state.get("creditor_budget_lock_key", "")))
	creditor_info.tooltip_text = creditor_detail
	summary_box.add_child(creditor_info)
	var unrest_level := int(state.get("active_unrest_level", 0))
	if unrest_level > 0:
		var labor_unrest := bool(state.get("active_unrest_labor", false))
		var unrest_info := label("%s: стабильность −%d за неделю%s  ⓘ" % [unrest_level_title(unrest_level, labor_unrest).capitalize(), unrest_stability_loss(unrest_level), " • доходы сокращены" if labor_unrest else ""], 16, RED)
		unrest_info.tooltip_text = "Причина: %s. Последствия рассчитываются при завершении недели.%s" % [str(state.get("active_unrest_cause", "")), " Участники забастовки временно не считаются вышедшими на работу: точный итог уже учтён в карточках недельных доходов ниже." if labor_unrest else ""]
		summary_box.add_child(unrest_info)
	var balance_line := label("ИТОГО ЗА НЕДЕЛЮ: доходы %.2f млн • расходы %.2f млн • баланс %+.2f млн ⓘ" % [actual_income, actual_expenses, weekly_delta], 17, Color("#6f3e37"))
	balance_line.tooltip_text = "Наведите на отдельную статью ниже, чтобы увидеть её полный расчёт."
	summary_box.add_child(balance_line)
	var forecast_line := label("ПРОГНОЗ КАЗНЫ: 1 нед. %.2f млн • 4 нед. %.2f млн • 13 нед. %.2f млн ⓘ" % [forecast, float(state.get("money", 0.0)) + weekly_delta * 4.0, float(state.get("money", 0.0)) + weekly_delta * 13.0], 17, RED if forecast <= 0.0 else Color("#3f6248"))
	forecast_line.tooltip_text = "Прогноз использует текущие доходы и расходы и предполагает, что бюджет, население, набор, цены и события не изменятся."
	summary_box.add_child(forecast_line)
	if state.has("last_budget_change"):
		var budget_change := label(str(state.last_budget_change) + "  ⓘ", 14, BLUE)
		budget_change.tooltip_text = str(state.get("last_budget_change_detail", ""))
		summary_box.add_child(budget_change)
	content.add_child(label("НЕДЕЛЬНЫЕ ДОХОДЫ", 15, Color("#6f3e37")))
	var income_grid := GridContainer.new()
	income_grid.columns = 2
	income_grid.add_theme_constant_override("h_separation", 10)
	income_grid.add_theme_constant_override("v_separation", 8)
	content.add_child(income_grid)
	for income_item in weekly_income_breakdown():
		add_income_card(income_grid, income_item, tier)
	var clan_flow := weekly_clan_money_flow()
	if clan_flow > 0.0:
		add_income_card(income_grid, {"title": "Эффект олигархов", "amount": clan_flow, "calculation": "Пороговый эффект текущей поддержки олигархов"}, tier)
	content.add_child(label("РЕГУЛИРУЕМЫЕ НЕДЕЛЬНЫЕ РАСХОДЫ", 15, Color("#6f3e37")))
	content.add_child(label("Нажмите на статью, чтобы сравнить три уровня расходов, их последствия и реакцию парламента. Все выбранные уровни сохраняются в одном черновике.", 14, Color("#5f594d")))
	var budget_icon_grid := GridContainer.new()
	budget_icon_grid.columns = 3
	budget_icon_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	budget_icon_grid.add_theme_constant_override("h_separation", 12)
	budget_icon_grid.add_theme_constant_override("v_separation", 12)
	content.add_child(budget_icon_grid)
	for item in WEEKLY_BUDGET_LINES:
		add_budget_icon_card(budget_icon_grid, item, tier)
	add_budget_vote_panel(content)
	var nonbudget_expenses := weekly_nonbudget_expense_breakdown()
	if not nonbudget_expenses.is_empty() or clan_flow < 0.0:
		content.add_child(label("ПРОЧИЕ НЕДЕЛЬНЫЕ РАСХОДЫ", 15, Color("#6f3e37")))
		var expense_grid := GridContainer.new()
		expense_grid.columns = 2
		expense_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		expense_grid.add_theme_constant_override("h_separation", 12)
		expense_grid.add_theme_constant_override("v_separation", 10)
		content.add_child(expense_grid)
		for item in nonbudget_expenses:
			add_income_card(expense_grid, item, tier)
		if clan_flow < 0.0:
			add_income_card(expense_grid, {"title": "Давление олигархов", "amount": clan_flow, "calculation": "Пороговый эффект низкой поддержки олигархов"}, tier)
	content.add_child(label("РЕСУРСЫ ЭТОЙ НЕДЕЛИ", 15, Color("#6f3e37")))
	var resource_hint := label("Нефть и металл текущей недели: распределите внутреннее использование, остаток продастся автоматически. ⓘ", 14, Color("#5f594d"))
	resource_hint.tooltip_text = "Ресурсы нельзя сохранять про запас. Металл внутри страны используется только для наземной техники. Авиацию республика не производит: её можно лишь купить или получить в событиях."
	content.add_child(resource_hint)
	var oil_export_gross := float(exported_oil()) * current_oil_price()
	var oil_export_final := adjusted_money_transaction(oil_export_gross, tier)
	add_resource_row(content, "oil_to_army", "НЕФТЬ → СНАБЖЕНИЕ АРМИИ", int(state.get("oil_to_army", 0)), current_oil_output(), "Экспортный доход: %.2f млн" % oil_export_final, transaction_tooltip("Экспорт нефти", oil_export_gross, tier, "%d ед. на экспорт × %.2f млн за единицу • %s" % [exported_oil(), current_oil_price(), oil_output_reduction_note()]))
	add_resource_row(content, "metal_to_equipment", "МЕТАЛЛ → НАЗЕМНАЯ ТЕХНИКА", int(state.get("metal_to_equipment", 0)), current_metal_output(), "Выпуск +%d ед. • нагрузка на баланс %.2f млн" % [equipment_production_per_week(), equipment_balance_load(tier)], equipment_production_tooltip(tier))
	if int(state.get("metal_price_weeks", 0)) > 0 or int(state.get("oil_price_weeks", 0)) > 0:
		var price_alert := label("ЦЕНЫ НА СЫРЬЁ ВРЕМЕННО ИЗМЕНЕНЫ ⓘ", 14, RED)
		price_alert.tooltip_text = "Текущая цена нефти: %.2f млн/ед. • осталось %d нед.\nТекущая цена металла: %.2f млн/ед. • осталось %d нед.\nДоход после коррупции показан в соответствующих статьях." % [current_oil_price(), int(state.get("oil_price_weeks", 0)), current_metal_price(), int(state.get("metal_price_weeks", 0))]
		content.add_child(price_alert)
	var close := menu_button("ВЕРНУТЬСЯ К ДОКЛАДУ")
	close.pressed.connect(close_overlay)
	content.add_child(close)
	show_overlay(scroll, PAPER, true, 1040)
	restore_overlay_scroll_position(scroll, scroll_position)


func add_income_card(parent: Container, item: Dictionary, corruption_tier: int) -> void:
	var gross := float(item.get("amount", 0.0))
	var actual := adjusted_money_transaction(gross, corruption_tier)
	var detail := transaction_tooltip(str(item.get("title", "Доход")), gross, corruption_tier, str(item.get("calculation", "")))
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", style(Color("#ded4bf"), 10, Color("#9a8c73"), 1))
	add_hover_detail(panel, detail)
	parent.add_child(panel)
	var operation_text := "%s: %.2f млн%s ⓘ" % [str(item.get("title", "Операция")), absf(actual), " расход" if actual < 0.0 else " доход"]
	var operation_label := label(operation_text, 14, INK)
	add_hover_detail(operation_label, detail)
	panel.add_child(operation_label)


func budget_icon_color(key: String) -> Color:
	match key:
		"budget_social":
			return GOLD
		"budget_health":
			return GREEN
		"budget_admin":
			return BLUE
		"budget_defense":
			return RED
		"budget_debt":
			return Color("#8b6c4b")
		"budget_infrastructure":
			return Color("#6f7b5f")
	return Color("#8f826b")


func budget_item_by_key(key: String) -> Dictionary:
	for item in WEEKLY_BUDGET_LINES:
		if str(item.get("key", "")) == key:
			return item
	return {}


func add_budget_icon_card(parent: Container, item: Dictionary, corruption_tier: int) -> void:
	var key := str(item["key"])
	var current_level := budget_level(key)
	var draft_level := draft_budget_level(key)
	var draft_amount := budget_final_for_level(key, draft_level, corruption_tier)
	var accent := budget_icon_color(key)
	var button := Button.new()
	button.name = "BudgetIcon_" + key
	button.custom_minimum_size = Vector2(0, 178)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_stylebox_override("normal", style(Color("#d8cdb5"), 12, GOLD if draft_level != current_level else accent, 2 if draft_level == current_level else 3))
	button.add_theme_stylebox_override("hover", style(Color("#e2d8c3"), 12, GOLD, 3))
	button.add_theme_stylebox_override("pressed", style(Color("#c9bea6"), 12, accent, 3))
	button.tooltip_text = budget_breakdown_tooltip(item, corruption_tier) + "\n\nНажмите, чтобы сравнить все три уровня и выбрать новый."
	button.pressed.connect(func(): show_budget_level_selector(key, current_overlay_scroll_position()))
	parent.add_child(button)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side_name in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side_name, 10)
	margin.add_theme_constant_override("margin_top", 9)
	margin.add_theme_constant_override("margin_bottom", 9)
	button.add_child(margin)
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 3)
	margin.add_child(box)
	var icon := BudgetIconArt.new()
	icon.custom_minimum_size = Vector2(64, 64)
	icon.setup(key, accent)
	box.add_child(icon)
	box.add_child(label(str(item["title"]).to_upper(), 13, Color("#5b4038"), HORIZONTAL_ALIGNMENT_CENTER))
	var level_caption: String = str(BUDGET_LEVEL_NAMES[draft_level]).to_upper()
	if draft_level != current_level:
		level_caption = "%s  →  %s" % [BUDGET_LEVEL_NAMES[current_level].to_upper(), level_caption]
	box.add_child(label(level_caption, 12, RED if draft_level != current_level else Color("#5f594d"), HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(label("%.2f МЛН / НЕД." % draft_amount, 16, INK, HORIZONTAL_ALIGNMENT_CENTER))


func budget_reaction_preview(key: String, delta: int) -> String:
	if delta == 0:
		return "Немедленно после принятия: без изменений."
	var reaction := budget_reaction_for_change(key, delta)
	if reaction.is_empty():
		return "Немедленно после принятия: реакции групп и показателей нет."
	var names := {
		"support": "поддержка власти", "stability": "стабильность",
		"army": "лояльность армии", "war_support": "поддержка войны",
		"clan_workers": "профсоюзы", "clan_regions": "регионы"
	}
	var parts: Array[String] = []
	for effect_key in reaction.keys():
		var value := int(reaction[effect_key])
		parts.append("%s %s%d" % [str(names.get(effect_key, effect_key)), "+" if value > 0 else "−", absi(value)])
	return "Немедленно после принятия: " + ", ".join(parts) + "."


func budget_parliament_preview(key: String, delta: int) -> String:
	if delta == 0:
		return "Парламент: эта статья остаётся без изменений."
	var modifiers := budget_parliament_modifiers(key, delta)
	var faction_names := {
		"center": "Президентский центр", "guard": "Старая гвардия",
		"regions": "Региональный список", "civic": "Гражданская коалиция"
	}
	var parts: Array[String] = []
	for faction_key in ["center", "guard", "regions", "civic"]:
		var value := int(modifiers.get(faction_key, 0)) * absi(delta)
		if value != 0:
			parts.append("%s %s%d" % [str(faction_names[faction_key]), "+" if value > 0 else "−", absi(value)])
	return "Сдвиг позиций фракций: " + (", ".join(parts) if not parts.is_empty() else "нейтрально") + "."


func show_budget_level_selector(key: String, economy_scroll_position := 0) -> void:
	var item := budget_item_by_key(key)
	if item.is_empty():
		return
	var corruption_tier := int(state.get("corruption_tier", 0))
	var current_level := budget_level(key)
	var selected_level := draft_budget_level(key)
	var modal := VBoxContainer.new()
	modal.custom_minimum_size = Vector2(980, 0)
	modal.add_theme_constant_override("separation", 12)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(980, 505)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	modal.add_child(scroll)
	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(930, 0)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 7)
	scroll.add_child(content)
	content.add_child(label(str(item["title"]).to_upper(), 26, INK, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label(str(item.get("impact", "")), 14, Color("#5f594d"), HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label("Действует: %s • в черновике: %s. Изменения вступят в силу после чрезвычайного указа." % [BUDGET_LEVEL_NAMES[current_level], BUDGET_LEVEL_NAMES[selected_level]] if emergency_powers_override_active() else "Действует: %s • в черновике: %s. Изменения вступят в силу после голосования." % [BUDGET_LEVEL_NAMES[current_level], BUDGET_LEVEL_NAMES[selected_level]], 13, Color("#6f3e37"), HORIZONTAL_ALIGNMENT_CENTER))
	var levels_grid := GridContainer.new()
	levels_grid.columns = 3
	levels_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	levels_grid.add_theme_constant_override("h_separation", 12)
	content.add_child(levels_grid)
	for level in range(3):
		add_budget_level_choice(levels_grid, item, level, corruption_tier, economy_scroll_position)
	var back := menu_button("ВЕРНУТЬСЯ К БЮДЖЕТУ")
	back.pressed.connect(show_economy.bind(economy_scroll_position))
	modal.add_child(back)
	show_overlay(modal, PAPER, true, 1040)


func add_budget_level_choice(parent: Container, item: Dictionary, level: int, corruption_tier: int, economy_scroll_position: int) -> void:
	var key := str(item["key"])
	var current_level := budget_level(key)
	var selected_level := draft_budget_level(key)
	var delta := level - current_level
	var amount := budget_final_for_level(key, level, corruption_tier)
	var current_amount := budget_final_for_level(key, current_level, corruption_tier)
	var accent := GOLD if level == selected_level else BLUE if level == current_level else Color("#9a8c73")
	var panel := PanelContainer.new()
	panel.name = "BudgetLevel_%d" % level
	panel.custom_minimum_size = Vector2(292, 320)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", style(Color("#ded4bf"), 13, accent, 3 if level == selected_level else 1))
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)
	var status_parts: Array[String] = []
	if level == current_level:
		status_parts.append("ДЕЙСТВУЮЩИЙ")
	if level == selected_level:
		status_parts.append("В ЧЕРНОВИКЕ")
	box.add_child(label(BUDGET_LEVEL_NAMES[level].to_upper(), 17, Color("#6f3e37"), HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(label(" • ".join(status_parts) if not status_parts.is_empty() else " ", 11, accent, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(label("%.2f МЛН В НЕДЕЛЮ" % amount, 18, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var amount_delta := amount - current_amount
	var delta_text := "Расход не изменится."
	if amount_delta > 0.001:
		delta_text = "Расход вырастет на %.2f млн в неделю." % amount_delta
	elif amount_delta < -0.001:
		delta_text = "Экономия составит %.2f млн в неделю." % absf(amount_delta)
	box.add_child(label(delta_text, 12, Color("#5f594d"), HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(HSeparator.new())
	box.add_child(label(budget_level_consequence_text(key, level), 12, INK))
	box.add_child(label(budget_reaction_preview(key, delta), 12, Color("#5b4038")))
	box.add_child(label(budget_parliament_preview(key, delta), 11, Color("#4f6170")))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)
	var amendment_cost := absi(delta)
	box.add_child(label("Цена поправки: %d очк. решений." % amendment_cost, 11, Color("#5f594d"), HORIZONTAL_ALIGNMENT_CENTER))
	var concession_locked := key == "budget_social" and level == 0 and social_budget_reduction_locked()
	if concession_locked:
		box.add_child(label("НЕДОСТУПНО: после уступки протестующим выплаты нельзя сокращать ещё %d нед." % social_budget_lock_weeks_left(), 11, RED, HORIZONTAL_ALIGNMENT_CENTER))
	var creditor_locked := not creditor_budget_change_allowed(key, level)
	if creditor_locked:
		box.add_child(label("НЕДОСТУПНО: " + creditor_budget_lock_message(key), 11, RED, HORIZONTAL_ALIGNMENT_CENTER))
	var choose := small_button("ВЫБРАТЬ" if level != selected_level else "ВЫБРАНО")
	choose.disabled = level == selected_level or concession_locked or creditor_locked
	choose.pressed.connect(set_budget_draft_level.bind(key, level, economy_scroll_position))
	box.add_child(choose)


func set_budget_draft_level(key: String, level: int, economy_scroll_position := 0) -> void:
	if key == "budget_social" and level == 0 and social_budget_reduction_locked():
		show_notice("После уступки протестующим социальную помощь нельзя опустить ниже базового уровня ещё %d нед." % social_budget_lock_weeks_left())
		return
	if not creditor_budget_change_allowed(key, level):
		show_notice(creditor_budget_lock_message(key))
		return
	budget_draft[key] = clampi(level, 0, 2)
	show_economy(economy_scroll_position)


func add_budget_card(parent: Container, item: Dictionary, corruption_tier: int) -> void:
	var key := str(item["key"])
	var current_level := budget_level(key)
	var level := draft_budget_level(key)
	var actual_amount := budget_final_for_level(key, current_level, corruption_tier)
	var draft_amount := budget_final_for_level(key, level, corruption_tier)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(470, 118)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", style(Color("#ded4bf"), 12, Color("#9a8c73"), 1))
	var detail := budget_breakdown_tooltip(item, corruption_tier)
	add_hover_detail(panel, detail)
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	panel.add_child(box)
	var title_text := label(str(item["title"]).to_upper(), 14, Color("#6f3e37"))
	add_hover_detail(title_text, detail)
	box.add_child(title_text)
	var amount_caption := "%s • %.2f млн/нед." % [BUDGET_LEVEL_NAMES[current_level], actual_amount]
	if level != current_level:
		amount_caption += "  →  %s • %.2f млн/нед." % [BUDGET_LEVEL_NAMES[level], draft_amount]
	var amount_text := label(amount_caption + " ⓘ", 16, INK)
	add_hover_detail(amount_text, detail)
	box.add_child(amount_text)
	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 8)
	box.add_child(controls)
	var minus := compact_button("−")
	var social_minus_locked := key == "budget_social" and level <= 1 and social_budget_reduction_locked()
	var creditor_minus_locked := level > 0 and not creditor_budget_change_allowed(key, level - 1)
	minus.disabled = level <= 0 or social_minus_locked or creditor_minus_locked
	if social_minus_locked:
		minus.tooltip_text = "После уступки протестующим расходы нельзя опустить ниже базового уровня ещё %d нед." % social_budget_lock_weeks_left()
	elif creditor_minus_locked:
		minus.tooltip_text = creditor_budget_lock_message(key)
	elif level > 0:
		var lower_final := budget_final_for_level(key, level - 1, corruption_tier)
		minus.tooltip_text = "Изменить черновик до уровня «%s».\nРасход после принятия: %.2f млн/нед.\nИзменение к действующему бюджету: %+.2f млн/нед.\n%s\n%s" % [BUDGET_LEVEL_NAMES[level - 1], lower_final, lower_final - actual_amount, budget_level_consequence_text(key, level - 1), "Поправку можно утвердить чрезвычайным указом без голосования." if emergency_powers_override_active() else "Поправка вступит в силу только после голосования."]
	else:
		minus.tooltip_text = "Расход уже находится на минимальном уровне."
	minus.pressed.connect(func(): change_budget_level(key, -1))
	controls.add_child(minus)
	var level_text := label("УРОВЕНЬ %d / 3" % (level + 1), 13, Color("#5f594d"), HORIZONTAL_ALIGNMENT_CENTER)
	add_hover_detail(level_text, detail)
	level_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls.add_child(level_text)
	var plus := compact_button("+")
	var creditor_plus_locked := level < 2 and not creditor_budget_change_allowed(key, level + 1)
	plus.disabled = level >= 2 or creditor_plus_locked
	if creditor_plus_locked:
		plus.tooltip_text = creditor_budget_lock_message(key)
	elif level < 2:
		var higher_final := budget_final_for_level(key, level + 1, corruption_tier)
		plus.tooltip_text = "Изменить черновик до уровня «%s».\nРасход после принятия: %.2f млн/нед.\nИзменение к действующему бюджету: %+.2f млн/нед.\n%s\n%s" % [BUDGET_LEVEL_NAMES[level + 1], higher_final, higher_final - actual_amount, budget_level_consequence_text(key, level + 1), "Поправку можно утвердить чрезвычайным указом без голосования." if emergency_powers_override_active() else "Поправка вступит в силу только после голосования."]
	else:
		plus.tooltip_text = "Расход уже находится на максимальном уровне."
	plus.pressed.connect(func(): change_budget_level(key, 1))
	controls.add_child(plus)


func add_budget_vote_panel(parent: VBoxContainer) -> void:
	var cost := budget_draft_cost()
	var forecast := parliament_vote_forecast("budget")
	var override_active := emergency_powers_override_active()
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", style(Color("#d2c5aa"), 14, GOLD if override_active else GREEN if bool(forecast.get("passed", false)) else RED, 2))
	add_hover_detail(panel, ("Чрезвычайные полномочия позволяют утвердить поправку указом. Расклад парламента приведён только для оценки политической реакции.\n\n" if override_active else "") + str(forecast.get("detail", "")))
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	box.add_child(label("БЮДЖЕТНАЯ ПОПРАВКА", 16, Color("#6f3e37")))
	var draft_text := "Черновик не отличается от действующего бюджета."
	if cost > 0:
		draft_text = "Изменено ступеней: %d • стоимость: %d очк. решений" % [cost, cost]
	box.add_child(label(draft_text, 15, INK))
	var forecast_text := ("ЧРЕЗВЫЧАЙНЫЙ УКАЗ • ПАРЛАМЕНТ МОЖНО ОБОЙТИ" if override_active else "ПРОГНОЗ ГОЛОСОВ: " + parliament_vote_summary(forecast)) + "  ⓘ"
	var forecast_label := label(forecast_text, 16, GOLD if override_active else GREEN if bool(forecast.get("passed", false)) else RED)
	add_hover_detail(forecast_label, ("Формальное голосование не требуется. Прогноз без указа: %s.\n\n" % parliament_vote_summary(forecast) if override_active else "") + str(forecast.get("detail", "")))
	box.add_child(forecast_label)
	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 10)
	box.add_child(controls)
	var submit_caption := "УТВЕРДИТЬ ЧРЕЗВЫЧАЙНЫМ УКАЗОМ" if override_active else "ВНЕСТИ В ПАРЛАМЕНТ"
	var submit := menu_button(submit_caption if cost == 0 else "%s — %d ОЧК." % [submit_caption, cost])
	submit.disabled = cost <= 0 or cost > int(state.get("influence", 0))
	submit.tooltip_text = ("Президент утвердит весь черновик без голосования парламента.\n\n" if override_active else "Парламент проголосует за весь черновик сразу. При отклонении бюджет, отношения групп и очки решений не изменятся.\n\n") + str(forecast.get("detail", ""))
	submit.pressed.connect(submit_budget_amendment)
	controls.add_child(submit)
	var discard := menu_button("СБРОСИТЬ ЧЕРНОВИК")
	discard.disabled = cost <= 0
	discard.pressed.connect(discard_budget_draft)
	controls.add_child(discard)
	if cost > int(state.get("influence", 0)):
		box.add_child(label("Не хватает очков решений: сократите пакет или дождитесь новой недели.", 14, RED))


func discard_budget_draft() -> void:
	var scroll_position := current_overlay_scroll_position()
	reset_budget_draft()
	show_economy(scroll_position)


func compact_button(text_value: String) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(54, 38)
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_stylebox_override("normal", style(Color("#c9bea6"), 8, Color("#8f826b"), 1))
	button.add_theme_stylebox_override("hover", style(Color("#b9ad94"), 8, GOLD, 1))
	return button


func add_resource_row(parent: VBoxContainer, key: String, caption: String, value: int, maximum: int, explanation: String, tooltip_detail := "", return_screen := "economy") -> void:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", style(Color("#ded4bf"), 10, Color("#9a8c73"), 1))
	add_hover_detail(panel, tooltip_detail)
	parent.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	panel.add_child(row)
	var texts := VBoxContainer.new()
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(texts)
	var caption_text := label(caption, 14, Color("#6f3e37"))
	add_hover_detail(caption_text, tooltip_detail)
	texts.add_child(caption_text)
	var value_text := label("%d из %d • %s%s" % [value, maximum, explanation, " ⓘ" if tooltip_detail != "" else ""], 14, INK)
	add_hover_detail(value_text, tooltip_detail)
	texts.add_child(value_text)
	var minus := compact_button("−")
	minus.disabled = value <= 0
	minus.pressed.connect(func(): change_resource_allocation(key, -1, return_screen))
	row.add_child(minus)
	var plus := compact_button("+")
	plus.disabled = value >= maximum
	plus.pressed.connect(func(): change_resource_allocation(key, 1, return_screen))
	row.add_child(plus)


func change_resource_allocation(key: String, delta: int, return_screen := "economy") -> void:
	var scroll_position := current_overlay_scroll_position()
	if key == "oil_to_army":
		state[key] = clampi(int(state.get(key, 0)) + delta, 0, current_oil_output())
	else:
		state[key] = clampi(int(state.get(key, 0)) + delta, 0, current_metal_output())
	autosave_if_iron()
	if return_screen == "army":
		show_army(scroll_position)
	else:
		show_economy(scroll_position)


func change_budget_level(key: String, delta: int) -> void:
	var old_level := draft_budget_level(key)
	var new_level := clampi(old_level + delta, 0, 2)
	if key == "budget_social" and new_level == 0 and social_budget_reduction_locked():
		return
	if not creditor_budget_change_allowed(key, new_level):
		show_notice(creditor_budget_lock_message(key))
		return
	if new_level == old_level:
		return
	var scroll_position := current_overlay_scroll_position()
	budget_draft[key] = new_level
	autosave_if_iron()
	show_economy(scroll_position)


func add_effect_delta(target: Dictionary, key: String, amount: int) -> void:
	if amount != 0:
		target[key] = int(target.get(key, 0)) + amount


func merge_numeric_effects(target: Dictionary, addition: Dictionary) -> void:
	for key in addition.keys():
		add_effect_delta(target, str(key), int(addition[key]))


func budget_reaction_for_change(key: String, delta: int) -> Dictionary:
	var reaction: Dictionary = {}
	var steps := absi(delta)
	if key == "budget_social":
		add_effect_delta(reaction, "support", steps * (2 if delta > 0 else -3))
		add_effect_delta(reaction, "clan_workers", steps * (5 if delta > 0 else -6))
	elif key == "budget_health":
		add_effect_delta(reaction, "support", steps * (2 if delta > 0 else -2))
		add_effect_delta(reaction, "stability", steps * (1 if delta > 0 else -2))
	elif key == "budget_defense":
		add_effect_delta(reaction, "army", steps * (4 if delta > 0 else -5))
		add_effect_delta(reaction, "war_support", steps * (1 if delta > 0 else -2))
	elif key == "budget_infrastructure":
		add_effect_delta(reaction, "clan_regions", steps * (5 if delta > 0 else -6))
		add_effect_delta(reaction, "stability", steps * (1 if delta > 0 else -2))
	elif key == "budget_admin":
		add_effect_delta(reaction, "stability", steps if delta > 0 else -steps)
	return reaction


func update_social_protest_from_budget() -> void:
	if budget_level("budget_social") == 0 and projected_pending_value("support") <= 40:
		state.social_protest_pending = true
		state.social_protest_due_week = int(state.get("week", 1)) + 1
	elif budget_level("budget_social") >= 1:
		state.social_protest_pending = false


func submit_budget_amendment() -> void:
	var cost := budget_draft_cost()
	if cost <= 0:
		show_notice("В проекте нет изменений к действующему бюджету.")
		return
	if int(state.get("influence", 0)) < cost:
		show_notice("Для этой бюджетной поправки требуется %d очк. решений." % cost)
		return
	if draft_budget_level("budget_social") == 0 and social_budget_reduction_locked():
		show_notice("После уступки протестующим социальную помощь нельзя опустить ниже базового уровня ещё %d нед." % social_budget_lock_weeks_left())
		return
	var creditor_lock_key := str(state.get("creditor_budget_lock_key", ""))
	if creditor_budget_lock_active(creditor_lock_key) and draft_budget_level(creditor_lock_key) != creditor_budget_required_level(creditor_lock_key):
		show_notice(creditor_budget_lock_message(creditor_lock_key))
		return
	var scroll_position := current_overlay_scroll_position()
	var forecast := parliament_vote_forecast("budget")
	var override_active := emergency_powers_override_active()
	if override_active:
		state.last_parliament_vote = "Бюджетная поправка введена чрезвычайным указом без голосования."
		state.last_parliament_vote_detail = "Прогноз возможного голосования: %s\n\n%s\n\nЧрезвычайные полномочия позволили президенту не выносить проект в зал." % [parliament_vote_summary(forecast), str(forecast.get("detail", ""))]
	else:
		record_parliament_vote("Бюджетная поправка", forecast)
	if not override_active and not bool(forecast.get("passed", false)):
		state.last_budget_change = "Парламент отклонил бюджетную поправку. Черновик сохранён."
		state.last_budget_change_detail = str(forecast.get("detail", "")) + "\n\nБюджет, отношения групп и очки решений не изменились."
		update_interface()
		autosave_if_iron()
		show_parliament_vote_result("ПОПРАВКА ОТКЛОНЕНА", "%d за, %d против. Действующий бюджет не изменился; черновик можно исправить и внести снова." % [int(forecast.get("yes", 0)), int(forecast.get("no", 0))], str(forecast.get("detail", "")), "economy", scroll_position)
		return
	var reaction: Dictionary = {}
	var changed_titles: Array[String] = []
	for item in WEEKLY_BUDGET_LINES:
		var key := str(item["key"])
		var old_level := budget_level(key)
		var new_level := draft_budget_level(key)
		var delta := new_level - old_level
		if delta == 0:
			continue
		changed_titles.append("%s: %s → %s" % [str(item["title"]), BUDGET_LEVEL_NAMES[old_level], BUDGET_LEVEL_NAMES[new_level]])
		merge_numeric_effects(reaction, budget_reaction_for_change(key, delta))
		state[key] = new_level
	reaction = apply_media_support_filter(reaction)
	state.influence = int(state.get("influence", 0)) - cost
	var previous_corruption_tier := projected_corruption_tier()
	var applied_reaction: Dictionary = {}
	if not reaction.is_empty():
		applied_reaction = queue_week_change("Принятая бюджетная поправка", reaction)
	update_social_protest_from_budget()
	var reaction_text := effects_to_text(reaction, applied_reaction, previous_corruption_tier, true) if not reaction.is_empty() else "числовой реакции групп нет"
	reset_budget_draft()
	state.last_budget_change = "Президент утвердил бюджетную поправку чрезвычайным указом без голосования." if override_active else "Парламент принял бюджетную поправку: %d за, %d против." % [int(forecast.get("yes", 0)), int(forecast.get("no", 0))]
	state.last_budget_change_detail = "%s\n\nПотрачено очков решений: %d. Эффект при завершении недели: %s\n\n%s" % [str(state.get("last_parliament_vote_detail", forecast.get("detail", ""))), cost, reaction_text, "\n".join(changed_titles)]
	update_interface()
	autosave_if_iron()
	var result_title := "ПОПРАВКА ВВЕДЕНА УКАЗОМ" if override_active else "ПОПРАВКА ПРИНЯТА"
	var result_message := "Парламентское голосование не проводилось. Новые уровни бюджета зафиксированы чрезвычайным указом; денежный расчёт и реакция групп произойдут при переходе к следующей неделе.\n\n%s" % "\n".join(changed_titles) if override_active else "%d за, %d против. Новые уровни бюджета зафиксированы; денежный расчёт и реакция групп произойдут при переходе к следующей неделе.\n\n%s" % [int(forecast.get("yes", 0)), int(forecast.get("no", 0)), "\n".join(changed_titles)]
	show_parliament_vote_result(result_title, result_message, str(state.get("last_parliament_vote_detail", forecast.get("detail", ""))), "economy", scroll_position)


func budget_title(key: String) -> String:
	for item in WEEKLY_BUDGET_LINES:
		if str(item["key"]) == key:
			return str(item["title"])
	return key




func show_army(scroll_position := 0) -> void:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(980, 650)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	scroll.add_child(content)
	content.add_child(label("АРМИЯ", 30, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var army_hint := label("Численность связана с населением; подробности показателей доступны при наведении. ⓘ", 15, Color("#4c4941"), HORIZONTAL_ALIGNMENT_CENTER)
	army_hint.tooltip_text = "Новобранцы сначала переходят из безработных, затем из работающих. Демобилизованные и дезертиры возвращаются в гражданскую экономику. Поддержка войны 30% и ниже замедляет набор, 65% и выше ускоряет его. Боеспособность складывается из подготовки, наземной техники, авиации, снабжения и морали."
	content.add_child(army_hint)
	if state.has("last_army_change"):
		var army_change := label(str(state.get("last_army_change", "")) + "  ⓘ", 14, BLUE, HORIZONTAL_ALIGNMENT_CENTER)
		army_change.tooltip_text = str(state.get("last_army_change_detail", ""))
		content.add_child(army_change)
	content.add_child(label("СПОСОБ КОМПЛЕКТОВАНИЯ", 15, Color("#6f3e37")))
	var model_grid := GridContainer.new()
	model_grid.columns = 2
	model_grid.add_theme_constant_override("h_separation", 10)
	model_grid.add_theme_constant_override("v_separation", 8)
	content.add_child(model_grid)
	for model_id in ["contract", "mixed", "universal", "mobilization"]:
		add_recruitment_option(model_grid, model_id)
	var current_loyalty := int(state.get("army", 50))
	var loyalty := projected_pending_value("army")
	var projected_army := projected_army_snapshot()
	content.add_child(label("СОСТОЯНИЕ ВООРУЖЁННЫХ СИЛ", 15, Color("#6f3e37")))
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	content.add_child(grid)
	var current_personnel := int(state.get("army_personnel", 0))
	var expected_personnel := int(projected_army["personnel"])
	var current_recruitment_model: Dictionary = RECRUITMENT_MODELS.get(str(state.get("recruitment_model", "mixed")), RECRUITMENT_MODELS["mixed"])
	var current_recruitment_speed := roundi(float(current_recruitment_model.get("speed", 6000)) * recruitment_speed_multiplier(projected_pending_value("war_support")))
	add_army_metric(grid, "ВОЕННОСЛУЖАЩИЕ", format_people(expected_personnel), "Цель выбранной модели: %s; текущий предел изменения за неделю: %s (множитель поддержки войны ×%.2f)." % [format_people(recruitment_target()), format_people(current_recruitment_speed), recruitment_speed_multiplier(projected_pending_value("war_support"))], BLUE, expected_personnel != current_personnel, format_people(current_personnel))
	var current_effectiveness := army_effectiveness()
	var expected_effectiveness := int(projected_army["effectiveness"])
	add_army_metric(grid, "БОЕСПОСОБНОСТЬ", "%d%%" % expected_effectiveness, "Качество %d%% • подготовка %d%% • ожидаемая мораль %d%% • ожидаемое снабжение %d%% • поправка лояльности штаба %+d п.п.%s" % [int(projected_army.get("quality", expected_effectiveness)), army_training(), int(projected_army["morale"]), int(projected_army["supply"]), army_loyalty_quality_modifier(projected_pending_value("army")), " • во время войны учитывается нехватка людей на фронте" if bool(state.get("at_war", false)) else ""], GREEN, expected_effectiveness != current_effectiveness, "%d%%" % current_effectiveness)
	if bool(state.get("at_war", false)):
		var frontline_required := int(projected_army.get("frontline_required", frontline_required_personnel()))
		var frontline_explanation := "Минимум для удержания фронта при текущем качестве армии. Улучшение техники, авиации, подготовки и снабжения снижает потребность в людях; недостающее число можно компенсировать мобилизацией."
		add_army_metric(grid, "МИНИМУМ ДЛЯ ФРОНТА", format_people(frontline_required), frontline_explanation, RED if expected_personnel < frontline_required else GREEN)
	add_army_metric(grid, "ЛОЯЛЬНОСТЬ", "%d%%" % loyalty, army_loyalty_explanation(loyalty), RED if loyalty <= 30 else BLUE, loyalty != current_loyalty, "%d%%" % current_loyalty)
	var current_equipment := int(state.get("army_equipment", 0))
	var expected_equipment := int(projected_army["equipment"])
	add_army_metric(grid, "НАЗЕМНАЯ ТЕХНИКА", "%d ед." % expected_equipment, "Потребность ожидаемой армии: %d • плановый выпуск +%d/нед." % [int(projected_army["required_equipment"]), equipment_production_per_week()], GOLD, expected_equipment != current_equipment, "%d ед." % current_equipment)
	var current_aircraft := int(state.get("army_aircraft", 0))
	var expected_aircraft := int(projected_army["aircraft"])
	add_army_metric(grid, "АВИАЦИЯ", "%d ед." % expected_aircraft, "Потребность ожидаемой армии: %d. Республика не производит авиацию: самолёты и вертолёты можно только купить или получить через помощь и события." % int(projected_army["required_aircraft"]), GOLD, expected_aircraft != current_aircraft, "%d ед." % current_aircraft)
	var current_supply := army_supply()
	var expected_supply := int(projected_army["supply"])
	add_army_metric(grid, "НЕФТЯНОЕ СНАБЖЕНИЕ", "%d из %d ед." % [int(state.get("oil_to_army", 0)), int(projected_army["oil_need"])], "Ожидаемое покрытие потребности: %d%%. Дефицит режет боеспособность." % expected_supply, BLUE, expected_supply != current_supply, "%d%%" % current_supply)
	content.add_child(label("ПРОИЗВОДСТВО И СНАБЖЕНИЕ", 15, Color("#6f3e37")))
	var production_hint := label("Внутри страны производится только наземная техника. Остаток ресурсов продаётся автоматически. ⓘ", 14, Color("#5f594d"))
	production_hint.tooltip_text = "Металл и нефть нельзя запасать. Авиационного производства в республике нет; авиация меняется только через закупки, помощь, потери и события."
	content.add_child(production_hint)
	var tier := int(state.get("corruption_tier", 0))
	add_resource_row(content, "metal_to_equipment", "МЕТАЛЛ → НАЗЕМНАЯ ТЕХНИКА", int(state.get("metal_to_equipment", 0)), current_metal_output(), "Выпуск +%d ед. • нагрузка на баланс %.2f млн" % [equipment_production_per_week(), equipment_balance_load(tier)], equipment_production_tooltip(tier), "army")
	var oil_export_gross := float(exported_oil()) * current_oil_price()
	var oil_export_final := adjusted_money_transaction(oil_export_gross, tier)
	add_resource_row(content, "oil_to_army", "НЕФТЬ → СНАБЖЕНИЕ", int(state.get("oil_to_army", 0)), current_oil_output(), "Снабжение %d%% • экспорт %.2f млн" % [army_supply(), oil_export_final], "Потребность армии: %d ед. нефти\nДоступная добыча: %d ед. (%s)\nВыделено: %d ед.\nПокрытие: %d%%\nОстаток на экспорт: %d ед.\n%s" % [army_oil_need(), current_oil_output(), oil_output_reduction_note(), int(state.get("oil_to_army", 0)), army_supply(), exported_oil(), transaction_tooltip("Экспорт нефти", oil_export_gross, tier, "%d ед. × %.2f млн" % [exported_oil(), current_oil_price()])], "army")
	var defense_base := budget_line_amount("Армия и внутренние силы")
	var defense_actual := absf(adjusted_money_transaction(-defense_base, int(state.get("corruption_tier", 0))))
	var defense_line := label("ОБОРОНА: расход %.2f млн/нед. • %s • министр %s ⓘ" % [defense_actual, BUDGET_LEVEL_NAMES[budget_level("budget_defense")], current_minister_name("defense")], 15, Color("#5f594d"), HORIZONTAL_ALIGNMENT_CENTER)
	defense_line.tooltip_text = army_budget_breakdown_tooltip(tier)
	content.add_child(defense_line)
	var close := menu_button("ВЕРНУТЬСЯ К ДОКЛАДУ")
	close.pressed.connect(close_overlay)
	content.add_child(close)
	show_overlay(scroll, PAPER, true, 1040)
	restore_overlay_scroll_position(scroll, scroll_position)


func add_recruitment_option(parent: Container, model_id: String) -> void:
	var data: Dictionary = RECRUITMENT_MODELS[model_id]
	var current := str(state.get("recruitment_model", "mixed")) == model_id
	var locked := model_id == "mobilization" and not bool(state.get("at_war", false)) and not bool(state.get("military_threat", false))
	var button := Button.new()
	var adjusted_speed := roundi(float(data.get("speed", 6000)) * recruitment_speed_multiplier(projected_pending_value("war_support")))
	button.text = "%s%s\nЦель: %s • темп: %s/нед. • подготовка %d%% ⓘ" % [str(data["title"]).to_upper(), " • ВЫБРАНО" if current else "", format_people(recruitment_target_for(model_id)), format_people(adjusted_speed), int(data["training"])]
	button.custom_minimum_size = Vector2(0, 78)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_stylebox_override("normal", style(Color("#d8cdb5") if not current else Color("#c8d4c0"), 12, GREEN if current else Color("#92846c"), 2 if current else 1))
	button.add_theme_stylebox_override("disabled", style(Color("#c8d4c0") if current else Color("#b9b2a3"), 12, GREEN if current else Color("#8e887c"), 2 if current else 1))
	button.add_theme_color_override("font_disabled_color", INK if current else Color("#6f6a61"))
	button.disabled = current or locked or recruitment_changed_this_week
	var support_speed_note := "Поддержка войны меняет недельный темп набора: сейчас ×%.2f." % recruitment_speed_multiplier(projected_pending_value("war_support"))
	button.tooltip_text = "Мобилизация доступна только во время войны или объявленной военной угрозы.\n%s\n%s" % [str(data["description"]), support_speed_note] if locked else "%s\n%s\nСмена модели стоит 1 очко решения. Расширение призыва при поддержке войны 30%% и ниже вызовет протест." % [str(data["description"]), support_speed_note]
	button.pressed.connect(show_recruitment_confirmation.bind(model_id))
	parent.add_child(button)


func recruitment_target_for(model_id: String) -> int:
	var old_model := str(state.get("recruitment_model", "mixed"))
	state.recruitment_model = model_id
	var target := recruitment_target()
	state.recruitment_model = old_model
	return target


func show_recruitment_confirmation(model_id: String) -> void:
	var data: Dictionary = RECRUITMENT_MODELS[model_id]
	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(720, 0)
	content.add_theme_constant_override("separation", 14)
	content.add_child(label("СМЕНИТЬ СПОСОБ КОМПЛЕКТОВАНИЯ?", 26, INK, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label(str(data["title"]), 23, Color("#6f3e37"), HORIZONTAL_ALIGNMENT_CENTER))
	var adjusted_speed := roundi(float(data.get("speed", 6000)) * recruitment_speed_multiplier(projected_pending_value("war_support")))
	content.add_child(label("Целевая численность: %s. Текущий предел изменения: %s в неделю. Переход будет постепенным; люди физически перейдут между гражданскими группами и армией." % [format_people(recruitment_target_for(model_id)), format_people(adjusted_speed)], 17, Color("#4c4941"), HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label("Стоимость: 1 очко решения. Подготовка модели: %d%%. %s" % [int(data["training"]), str(data["description"])], 16, Color("#5f594d"), HORIZONTAL_ALIGNMENT_CENTER))
	var confirm := menu_button("ПОДТВЕРДИТЬ")
	confirm.disabled = int(state.get("influence", 0)) < 1
	confirm.pressed.connect(set_recruitment_model.bind(model_id))
	content.add_child(confirm)
	var back := menu_button("НАЗАД К АРМИИ")
	back.pressed.connect(show_army)
	content.add_child(back)
	show_overlay(content, PAPER, true, 780)


func set_recruitment_model(model_id: String) -> void:
	if int(state.get("influence", 0)) < 1 or recruitment_changed_this_week:
		show_notice("Сменить способ комплектования на этой неделе нельзя.")
		return
	if model_id == "mobilization" and not bool(state.get("at_war", false)) and not bool(state.get("military_threat", false)):
		show_notice("Мобилизация доступна только во время войны или объявленной военной угрозы.")
		return
	var previous_model_id := str(state.get("recruitment_model", "mixed"))
	var recruitment_order := {"contract": 0, "mixed": 1, "universal": 2, "mobilization": 3}
	var expands_draft := int(recruitment_order.get(model_id, 0)) > int(recruitment_order.get(previous_model_id, 0))
	state.recruitment_model = model_id
	state.influence = int(state.get("influence", 0)) - 1
	recruitment_changed_this_week = true
	var reaction: Dictionary = {}
	if model_id == "universal":
		reaction = {"support": -1, "war_support": -2, "army": 2}
	elif model_id == "contract":
		reaction = {"army": 1, "clan_workers": 2}
	elif model_id == "mobilization":
		reaction = {"support": -3, "war_support": -5, "army": 4}
	reaction = amplify_decision_effects(reaction, "general")
	reaction = apply_media_support_filter(reaction)
	var previous_corruption_tier := projected_corruption_tier()
	var applied_reaction := queue_week_change("Смена способа комплектования", reaction) if not reaction.is_empty() else {}
	if expands_draft and projected_pending_value("war_support") <= WAR_SUPPORT_LOW:
		schedule_unrest({
			"cause": "расширение призыва до модели «%s»" % str(RECRUITMENT_MODELS[model_id]["title"]),
			"kind": "antiwar",
			"base_level": 1,
			"reversible": false
		}, 1)
	state.last_army_change = "Способ комплектования изменён: %s." % str(RECRUITMENT_MODELS[model_id]["title"])
	state.last_army_change_detail = "Потрачено 1 очко решения. Эффект при завершении недели: %s. Целевая численность — %s." % [effects_to_text(reaction, applied_reaction, previous_corruption_tier, true), format_people(recruitment_target())]
	update_interface()
	autosave_if_iron()
	show_army()


func army_loyalty_explanation(value: int) -> String:
	if value >= 80:
		return "Критически высокая: штаб без сопротивления исполняет приказы; боеспособность +10 п.п."
	if value >= 65:
		return "Высокая: штаб поддерживает президента; боеспособность +5 п.п."
	if value <= 20:
		return "Критически низкая: штаб саботирует приказы и бережёт собственные части; боеспособность −15 п.п."
	if value <= 40:
		return "Низкая: командование исполняет приказы формально; боеспособность −7 п.п."
	return "Неустойчивая: командование выполняет приказы, но активного бонуса не даёт."


func add_army_metric(parent: Container, caption: String, value: String, explanation: String, accent: Color, pending := false, current_value := "") -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 92)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", style(Color("#d8cdb5"), 13, Color(accent, 0.8), 2))
	var detail := explanation
	if pending:
		detail = pending_value_tooltip(caption.capitalize(), current_value, value) + "\n\n" + explanation
	add_hover_detail(panel, detail)
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)
	var caption_text := label(caption, 13, accent)
	add_hover_detail(caption_text, detail)
	box.add_child(caption_text)
	var value_text := label(value + "  ⓘ", 20, PENDING_BLUE if pending else INK)
	add_hover_detail(value_text, detail)
	box.add_child(value_text)


func show_population() -> void:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(980, 650)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	scroll.add_child(content)
	content.add_child(label("НАСЕЛЕНИЕ", 30, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var civilian_adults := int(state.get("pop_employed", 0)) + int(state.get("pop_unemployed", 0))
	var unemployment := float(state.get("pop_unemployed", 0)) / maxf(float(civilian_adults), 1.0) * 100.0
	var voters := civilian_adults + int(state.get("pop_pensioners", 0)) + int(state.get("army_personnel", 0))
	var projected_employed := projected_pending_value("pop_employed")
	var projected_unemployed := projected_pending_value("pop_unemployed")
	var projected_pensioners := projected_pending_value("pop_pensioners")
	var projected_personnel := projected_pending_value("army_personnel")
	var projected_civilian_adults := projected_employed + projected_unemployed
	var projected_voters := projected_civilian_adults + projected_pensioners + projected_personnel
	var population_pending := projected_total_population() != total_population() or projected_voters != voters or projected_unemployed != int(state.get("pop_unemployed", 0))
	var summary := PanelContainer.new()
	summary.add_theme_stylebox_override("panel", style(Color("#d8cdb5"), 14, Color("#92846c"), 1))
	content.add_child(summary)
	var summary_box := VBoxContainer.new()
	summary_box.add_theme_constant_override("separation", 4)
	summary.add_child(summary_box)
	summary_box.add_child(label("ВСЕГО: %s • потенциальных избирателей: %s" % [format_people(total_population()), format_people(voters)], 22, INK))
	if population_pending:
		var projected_unemployment := float(projected_unemployed) / maxf(float(projected_civilian_adults), 1.0) * 100.0
		var population_projection := label("ПОСЛЕ ПРИНЯТЫХ РЕШЕНИЙ: всего %s • избирателей %s • безработица %.1f%%  ⓘ" % [format_people(projected_total_population()), format_people(projected_voters), projected_unemployment], 16, PENDING_BLUE)
		population_projection.tooltip_text = "Голубые числа ещё не применены и вступят в силу при переходе к следующей неделе."
		summary_box.add_child(population_projection)
	summary_box.add_child(label("Безработица среди гражданских взрослых: %.1f%% • доступный резерв труда и призыва: %s" % [unemployment, format_people(civilian_adults)], 16, Color("#5f594d")))
	summary_box.add_child(label(str(state.get("last_population_report", "Месячного отчёта ещё не было.")), 15, BLUE))
	var weeks_to_report := 4 - (int(state.get("week", 1)) % 4)
	if weeks_to_report == 0:
		weeks_to_report = 4
	summary_box.add_child(label("Следующий автоматический демографический пересчёт через %d нед." % weeks_to_report, 14, Color("#5f594d")))
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	content.add_child(grid)
	add_population_card(grid, "ДЕТИ", int(state.get("pop_children", 0)), projected_pending_value("pop_children"), "Требуют школ, медицины и пособий; постепенно входят в рабочий возраст.", GOLD)
	add_population_card(grid, "РАБОТАЮЩИЕ ВЗРОСЛЫЕ", int(state.get("pop_employed", 0)), projected_employed, "Главный источник налогов, избирателей и пополнения армии.", GREEN)
	add_population_card(grid, "БЕЗРАБОТНЫЕ", int(state.get("pop_unemployed", 0)), projected_unemployed, "Получают помощь; первыми попадают под призыв и программы занятости.", RED)
	add_population_card(grid, "ПЕНСИОНЕРЫ", int(state.get("pop_pensioners", 0)), projected_pensioners, "Голосуют и получают обязательные выплаты; число меняется со старением.", BLUE)
	add_population_card(grid, "МИГРАНТЫ И БЕЖЕНЦЫ", int(state.get("pop_migrants", 0)), projected_pending_value("pop_migrants"), "Требуют первичной помощи; не голосуют и не призываются без интеграции. Раз в четыре недели минимальное финансирование образования и медицины даёт отток 8 тыс., приоритетное — приток 8 тыс.", RED)
	add_population_card(grid, "ВОЕННОСЛУЖАЩИЕ", int(state.get("army_personnel", 0)), projected_personnel, "Изъяты из гражданской рабочей силы; возвращаются после демобилизации.", BLUE)
	content.add_child(label("СВЯЗЬ С БЮДЖЕТОМ", 15, Color("#6f3e37")))
	var tier := int(state.get("corruption_tier", 0))
	var tax_gross := snappedf(float(state.get("pop_employed", 0)) / 1000000.0 * 2.0, 0.01)
	var tax_final := adjusted_money_transaction(tax_gross, tier)
	var social_final := absf(adjusted_money_transaction(-budget_amount_by_key("budget_social"), tier))
	var health_final := absf(adjusted_money_transaction(-budget_amount_by_key("budget_health"), tier))
	var population_budget := label("ЗА НЕДЕЛЮ: налоги работающих +%.2f млн • социальные расходы −%.2f млн • образование и медицина −%.2f млн ⓘ" % [tax_final, social_final, health_final], 16, Color("#5f594d"))
	population_budget.tooltip_text = "%s\n\n%s\n\n%s" % [
		transaction_tooltip("Налоги работающих", tax_gross, tier, "%s работающих × 2.00 млн за 1 млн человек" % format_people(int(state.get("pop_employed", 0)))),
		budget_breakdown_tooltip(WEEKLY_BUDGET_LINES[0], tier),
		budget_breakdown_tooltip(WEEKLY_BUDGET_LINES[1], tier)
	]
	content.add_child(population_budget)
	var draft_hint := label("Призыв перемещает людей между гражданскими группами и армией. ⓘ", 15, Color("#5f594d"))
	draft_hint.tooltip_text = "Армия сначала забирает безработных, затем работающих. Массовый призыв одновременно уменьшает налоговую базу и увеличивает оборонные расходы; демобилизация возвращает людей в экономику."
	content.add_child(draft_hint)
	var close := menu_button("ВЕРНУТЬСЯ К ДОКЛАДУ")
	close.pressed.connect(close_overlay)
	content.add_child(close)
	show_overlay(scroll, PAPER, true, 1040)


func add_population_card(parent: Container, caption: String, count: int, projected_count: int, explanation: String, accent: Color) -> void:
	var pending := projected_count != count
	var detail := explanation
	if pending:
		detail = pending_value_tooltip(caption.capitalize(), format_people(count), format_people(projected_count)) + "\n\n" + explanation
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 92)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", style(Color("#d8cdb5"), 12, Color(accent, 0.75), 2))
	add_hover_detail(panel, detail)
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)
	var caption_text := label(caption, 13, accent)
	add_hover_detail(caption_text, detail)
	box.add_child(caption_text)
	var value_text := label(format_people(projected_count) + "  ⓘ", 21, PENDING_BLUE if pending else INK)
	add_hover_detail(value_text, detail)
	box.add_child(value_text)


func show_ministers() -> void:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(900, 620)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	scroll.add_child(content)
	content.add_child(label("ПРАВИТЕЛЬСТВО", 28, INK, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label("Чрезвычайные полномочия позволяют президенту утверждать бюджет и министров без голосования. Министры не решают за президента, но меняют доклады, события и доступные ответы." if emergency_powers_override_active() else "Парламент утверждает бюджетные поправки и министров. Министры не решают за президента, но меняют доклады, события и доступные ответы.", 16, Color("#4c4941"), HORIZONTAL_ALIGNMENT_CENTER))
	add_election_government_panel(content)
	add_parliament_panel(content)
	content.add_child(label("СОСТАВ КАБИНЕТА", 16, Color("#6f3e37")))
	for slot in ["economy", "interior", "defense", "foreign"]:
		add_minister_row(content, slot)
	var close := menu_button("ВЕРНУТЬСЯ К ДОКЛАДУ")
	close.pressed.connect(close_overlay)
	content.add_child(close)
	show_overlay(scroll, PAPER, true, 960)


func add_election_government_panel(parent: VBoxContainer) -> void:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", style(Color("#d9ceb7"), 14, GOLD, 2))
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	var weeks_left := maxi(0, DEMO_WEEKS - int(state.get("week", 1)) + 1)
	box.add_child(label("ВРЕМЕННЫЙ МАНДАТ • %s" % ("ВЫБОРЫ НА ЭТОЙ НЕДЕЛЕ" if weeks_left <= 1 else "ДО ВЫБОРОВ %d НЕД." % weeks_left), 20, INK))
	box.add_child(label("После смерти президента вице-президент исполняет его обязанности только до досрочного голосования. Должность была получена по спорной процедуре, поэтому победу придётся подтвердить выборами либо удержать власть иным способом.", 14, Color("#5f594d")))
	var forecast := label("ПРОГНОЗ: %s  ⓘ" % election_forecast_label(true), 16, election_forecast_color(true))
	forecast.tooltip_text = election_forecast_tooltip(true)
	box.add_child(forecast)
	var campaign_name := election_campaign_name(str(state.get("election_campaign", "")))
	var rules_name := election_rules_name(str(state.get("election_rules", "undecided")))
	box.add_child(label("Кампания: %s • правила подсчёта: %s" % [campaign_name, rules_name], 14, Color("#6f3e37")))


func add_parliament_panel(parent: VBoxContainer) -> void:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", style(Color("#d2c5aa"), 14, Color("#8b6c4b"), 2))
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	panel.add_child(box)
	box.add_child(label("ПАРЛАМЕНТ • %d МЕСТ" % PARLIAMENT_TOTAL_SEATS, 21, INK))
	box.add_child(label("Партия президента: 82 места • простое большинство: %d • конституционное: %d" % [PARLIAMENT_MAJORITY, PARLIAMENT_CONSTITUTIONAL_MAJORITY], 15, Color("#5f594d")))
	var rule_text := "ЧРЕЗВЫЧАЙНЫЕ ПОЛНОМОЧИЯ: президент может обходить парламент при бюджете и назначении министров. Позиции фракций остаются видимыми как политическое предупреждение. ⓘ" if emergency_powers_override_active() else "Большинство партии существует на бумаге, но отдельные фракции могут голосовать против конкретной поправки или кандидатуры. ⓘ"
	var rule := label(rule_text, 14, RED if emergency_powers_override_active() else Color("#6f3e37"))
	rule.tooltip_text = "Закон отменил обязательное голосование по бюджету и министрам. Отмена чрезвычайных полномочий вернёт парламентский контроль." if emergency_powers_override_active() else "Голосование не случайно. На позицию фракций влияют поддержка власти, отношение армии и регионов, гражданский контроль, авторитарные меры и содержание проекта. 61 голос необходим для принятия решения."
	box.add_child(rule)
	for faction_data in PARLIAMENT_FACTIONS:
		var faction: Dictionary = faction_data
		var faction_key := str(faction["key"])
		var score := parliament_faction_base_score(faction_key)
		var row := PanelContainer.new()
		row.add_theme_stylebox_override("panel", style(Color("#ddd2bc"), 8, Color("#9a8c73"), 1))
		add_hover_detail(row, parliament_faction_reasons(faction_key))
		box.add_child(row)
		var row_box := HBoxContainer.new()
		row_box.add_theme_constant_override("separation", 8)
		row.add_child(row_box)
		var name_text := label("%s • %d мест" % [str(faction["title"]), int(faction["seats"])], 15, INK)
		name_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		add_hover_detail(name_text, parliament_faction_reasons(faction_key))
		row_box.add_child(name_text)
		var position_color := GREEN if score > 0 else RED if score < 0 else Color("#7d6b4f")
		var position := label(parliament_position_name(score).to_upper() + "  ⓘ", 13, position_color, HORIZONTAL_ALIGNMENT_RIGHT)
		position.custom_minimum_size = Vector2(210, 0)
		position.autowrap_mode = TextServer.AUTOWRAP_OFF
		add_hover_detail(position, parliament_faction_reasons(faction_key))
		row_box.add_child(position)
	if str(state.get("last_parliament_vote", "")) != "":
		var last_vote := label("ПОСЛЕДНЕЕ ГОЛОСОВАНИЕ: " + str(state.get("last_parliament_vote", "")) + "  ⓘ", 14, BLUE)
		add_hover_detail(last_vote, str(state.get("last_parliament_vote_detail", "")))
		box.add_child(last_vote)
	else:
		box.add_child(label("Последних голосований ещё не было.", 14, Color("#5f594d")))


func add_minister_row(parent: VBoxContainer, slot: String) -> void:
	var data := minister_data(slot)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", style(Color("#d8cdb5"), 12, Color("#92846c"), 1))
	parent.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	panel.add_child(row)
	var texts := VBoxContainer.new()
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(texts)
	texts.add_child(label(str(MINISTER_OFFICES.get(slot, slot)), 12, Color("#7c4d43")))
	texts.add_child(label(str(data.get("name", "Вакансия")), 20, INK))
	texts.add_child(label("Идеология: %s • черта «%s»" % [str(data.get("ideology", "")), str(data.get("trait", ""))], 13, Color("#5f594d")))
	texts.add_child(label("Лояльность: %s • опора: %s" % [str(data.get("loyalty", "неизвестна")), str(data.get("patron", "нет"))], 13, Color("#5f594d")))
	var choose := Button.new()
	choose.text = "КАНДИДАТЫ"
	choose.custom_minimum_size = Vector2(150, 58)
	choose.add_theme_font_size_override("font_size", 13)
	choose.add_theme_color_override("font_color", INK)
	choose.add_theme_stylebox_override("normal", style(Color("#b9ad94"), 10, Color("#766a55"), 1))
	choose.pressed.connect(show_minister_candidates.bind(slot))
	row.add_child(choose)


func show_minister_candidates(slot: String) -> void:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(900, 620)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	scroll.add_child(content)
	content.add_child(label(str(MINISTER_OFFICES.get(slot, slot)), 27, INK, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label("Выберите кандидата сами. Назначение стоит 2 очка решения и требует 61 голос; списание произойдёт только после одобрения парламента.", 15, Color("#4c4941"), HORIZONTAL_ALIGNMENT_CENTER))
	for raw_candidate in MINISTER_CANDIDATES.get(slot, []):
		var candidate: Dictionary = raw_candidate
		var panel := PanelContainer.new()
		var current := str(selected_ministers.get(slot, "")) == str(candidate.get("id", ""))
		var locked := is_minister_locked(slot, candidate)
		panel.add_theme_stylebox_override("panel", style(Color("#d8cdb5"), 12, GREEN if current else RED if locked else Color("#92846c"), 2 if current else 1))
		content.add_child(panel)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		panel.add_child(row)
		var texts := VBoxContainer.new()
		texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(texts)
		texts.add_child(label("%s%s" % [str(candidate["name"]), " • ДЕЙСТВУЮЩИЙ" if current else ""], 20, INK))
		texts.add_child(label("Идеология: %s • лояльность: %s" % [str(candidate["ideology"]), str(candidate["loyalty"])], 13, Color("#5f594d")))
		texts.add_child(label("Опора: %s • черта «%s»" % [str(candidate["patron"]), str(candidate["trait"])], 13, Color("#5f594d")))
		texts.add_child(label(str(candidate["known"]), 13, Color("#6f3e37")))
		if locked:
			texts.add_child(label("НЕДОСТУПЕН: " + str(candidate.get("locked_reason", "сюжетное ограничение")), 13, RED))
		var select := Button.new()
		select.text = "ВЫБРАТЬ"
		select.custom_minimum_size = Vector2(130, 58)
		select.add_theme_font_size_override("font_size", 13)
		select.add_theme_color_override("font_color", INK)
		select.add_theme_stylebox_override("normal", style(Color("#b9ad94"), 10, Color("#766a55"), 1))
		select.disabled = current or locked
		select.pressed.connect(show_minister_confirmation.bind(slot, str(candidate["id"])))
		row.add_child(select)
	var back := menu_button("НАЗАД К ПРАВИТЕЛЬСТВУ")
	back.pressed.connect(show_ministers)
	content.add_child(back)
	show_overlay(scroll, PAPER, true, 960)


func show_minister_confirmation(slot: String, candidate_id: String) -> void:
	var current := minister_data(slot)
	var candidate := minister_data(slot, candidate_id)
	var forecast := parliament_vote_forecast("minister", candidate_id)
	var override_active := emergency_powers_override_active()
	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(760, 0)
	content.add_theme_constant_override("separation", 14)
	content.add_child(label("ВНЕСТИ КАНДИДАТУРУ", 27, INK, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label("%s → %s" % [str(current.get("name", "Вакансия")), str(candidate.get("name", "Кандидат"))], 23, Color("#6f3e37"), HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label("Идеология кандидата: %s\nЛояльность: %s\nОпора: %s\nЧерта: «%s»" % [str(candidate.get("ideology", "")), str(candidate.get("loyalty", "")), str(candidate.get("patron", "")), str(candidate.get("trait", ""))], 17, Color("#4c4941"), HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label("Известные последствия: " + str(candidate.get("known", "Будущие события изменятся.")), 16, Color("#5f594d"), HORIZONTAL_ALIGNMENT_CENTER))
	var forecast_text := "ЧРЕЗВЫЧАЙНОЕ НАЗНАЧЕНИЕ • ПАРЛАМЕНТ МОЖНО ОБОЙТИ  ⓘ" if override_active else "ПРОГНОЗ ГОЛОСОВ: %s  ⓘ" % parliament_vote_summary(forecast)
	var forecast_label := label(forecast_text, 16, GOLD if override_active else GREEN if bool(forecast.get("passed", false)) else RED, HORIZONTAL_ALIGNMENT_CENTER)
	add_hover_detail(forecast_label, ("Голосование не требуется. Прогноз без чрезвычайного указа: %s.\n\n" % parliament_vote_summary(forecast) if override_active else "") + str(forecast.get("detail", "")))
	content.add_child(forecast_label)
	content.add_child(label("Стоимость: 2 очка решений. Президент назначит министра без голосования парламента." if override_active else "Стоимость: 2 очка решений. При провале голосования министр, отношения групп и очки не изменятся.", 15, GOLD if override_active else RED, HORIZONTAL_ALIGNMENT_CENTER))
	var confirm := menu_button("НАЗНАЧИТЬ ЧРЕЗВЫЧАЙНЫМ УКАЗОМ" if override_active else "ВНЕСТИ КАНДИДАТУРУ")
	confirm.disabled = int(state.get("influence", 0)) < 2
	confirm.tooltip_text = ("Чрезвычайные полномочия отменяют обязательное голосование.\n\n" if override_active else "") + str(forecast.get("detail", ""))
	confirm.pressed.connect(appoint_minister.bind(slot, candidate_id))
	content.add_child(confirm)
	var back := menu_button("НАЗАД К КАНДИДАТАМ")
	back.pressed.connect(show_minister_candidates.bind(slot))
	content.add_child(back)
	show_overlay(content, PAPER, true, 820)


func appoint_minister(slot: String, candidate_id: String) -> void:
	var candidate := minister_data(slot, candidate_id)
	if candidate.is_empty() or is_minister_locked(slot, candidate):
		show_notice("Этот кандидат сейчас недоступен.")
		return
	if str(selected_ministers.get(slot, "")) == candidate_id:
		show_notice("Этот кандидат уже занимает должность.")
		return
	if int(state.get("influence", 0)) < 2:
		show_notice("Для назначения требуется 2 очка решений.")
		return
	var forecast := parliament_vote_forecast("minister", candidate_id)
	var override_active := emergency_powers_override_active()
	if override_active:
		state.last_parliament_vote = "Министр %s назначен чрезвычайным указом без голосования." % str(candidate.get("name", "Кандидат"))
		state.last_parliament_vote_detail = "Прогноз возможного голосования: %s\n\n%s\n\nЧрезвычайные полномочия позволили президенту обойти парламент." % [parliament_vote_summary(forecast), str(forecast.get("detail", ""))]
	else:
		record_parliament_vote("Назначение: %s" % str(candidate.get("name", "Кандидат")), forecast)
	if not override_active and not bool(forecast.get("passed", false)):
		update_interface()
		autosave_if_iron()
		show_parliament_vote_result("КАНДИДАТУРА ОТКЛОНЕНА", "%s остаётся вне правительства. %d депутатов проголосовали за, %d — против. Министр, отношения групп и очки решений не изменились." % [str(candidate.get("name", "Кандидат")), int(forecast.get("yes", 0)), int(forecast.get("no", 0))], str(forecast.get("detail", "")), "government")
		return
	state.influence = int(state.get("influence", 0)) - 2
	selected_ministers[slot] = candidate_id
	var original_effects := minister_initial_effects(slot, candidate_id, candidate)
	original_effects = apply_media_support_filter(original_effects)
	var appointed: Dictionary = state.get("appointed_ministers", {})
	var seen_candidates: Array = appointed.get(slot, [])
	var previous_corruption_tier := projected_corruption_tier()
	var applied_effects: Dictionary = {}
	var first_appointment := not candidate_id in seen_candidates
	if first_appointment:
		applied_effects = queue_week_change("Назначение министра: %s" % str(candidate.get("name", "Кандидат")), original_effects)
		seen_candidates.append(candidate_id)
		appointed[slot] = seen_candidates
		state.appointed_ministers = appointed
	if not current_event.is_empty() and not event_resolved:
		customize_event_for_ministers()
	update_interface()
	autosave_if_iron()
	var exact := effects_to_text(original_effects, applied_effects, previous_corruption_tier, true) if first_appointment else "Повторное назначение не создаёт второй раз первоначальную реакцию групп."
	var result_title := "МИНИСТР НАЗНАЧЕН УКАЗОМ" if override_active else "КАНДИДАТУРА УТВЕРЖДЕНА"
	var result_message := "Президент назначил %s без голосования парламента. Новый министр вступает в должность; числовая реакция будет применена при переходе к следующей неделе.\n\nЗафиксированные последствия: %s\nБудущие профильные доклады и варианты решений изменились; дипломатическая реакция может проявиться действиями соседей." % [str(candidate.get("name", "Кандидат")), exact] if override_active else "Парламент утвердил кандидатуру %s: %d депутатов за, %d — против. Новый министр вступает в должность; числовая реакция будет применена при переходе к следующей неделе.\n\nЗафиксированные последствия: %s\nБудущие профильные доклады и варианты решений изменились; дипломатическая реакция может проявиться действиями соседей." % [str(candidate.get("name", "Кандидат")), int(forecast.get("yes", 0)), int(forecast.get("no", 0)), exact]
	show_parliament_vote_result(result_title, result_message, str(state.get("last_parliament_vote_detail", forecast.get("detail", ""))), "government")


func show_parliament_vote_result(title_text: String, message: String, detail: String, return_screen: String, scroll_position := 0) -> void:
	play_game_sound("warning" if title_text.contains("ОТКЛОНЕН") else "decision")
	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(760, 0)
	content.add_theme_constant_override("separation", 18)
	content.add_child(label("ЧРЕЗВЫЧАЙНЫЙ УКАЗ" if title_text.contains("УКАЗОМ") else "ПАРЛАМЕНТСКОЕ ГОЛОСОВАНИЕ", 16, Color("#8b6c4b"), HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label(title_text, 27, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var result := label(message + "  ⓘ", 19, Color("#4c4941"), HORIZONTAL_ALIGNMENT_CENTER)
	add_hover_detail(result, detail)
	content.add_child(result)
	var back := menu_button("ВЕРНУТЬСЯ К БЮДЖЕТУ" if return_screen == "economy" else "ВЕРНУТЬСЯ К ПРАВИТЕЛЬСТВУ")
	if return_screen == "economy":
		back.pressed.connect(show_economy.bind(scroll_position))
	else:
		back.pressed.connect(show_ministers)
	content.add_child(back)
	show_overlay(content, PAPER, true, 820)


func show_notice(message: String, tooltip_detail := "") -> void:
	play_game_sound("warning")
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 20)
	content.add_child(label("СЛУЖЕБНАЯ ЗАПИСКА", 18, RED, HORIZONTAL_ALIGNMENT_CENTER))
	var message_label := label(message, 22, INK, HORIZONTAL_ALIGNMENT_CENTER)
	message_label.tooltip_text = tooltip_detail
	content.add_child(message_label)
	var close := menu_button("ПОНЯТНО")
	close.pressed.connect(close_overlay)
	content.add_child(close)
	show_overlay(content, PAPER, false)


func show_overlay(content: Control, panel_color: Color, can_cancel: bool, panel_width := 610.0) -> void:
	close_overlay()
	overlay = Control.new()
	overlay_can_cancel = can_cancel
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	game_root.add_child(overlay)
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.025, 0.03, 0.84)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(dim)
	if can_cancel:
		dim.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.pressed:
				close_overlay()
		)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(panel_width, 0)
	panel.add_theme_stylebox_override("panel", style(panel_color, 22, GOLD, 2))
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)
	margin.add_child(content)
	active_overlay_scroll = content as ScrollContainer


func current_overlay_scroll_position() -> int:
	return active_overlay_scroll.scroll_vertical if is_instance_valid(active_overlay_scroll) else 0


func restore_overlay_scroll_position(scroll: ScrollContainer, position: int) -> void:
	if position > 0:
		scroll.set_deferred("scroll_vertical", position)


func close_overlay() -> void:
	if is_instance_valid(overlay):
		overlay.queue_free()
	overlay = null
	overlay_can_cancel = false
	active_overlay_scroll = null


func check_terminal_state() -> bool:
	if bool(state.get("at_war", false)) and int(state.get("war_support", 0)) <= 0:
		var surrender_enemy := str(state.get("war_enemy", "east"))
		show_ending("КАПИТУЛЯЦИЯ", "Поддержка войны упала до нуля. Забастовали военные заводы, семьи перекрыли дороги к частям, резервисты отказались являться, а парламент потребовал принять любые условия государства «%s». Правительство подписало капитуляцию не после разгрома армии, а после исчезновения общественной воли продолжать войну." % neighbor_title(surrender_enemy))
		return true
	if bool(state.get("at_war", false)) and army_effectiveness() <= 0:
		var enemy := str(state.get("war_enemy", "east"))
		show_ending("КАПИТУЛЯЦИЯ", "%s прорвал фронт после полного распада боеспособных частей. Правительство подписало капитуляцию, армия разоружена, а внешняя политика и ключевые государственные решения перешли под контроль победителя." % neighbor_title(enemy))
		return true
	if float(state.money) <= 0.0:
		show_ending("ДЕФОЛТ", "Казна опустела. Выплаты остановились, а коалиция силовиков и парламентариев отстранила президента. Страна входит в следующий год с замороженными счетами и новым временным правительством.")
		return true
	if int(state.support) <= 0:
		show_ending("СВЕРЖЕНИЕ", "Президент утратил последнюю общественную опору. Протестующие заняли правительственный квартал, а армия отказалась защищать дворец.")
		return true
	if int(state.army) <= 0:
		show_ending("ВОЕННЫЙ ПЕРЕВОРОТ", "Командование отказалось признавать власть президента. На рассвете армия заняла правительственный квартал, а старший брат объявил о создании временного Совета национального спасения.")
		return true
	if int(state.stability) <= 0:
		show_ending("РАСКОЛ", "Центральная власть перестала исполнять решения в регионах. Соседи объявили о защите своих граждан, и страна вступила в гражданскую войну.")
		return true
	return false


func election_external_legacy_text() -> String:
	if bool(state.get("at_war", false)):
		return "Голосование прошло на фоне войны с государством «%s»; новый политический мандат не отменяет фронтовых потерь и зависимости от снабжения." % neighbor_title(str(state.get("war_enemy", "east")))
	if int(state.get("east_relation", 2)) == 3 and int(state.get("west_relation", 2)) < 3:
		return "К концу временного срока республика теснее связана с Восточным Союзом, а пространство для самостоятельного внешнего курса стало уже."
	if int(state.get("west_relation", 2)) == 3 and int(state.get("east_relation", 2)) < 3:
		return "К концу временного срока республика вошла в западную систему договоров, отдалившись от Восточного Союза."
	return "Республика сохранила промежуточное положение между соседями, вместе со свободой манёвра и постоянным риском нового давления."


func election_ending_data() -> Dictionary:
	var method := str(state.get("election_method", ""))
	var honest_score := election_honest_score(false)
	var acceptance := election_acceptance_score()
	var title := "ДОСРОЧНЫЕ ВЫБОРЫ"
	var text := ""
	if method in ["fair", "negotiated"]:
		var counted_score := election_effective_score(false, method)
		if counted_score >= 50:
			title = "ИЗБРАННЫЙ ПРЕЗИДЕНТ"
			text = "Проверяемый подсчёт дал временному президенту %d%% голосов. Сомнительное назначение вице-президентом осталось частью биографии, но теперь власть получила собственный избирательный мандат." % counted_score
		else:
			title = "МИРНАЯ ПЕРЕДАЧА ВЛАСТИ"
			text = "Временный президент получил %d%% голосов и признал поражение. Через двадцать шесть недель после смерти отца республика передала власть избранному сопернику без переворота и наследования должности." % counted_score
	elif method == "managed":
		var official_score := election_effective_score(false, "managed")
		if official_score < 50:
			title = "АППАРАТ НЕ СПАС"
			text = "Даже административный ресурс дал только %d%% официального результата при реальной электоральной опоре около %d%%. Комиссия признала победу соперника, а попытка управлять подсчётом оставила новому правительству расколотые институты." % [official_score, honest_score]
		elif acceptance >= 45:
			title = "УПРАВЛЯЕМАЯ ПОБЕДА"
			text = "Комиссия объявила %d%% за действующего президента при реальной электоральной опоре около %d%%. Аппарат обеспечил второй мандат, а достаточно устойчивые институты не позволили протесту немедленно сорвать передачу полномочий." % [official_score, honest_score]
		else:
			title = "ВЫБОРЫ БЕЗ ПРИЗНАНИЯ"
			text = "Комиссия объявила победу с %d%%, хотя реальная электоральная опора оценивалась примерно в %d%%. При уровне общественного принятия %d%% параллельный подсчёт, улица и часть государственных органов отказались считать новый мандат законным." % [official_score, honest_score, acceptance]
	elif method == "rigged":
		if acceptance >= 55 and int(state.get("army", 0)) >= 45:
			title = "ПОБЕДА ПО ПРОТОКОЛУ"
			text = "Государственные каналы объявили 68%% до завершения подсчёта. Реальная поддержка оценивалась примерно в %d%%, но армия, аппарат и достаточно устойчивые группы обеспечили исполнение официального результата." % honest_score
		else:
			title = "ИЗБИРАТЕЛЬНЫЙ КРИЗИС"
			text = "Президент объявил себе 68%% до завершения подсчёта при реальной поддержке около %d%%. Уровень принятия результата составил лишь %d%%: страна закончила временный период двумя конкурирующими центрами власти." % [honest_score, acceptance]
	elif method == "postponed":
		if bool(state.get("at_war", false)) and int(state.get("support", 0)) >= 40 and int(state.get("war_support", 0)) >= 40 and int(state.get("stability", 0)) >= 35:
			title = "ОТЛОЖЕННЫЙ МАНДАТ"
			text = "Выборы перенесли до окончания войны. Значительная часть общества приняла чрезвычайную необходимость, но временный президент остался у власти без нового срока и теперь зависит от продолжения войны и обещания всё-таки открыть участки."
		else:
			title = "ПРОСРОЧЕННЫЙ МАНДАТ"
			text = "Выборы отменили после истечения временного срока, но общество не приняло войну как достаточное оправдание. Парламент, улица и региональные власти спорят, кому принадлежат полномочия после двадцать шестой недели."
	else:
		text = "Временный срок закончился, но государственные органы не смогли установить признанный порядок передачи власти."
	text += "\n\n" + election_external_legacy_text()
	return {"title": title, "text": text}


func week_count_text(week_count: int) -> String:
	var absolute := absi(week_count)
	var last_two := absolute % 100
	var last_one := absolute % 10
	var word := "недель"
	if last_two < 11 or last_two > 14:
		if last_one == 1:
			word = "неделю"
		elif last_one in [2, 3, 4]:
			word = "недели"
	return "%d %s" % [week_count, word]


func show_ending(forced_title := "", forced_text := "") -> void:
	var ending_title := forced_title
	var ending_text := forced_text
	if ending_title == "" and str(state.get("election_method", "")) != "":
		var election_result := election_ending_data()
		ending_title = str(election_result.get("title", "ДОСРОЧНЫЕ ВЫБОРЫ"))
		ending_text = str(election_result.get("text", ""))
	if ending_title == "":
		var final_alignment := str(state.get("final_alignment", ""))
		if final_alignment == "east":
			ending_title = "ВОСТОЧНЫЙ КУРС"
			ending_text = "Восточный Союз гарантировал безопасность режима и доступ к топливу. Республика сохранила флаг и президента, но ключевые решения теперь начинаются с консультации в восточном посольстве."
		elif final_alignment == "west":
			ending_title = "ЗАПАДНЫЙ КУРС"
			ending_text = "Республика вошла в западную систему договоров. Инвестиции вернулись, парламент стал громче, а старые связи с Восточным Союзом оборвались."
		elif final_alignment == "neutral":
			ending_title = "ХРУПКИЙ НЕЙТРАЛИТЕТ"
			ending_text = "Республика не вступила ни в один блок. Оба соседа недовольны, однако ни один не решился разрушить буфер. Страна сохранила свободу манёвра вместе с долгами и противоречиями."
		elif int(state.get("east_relation", 2)) == 3 and int(state.get("west_relation", 2)) < 3:
			ending_title = "ВОСТОЧНЫЙ КУРС"
			ending_text = "Восточный Союз гарантировал безопасность режима и доступ к топливу. Республика сохранила флаг и президента, но ключевые решения теперь начинаются с консультации в восточном посольстве."
		elif int(state.get("west_relation", 2)) == 3 and int(state.get("east_relation", 2)) < 3:
			ending_title = "ЗАПАДНЫЙ КУРС"
			ending_text = "Республика вошла в западную систему договоров. Инвестиции вернулись, парламент стал громче, а старые связи с Восточным Союзом оборвались."
		elif int(state.authoritarian) >= 2:
			ending_title = "НАСЛЕДСТВО ОТЦА"
			ending_text = "Президент сохранил семейную систему власти и сделал её прочнее. Порядок восстановлен, но вопрос о том, кому принадлежит республика, больше не задают вслух."
		else:
			ending_title = "ХРУПКИЙ НЕЙТРАЛИТЕТ"
			ending_text = "Республика не вступила ни в один блок. Оба соседа недовольны, однако ни один не решился разрушить буфер. Страна сохранила свободу манёвра вместе с долгами и противоречиями."
	var survived_weeks: int = maxi(0, int(state.get("week", 1)) - 1)
	if survived_weeks < DEMO_WEEKS:
		ending_text += "\n\nПравительство продержалось %s из 26 прежде, чем правление завершилось досрочно." % week_count_text(survived_weeks)
	var ending_achievement := achievement_definition(ending_title)
	var achievement_unlocked_now := unlock_ending_achievement(ending_title)
	play_game_sound("ending")
	clear_screen()
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 42)
	margin.add_theme_constant_override("margin_right", 42)
	margin.add_theme_constant_override("margin_top", 56)
	margin.add_theme_constant_override("margin_bottom", 42)
	screen_layer.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	margin.add_child(column)
	column.add_child(label("КОНЕЦ ПРОТОТИПА • %s" % week_count_text(survived_weeks).to_upper(), 15, GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	column.add_child(label(ending_title, 46, CREAM, HORIZONTAL_ALIGNMENT_CENTER))
	if achievement_unlocked_now and not ending_achievement.is_empty():
		column.add_child(label("ДОСТИЖЕНИЕ ОТКРЫТО: %s" % str(ending_achievement.get("title", "Новая концовка")).to_upper(), 17, GREEN, HORIZONTAL_ALIGNMENT_CENTER))
	var panel := PanelContainer.new()
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", style(PAPER, 24, GOLD, 2))
	column.add_child(panel)
	var summary := VBoxContainer.new()
	summary.add_theme_constant_override("separation", 20)
	panel.add_child(summary)
	var ending_copy := label(ending_text, 23, INK, HORIZONTAL_ALIGNMENT_CENTER)
	ending_copy.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ending_copy.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	summary.add_child(ending_copy)
	summary.add_child(label("ИТОГИ ПРАВЛЕНИЯ", 16, RED, HORIZONTAL_ALIGNMENT_CENTER))
	var recruitment: Dictionary = RECRUITMENT_MODELS.get(str(state.get("recruitment_model", "mixed")), RECRUITMENT_MODELS["mixed"])
	var war_outcome := "мир" if not bool(state.get("at_war", false)) else "война с %s • потери %s" % [neighbor_title(str(state.get("war_enemy", "east"))), format_people(int(state.get("war_casualties", 0)))]
	var metrics := "Казна: %.2f млн • долг: %.2f млн\nМеждународные кредиторы: %s\nВосточный Союз: %s • Западная Федерация: %s\nВнешнее положение: %s\nПоддержка власти: %d%% • стабильность: %d%% • поддержка войны: %d%%\nНаселение: %s • военнослужащие: %s\nАрмия: лояльность %d%% • боеспособность %d%% • %s\nНаземная техника: %d • авиация: %d\nКоррупция: %s • потери доходов: %d%%" % [float(state.money), float(state.get("debt", 0.0)), creditor_obligation_level(int(state.get("creditor_obligations", 0))), neighbor_relation_band("east"), neighbor_relation_band("west"), war_outcome, state.support, state.stability, state.war_support, format_people(total_population()), format_people(int(state.get("army_personnel", 0))), state.army, army_effectiveness(), str(recruitment.get("title", "смешанная")), int(state.get("army_equipment", 0)), int(state.get("army_aircraft", 0)), corruption_level(int(state.corruption_tier)), corruption_transaction_rate(int(state.corruption_tier))]
	summary.add_child(label(metrics, 20, Color("#423e36"), HORIZONTAL_ALIGNMENT_CENTER))
	column.add_child(label("Игра не оценивает этот итог. Победа это или поражение — решаете вы.", 16, Color("#cfc3aa"), HORIZONTAL_ALIGNMENT_CENTER))
	var again := menu_button("НАЧАТЬ НОВУЮ КАМПАНИЮ")
	again.pressed.connect(show_start_screen)
	column.add_child(again)


func _unhandled_input(event: InputEvent) -> void:
	if is_fullscreen_shortcut(event):
		toggle_fullscreen()
		get_viewport().set_input_as_handled()
		return
	var cancel_pressed: bool = event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE)
	if cancel_pressed:
		if is_instance_valid(overlay) and overlay_can_cancel:
			close_overlay()
			get_viewport().set_input_as_handled()
		return
	if not is_instance_valid(game_root) or is_instance_valid(overlay) or current_event.is_empty():
		return
	if event.is_action_pressed("ui_left") or (event is InputEventKey and event.pressed and event.keycode == KEY_A):
		choose_option("left")
	elif event.is_action_pressed("ui_right") or (event is InputEventKey and event.pressed and event.keycode == KEY_D):
		choose_option("right")
	elif (event.is_action_pressed("ui_down") or (event is InputEventKey and event.pressed and event.keycode == KEY_S)) and current_event.has("third"):
		choose_option("third")


func build_event_database() -> void:
	financial_crisis_event = event(
		"Министерство экономики", "official", "#c7a96b", "Счета к оплате",
		"До обязательных выплат осталось два дня. Казначейство предупреждает: при неизменном бюджете к расчётному дню денег не останется.",
		option("Напечатать деньги", "Меньше денег • без нового долга и внешних условий • шестинедельный инфляционный шок", {"money": 21, "support": -4, "stability": -1}, "Центральный банк выпустил новые деньги. Выплаты проведены. Следующие шесть недель государственные контракты будут обходиться на 1.20 млн дороже; на третьей и шестой неделе инфляционного шока поддержка власти снизится ещё на 2 пункта.", {"printed_money": true}),
		option("Кредит фонда", "Больше денег • меньше немедленный удар по поддержке • новый долг и внешние условия", {"money": 28, "debt": 40, "creditor_obligations": 2, "support": -2}, "Международный фонд перечислил чрезвычайный транш. Республика получила деньги на ближайшие выплаты, признала новый долг и согласилась на проверку условий кредитной линии.", {"fund_debt": true}),
		option("Ничего не делать", "Немедленных изменений нет • за оставшиеся два дня бюджет ещё можно пересмотреть", {}, "Вы отложили решение и не дали казначейству нового источника денег. За оставшиеся два дня ещё можно сократить расходы или изменить распределение ресурсов; при неизменном прогнозе обязательные выплаты сорвутся.", {"financial_crisis_ignored": true})
	)
	creditor_review_event = event(
		"Международный фонд", "official", "#536f82", "Условия кредитной линии",
		"После чрезвычайного транша фонд требует на четыре недели сократить одну из статей бюджета либо сделать обслуживание долга приоритетным. Отказ означает штраф, ужесточение условий и закрытие резервной кредитной линии.",
		option("Принять сокращение", "Одна статья станет минимальной на четыре недели", {"creditor_obligations": -1}, "Правительство подписало программу сокращений.", {"creditor_austerity_accepted": true}),
		option("Приоритет выплат долга", "Обслуживание долга станет приоритетным на четыре недели", {"creditor_obligations": -1}, "Казначейство подписало обязательный график платежей.", {"creditor_debt_priority_accepted": true}),
		option("Отказаться от требований", "Штраф 10 млн • долг +12 млн • стабильность резко снизится • условия кредиторов станут максимальными", {"money": -10, "support": 4, "stability": -10, "debt": 12, "creditor_obligations": 1, "clan_oligarchs": -10}, "Президент отказался выполнять требования фонда. Кредиторы начислили штраф, закрыли резервную линию и предупредили банки о риске работы с республикой.", {"creditor_terms_refused": true, "fund_access_closed": true})
	)
	social_protest_event = event(
		"Министерство внутренних дел", "official", "#a9473f", "Пустые конверты",
		"После сокращения пенсий и пособий колонны пенсионеров, безработных и бюджетников перекрыли центр столицы. При низкой поддержке власти обещания переждать кризис никого не убедили: протестующие требуют вернуть выплаты, а профсоюзы готовят общую забастовку.",
		option("Вернуть выплаты", "Социальные расходы вернутся к базовым • новое сокращение будет запрещено на месяц • протесты прекратятся", {"support": 3, "stability": 5, "clan_workers": 8}, "Правительство восстановило базовые выплаты. Колонны разошлись, но соглашение с организаторами запрещает снова сокращать пенсии и пособия в течение четырёх недель.", {"social_budget_concession": true}),
		option("Задержать организаторов", "Новых расходов не будет • порядок частично восстановится • поддержка и профсоюзы отвернутся", {"support": -3, "stability": 3, "army": 1, "clan_workers": -8, "authoritarian": 1}, "Полиция задержала координаторов до рассвета и заблокировала профсоюзные кассы. Часть колонн рассыпалась без командования, но оставшиеся участники назвали протест политическим и потребовали освобождения арестованных.", {"social_protest_organizers_detained": true}),
		option("Разогнать колонны", "Порядок восстановится быстро • поддержка и профсоюзы резко отвернутся • армия одобрит силу", {"support": -7, "stability": 4, "army": 3, "war_support": -2, "clan_workers": -12, "authoritarian": 1}, "Полиция очистила центр до рассвета. Выплаты не восстановили, движение транспорта возобновилось, но кадры задержаний объединили разрозненных противников власти.", {"social_protest_suppressed": true})
	)
	emergency_powers_protest_event = event(
		"Министерство внутренних дел", "official", "#a9473f", "Парламент за ограждением",
		"После передачи президенту права действовать без голосования парламентская оппозиция, профсоюзы, церковные общины и региональные делегации вышли к правительственному кварталу. При низкой поддержке власти чрезвычайный закон восприняли не как военную меру, а как попытку отменить представительство на время войны.",
		option("Отменить полномочия", "Парламент вернёт контроль • поддержка и гражданские группы укрепятся • порядок и армия пострадают", {"support": 6, "stability": -6, "army": -7, "clan_oligarchs": 5, "clan_church": 5, "clan_workers": 5, "clan_regions": 5}, "Президент отменил чрезвычайные полномочия и вернул бюджеты и назначения на голосование. Коалиция протеста объявила это победой, однако штаб назвал решение капитуляцией перед улицей во время войны.", {"emergency_powers_repealed": true}),
		option("Задержать координаторов", "Порядок восстановится • поддержка и гражданские группы отвернутся • армия одобрит силу", {"support": -5, "stability": 5, "army": 2, "clan_oligarchs": -3, "clan_church": -4, "clan_workers": -8, "clan_regions": -4, "authoritarian": 1}, "Полиция задержала координаторов и очистила проходы к министерствам. Чрезвычайный закон сохранился, но разрозненные гражданские группы впервые создали общий комитет против президентских указов.", {"emergency_powers_protest_suppressed": true}),
		option("Ввести военную комендатуру", "Порядок и армия резко укрепятся • поддержка войны и отношения со всеми гражданскими группами рухнут", {"support": -8, "stability": 8, "army": 5, "war_support": -6, "clan_oligarchs": -6, "clan_church": -6, "clan_workers": -10, "clan_regions": -8, "authoritarian": 1}, "Военная комендатура закрыла центр, приостановила городской транспорт и взяла под охрану парламент. Столица подчинилась, но фронтовые семьи обвинили власть в использовании армии против собственного тыла.", {"emergency_military_command": true})
	)
	var archive_event := event(
		"Государственный архив", "official", "#8b6c4b", "Папка без печати",
		"Реставраторы нашли протоколы последних месяцев восточной оккупации. Документы подтверждают тайные аресты, но в них названы семьи нескольких действующих чиновников.",
		option("Опубликовать", "Поддержка вырастет • порядок и отношения с Востоком пострадают", {"support": 4, "stability": -2, "east_pressure": 2}, "Архив выложил сканы без купюр. Родственники пропавших собрались у бывшей тюрьмы, а Восточный Союз назвал публикацию переписыванием истории.", {"occupation_archives_published": true}),
		option("Передать комиссии", "Порядок сохранится • общество заподозрит сокрытие", {"support": -2, "stability": 2, "neutrality": 1}, "Документы опечатали до завершения закрытого расследования. Комиссия начала вызывать бывших чиновников, а газеты напечатали пустые страницы вместо фамилий.", {"occupation_archives_classified": true})
	)
	events = [
		event("Канцелярия президента", "family", "#a9473f", "День после похорон", "Несколько месяцев назад отец провёл ваше назначение вице-президентом через спорное парламентское голосование. После его убийства вы автоматически стали исполняющим обязанности президента, но только на 26 недель: затем конституция требует досрочных выборов. Служба безопасности не исключает нового нападения, а старший брат предлагает на две недели передать армии охрану парламента, телевидения, центрального банка и президентской резиденции.",
			liberal_option("Оставить охрану полиции", "Поддержка немного вырастет • брат настроит армию против решения", {"support": 4, "army": -5, "brother_trust": -1}, "Вы оставили ключевые здания под охраной полиции. Газеты называют это первым самостоятельным решением нового президента, а брат — опасным недоверием к армии после покушения.", "Поддержка немного вырастет • армия останется вне столицы", "Вы оставили ключевые здания под охраной полиции. Газеты называют это первым самостоятельным решением нового президента."),
			option("Передать объекты армии", "Порядок и армия укрепятся • поддержка снизится • развёртывание потребует денег", {"money": -2, "stability": 5, "army": 4, "support": -2, "brother_trust": 1}, "Военные на две недели заняли внешние посты у парламента, телевидения, центрального банка и президентской резиденции. Работа учреждений продолжилась, но фотографии бронемашин в центре столицы вызвали споры о том, кто теперь обеспечивает передачу власти.")),
		event("Служба безопасности", "military", "#536f82", "Генерал с чемоданом", "Следователи задержали популярного генерала при получении взятки. Он близок к вашему брату и располагает сведениями о закупках армии.",
			liberal_option("Передать в суд", "Коррупция снизится • брат настроит штаб против гражданского суда", {"corruption_tier": -1, "support": 4, "army": -9, "brother_trust": -1}, "Дело передано гражданскому суду. Брат отказался присутствовать на заседании правительства и назвал процесс атакой на армию.", "Коррупция снизится • генерал предстанет перед гражданским судом", "Дело передано гражданскому суду. Брат осудил решение, но больше не мог использовать должность министра обороны для давления на штаб."),
			option("Засекретить", "Армия поддержит • велик риск будущей утечки", {"corruption_tier": 1, "army": 8, "support": -2}, "Генерала тихо перевели в резерв. В штабе оценили жест, но копия протокола исчезла из архива.")),
		event("Губернатор Северного края", "official", "#668269", "Мороз без топлива", "Три приграничных города остались без отопления. Восточный Союз предлагает восемь недель льготных поставок. Письменных политических условий нет, но посол предупреждает: Союз ожидает ответного понимания во внешней политике.",
			option("Купить на открытом рынке", "Большие расходы • регион и самостоятельный курс укрепятся • отношения с соседями не изменятся", {"money": -14, "support": 3, "stability": 4, "neutrality": 2, "clan_regions": 7}, "Правительство закупило топливо на открытом рынке. Колонны дошли до городов до нового похолодания, а оба соседа получили одинаковые счета по рыночной цене.", {"independent_energy_purchase": true}),
			option("Принять восточную скидку", "Восемь недель дополнительной выгоды • Восток предъявит отдельное требование • Запад насторожится", {"support": 2, "stability": 2, "neutrality": -2, "east_commitment": 2, "west_pressure": 4, "clan_regions": 4}, "Восточные цистерны пересекли границу под телекамерами. Топливо подешевело, а посол попросил оставить свободное место в календаре президента через несколько недель.", {"east_energy_promise": true}),
			option("Ввести нормирование", "Казна сохранится • перебои ударят по поддержке, порядку и регионам • отношения с соседями не изменятся", {"support": -5, "stability": -6, "neutrality": 3, "clan_regions": -7, "war_support": -2}, "Школы закрыли на неделю, предприятия перешли на ночные смены, а дома отапливали по графику. Страна не приняла иностранную зависимость, но заплатила за самостоятельность внутренним кризисом.", {"winter_rationing": true})),
		event("Министр иностранных дел", "diplomat", "#6d788d", "Обвинение без доказательств", "Следствие нашло оружие, которое могло попасть в страну через восточные военные склады. Доказательств недостаточно, но публичное обвинение способно объединить общество.",
			option("Обвинить Восток", "Поддержка и военные настроения вырастут • порядок и отношения с Востоком пострадают", {"support": 5, "stability": -4, "east_pressure": 6, "west_commitment": 1, "war_support": 6}, "Вы обвинили Восточный Союз в убийстве отца. Его посол покинул церемонию, у посольства начались стычки, а западные дипломаты предложили помощь.", {"accused_east": true}),
			option("Не спешить", "Поддержка снизится • порядок и нейтральность укрепятся", {"support": -3, "stability": 2, "neutrality": 3}, "Вы отказались превращать неполные материалы в обвинение. Сторонники назвали это слабостью, зато следователи сохранили контакты по обе стороны границы.", {"investigation_open": true})),
		event("Старший брат", "military", "#a9473f", "Офицеры помнят отца", "Брат требует закрепить особую роль армии в конституции. По его словам, парламентские партии уже готовятся продать страну тому, кто предложит больше денег.",
			liberal_option("Гражданский контроль", "Брат поднимет штаб против реформы • парламент станет свободнее", {"support": 5, "army": -12, "stability": -3, "brother_trust": -2}, "Право назначать командование передано гражданскому правительству. Под давлением брата несколько генералов демонстративно подали рапорты.", "Парламент станет свободнее • влияние военных на назначения сократится", "Право назначать командование передано гражданскому правительству. Новый министр обороны обеспечил исполнение реформы без организованного выступления штаба.", {"parliament_free": true}),
			option("Гарантии армии", "Стабильность вырастет • военные усилятся", {"army": 10, "stability": 6, "support": -4, "authoritarian": 1}, "Армия получила места в Совете безопасности. Брат заявил, что отец одобрил бы ваше решение.")),
		event("Западная делегация", "diplomat", "#536f82", "Пакет модернизации", "Западная Федерация предлагает первый транш, подготовку чиновников и временный доступ к рынку. Через несколько недель комиссия проверит государственные компании и закупки перед открытием второго этапа.",
			liberal_option("Подписать", "Казна вырастет • брат и Восток ответят • Запад потребует реформ", {"money": 18, "support": 2, "west_commitment": 2, "east_pressure": 5, "army": -6}, "Соглашение подписано. Брат назвал реформы капитуляцией, Восточный Союз начал проверку грузов на границе, а совместная комиссия запросила реестры компаний до перечисления следующей помощи.", "Казна вырастет • Восток ответит • Запад потребует реформ", "Соглашение подписано. Запад объявил его историческим, Восточный Союз начал проверку грузов на границе, а совместная комиссия запросила реестры компаний до перечисления следующей помощи.", {"western_package": true}),
			option("Сохранить дистанцию", "Нейтральность укрепится • казна и отношения с Западом пострадают", {"neutrality": 3, "support": -2, "stability": 1, "west_pressure": 3}, "Делегация уехала без заявления. Министр финансов вычеркнул ожидаемый транш, зато государственные компании сохранили прежние правила управления."),
			option("Принять только техническую миссию", "Небольшой транш • отношения с Западом улучшатся, с Востоком ухудшатся • полного доступа к рынку не будет", {"money": 6, "support": 1, "west_commitment": 1, "east_pressure": 2, "clan_oligarchs": -3}, "Западные специалисты заняли два этажа министерства, но не получили права проверять предприятия без приглашения. Республика получила оборудование и консультации, сохранив большую часть свободы ценой меньшей помощи.", {"western_technical_mission": true})),
		event("Редакция столичной газеты", "official", "#8b6c4b", "Слишком большой портрет", "Без конкурса отпечатаны десять тысяч парадных портретов нового президента. В сельских школах они не помещаются между окнами, а подрядчик принадлежит родственнику партийного казначея. Газеты спорят уже не о размере рам, а о том, является ли нелепая закупка первым испытанием новой власти.",
			liberal_option("Отменить заказ", "Пресса оценит самоиронию • брат поднимет офицерские клубы", {"money": -3, "support": 3, "army": -4, "brother_trust": -1}, "Портреты отправили на переработку. Газеты напечатали добрую карикатуру, а брат организовал выступления офицерских клубов в защиту наследия отца.", "Пресса оценит самоиронию • культ личности ослабнет", "Портреты отправили на переработку. Газеты напечатали добрую карикатуру; без брата во главе обороны офицерские клубы не превратили спор о портретах в армейский конфликт."),
			option("Расширить простенки", "Расходы и недовольство общества • армия и брат поддержат жест", {"money": -6, "support": -3, "army": 5, "brother_trust": 1, "authoritarian": 1}, "Министерство образования нашло средства на ремонт стен. Строители называют программу буквальным расширением власти, зато портреты торжественно открыли армейские делегации."),
			option("Продать тираж на аукционе", "Казна вернёт часть денег • скандал станет народной сатирой • партийный подрядчик потеряет контракт", {"money": 2, "support": 2, "stability": -2, "clan_oligarchs": -4}, "Портреты продавали поштучно с сертификатом неудачной закупки. Самый большой купила сатирическая газета и повесила напротив парламента, а подрядчик потребовал компенсацию.")),
		event("Министерство внутренних дел", "official", "#a9473f", "Весна в столице", "Студенты требуют раскрыть материалы о покушении и провести досрочные выборы. Пока протест мирный, но министр сообщает о людях с оружием среди участников.",
			liberal_option("Допустить митинг", "Стабильность может снизиться • поддержка вырастет • брат обвинит власть в слабости", {"support": 6, "stability": -5, "army": -3}, "Митинг прошёл без вмешательства армии. К вечеру радикалы ушли, а площадь осталась за студентами; брат публично обвинил правительство в слабости.", "Стабильность может снизиться • поддержка вырастет", "Митинг прошёл без вмешательства армии. К вечеру радикалы ушли, а площадь осталась за студентами."),
			option("Зачистить площадь", "Порядок восстановится • будут жертвы", {"stability": 9, "support": -10, "army": 4, "war_support": -2, "authoritarian": 1}, "Площадь очищена за сорок минут. Больницы сообщили о погибших, телевидение — о восстановленном движении.")),
		event("Совет безопасности", "military", "#536f82", "Учебный центр", "Западная Федерация предлагает постоянный учебный центр и обмен разведданными. Это повысит совместимость армии и доступ к помощи, но иностранные специалисты получат сведения о штабах, связи и снабжении.",
			option("Разместить постоянный центр", "Армия и казна укрепятся • Восток ответит резко • при низкой поддержке начнутся протесты", {"army": 10, "war_support": 4, "support": -5, "west_commitment": 2, "east_pressure": 7, "money": 7}, "Западные военнослужащие прибыли как инструкторы. Восточный Союз объявил договор прямой угрозой, а жители соседних посёлков потребовали ограничить передвижение конвоев.", {"foreign_base": "west", "western_intelligence_link": true, "unrest": {"cause": "размещение постоянного иностранного учебного центра", "kind": "civic", "base_level": 1, "reversible": false, "condition": "low_support"}}),
			option("Отказать", "Нейтральность и поддержка укрепятся • собственная оборона потребует денег", {"neutrality": 4, "army": -5, "support": 2, "money": -6, "east_pressure": 2, "west_pressure": 2}, "Правительство отказало Западу и публично закрыло вопрос об иностранных базах. Штаб потребовал срочно оплатить собственные учения, а оба соседа усилили наблюдение за границей.", {"independent_defense_training": true}),
			option("Проводить только временные учения", "Заметные расходы • армия получит часть пользы • постоянного иностранного объекта не будет", {"money": -8, "army": 5, "war_support": 2, "west_commitment": 1, "east_pressure": 3, "neutrality": 1}, "Инструкторы провели шестинедельные учения и покинули страну вместе с оборудованием связи. Штаб получил новые методики, но не постоянную поддержку.", {"temporary_western_exercises": true})),
		event("Пограничная администрация", "official", "#668269", "Два паспорта", "Восточное консульство ускоренно выдаёт паспорта жителям приграничных районов. Документы пока не дают местных прав, но Союз уже называет их владельцев своими гражданами и собирает отдельные списки.",
			option("Зарегистрировать владельцев", "Государство узнает масштаб явления • регионы успокоятся • Восток потребует признать отдельное представительство", {"money": -3, "stability": 3, "support": -2, "east_commitment": 1, "clan_regions": 6}, "Муниципалитеты начали добровольную регистрацию. Через неделю восточное консульство потребовало использовать его собственный список и признать совет владельцев паспортов.", {"passport_policy_pending": true, "foreign_passports_registered": true}),
			option("Закрыть консульские пункты", "Поддержка вырастет • порядок в приграничье ухудшится • Восток предъявит ответное требование", {"support": 5, "stability": -6, "east_pressure": 4, "war_support": 4, "clan_regions": -9}, "Полиция опечатала временные пункты, но выдача продолжилась через мобильные автобусы за границей. Восток объявил закрытие дискриминацией.", {"passport_policy_pending": true, "east_consulates_closed": true}),
			option("Допустить независимый учёт", "Расходы • доверие регионов укрепится • отношения с соседями не изменятся • спор не будет решён", {"money": -5, "stability": 2, "neutrality": 2, "clan_regions": 4}, "Наблюдатели начали опрашивать жителей и проверять случаи давления. Консульство сохранило работу, но больше не могло скрывать темпы выдачи документов. Оба соседа публично выразили недовольство, однако дипломатические отношения остались на прежнем уровне.", {"passport_policy_pending": true, "passport_observers_invited": true})),
		event("Бюро переписи", "official", "#668269", "Люди без адресов", "Перепись обнаружила тридцать тысяч мигрантов и беженцев, которые давно работают без постоянной регистрации. Статистики предлагают признать их обычными работающими гражданами, но оформление потребует денег.",
			option("Оформить документы", "Расходы • работников и налогоплательщиков станет больше", {"money": -4, "pop_migrants": -30000, "pop_employed": 30000, "support": 2, "clan_workers": 4, "clan_regions": -3}, "Тридцать тысяч человек получили постоянные документы и вошли в официальный рынок труда. Муниципалитеты потребовали дополнительное финансирование."),
			option("Оставить временный статус", "Казна получит немного денег • положение людей останется нестабильным", {"money": 3, "support": -2, "stability": -3, "clan_oligarchs": 6}, "Крупные подрядчики сохранили дешёвую рабочую силу и перечислили налоговый аванс. Правозащитники опубликовали фотографии бараков.", {"migrant_gray_status": true}),
			option("Дать регистрацию через муниципалитеты", "Центр потратит меньше • регионы сами определят квоты • губернаторы и местные различия усилятся", {"money": -2, "pop_migrants": -18000, "pop_employed": 18000, "support": 1, "stability": -1, "clan_regions": 8}, "Губернаторы получили квоты и собственные критерии. В одном городе документы выдавали по трудовому договору, в соседнем — только семьям с детьми; люди начали переезжать между очередями.", {"municipal_migrant_quotas": true})),
		event("Пограничная служба", "official", "#536f82", "Автобусы у перевала", "На восточной границе остановилась колонна с сорока тысячами людей, бегущих от подавленных беспорядков в Восточном Союзе. Союз называет их преступниками и требует закрыть пропускные пункты.",
			option("Открыть границу", "Большие расходы • церковь поможет • Восток ответит резко", {"money": -9, "pop_migrants": 40000, "support": 1, "stability": -2, "clan_church": 8, "east_pressure": 3, "west_commitment": 1}, "Людей разместили в школах и церковных приютах. Восточный посол потребовал выдать организаторов исхода."),
			option("Развернуть колонну", "Порядок сохранится • церковь и часть общества будут возмущены", {"stability": 2, "support": -3, "clan_church": -10, "east_commitment": 1, "war_support": 2}, "Шлагбаумы остались закрыты. Восточный Союз поблагодарил правительство, а ночью церковные колокола звонили в память о погибших у перевала.", {"refugees_turned_back": true}),
			option("Открыть временный лагерь у границы", "Расходы будут умеренными • решение отложится • регионы и оба соседа начнут давить на лагерь", {"money": -5, "pop_migrants": 15000, "support": -1, "stability": -3, "clan_regions": -4, "neutrality": 2, "east_pressure": 2}, "Пятнадцать тысяч человек впустили в палаточный лагерь под международным наблюдением, остальные остались у перевала. Восток требует списки, Запад — свободный проход, губернатор — дату закрытия.", {"border_refugee_camp": true})),
		event("Министерство экономики", "official", "#c7a96b", "Пустующие цеха", "Три оборонных завода стоят без заказов, пока в промышленных городах растёт безработица. Можно запустить государственный заказ или передать цеха частному объединению за налоговые льготы.",
			option("Дать госзаказ", "Крупные расходы • занятость и выпуск техники вырастут", {"money": -10, "pop_unemployed": -18000, "pop_employed": 18000, "army_equipment": 12, "clan_workers": 10, "clan_oligarchs": -6}, "Заводы вновь включили ночные смены. Первые машины переданы армии, но казначейство требует объяснить источник следующих выплат.", {"state_factory_order": true}),
			option("Отдать частникам", "Меньше расходов • рабочих мест станет больше • коррупция усилится", {"money": -5, "pop_unemployed": -24000, "pop_employed": 24000, "corruption_tier": 1, "clan_oligarchs": 10, "clan_workers": 4}, "Промышленное объединение быстро наняло рабочих. В приложении к договору обнаружились льготы, которых депутаты не помнят на голосовании.", {"private_factory_concession": true})),
		event("Бюджетный комитет", "official", "#8b6c4b", "Квартальная поправка", "Наступил срок квартальной корректировки. Денег хватит либо на досрочную выплату кредиторам, либо на обещанную прибавку пенсионерам. Провести оба решения без нового займа невозможно.",
			option("Снизить долг", "Очень большие расходы • долг и финансовый риск заметно снизятся • поддержка пострадает", {"money": -14, "debt": -35, "support": -4, "stability": 4}, "Казначейство досрочно погасило крупную часть обязательств. Кредиторы смягчили условия, а союзы пенсионеров объявили, что правительство оплатило доверие банков их обещанной прибавкой.", {"quarter_debt_paid": true}),
			option("Доплатить пенсионерам", "Большие расходы • поддержка вырастет • долг и бюджетный риск усилятся", {"money": -9, "debt": 14, "support": 6, "stability": -2}, "Пенсионеры получили разовую доплату. Правительство перенесло квартальный платёж и взяло краткосрочный заём, поэтому следующая бюджетная поправка станет тяжелее.", {"pension_supplement_paid": true})),
		event("Министерство обороны", "military", "#a9473f", "Некомплект гарнизонов", "Штаб сообщает, что приграничным гарнизонам не хватает восьми тысяч человек. Министр обороны предлагает провести срочный шестимесячный набор либо ограничиться дорогими выплатами контрактникам.",
			option("Провести срочный набор", "Армия быстро вырастет • экономика и поддержка войны пострадают • при низкой поддержке войны начнутся протесты", {"pop_unemployed": -6000, "pop_employed": -2000, "army_personnel": 8000, "army": 4, "support": -4, "war_support": -6, "stability": -2}, "Повестки закрыли нехватку людей. Заводы пожаловались на уход специалистов, а в университетах появились группы помощи уклонистам.", {"emergency_six_month_draft": true, "unrest": {"cause": "срочный шестимесячный призыв", "kind": "antiwar", "base_level": 1, "reversible": false, "condition": "low_war_support"}}),
			option("Поднять выплаты", "Большие расходы • прирост будет меньше, но армия поддержит решение", {"money": -9, "pop_unemployed": -2000, "army_personnel": 2000, "army": 7, "support": 1, "war_support": 2}, "Контракт продлили опытные сержанты, и набор пошёл без облав. Штаб признаёт, что часть вакансий всё равно осталась открытой.", {"military_retention_bonus": true})),
		event("Военная приёмка", "military", "#536f82", "Коробки передач", "На новых бронемашинах лопаются коробки передач. Завод принадлежит союзнику правящей партии. Инспекторы требуют полного аудита, владелец обещает всё исправить без публичного скандала.",
			liberal_option("Провести аудит", "Очень большие расходы • коррупция снизится • брат и владельцы завода ответят", {"money": -11, "army_equipment": 16, "corruption_tier": -1, "army": -2, "clan_oligarchs": -8}, "Партию машин отозвали и заменили. Аудиторы нашли завышенные сметы, а брат использовал публикацию сведений о технике, чтобы настроить командование против правительства.", "Очень большие расходы • коррупция снизится • владельцы завода ответят", "Партию машин отозвали и заменили. Аудиторы нашли завышенные сметы; новый министр обороны не позволил превратить проверку подрядчика в конфликт армии с правительством.", {"military_factory_audit": true}),
			option("Принять тихий ремонт", "Умеренные расходы • армия быстрее получит технику • коррупция усилится", {"money": -6, "army_equipment": 10, "corruption_tier": 1, "army": 4, "clan_oligarchs": 8}, "Завод заменил часть узлов за закрытыми воротами. Машины вернулись в части, а контракт владельца продлили без конкурса.", {"military_repair_coverup": true})),
		event("Военно-воздушное командование", "military", "#536f82", "Самолёты с чужими кодами", "Западная Федерация предлагает шесть подержанных самолётов. Республика не умеет производить авиацию, поэтому штаб одновременно запросил встречное предложение Восточного Союза.",
			option("Купить западные", "Очень большие расходы • авиация усилится быстро • Восток ответит", {"money": -16, "army_aircraft": 6, "army": 6, "west_commitment": 1, "east_pressure": 5}, "Шесть самолётов приземлились под охраной западных техников. Восточный Союз объявил поставку нарушением регионального равновесия.", {"western_aircraft_contract": true}),
			option("Принять восточную поставку", "Расходы ниже • самолётов будет меньше • Запад получит повод для давления", {"money": -9, "army_aircraft": 4, "army": 4, "east_commitment": 2, "west_pressure": 4}, "Восточный Союз передал четыре самолёта из резерва и прислал собственных техников. Посол напомнил, что запчасти будут поступать только при сохранении сотрудничества.", {"eastern_aircraft_supply": true}),
			option("Отложить закупку", "Казна сохранится • авиационный разрыв и недовольство штаба вырастут", {"army": -5, "war_support": -4, "neutrality": 2}, "Переговоры поставили на паузу. Казначейство сохранило деньги, но командование отменило часть полётов и предупредило, что собственными заводами заменить самолёты невозможно.", {"aircraft_purchase_deferred": true})),
		event("Министерство промышленности", "official", "#c7a96b", "Руда дешевле щебня", "Мировая цена металлов обвалилась на несколько недель. Экспортёры предлагают сохранить поставки ради контрактов, а профсоюзы требуют перенаправить почти всю недельную добычу оборонным заводам.",
			option("Сохранить экспорт", "Доход от металла снизится • контракты сохранятся • военное производство замедлится", {"clan_oligarchs": 7, "clan_workers": -6}, "Экспортные составы ушли по действующим контрактам, но выручка резко упала. Оборонные заводы получили лишь остаток сырья.", {"metal_to_equipment": 1, "metal_price_factor": 0.7, "metal_price_weeks": 8, "metal_export_priority": true}),
			option("Загрузить заводы", "Экспорт сократится • рабочие и армия поддержат решение", {"money": -4, "army": 3, "clan_workers": 7, "clan_oligarchs": -6}, "Семь единиц недельной добычи направили на выпуск наземной техники. Авиационных заводов у республики нет, поэтому самолёты по-прежнему придётся покупать за рубежом.", {"metal_to_equipment": 7, "metal_price_factor": 0.7, "metal_price_weeks": 8, "metal_defense_priority": true})),
		event("Энергетическая комиссия", "official", "#8b6c4b", "Последние цистерны", "Восточный Союз предлагает аванс за долгосрочную поставку большей части недельной добычи нефти. Штаб требует оставить всё топливо для учений наземной техники и авиации.",
			option("Оставить армии", "Экспорт исчезнет • снабжение и поддержка армии вырастут", {"army": 5, "war_support": 2, "neutrality": 1, "clan_oligarchs": -4}, "Нефтяные цистерны ушли в гарнизоны. Учения состоялись в полном объёме, а экспортёры потребовали компенсации.", {"oil_to_army": 12, "oil_reserved_for_army": true}),
			option("Подписать контракт", "Казна сильно вырастет • армия останется без части топлива", {"money": 10, "army": -6, "east_commitment": 1, "west_pressure": 1, "clan_oligarchs": 7}, "Восточный аванс поступил в казну. Для армии оставили четыре единицы добычи, поэтому часть полётов и учений отменили.", {"oil_to_army": 4, "eastern_oil_contract": true})),
		event("Совет по образованию", "official", "#8b6c4b", "Учебник Веры", "Церковь Веры подготовила бесплатный учебник для всех школ. В нём история независимости названа исполнением завета отца. Светские учителя требуют сохранить единый гражданский курс.",
			option("Принять учебник", "Церковь и порядок укрепятся • учителя и профсоюзы ответят", {"support": 2, "stability": 3, "clan_church": 12, "clan_workers": -9, "authoritarian": 1}, "Школы получили бесплатные книги. Церковь организовала торжественные уроки, а учительские союзы начали кампанию против политической главы.", {"faith_school_curriculum": true}),
			option("Сохранить светский курс", "Учителя поддержат решение • церковь расшатает порядок", {"support": 1, "stability": -3, "neutrality": 1, "clan_church": -12, "clan_workers": 9}, "Министерство отклонило церковный учебник. Учительские союзы приветствовали решение, а воскресные проповеди впервые открыто критиковали президента.", {"secular_school_curriculum": true}),
			option("Сделать курс выборным", "Открытого проигравшего не будет • школы и регионы получат разные программы • печать комплектов потребует денег", {"money": -4, "support": 1, "stability": -2, "clan_church": 5, "clan_workers": 4, "clan_regions": 4}, "Родителям разрешили выбирать между гражданским и церковным курсом. В крупных школах появились две группы, в малых один учитель теперь ведёт несовместимые учебники по очереди.", {"elective_faith_curriculum": true})),
		event("Министерство экономики", "official", "#a9473f", "Красные каски", "Шахтёры заняли административное здание металлического комбината. Они требуют погасить задержки по зарплате и уволить директора, связанного с крупным олигархом.",
			option("Выполнить требования", "Большие расходы • рабочие поддержат власть • олигархи ответят", {"money": -9, "stability": 4, "clan_workers": 12, "clan_oligarchs": -10}, "Задолженность погасили, директора сняли. Шахтёры вернулись в смены, а владельцы комбината остановили пожертвования правящей партии.", {"miners_demands_met": true}),
			option("Нанять замену", "Казна сэкономит • часть людей потеряет работу • нарушение трудовых прав вызовет более широкую забастовку", {"money": 3, "pop_employed": -5000, "pop_unemployed": 5000, "stability": -6, "corruption_tier": 1, "clan_workers": -15, "clan_oligarchs": 8}, "Полиция освободила проходную, а подрядчик привёз сменных рабочих. Пять тысяч участников забастовки уволены, оборудование несколько раз останавливалось из-за саботажа.", {"miners_strike_broken": true, "unrest": {"cause": "увольнение бастующих шахтёров и найм штрейкбрехеров", "kind": "labor", "labor": true, "base_level": 2, "reversible": false}})),
		event("Военная разведка", "military", "#536f82", "Добровольцы без шевронов", "Правительство далёкой страны просит не мешать набору добровольцев для её гражданской войны. Западная Федерация поддерживает эту сторону, Восточный Союз вооружает её противников.",
			option("Помочь тайному набору", "Люди покинут страну • армия получит опыт • Восток обвинит республику", {"money": -6, "pop_employed": -2500, "pop_unemployed": -1500, "war_support": 6, "army": 3, "west_commitment": 1, "east_pressure": 3}, "Четыре тысячи добровольцев выехали через туристические фирмы. Официально государство не участвовало, но фотографии инструкторов уже появились в сети.", {"covert_volunteers_sent": true}),
			option("Послать только помощь", "Расходы • поддержка и нейтралитет вырастут • военного опыта не будет", {"money": -7, "support": 4, "war_support": -2, "neutrality": 2}, "Вместо людей республика отправила врачей, палатки и лекарства. Обе стороны конфликта пропустили конвой, хотя ни одна не поблагодарила публично.", {"humanitarian_convoy_sent": true}),
			option("Запретить вербовку обеих сторон", "Люди останутся в стране • оба соседа окажут давление • полиция получит новые полномочия", {"money": -3, "stability": 3, "war_support": -4, "east_pressure": 2, "west_pressure": 2, "authoritarian": 1}, "Вербовочные офисы закрыли, счета посредников заморозили. Часть людей отказалась от поездки, остальные пересекли границу как туристы, а оба посольства обвинили республику в помощи противнику.", {"foreign_recruitment_banned": true})),
		event("Следственная комиссия", "military", "#a9473f", "Пропавший свидетель", "Офицер снабжения, готовый рассказать о происхождении оружия из дела о покушении, исчез вместе с семьёй. Следователи просят публичных гарантий защиты, а старший брат требует передать поиск военной разведке.",
			liberal_option("Защитить свидетелей публично", "Расходы • следствию начнут доверять • брат настроит армию против расследования", {"money": -5, "support": 4, "army": -5, "corruption_tier": -1, "brother_trust": -1}, "Президент объявил награду и программу защиты. Комиссия получила новые показания о военных складах, а брат назвал расследование атакой на армию. Его положение в министерстве пошатнулось.", "Расходы • следствию начнут доверять • коррупция снизится", "Президент объявил награду и программу защиты. Комиссия получила новые показания о военных складах; гражданское руководство Минобороны не позволило представить расследование атакой на всю армию.", {"public_witness_protection": true, "defense_alternatives_unlocked": true}),
			option("Передать поиск брату", "Армия и порядок укрепятся • расследование станет зависеть от военных", {"stability": 3, "army": 6, "support": -3, "brother_trust": 1, "authoritarian": 1}, "Военная разведка закрыла границы и изъяла архивы комиссии. Через двое суток она сообщила, что офицер действовал один и погиб при задержании.", {"investigation_under_brother": true})),
		event("Министр иностранных дел", "diplomat", "#6d788d", "Таможня до заката", "Восточный Союз задержал грузовые составы после сообщений о переходе республики на западные правила торговли. Он предлагает восстановить пропуск только после допуска своих инспекторов на республиканские таможенные пункты. Приграничные губернаторы требуют решить вопрос до закрытия рынков.",
			option("Допустить инспекторов", "Торговля возобновится и даст постоянный доход • Восток получит доступ к базе перевозчиков • коррупция усилится", {"money": 9, "stability": 3, "east_commitment": 1, "west_pressure": 2, "corruption_tier": 1, "clan_regions": 6}, "Составы пересекли границу до вечера. Восточные инспекторы заняли кабинеты на трёх пунктах и получили доступ к базе перевозчиков.", {"joint_eastern_customs": true}),
			option("Ввести ответные проверки", "Казна и регионы пострадают • поддержка и военные настроения вырастут", {"money": -7, "support": 6, "stability": -4, "war_support": 5, "neutrality": 2, "east_pressure": 5, "clan_regions": -7}, "Республика остановила встречные составы. На границе выросла очередь грузовиков, Восточный Союз начал переброску частей, и правительство официально признало военную угрозу.", {"reciprocal_border_checks": true, "military_threat": true}),
			option("Перенаправить грузы на Запад", "Очень большие расходы сейчас • Восток усилит давление • западный рынок временно откроется", {"money": -11, "support": 2, "stability": -2, "west_commitment": 2, "east_pressure": 6, "clan_regions": -3}, "Составы развернули к западным перевалам, перегрузили на другую колею и заново сертифицировали. Часть товара испортилась, зато экспортёры впервые получили альтернативный маршрут.", {"extend_west_market_access": true, "western_transit_route": true})),
		event("Центральная избирательная комиссия", "official", "#c7a96b", "Досрочные выборы", "Двадцать шесть недель временного президентства закончились. Участки закрываются вечером, а комиссии готовят протоколы. Можно заранее обязаться признать подсчёт, подключить государственный аппарат к обеспечению нужного результата или объявить победу до завершения подсчёта.",
			option("Признать итог подсчёта", "Результат определят реальная поддержка, группы и выбранные правила выборов • возможно мирное поражение", {}, "Президент приказал не вмешиваться в передачу протоколов и публично обязался признать итог комиссии.", {"election_method": "fair"}),
			option("Использовать аппарат", "Официальный результат улучшится • поддержка и доверие к процедуре снизятся • непризнание возможно", {"support": -5, "stability": -4, "clan_oligarchs": 6, "authoritarian": 1}, "Администрации получили целевые показатели явки, государственные каналы — единую сетку эфира, а председатели комиссий — звонки из президентской канцелярии.", {"election_method": "managed"}),
			option("Объявить победу заранее", "Поражение в протоколах станет невозможным • страна, группы и улица могут не признать новый мандат", {"support": -9, "stability": -8, "army": 3, "clan_oligarchs": -6, "clan_church": -6, "clan_workers": -10, "clan_regions": -8, "authoritarian": 1}, "Государственное телевидение объявило победу президента до поступления половины протоколов. Оппозиция потребовала от комиссии и армии решить, существует ли после этого законный результат.", {"election_method": "rigged"}))
	]
	var language_event := event("Комиссия по языкам", "official", "#668269", "Три языка в одном классе", "В приграничных школах дети учатся на государственном языке, языке Восточного Союза или языке западной общины — в зависимости от директора. Перед общими экзаменами суд потребовал установить единое правило, а оба соседа уже объявили себя защитниками местных семей.",
		option("Оставить только государственный", "Поддержка и военные настроения вырастут • приграничные районы начнут протесты • Восток усилит давление", {"money": -3, "support": 5, "stability": -5, "war_support": 4, "clan_regions": -9, "east_pressure": 4}, "Учителей отправили на срочную переподготовку. В столице решение встретили флагами, но в приграничных городах родители начали не пускать детей на уроки.", {"state_language_only": true, "unrest": {"cause": "запрет местных языков в приграничных школах", "kind": "regional", "base_level": 2, "reversible": true, "reversal": "language"}}),
		option("Ввести местное двуязычие", "Потребуются заметные расходы • порядок и отношения с регионами укрепятся • единая программа станет сложнее", {"money": -7, "support": 1, "stability": 4, "clan_regions": 7, "neutrality": 1}, "Каждый район получил право выбрать второй язык по данным переписи. Пришлось нанимать новых учителей и печатать три комплекта экзаменов, зато школы продолжили работу.", {"local_bilingualism": true}),
		option("Провести местные референдумы", "Расходы будут умеренными • регионы получат больше власти • кампания расколет несколько городов", {"money": -4, "support": -2, "stability": -2, "war_support": -2, "clan_regions": 10, "neutrality": 3}, "Голосования дали разные результаты даже в соседних посёлках. Губернаторы приветствовали самостоятельность, а министерство получило карту из десятков несовместимых школьных правил.", {"language_referendums": true}))
	var media_sale_event := event("Антимонопольная комиссия", "official", "#536f82", "Канал на продажу", "Убыточный крупнейший телеканал ищет владельца. Холдинг из Восточного Союза обещает сохранить весь штат, общественный фонд просит государственный заём, а комиссия предлагает ограничить иностранную долю и раздробить сделку.",
		option("Разрешить восточную покупку", "Казна и олигархи выиграют • канал сохранит штат • новый владелец позднее потребует доступ к политическому эфиру", {"money": 8, "support": -2, "stability": 2, "east_commitment": 1, "clan_oligarchs": 7}, "Холдинг погасил долги канала и сохранил редакцию. В договоре обнаружился пункт о консультантах владельца по вопросам международной политики.", {"eastern_media_sale": true}),
		option("Выдать заём общественному фонду", "Крупные расходы • поддержка и независимость редакции укрепятся • олигархи потеряют актив", {"money": -8, "support": 4, "stability": -1, "clan_oligarchs": -6, "clan_workers": 3, "neutrality": 2}, "Журналисты и зрители создали общественный фонд и получили государственный заём. Канал сохранил независимость, но теперь должен казне и требует постоянного контроля расходов.", {"public_media_trust": true}),
		option("Ограничить иностранную долю", "Умеренные расходы и временная неопределённость • Восток усилит давление • правила станут прозрачнее", {"money": -3, "support": 2, "stability": -2, "east_pressure": 3, "neutrality": 2}, "Комиссия разрешила иностранцам владеть только четвертью канала и обязала раскрывать все платежи. Покупатель отступил, а редакция начала искать нескольких мелких инвесторов.", {"foreign_media_cap": true}))
	var mobility_event := event("Министерство труда", "diplomat", "#536f82", "Визовые окна", "Западная Федерация предлагает безвизовый режим и свободный доступ к сезонной работе. Переводы семей поддержат экономику, но больницы, стройки и армейский резерв могут потерять молодых специалистов.",
		option("Открыть свободный выезд", "Поддержка и переводы вырастут • часть людей уедет • отношения с Западом улучшатся, с Востоком ухудшатся", {"money": 5, "support": 4, "pop_employed": -18000, "pop_unemployed": -12000, "west_commitment": 1, "east_pressure": 2, "clan_workers": 3}, "Очереди выстроились у визовых центров. Безработица снизилась, семьи получили первые переводы, а предприятия начали предлагать более высокие зарплаты оставшимся специалистам.", {"west_labor_mobility": true}),
		option("Согласовать отраслевые квоты", "Расходы на управление • безработица немного снизится • утечка работников будет ограничена", {"money": -3, "support": 2, "pop_unemployed": -8000, "west_commitment": 1, "neutrality": 1, "clan_oligarchs": -3}, "Правительство выдало ограниченные разрешения безработным и сезонным рабочим. Запад согласился на квоты, а работодатели потребовали ещё больше исключений.", {"limited_west_mobility": true}),
		option("Отказаться от режима", "Работники останутся в стране • поддержка снизится • нейтральность и отношения с Востоком укрепятся", {"support": -3, "neutrality": 3, "west_pressure": 3, "east_commitment": 1, "clan_workers": -2}, "Переговоры закрыли. Восток приветствовал решение, а молодые специалисты обвинили правительство в лишении их возможности заработать.", {"west_mobility_refused": true}))
	var committee_event := event("Председатель парламента", "official", "#8b6c4b", "Комитет двенадцати", "Двенадцать депутатов лояльного большинства потребовали открытых слушаний по военным закупкам и расходам фонда имени вашего отца. Они ещё не стали оппозицией, но без их голосов следующая бюджетная поправка не пройдёт.",
		liberal_option("Открыть слушания", "Поддержка вырастет и коррупция снизится • брат настроит армию против парламентского расследования", {"support": 5, "stability": -4, "army": -2, "corruption_tier": -1, "clan_oligarchs": -9}, "Заседание показали в прямом эфире. Аудиторы нашли двойные счета, брат назвал слушания атакой на армию, а правящая фракция впервые голосовала не по команде.", "Поддержка вырастет и коррупция снизится • парламентский скандал ударит по порядку и дисциплине партии", "Заседание показали в прямом эфире. Аудиторы нашли двойные счета, а правящая фракция впервые голосовала не по команде; новый министр обороны не позволил втянуть всю армию в скандал.", {"committee_hearings_open": true}),
		option("Закрыть комитет голосами фракции", "Парламент быстро успокоится • поддержка снизится • дисциплина старой гвардии и зависимость от покровителей усилятся", {"support": -5, "stability": 5, "corruption_tier": 1, "clan_oligarchs": 7, "authoritarian": 1}, "Депутатов заменили за одно вечернее заседание. Бюджет прошёл без вопросов, но утром газеты напечатали имена двенадцати исключённых на первых полосах.", {"committee_closed": true}),
		option("Добавить региональные поправки", "Потребуются крупные расходы • региональные депутаты поддержат кабинет • торговля голосами станет очевидной", {"money": -9, "support": 1, "stability": 3, "corruption_tier": 1, "clan_regions": 9}, "Каждый из двенадцати округов получил собственную стройку. Комитет отозвал требование, а остальные губернаторы прислали председателю парламента списки своих цен.", {"committee_regional_deal": true}))
	var health_event := event("Личный врач президента", "family", "#a9473f", "Снимок из клиники", "Газеты получили фотографию президента у кардиологического отделения. Врач говорит об истощении и нарушении ритма: непосредственной угрозы нет, но восемнадцатичасовой график придётся сократить. Старший брат уже предложил временно вести заседания Совета безопасности.",
		option("Опубликовать заключение", "Открытость укрепит поддержку • вид ослабленного президента встревожит аппарат и военных", {"support": 5, "stability": -4, "army": -2, "brother_trust": -1}, "Медицинское заключение появилось на сайте без купюр. Люди оценили честность, но рынки просели, а брат заявил офицерам, что государство не может болеть вместе с президентом."),
		option("Скрыть диагноз", "Внешнее спокойствие сохранится • врачей заставят изменить документы • слухи ударят по доверию", {"support": -3, "stability": 3, "corruption_tier": 1, "brother_trust": -1}, "Клинику обязали назвать фотографию монтажом, а журнал приёма переписали. Рабочий график не изменился, но оригинал страницы уже предлагают купить трём редакциям."),
		option("Передать Совет брату", "Армия и порядок укрепятся • общественная поддержка снизится • брат получит политический вес", {"support": -6, "stability": 4, "army": 7, "brother_trust": 2, "authoritarian": 1}, "Брат занял президентское кресло во главе Совета безопасности и провёл заседание без вас. Генералы успокоились, зато вечерние новости обсуждали уже не здоровье, а фактического правителя страны."))
	var radio_event := event("Национальный совет вещания", "official", "#536f82", "Частота 91,3", "Ночью восточные передатчики заглушили приграничное радио и выпустили поддельный приказ о нормировании топлива. Инженеры могут подавить весь диапазон вместе с аварийными сообщениями, журналисты предлагают разобрать подделку в прямом эфире, а дипломаты — решить вопрос без огласки.",
		option("Заглушить диапазон", "Паника быстро прекратится • жители лишатся вещания • ограничение СМИ вызовет протест", {"support": -4, "stability": 5, "army": 3, "clan_regions": -4, "east_pressure": 3, "authoritarian": 1}, "Военные передатчики накрыли весь приграничный диапазон белым шумом. Поддельный приказ исчез вместе с местными новостями и предупреждением о паводке.", {"border_broadcast_blackout": true, "unrest": {"cause": "глушение приграничного радио вместе с местными новостями", "kind": "civic", "base_level": 1, "reversible": true, "reversal": "radio_blackout"}}),
		option("Разобрать подделку в эфире", "Потребуются расходы • поддержка вырастет • спор станет публичным и на несколько дней усилит беспорядок", {"money": -5, "support": 5, "stability": -3, "war_support": 2, "east_pressure": 3}, "Редакция показала монтаж записи по секундам и пригласила независимых инженеров. Выпуск посмотрела вся страна, но Восточный Союз назвал его государственной провокацией.", {"media_resilience_program": true}),
		option("Договориться без огласки", "Казна не пострадает и эфир вернётся • обществу не объяснят произошедшее • Восток получит уступку", {"support": -3, "stability": 3, "army": -2, "east_commitment": 1, "east_pressure": -2}, "Передатчик выключили после закрытого звонка и обещания не выносить дело на международные площадки. Радио снова работает, но официальный приказ о топливе так и не опровергли.", {"east_media_silence_pact": true}))
	var turbine_event := event("Энергетическая комиссия", "official", "#8b6c4b", "Турбина номер четыре", "Подшипник крупнейшей гидроэлектростанции разрушается. Турбина построена во время восточной оккупации: Восточный Союз предлагает почти бесплатную замену вместе с десятилетним обслуживанием, западный подрядчик — дорогую переделку, а местные инженеры могут разобрать вторую турбину на детали.",
		option("Принять восточный контракт", "Расходы будут небольшими и сеть быстро восстановится • Восток получит долгосрочный доступ к станции", {"money": -2, "stability": 6, "clan_regions": 4, "east_commitment": 2, "west_pressure": 2}, "Восточная бригада заменила узел за двое суток и оставила на станции постоянных специалистов. Свет вернулся, а копия ключей от машинного зала появилась у соседнего государства.", {"eastern_turbine_service": true}),
		option("Заказать западную переделку", "Очень большие расходы • зависимость от старого оборудования исчезнет • Восток усилит давление", {"money": -13, "support": 2, "stability": 4, "clan_workers": 3, "west_commitment": 1, "east_pressure": 4}, "Корпус турбины разрезали и установили западный узел с местными переходниками. Станция снова выдаёт ток, но казначейство оплатило срочную доставку, а Восток отозвал технические схемы.", {"western_grid_standard": true}),
		option("Ремонтировать своими силами", "Расходы останутся значительными • нейтральный курс укрепится • до завершения ремонта будут перебои", {"money": -7, "support": -2, "stability": -5, "clan_workers": 5, "clan_regions": -4, "neutrality": 3}, "Инженеры разобрали исправную турбину и собрали из двух машин одну. Страна сохранила контроль над станцией, но несколько областей перешли на график отключений.", {"domestic_turbine_repair": true}))
	var heating_event := event("Мэр промышленного города", "official", "#a9473f", "Котельная комбината", "Городская котельная задолжала за топливо и через четыре дня остановится. Владелец металлургического комбината готов погасить долг в обмен на двенадцатилетнюю концессию, профсоюз предлагает рабочий кооператив с государственной гарантией, а мэр просит прямую помощь казны.",
		option("Погасить долг из бюджета", "Крупные расходы и новый долг • тепло, поддержка и доверие регионов будут сохранены", {"money": -11, "debt": 5, "support": 4, "stability": 4, "clan_regions": 4}, "Казначейство оплатило топливо и взяло короткий заём. Котельная осталась городской, батареи нагрелись, а мэры других должников запросили такие же условия."),
		option("Отдать котельную комбинату", "Казна получит аванс и кризис закончится быстро • олигархи усилятся • рабочие и прозрачность пострадают", {"money": 7, "support": -3, "stability": 3, "corruption_tier": 1, "clan_oligarchs": 10, "clan_workers": -10}, "Комбинат перечислил аванс и подал тепло. Новый тариф обнаружился только в приложении к договору, которое депутатам раздали после голосования."),
		option("Поддержать кооператив", "Потребуются деньги и государственная гарантия • профсоюзы укрепятся • переходное управление создаст риск перебоев", {"money": -6, "debt": 9, "support": 2, "stability": -2, "clan_workers": 10, "clan_oligarchs": -8, "clan_regions": 3}, "Рабочие выбрали правление и сами заказали топливо под гарантию государства. Котельная запустилась с опозданием, а владелец комбината отменил ремонт городской магистрали."))
	var border_event := event("Пограничная комиссия", "diplomat", "#536f82", "Столб номер 217", "После весеннего разлива пограничный столб оказался у сельского кладбища и насосной станции. Восточные карты проводят границу на семьсот метров западнее, местные жители считают землю своей, а Западная Федерация предлагает оплатить международный арбитраж.",
		option("Перенести столб", "Порядок на границе восстановится и Восток смягчит меры • поддержка, военные настроения и доверие региона упадут", {"money": -4, "support": -5, "stability": 4, "war_support": -4, "clan_regions": -8, "east_commitment": 1, "east_pressure": -3}, "Столб перенесли ночью, семьям выплатили компенсации, а насосную станцию обнесли новым забором. Очереди на восточной границе сократились, но утром жители вернули на старое место республиканский флаг."),
		option("Обратиться в арбитраж", "Потребуются расходы • защита границы укрепит поддержку • до решения суда порядок ухудшится, Восток ответит", {"money": -7, "support": 3, "stability": -3, "war_support": 3, "clan_regions": 4, "west_commitment": 1, "east_pressure": 4}, "Западные геодезисты установили камеры и начали измерения. Жители дежурят у кладбища, а Восточный Союз перекрыл ближайшую дорогу до решения суда."),
		option("Заморозить линию совместным патрулём", "Нейтральность укрепится • спор не будет решён • армия сочтёт совместный пост уступкой", {"money": -5, "stability": 1, "army": -4, "clan_regions": 2, "neutrality": 3, "east_pressure": 1}, "Обе стороны поставили временный пост между двумя вариантами границы. Насос работает, кладбище открыто, но патрули каждое утро сверяют разные карты одной и той же земли."))
	var returnees_event := event("Служба безопасности", "military", "#536f82", "Люди с чужой войны", "Три тысячи граждан вернулись из далёкой гражданской войны с боевым опытом и незарегистрированным оружием. Большинство служило в бригаде, поддержанной Западной Федерацией. Армия хочет принять их единым подразделением, министерство труда — разоружить и вернуть к мирной жизни, а олигархи предлагают работу в частной охране.",
		option("Принять в армию после проверки", "Армия получит людей и опыт • порядок ухудшится • Восток назовёт подразделение западным легионом", {"money": -6, "pop_employed": -1000, "pop_unemployed": -2000, "army_personnel": 3000, "army": 5, "war_support": 5, "stability": -4, "west_commitment": 1, "east_pressure": 3}, "После краткой проверки ветераны вошли в отдельный батальон. Штаб доволен их опытом, но полиция уже расследует драку между новобранцами и пограничниками."),
		option("Провести разоружение и реинтеграцию", "Потребуются крупные расходы • порядок и поддержка укрепятся • армия потеряет подготовленных бойцов", {"money": -9, "support": 3, "stability": 4, "army": -3, "war_support": -4, "clan_workers": 5}, "Оружие приняли за компенсацию, ветеранам оплатили лечение и рабочие курсы. Большинство разъехалось по домам, а генералы назвали программу растратой боевого опыта."),
		option("Разрешить частные охранные отряды", "Казна получит деньги • олигархи усилятся • вооружённые группы ослабят государственный порядок", {"money": 6, "support": -3, "stability": -5, "army": -2, "war_support": 2, "corruption_tier": 1, "clan_oligarchs": 8}, "Охранные фирмы оплатили лицензии и разобрали ветеранов по портам, шахтам и складам. Через неделю два отряда отказались пропустить государственную инспекцию без разрешения владельца."))
	var tape_event := event("Редакция «Республиканского утра»", "official", "#a9473f", "Плёнка из приёмной", "Редактор получил запись разговора из приёмной покойного президента. На ней человек с голосом начальника охраны обсуждает слежку за журналистом, расследовавшим оружейные контракты. Оригинала нет, а посредник просит государственную защиту.",
		option("Заказать независимую экспертизу", "Дорого и медленно • до проверки запись останется закрытой • продолжение будет опираться на экспертизу", {"money": -5, "support": 2, "stability": -2, "clan_oligarchs": -3}, "Копии отправили в три лаборатории, а посредника поместили под защиту. Две редакции согласились ждать, третья опубликовала лишь расшифровку без звука.", {"tape_authentication": true}),
		option("Опубликовать запись целиком", "Повестка перейдёт к обществу • поддержка вырастет, порядок пострадает • подлинность останется спорной", {"support": 6, "stability": -6, "clan_oligarchs": -5}, "Запись прозвучала в вечернем эфире. К полуночи страна знала каждую паузу, но не знала, был ли разговор настоящим.", {"tape_published_raw": true}),
		option("Изъять все копии", "Скандал затихнет сейчас • редакции и поддержка отвернутся • утечка позднее будет разрушительнее", {"support": -5, "stability": 4, "authoritarian": 1, "clan_workers": -4}, "Следователи вынесли серверы и подписки о неразглашении. Утром редакция вышла с пустой первой полосой и номером статьи конституции о свободе слова.", {"tape_seized": true}))
	var protocols_event := event("Окружная избирательная комиссия", "official", "#668269", "Протокол с мокрой печатью", "Учительница принесла в столицу заверенную копию протокола недавних парламентских довыборов. В официальной таблице победитель тот же, но явка выше на одиннадцать тысяч голосов — ровно столько нужно президентскому центру для сохранения конституционного большинства.",
		option("Пересчитать спорные округа", "Результат задержится • порядок и партийная дисциплина ослабнут • доверие к процедуре вырастет", {"money": -4, "support": 4, "stability": -4, "clan_regions": 4}, "Урны опечатали повторно, а наблюдателей пустили в архив. Лояльные депутаты требуют остановить унижение комиссии, оппозиция везёт в столицу новые копии.", {"protocol_recount": true}),
		option("Утвердить официальный итог", "Большинство сохранится • немедленный порядок укрепится • низкая поддержка превратит спор в уличный", {"support": -4, "stability": 3, "authoritarian": 1}, "ЦИК объявила расхождение ошибкой оператора и выдала мандаты. Учительницу уволили из комиссии, зато её протокол уже печатают заводские газеты.", {"protocol_certified": true}),
		option("Опубликовать сканы всех протоколов", "Граждане смогут считать сами • аппарат потеряет контроль над итогом • продолжение изменит парламент", {"money": -3, "support": 5, "stability": -3, "clan_workers": 4, "clan_oligarchs": -3}, "Сайт ЦИК лёг через семь минут, но архив успели скачать наблюдатели. К утру появились три параллельных подсчёта и ни одного удобного правительству ответа.", {"protocol_scans": true}))
	var tariff_event := event("Комиссия по тарифам", "official", "#c7a96b", "Тариф до выборов", "Цена топлива для теплосетей выросла, но коммунальный тариф всё ещё рассчитан по прошлогодней цене. Если ничего не менять, разницу накопят государственные сети; если поднять плату сразу, самый тяжёлый месяц придётся на семьи перед местными выборами.",
		option("Заморозить тариф для всех", "Поддержка и порядок сохранятся сейчас • сети накопят долг • через три недели придёт счёт", {"money": -4, "support": 5, "stability": 3, "clan_regions": 4}, "Тариф оставили прежним, а разницу временно закрыли из резерва. Квитанции не изменились, зато директора теплосетей начали вести отдельную книгу неоплаченной разницы.", {"tariff_freeze": true}),
		option("Поднять тариф и дать адресные субсидии", "Дорогое администрирование • помощь получат не все • долг сетей будет меньше", {"money": -7, "support": -2, "stability": -2, "corruption_tier": -1, "clan_workers": 5}, "Новый тариф вступил в силу вместе с реестром субсидий. Пенсионеры получили компенсацию, арендаторы и жители общежитий обнаружили, что их нет ни в одном списке.", {"targeted_tariff_support": true}),
		option("Переложить разницу на заводы", "Казна сэкономит • население не увидит роста цены • промышленность и рабочие заплатят позже", {"money": 3, "support": 3, "stability": -2, "clan_oligarchs": -7, "clan_workers": -6}, "Промышленный газ подорожал, а бытовой остался прежним. Владельцы комбинатов назвали это налогом без закона и начали готовить сокращения смен.", {"industrial_cross_subsidy": true}))
	var court_event := event("Антикоррупционная служба", "official", "#8b6c4b", "Суд без кворума", "Конституционный суд отменил раскрытие имущества чиновников, после чего трое судей перестали приходить на заседания. Антикоррупционная служба продолжает проверки, министерства считают их незаконными, а парламент не может согласовать новых судей.",
		option("Исполнить решение суда", "Правовой порядок сохранится • антикоррупционные дела остановятся • старые элиты укрепятся", {"support": -5, "stability": 4, "corruption_tier": 1, "clan_oligarchs": 8}, "Реестр деклараций закрыли, расследования приостановили. Суд формально победил, но утром чиновники начали исправлять уже поданные документы.", {"court_compliance": true}),
		liberal_option("Заменить судей через парламент", "Реформа продолжится • борьба за назначения расколет парламент • брат назовёт это атакой на порядок", {"support": 4, "stability": -5, "corruption_tier": -1, "clan_oligarchs": -8, "army": -3}, "Правительство внесло закон о досрочной замене судей. Фракции поддержали принцип и немедленно начали торговаться за каждое кресло.", "Реформа продолжится • борьба за назначения расколет парламент", "Правительство внесло закон о досрочной замене судей. Фракции поддержали принцип и немедленно начали торговаться за каждое кресло.", {"court_replacement": true}),
		option("Заморозить спор до консультаций", "Никто не победит сейчас • учреждения будут жить по разным правилам • появится время для компромисса", {"support": -2, "stability": -4, "neutrality": 1}, "Президент попросил стороны не исполнять спорные решения до консультаций. Суд назвал просьбу давлением, служба — капитуляцией, а банки перестали понимать, какие справки действуют.", {"court_delay": true}))
	var faith_event := event("Совет общин Веры", "official", "#8b6c4b", "Собор без благословения", "Часть духовенства хочет провозгласить церковную независимость от восточного центра Веры. Восточный Союз называет собор расколом, западные дипломаты — вопросом суверенитета, а местные приходы больше беспокоит, кому останутся храмы и кладбища.",
		option("Поддержать независимый собор", "Национальная церковь и поддержка укрепятся • Восток ответит • общины начнут спор об имуществе", {"support": 5, "stability": -4, "clan_church": 6, "east_pressure": 5, "war_support": 3}, "Президент пришёл на открытие собора. Делегаты провозгласили независимую церковь, а восточный центр в тот же вечер отстранил всех участников.", {"faith_independence": true}),
		option("Сохранить связь с восточным центром", "Церковная иерархия сохранит единство • Восток смягчится • сторонники независимости уйдут в отдельные общины", {"support": -3, "stability": 3, "clan_church": 7, "east_commitment": 1, "east_pressure": -2}, "Правительство признало прежнюю иерархию. Старшие священнослужители остались в своих кабинетах, а сторонники независимости начали служить в домах культуры.", {"faith_east_link": true}),
		option("Объявить государство нейтральным", "Власть не выберет церковь • нейтралитет укрепится • спор об имуществе останется без арбитра", {"support": -2, "stability": -3, "clan_church": -5, "neutrality": 3}, "Канцелярия назвала раскол внутренним делом общин. Обе стороны поблагодарили президента за невмешательство и одновременно потребовали у полиции ключи от одних и тех же храмов.", {"faith_neutrality": true}))
	var battalion_event := event("Пограничный губернатор", "military", "#536f82", "Батальон у заставы", "После серии диверсий губернатор собрал три тысячи добровольцев. У них свои командиры, пожертвованная олигархами техника и высокий авторитет в приграничье. Штаб предлагает включить батальон в армию, МВД — разоружить, губернаторы — узаконить такие отряды в каждом регионе.",
		option("Включить батальон в армию", "Людей на границе станет больше • единое командование возникнет не сразу • позже придётся решить конфликт приказов", {"money": -5, "army_personnel": 3000, "army": 4, "war_support": 5, "stability": -3}, "Добровольцам выдали армейские номера, но оставили прежнего командира на переходный период. В штабе уже лежат два несовместимых плана их применения.", {"volunteers_integrated": true}),
		option("Разоружить и распустить", "Порядок и контроль государства укрепятся • армия и приграничье потеряют резерв • часть оружия исчезнет", {"money": -3, "support": -3, "stability": 4, "army": -5, "war_support": -6, "clan_regions": -6}, "На площадку сдали бронемашины и половину автоматов. Остальные добровольцы разъехались раньше проверки, а полиция получила карту возможных тайников.", {"volunteers_disarmed": true}),
		option("Передать отряды губернаторам", "Регионы получат собственную оборону • центр сэкономит • армия потеряет монополию на вооружённую силу", {"money": 3, "stability": -3, "army": -4, "war_support": 4, "clan_regions": 10}, "Парламент узаконил территориальные отряды при губернаторах. На границе стало больше людей, но каждый район заказал собственную форму и написал собственный устав.", {"volunteers_regional": true}))
	var dinner_event := event("Супруга президента", "family", "#8b6c4b", "Ужин остывает", "— Я уже третий раз разогреваю ужин, — говорит жена, закрывая папку с вашей новой речью. — Страна переживёт один вечер без президента. Вопрос только в том, переживёшь ли ты вечер без страны.",
		option("Остаться на ужин", "Отдых укрепит личную устойчивость • пропущенное вечернее обращение уменьшит поддержку", {"support": -2, "stability": 4}, "Канцелярия отменила вечернюю запись. Вы впервые за несколько недель поужинали без папок на столе; утром помощники нашли вас спокойнее, а редакции — без обещанного обращения."),
		option("Ехать на телевидение", "Публичное присутствие укрепит поддержку • усталость и семейное напряжение ударят по устойчивости", {"support": 4, "stability": -3}, "Вы уехали до десерта. Обращение подняло рейтинг и заняло все вечерние эфиры, но на обратном пути в резиденции уже погасли окна."),
		option("Обсудить речь вместе", "Подготовка потребует денег и времени • поддержка и устойчивость немного вырастут", {"money": -2, "support": 2, "stability": 1}, "Жена вычеркнула из речи три канцелярские фразы и заставила вас объяснить решение обычными словами. Запись пришлось перенести и оплатить заново, зато обращение впервые прозвучало как речь человека, а не ведомства."))
	var wine_event := event("Повар резиденции", "family", "#a9473f", "Бутылка из погреба", "— Господин президент, тут неловкое дело, — повар показывает пустую ячейку в погребе. — Министр обороны ночью унёс бутылку отцовского вина. В накладной её нет, а персонал уже спорит, считается ли это приказом.",
		option("Отчитать министра", "Поддержка власти +1 • лояльность армии −1", {"support": 1, "army": -1}, "Министр получил официальный выговор и вернул бутылку через адъютанта. Персонал увидел, что даже высшие чиновники не стоят выше правил, а штаб счёл разбирательство публичным унижением своего руководителя."),
		option("Закрыть глаза", "Поддержка власти −1 • лояльность армии +1", {"support": -1, "army": 1}, "Вы велели повару закрыть журнал и больше не поднимать вопрос. Министр сохранил лицо перед штабом, но персонал резиденции понял, что для высших чиновников правила действуют иначе."))
	var father_room_event := event("Супруга президента", "family", "#536f82", "Комната отца", "— Здесь до сих пор лежат его очки и недописанная речь, — жена открывает кабинет покойного президента. — Слуги боятся вытирать пыль, брат называет комнату святыней, а архив требует опечатать бумаги. Мы не можем вечно жить вокруг закрытой двери.",
		option("Оставить всё как было", "Наследие отца и армейские традиционалисты укрепятся • содержание комнаты потребует денег • часть общества увидит культ", {"money": -2, "support": -2, "stability": 3, "army": 2, "brother_trust": 1}, "Кабинет сохранили нетронутым и открыли только для официальных годовщин. Брат лично расставил книги, а оппозиционные газеты напечатали фотографию комнаты под заголовком о наследственной республике."),
		option("Передать бумаги архиву", "Открытость укрепит поддержку • содержание и проверка документов обойдутся дорого • публикации раскачают аппарат", {"money": -4, "support": 4, "stability": -2, "clan_oligarchs": -2}, "Архивисты вынесли коробки под камерами и начали опись. Первые опубликованные заметки оказались безобидными, но несколько старых соратников отца уже потребовали закрыть фонд."),
		option("Сделать кабинет своим", "Новых расходов не будет • рабочий ритм укрепится • брат воспримет это как присвоение наследия", {"stability": 2, "brother_trust": -1}, "К утру табличку на двери заменили. Вы оставили отцовский стол, но убрали его портрет; жена сказала, что кабинет наконец снова стал комнатой, а брат неделю не отвечал на звонки."))
	var motorcade_event := event("Супруга президента", "family", "#668269", "Машина у школы", "— Я хотела забрать племянницу без камер, — говорит жена, показывая телефон. — Но к школе приехали три машины охраны, перекрыли улицу и не пропустили скорую. Теперь весь город обсуждает не ребёнка, а нашу колонну.",
		option("Извиниться и сократить кортеж", "Поддержка вырастет • безопасность семьи и порядок протокола ухудшатся", {"support": 4, "stability": -4}, "Жена записала короткое извинение у школьных ворот, а две машины сняли с маршрута. Горожане оценили жест, служба охраны — нет: теперь каждый выезд требует импровизации."),
		option("Сослаться на протокол", "Охрана сохранит прежний порядок • общественная поддержка снизится", {"support": -3, "stability": 3}, "Канцелярия опубликовала сухую справку о правилах безопасности. Улица открылась, но фотография пустого перекрёстка ещё неделю сопровождала статьи о привилегиях власти."),
		option("Опубликовать маршруты заранее", "Прозрачность укрепит поддержку • новая схема потребует денег • предсказуемость маршрутов ухудшит безопасность", {"money": -2, "support": 3, "stability": -2}, "Резиденция стала заранее сообщать о перекрытиях и оплатила отдельные объезды для экстренных служб. Жалоб стало меньше, зато охрана теперь меняет планы в последний момент и требует больше людей."))

	insert_story_event_after("Слишком большой портрет", dinner_event)
	insert_story_event_after("Ужин остывает", wine_event)
	insert_story_event_after("Бутылка из погреба", father_room_event)
	insert_story_event_after("Комната отца", motorcade_event)
	insert_story_event_after("Слишком большой портрет", health_event)
	insert_story_event_after("Слишком большой портрет", tape_event)
	insert_story_event_after("Квартальная поправка", tariff_event)
	insert_story_event_after("Учебник Веры", faith_event)
	insert_story_event_after("Некомплект гарнизонов", battalion_event)
	insert_story_event_after("Весна в столице", archive_event)
	insert_story_event_after("Весна в столице", committee_event)
	insert_story_event_after("Комитет двенадцати", protocols_event)
	insert_story_event_after("Комитет двенадцати", court_event)
	insert_story_event_after("Два паспорта", language_event)
	insert_story_event_after("Три языка в одном классе", radio_event)
	insert_story_event_after("Частота 91,3", media_sale_event)
	insert_story_event_after("Автобусы у перевала", border_event)
	insert_story_event_after("Столб номер 217", mobility_event)
	insert_story_event_after("Пустующие цеха", heating_event)
	insert_story_event_after("Самолёты с чужими кодами", turbine_event)
	insert_story_event_after("Пропавший свидетель", returnees_event)

	var mandatory_titles := {
		"День после похорон": true, "Генерал с чемоданом": true, "Мороз без топлива": true,
		"Обвинение без доказательств": true, "Офицеры помнят отца": true, "Пакет модернизации": true,
		"Весна в столице": true, "Два паспорта": true, "Папка без печати": true,
		"Пропавший свидетель": true, "Таможня до заката": true, "Досрочные выборы": true
	}
	var bucket_by_title := {
		"Пустующие цеха": "economy", "Квартальная поправка": "economy", "Руда дешевле щебня": "economy",
		"Последние цистерны": "economy", "Красные каски": "economy", "Турбина номер четыре": "economy", "Котельная комбината": "economy", "Тариф до выборов": "economy",
		"Учебный центр": "army", "Некомплект гарнизонов": "army", "Коробки передач": "army", "Самолёты с чужими кодами": "army", "Батальон у заставы": "army",
		"Слишком большой портрет": "society", "Люди без адресов": "society", "Учебник Веры": "society", "Три языка в одном классе": "society",
		"Комитет двенадцати": "society", "Снимок из клиники": "society", "Частота 91,3": "society", "Канал на продажу": "society",
		"Плёнка из приёмной": "society", "Протокол с мокрой печатью": "society", "Суд без кворума": "society",
		"Ужин остывает": "society", "Бутылка из погреба": "society", "Комната отца": "society", "Машина у школы": "society",
		"Автобусы у перевала": "world", "Добровольцы без шевронов": "world", "Столб номер 217": "world", "Люди с чужой войны": "world", "Визовые окна": "world", "Собор без благословения": "world"
	}
	story_event_pool.clear()
	for story_event in events:
		var story_title := str(story_event.get("title", ""))
		story_event["_story_id"] = story_title
		story_event["_mandatory"] = mandatory_titles.has(story_title)
		story_event["_bucket"] = str(bucket_by_title.get(story_title, ""))
		if not bool(story_event["_mandatory"]) and str(story_event["_bucket"]) == "":
			push_error("Сюжетное событие не отнесено к обязательным или случайному пулу: %s" % story_title)
		story_event_pool.append(story_event.duplicate(true))
	events.clear()


func insert_story_event_after(anchor_title: String, story_event: Dictionary) -> void:
	for index in range(events.size()):
		if str(events[index].get("title", "")) == anchor_title:
			events.insert(index + 1, story_event)
			return
	push_error("Не найдено место для сюжетного события после «%s»." % anchor_title)


func build_recurring_event_database() -> void:
	recurring_events.clear()
	var regions: Array[Dictionary] = [
		{"region": "Северный край", "office": "северная администрация", "cities": [
			{"city": "Радов", "city_gen": "Радова", "city_loc": "Радове", "city_dat": "Радову"},
			{"city": "Белогор", "city_gen": "Белогора", "city_loc": "Белогоре", "city_dat": "Белогору"},
			{"city": "Черницы", "city_gen": "Черниц", "city_loc": "Черницах", "city_dat": "Черницам"},
			{"city": "Острог", "city_gen": "Острога", "city_loc": "Остроге", "city_dat": "Острогу"}
		]},
		{"region": "Озёрная область", "office": "озёрная администрация", "cities": [
			{"city": "Милова", "city_gen": "Миловы", "city_loc": "Милове", "city_dat": "Милове"},
			{"city": "Бережск", "city_gen": "Бережска", "city_loc": "Бережске", "city_dat": "Бережску"},
			{"city": "Приозёрье", "city_gen": "Приозёрья", "city_loc": "Приозёрье", "city_dat": "Приозёрью"},
			{"city": "Ладен", "city_gen": "Ладена", "city_loc": "Ладене", "city_dat": "Ладену"}
		]},
		{"region": "Степная область", "office": "степная администрация", "cities": [
			{"city": "Леск", "city_gen": "Леска", "city_loc": "Леске", "city_dat": "Леску"},
			{"city": "Долин", "city_gen": "Долина", "city_loc": "Долине", "city_dat": "Долину"},
			{"city": "Вежа", "city_gen": "Вежи", "city_loc": "Веже", "city_dat": "Веже"},
			{"city": "Сухов", "city_gen": "Сухова", "city_loc": "Сухове", "city_dat": "Сухову"}
		]},
		{"region": "Южный округ", "office": "южная администрация", "cities": [
			{"city": "Каменец", "city_gen": "Каменца", "city_loc": "Каменце", "city_dat": "Каменцу"},
			{"city": "Рудня", "city_gen": "Рудни", "city_loc": "Рудне", "city_dat": "Рудне"},
			{"city": "Явор", "city_gen": "Явора", "city_loc": "Яворе", "city_dat": "Явору"},
			{"city": "Новоград", "city_gen": "Новограда", "city_loc": "Новограде", "city_dat": "Новограду"}
		]}
	]
	var templates: Array[Dictionary] = [
		{"id": "utilities", "source": "Министерство коммунального хозяйства", "role": "official", "accent": "#8b6c4b", "title": "Трубы под площадью", "body": "В {city} лопнула магистраль под центральной площадью. {office} просит срочный ремонт, а коммунальщики предлагают временную перемычку до весны.", "left": {"label": "Ремонтировать сейчас", "hint": "Заметные расходы • надёжность сетей и доверие регионов вырастут", "effects": {"money": -4, "stability": 2, "clan_regions": 1}, "result": "Бригады региона «{region}» вскрыли площадь и заменили участок трубы. К вечеру тепло вернулось в дома, а аварию вычеркнули из весенней сметы."}, "right": {"label": "Поставить перемычку", "hint": "Казна пострадает меньше • риск новой аварии и раздражение регионов сохранятся", "effects": {"money": -1, "stability": -1, "clan_regions": -1}, "result": "В {city} запустили временную линию. Тепло вернулось быстро, но губернатор предупредил: следующая авария может оказаться тяжелее."}},
		{"id": "clinics", "source": "Министерство здравоохранения", "role": "official", "accent": "#668269", "title": "Очередь к фельдшеру", "body": "В амбулаториях региона «{region}» не хватает дежурных врачей. Губернатор просит мобильные бригады либо перераспределение лекарств между районами.", "left": {"label": "Послать бригады", "hint": "Расходы • доступность помощи и поддержка власти вырастут", "effects": {"money": -3, "support": 2}, "result": "Мобильные врачи приняли пациентов в {city} и ближайших посёлках. Очереди сократились, но министерству пришлось оплатить дорогу и дополнительные смены."}, "right": {"label": "Перераспределить лекарства", "hint": "Казна не пострадает • губернаторы получат свободу действий • другие пациенты останутся без части запасов", "effects": {"support": -1, "clan_regions": 2}, "result": "Склады региона «{region}» передали запас самым загруженным амбулаториям. Губернатор справился своими силами, однако соседние районы сообщили о новых очередях."}},
		{"id": "schools", "source": "Совет по образованию", "role": "official", "accent": "#c7a96b", "title": "Школа с мокрым потолком", "body": "После ливней в школе города {city} протекла крыша. Родители требуют ремонта, администрация предлагает временно учить детей в две смены.", "left": {"label": "Оплатить ремонт", "hint": "Расходы • семьи и учителя поддержат решение", "effects": {"money": -3, "support": 2, "clan_workers": 1}, "result": "Кровлю школы в {city} закрыли до следующих дождей. Родители успокоились, а учителям не пришлось менять расписание."}, "right": {"label": "Ввести две смены", "hint": "Без расходов • занятия продолжатся • семьи и учителя будут недовольны", "effects": {"support": -2, "clan_workers": -1}, "result": "Уроки продолжились в сухом корпусе. Школу не закрыли, но поздние занятия осложнили жизнь семьям и преподавателям."}},
		{"id": "roads", "source": "Дорожное управление", "role": "official", "accent": "#8b6c4b", "title": "Мост на одной полосе", "body": "Инспекторы нашли трещины на мосту у города {city}. Можно провести быстрый ремонт либо ограничить движение тяжёлых грузовиков.", "left": {"label": "Укрепить пролёт", "hint": "Серьёзные расходы • порядок и положение регионов укрепятся", "effects": {"money": -4, "stability": 2, "clan_regions": 2}, "result": "Рабочие региона «{region}» укрепили пролёт. Грузовое движение возобновилось, а губернатор записал ремонт в заслуги совместной работе с центром."}, "right": {"label": "Ограничить движение", "hint": "Казна не пострадает • перевозки замедлятся • региональные власти потеряют доверие", "effects": {"support": -1, "stability": -1, "clan_regions": -2}, "result": "На мосту у {city} выставили посты и весы. Аварии избежали, но объезды сорвали поставки и вызвали спор губернатора с правительством."}},
		{"id": "customs", "source": "Таможенная служба", "role": "official", "accent": "#6d788d", "title": "Очередь у шлагбаума", "body": "На пропускном пункте региона «{region}» скопились скоропортящиеся грузы. Начальник смены просит оплатить ночную работу либо пропускать продукты вне очереди.", "left": {"label": "Оплатить ночную смену", "hint": "Расходы • очередь сократится без изменения правил • порядок укрепится", "effects": {"money": -3, "stability": 2, "clan_regions": 1}, "result": "Таможня работала всю ночь. К утру колонна у {city} сократилась, а обычная очерёдность сохранилась."}, "right": {"label": "Дать приоритет продуктам", "hint": "Без расходов • покупатели оценят решение • крупные перевозчики и порядок пострадают", "effects": {"support": 1, "stability": -1, "clan_oligarchs": -2}, "result": "Продукты прошли первыми, и рынок города {city} открылся вовремя. Владельцы задержанных грузов потребовали отменить ручное управление очередью."}},
		{"id": "police", "source": "Министерство внутренних дел", "role": "official", "accent": "#536f82", "title": "Ночные патрули", "body": "После серии краж жители города {city} требуют усилить патрули. Полиция просит сверхурочные, муниципалитет предлагает совместные гражданские обходы.", "left": {"label": "Оплатить сверхурочные", "hint": "Расходы • порядок укрепится • часть жителей возразит против усиления полиции", "effects": {"money": -2, "stability": 2, "support": -1}, "result": "Дополнительные наряды вышли на улицы города {city}. Краж стало меньше, но проверки документов вызвали жалобы жителей."}, "right": {"label": "Организовать обходы", "hint": "Поддержка вырастет • контроль станет менее надёжным", "effects": {"support": 2, "stability": -1}, "result": "Домовые комитеты региона «{region}» составили график обходов. Жители включились охотно, однако полиция не смогла отвечать за действия всех добровольцев."}},
		{"id": "procurement", "source": "Комитет государственных закупок", "role": "official", "accent": "#c7a96b", "title": "Хлеб для столовых", "body": "Школам и больницам региона «{region}» нужен новый поставщик хлеба. Местные пекарни дороже, а центральный комбинат крупного частного холдинга обещает дешёвую доставку раз в неделю.", "left": {"label": "Выбрать местных", "hint": "Повышенные расходы • регионы выиграют • крупный бизнес потеряет контракт", "effects": {"money": -3, "clan_regions": 3, "clan_oligarchs": -1}, "result": "Контракты получили пекарни вокруг города {city}. Поставки идут ежедневно, районные советы довольны, а холдинг обжалует закупку."}, "right": {"label": "Выбрать комбинат", "hint": "Казна сэкономит • крупный бизнес усилится • регионы лишатся заказов", "effects": {"money": -1, "clan_oligarchs": 3, "clan_regions": -2}, "result": "Центральный комбинат привёз первую партию в {city}. Цена оказалась ниже, но местные пекари начали увольнять работников."}},
		{"id": "garrison", "source": "Окружной штаб", "role": "military", "accent": "#536f82", "title": "Крыша казармы", "body": "В гарнизоне возле города {city} протекает старая казарма. Штаб просит срочный ремонт либо временное сокращение учений и размещение солдат в учебном корпусе.", "left": {"label": "Отремонтировать", "hint": "Крупные расходы • состояние армии заметно улучшится", "effects": {"money": -4, "army": 3}, "result": "Военные строители региона «{region}» заменили кровлю. Подразделение вернулось к обычному распорядку и наверстало учения."}, "right": {"label": "Сократить учения", "hint": "Казна не пострадает • армия и сторонники войны потеряют уверенность", "effects": {"army": -2, "war_support": -2}, "result": "Солдат разместили в учебном корпусе, а полевые выходы отменили. Казарма дождётся планового ремонта, но боевой график уже сорван."}},
		{"id": "rumors", "source": "Пресс-служба правительства", "role": "official", "accent": "#6d788d", "title": "Письмо без подписи", "body": "По городу {city} расходится сообщение о закрытии местной больницы. Само письмо поддельное, но в нём приведены настоящие неопубликованные страницы полного бюджета: больницу не закрывают, зато в других статьях действительно запланированы сокращения.", "left": {"label": "Опубликовать полный бюджет", "hint": "Слух будет опровергнут • другие сокращения станут публичными • потребуется разъяснительная кампания", "effects": {"money": -1, "support": 3, "clan_workers": -3}, "result": "Правительство выложило полный бюджет. Закрытие больницы оказалось выдумкой, но профсоюзы сразу потребовали отменить обнаруженные сокращения в других ведомствах."}, "right": {"label": "Дать местное опровержение", "hint": "Детали бюджета останутся закрыты • регионы помогут с объяснениями • общие сомнения сохранятся", "effects": {"support": -1, "clan_regions": 1}, "result": "Администрация города {city} показала лишь выписку по больнице. Местный слух ослаб, но национальные каналы решили, что правительство скрывает остальной документ."}},
		{"id": "migrant_housing", "source": "Миграционная служба", "role": "official", "accent": "#668269", "title": "Общежитие у вокзала", "body": "В городе {city} переполнено временное общежитие для приезжих рабочих. Государство может открыть новое общежитие либо обязать нанявшие людей предприятия самостоятельно обеспечить их жильём.", "left": {"label": "Открыть общежитие", "hint": "Крупные расходы • условия улучшатся быстро • работодатели избегут новых обязанностей", "effects": {"money": -4, "support": 2, "clan_oligarchs": 1}, "result": "В городе {city} открыли государственное общежитие. Семьи получили комнаты, а предприятия поблагодарили правительство за решение проблемы из казны."}, "right": {"label": "Обязать работодателей", "hint": "Казна не пострадает • бизнес окажет сопротивление • размещение займёт время", "effects": {"support": 1, "stability": -1, "clan_oligarchs": -4}, "result": "Предприятия региона «{region}» получили предписание снять жильё для приезжих. Людей начали расселять, но объединение работодателей готовит иск и остановило новые наймы."}},
		{"id": "power_grid", "source": "Энергетическая комиссия", "role": "official", "accent": "#8b6c4b", "title": "Трансформатор на пределе", "body": "Подстанция города {city} перегревается в часы пик. Энергетики предлагают срочно заменить трансформатор либо ввести короткие веерные отключения.", "left": {"label": "Заменить трансформатор", "hint": "Крупные расходы • энергосистема и доверие регионов укрепятся", "effects": {"money": -5, "stability": 3, "clan_regions": 1}, "result": "Новый трансформатор запустили ночью. Город {city} прошёл следующую пиковую нагрузку без аварии, а область отменила чрезвычайный график."}, "right": {"label": "Ввести график", "hint": "Казна не пострадает • сеть выдержит • жители и регионы понесут издержки", "effects": {"support": -2, "stability": -1, "clan_regions": -1}, "result": "В городе {city} опубликовали график коротких отключений. Сеть устояла, но тёмные вечера ударили по магазинам и терпению жителей."}},
		{"id": "wages", "source": "Трудовая инспекция", "role": "official", "accent": "#a9473f", "title": "Смена без надбавки", "body": "Рабочие муниципального предприятия города {city} отказались от ночной смены без обещанной надбавки. Инспекция предлагает государственное посредничество, а руководство просит добиться судебного предписания о выходе на работу.", "left": {"label": "Послать посредника", "hint": "Расходы • профсоюзы поддержат власть • соглашение не гарантировано", "effects": {"money": -2, "stability": 1, "clan_workers": 3}, "result": "Посредник добился временной доплаты и возврата ночной смены. Работа возобновилась, но окончательную сумму ещё предстоит согласовать."}, "right": {"label": "Добиться предписания суда", "hint": "Производство восстановится быстрее • принуждение к смене может расширить забастовку", "effects": {"stability": 2, "support": -2, "clan_workers": -3}, "result": "Суд обязал смену выйти до завершения разбирательства. Предприятие региона «{region}» заработало в полную силу, а профсоюз объявил решение политическим.", "set": {"unrest": {"cause": "судебное принуждение рабочих к ночной смене без надбавки", "kind": "labor", "labor": true, "base_level": 1, "reversible": false, "condition": "workers_low"}}}},
		{"id": "ceremony", "source": "Министерство культуры", "role": "family", "accent": "#c7a96b", "title": "День первого флага", "body": "В городе {city} готовят годовщину первого поднятия республиканского флага. Совет просит выбрать между гражданской церемонией и службой Церкви Веры.", "left": {"label": "Провести городской праздник", "hint": "Расходы • широкая поддержка вырастет • Церковь Веры окажется в стороне", "effects": {"money": -2, "support": 3, "clan_church": -2}, "result": "На площади города {city} выступили школьные оркестры и ветераны независимости. Светская церемония собрала много людей, но духовенство отказалось участвовать."}, "right": {"label": "Поддержать службу Веры", "hint": "Церковь заметно укрепится • светская часть общества отнесётся прохладнее", "effects": {"support": 1, "clan_church": 3}, "result": "Колокола региона «{region}» звонили одновременно. Церковь Веры назвала независимость общим обетом страны, а светские организации провели отдельную встречу."}}
	]
	var templates_by_family := {}
	var all_families: Array[String] = []
	for template in templates:
		var family := str(template["id"])
		templates_by_family[family] = template
		all_families.append(family)

	var used_variants := {}
	var recent_families: Array[String] = []
	var family_schedule: Array[String] = []
	for _round_index in range(4):
		var remaining_families := all_families.duplicate()
		while not remaining_families.is_empty():
			var family_candidates: Array[String] = []
			for candidate_family in remaining_families:
				if candidate_family not in recent_families:
					family_candidates.append(candidate_family)
			var family := family_candidates[routine_rng.randi_range(0, family_candidates.size() - 1)]
			family_schedule.append(family)
			remaining_families.erase(family)
			recent_families.append(family)
			if recent_families.size() > 4:
				recent_families.pop_front()

	recent_families.clear()
	for family in family_schedule:

		var location_candidates: Array[Dictionary] = []
		for region_index in range(regions.size()):
			var region_data: Dictionary = regions[region_index]
			for city_value in region_data["cities"]:
				var city_data: Dictionary = city_value
				var generation_key := "%s|%s|%s" % [family, str(region_data["region"]), str(city_data["city"])]
				if used_variants.has(generation_key):
					continue
				var location := region_data.duplicate(true)
				for city_key in city_data:
					location[city_key] = city_data[city_key]
				location["region_index"] = region_index
				location["generation_key"] = generation_key
				location_candidates.append(location)
		if location_candidates.is_empty():
			push_error("Не удалось собрать уникальный вариант малого события семейства %s." % family)
			break

		var location: Dictionary = location_candidates[routine_rng.randi_range(0, location_candidates.size() - 1)]
		var template: Dictionary = templates_by_family[family]
		var left_data: Dictionary = template["left"]
		var right_data: Dictionary = template["right"]
		var body_template := str(template["body"])
		if not body_template.contains("{city}"):
			body_template += " Доклад поступил из города {city}."
		var contextual_body := format_routine_text(body_template, location)
		var context_note := format_routine_text(recurring_event_context(family, int(location["region_index"])), location)
		if context_note != "":
			contextual_body += " " + context_note
		var routine := event(
			str(template["source"]),
			str(template["role"]),
			str(template["accent"]),
			"%s — %s" % [str(template["title"]), str(location["city"])],
			contextual_body,
			option(str(left_data["label"]), str(left_data["hint"]), (left_data["effects"] as Dictionary).duplicate(true), format_routine_text(str(left_data["result"]), location), (left_data.get("set", {}) as Dictionary).duplicate(true)),
			option(str(right_data["label"]), str(right_data["hint"]), (right_data["effects"] as Dictionary).duplicate(true), format_routine_text(str(right_data["result"]), location), (right_data.get("set", {}) as Dictionary).duplicate(true))
		)
		routine["_family"] = family
		routine["_generation_key"] = str(location["generation_key"])
		recurring_events.append(routine)
		used_variants[str(location["generation_key"])] = true


func format_routine_text(template_text: String, location: Dictionary) -> String:
	var formatted := template_text
	formatted = formatted.replace("По городу {city}", "По городу " + str(location["city_dat"]))
	formatted = formatted.replace("по городу {city}", "по городу " + str(location["city_dat"]))
	formatted = formatted.replace("города {city}", "города " + str(location["city_gen"]))
	formatted = formatted.replace("городе {city}", "городе " + str(location["city_loc"]))
	formatted = formatted.replace("городу {city}", "городу " + str(location["city_dat"]))
	formatted = formatted.replace("город {city}", "город " + str(location["city"]))
	formatted = formatted.replace("В {city}", "В " + str(location["city_loc"]))
	formatted = formatted.replace("в {city}", "в " + str(location["city_loc"]))
	formatted = formatted.replace("у {city}", "у " + str(location["city_gen"]))
	formatted = formatted.replace("{city}", str(location["city"]))
	return formatted.format(location)


func recurring_event_context(family: String, variant: int) -> String:
	var contexts := {
		"utilities": [
			"Старые планы сетей остались на восточном языке и не совпадают с нынешней застройкой.",
			"Грунт размыло после подъёма воды в озере, поэтому временный ремонт может не пережить следующий паводок.",
			"Ближайшая аварийная бригада находится в ста сорока километрах, и губернатор готов прислать дорожных рабочих.",
			"Перекрытие площади остановит субботний рынок, от которого зависят торговцы всего округа."
		],
		"clinics": [
			"Часть врачей живёт по другую сторону границы и опаздывает из-за новых проверок.",
			"До двух посёлков можно добраться только паромом, который уже три дня стоит из-за тумана.",
			"Фельдшеры тратят половину смены на дорогу между разбросанными степными сёлами.",
			"После запуска новой смены на металлургическом заводе число производственных травм выросло."
		],
		"schools": [
			"Здание раньше было пограничной казармой, и его стропила не меняли со времён оккупации.",
			"Влага уже добралась до кабинета химии, поэтому следующего сильного дождя школа может не выдержать.",
			"Соседняя школа и без того работает в две смены и принять учеников не сможет.",
			"В район недавно приехали семьи заводских рабочих, и свободных классов почти не осталось."
		],
		"roads": [
			"По этому мосту идут колонны к приграничному гарнизону, но штаб отказывается сокращать движение.",
			"Опоры стоят в воде после паводка, и инспекторы не гарантируют их состояние к концу месяца.",
			"Через неделю начнётся вывоз зерна, поэтому объезд ударит по десяткам небольших хозяйств.",
			"Большую часть нагрузки создают рудовозы частных карьеров, владельцы которых требуют не закрывать путь."
		],
		"customs": [
			"В очереди стоят молочные цистерны из приграничных хозяйств и грузовики восточных перевозчиков.",
			"Рыба с озёрных кооперативов испортится к утру, если холодильные машины не пройдут первыми.",
			"Фермеры везут ранние овощи, но дальнобойщики с промышленными грузами отказываются уступать очередь.",
			"За продуктами стоят вагоны с металлом, и экспортёры уже звонят в министерство экономики."
		],
		"police": [
			"Большинство краж связано с контрабандными складами у старой пограничной дороги.",
			"В курортный сезон население города почти удваивается, а штат полиции остаётся зимним.",
			"Из сельскохозяйственных машин сливают топливо, и фермеры начали выставлять собственную охрану.",
			"Кражи происходят возле рабочих общежитий после окончания ночной смены на заводе."
		],
		"procurement": [
			"Местные пекарни используют северную рожь, но просят гарантировать закупки до конца зимы.",
			"Озёрные паромы иногда срывают доставку, зато районные пекари готовы держать недельный запас муки.",
			"Степные кооперативы предлагают собственное зерно и требуют не отдавать контракт столичному холдингу.",
			"Центральный комбинат принадлежит группе, уже поставляющей питание на металлургический завод."
		],
		"garrison": [
			"Ночью температура в спальном корпусе падает ниже нормы, и командиры грозят перевести роту в город.",
			"Озёрная сырость испортила проводку, поэтому простой заплаты на крыше может оказаться мало.",
			"До ближайшей свободной казармы двести километров, а перевозка сорвёт полевые занятия.",
			"Пыль с металлургического комбината забивает вентиляцию и ускоряет разрушение кровли."
		],
		"rumors": [
			"Подделку первой распространила страница, которая обычно публикует новости Восточного Союза.",
			"К сообщению приложена запись голоса главного врача, хотя сам врач утверждает, что её смонтировали.",
			"В качестве доказательства используют фотографию закрытой сельской амбулатории из другого района.",
			"Слух разошёлся по чатам заводской смены после объявления о сокращении ведомственной поликлиники."
		],
		"migrant_housing": [
			"Среди жильцов есть семьи с приграничья, которые пока не решили, гражданами какой страны себя считать.",
			"Большинство приехало на восстановление дамб и останется в области только до конца сезона.",
			"Это сезонные рабочие, нанятые на уборку урожая без заранее подготовленного жилья.",
			"Контракт строительной фирмы закончился раньше срока, и несколько сотен людей одновременно потеряли комнаты."
		],
		"power_grid": [
			"Оборудование работает по старому восточному стандарту, поэтому подходящая замена есть только на одном складе.",
			"Насосы, удерживающие воду у жилых кварталов, нельзя отключать одновременно с домами.",
			"Главную нагрузку дают ирригационные станции, без которых фермеры потеряют часть урожая.",
			"Металлургический комбинат отказывается переносить плавку с вечернего пика без компенсации."
		],
		"wages": [
			"Спор начался на городской котельной, и остановка ночной смены оставит без тепла два квартала.",
			"Работники паромной службы предупреждают, что без смены утренние рейсы через озеро отменят.",
			"Конфликтует смена зернового элеватора за несколько дней до начала массового вывоза урожая.",
			"Предприятие обслуживает частный металлургический завод, но зарплаты рабочим платит муниципалитет."
		],
		"ceremony": [
			"Именно здесь первый флаг подняли над заброшенным пограничным пунктом после ухода оккупационных войск.",
			"В городе {city} флаг впервые провезли через озеро на рыбацкой лодке, и семьи тех рыбаков требуют места на сцене.",
			"В городе {city} новость о независимости передали с радиовышки раньше, чем она дошла до столицы.",
			"В городе {city} первый флаг появился над заводской проходной во время мирной ночной смены."
		]
	}
	var family_contexts: Array = contexts.get(family, [])
	if variant < 0 or variant >= family_contexts.size():
		return ""
	return str(family_contexts[variant])


func neighbor_peace_requirements_for_title(title: String) -> Array[String]:
	match title:
		"Мороз без топлива", "Два паспорта", "Автобусы у перевала", "Последние цистерны", "Таможня до заката", "Канал на продажу", "Частота 91,3", "Цена зимней скидки", "Список соотечественников", "Редакционная линия", "Два предстоятеля":
			return ["east"]
		"Пакет модернизации", "Учебный центр", "Визовые окна", "Второй транш":
			return ["west"]
		"Обвинение без доказательств", "Самолёты с чужими кодами", "Добровольцы без шевронов", "Три языка в одном классе", "Турбина номер четыре", "Столб номер 217", "Собор без благословения", "Две печати на одном ящике":
			return ["east", "west"]
	return []


func event_peace_requirements(event_data: Dictionary) -> Array[String]:
	var requirements: Array[String] = []
	var stored = event_data.get("_peace_required_with", [])
	if stored is Array:
		for side_variant in stored:
			var side := str(side_variant)
			if side in ["east", "west"] and side not in requirements:
				requirements.append(side)
	if requirements.is_empty():
		requirements = neighbor_peace_requirements_for_title(str(event_data.get("title", "")))
	return requirements


func event_blocked_by_current_war(event_data: Dictionary) -> bool:
	if not bool(state.get("at_war", false)):
		return false
	return str(state.get("war_enemy", "")) in event_peace_requirements(event_data)


func build_wartime_replacement_event(blocked_event: Dictionary) -> Dictionary:
	var enemy := neighbor_title(str(state.get("war_enemy", "east")))
	var original_title := str(blocked_event.get("title", "внешнеполитический доклад"))
	var variant := posmod(original_title.hash(), 3)
	var replacement: Dictionary
	if variant == 0:
		replacement = event("Военная администрация", "military", "#a9473f", "Эшелоны у развязки", "Доклад «%s» потерял смысл после начала войны с государством «%s». Вместо него штаб требует решить спор на железнодорожной развязке: отправить составы с техникой к фронту или сначала вывезти гражданских из приграничных городов." % [original_title, enemy],
			option("Отдать пути армии", "Снабжение и армия укрепятся • эвакуация замедлится • поддержка снизится", {"army": 4, "stability": 1, "support": -4, "war_support": 2}, "Военные эшелоны получили зелёный коридор. Техника дошла до фронта, а гражданские поезда остались ждать на запасных путях."),
			option("Сначала вывезти гражданских", "Потребуются деньги • поддержка укрепится • штаб и военные настроения пострадают", {"money": -6, "support": 5, "army": -3, "war_support": -3}, "Первые пути отдали эвакуационным составам. Тысячи семей покинули приграничье, но штаб перенёс доставку техники на следующую ночь."))
	elif variant == 1:
		replacement = event("Министерство внутренних дел", "official", "#536f82", "Школьные подвалы", "Внешнеполитический доклад «%s» отменён из-за войны с государством «%s». В приграничных школах срочно оборудуют убежища: губернаторы просят государственные деньги, а армия предлагает использовать собственные инженерные части." % [original_title, enemy],
			option("Оплатить гражданские убежища", "Крупные расходы • поддержка и устойчивость тыла вырастут", {"money": -7, "support": 4, "stability": 4, "clan_regions": 3}, "Подвалы укрепили гражданские подрядчики. Школы продолжили работу по сокращённому расписанию, а губернаторы публично поддержали решение центра."),
			option("Передать работы армии", "Казна сэкономит • армия и порядок укрепятся • фронт лишится части инженеров", {"money": -2, "army": 3, "stability": 2, "war_support": -3}, "Армейские инженеры оборудовали убежища быстрее сметы. Штаб предупредил, что те же части теперь не успеют восстановить фронтовые переправы."))
	else:
		replacement = event("Министерство здравоохранения", "official", "#668269", "Полевой госпиталь", "Переговоры по докладу «%s» прекращены после начала войны с государством «%s». Больницы у границы переполнены. Можно развернуть дорогой государственный госпиталь или передать лечение армейской медицинской службе." % [original_title, enemy],
			option("Развернуть гражданский госпиталь", "Крупные расходы • поддержка и стабильность вырастут • регионы получат новые мощности", {"money": -8, "support": 4, "stability": 3, "clan_regions": 4}, "На стадионе развернули гражданский госпиталь. Он принимает и военных, и жителей, но снабжение пришлось закупать по чрезвычайным ценам."),
			option("Передать лечение военным", "Армия укрепится • гражданские больницы разгрузятся • поддержка войны и общества снизится", {"army": 4, "stability": 2, "support": -3, "war_support": -2}, "Военная медицина приняла поток раненых и освободила районные больницы. Семьи потребовали объяснить, почему сведения о пациентах сразу засекретили."))
	replacement["_wartime_replacement_for"] = original_title
	replacement["_kind"] = str(blocked_event.get("_kind", "core"))
	return replacement


func event(source: String, role: String, accent: String, title: String, body: String, left: Dictionary, right: Dictionary, third: Dictionary = {}) -> Dictionary:
	var event_data := {"source": source, "role": role, "accent": accent, "title": title, "body": body, "left": left, "right": right}
	if not third.is_empty():
		event_data["third"] = third
	var peace_requirements := neighbor_peace_requirements_for_title(title)
	if not peace_requirements.is_empty():
		event_data["_peace_required_with"] = peace_requirements
	return event_data


func option(option_label: String, hint: String, effects: Dictionary, result: String, flags: Dictionary = {}) -> Dictionary:
	return {"label": option_label, "hint": hint, "effects": effects, "result": result, "set": flags}


func liberal_option(option_label: String, hint: String, effects: Dictionary, result: String, hint_without_brother: String, result_without_brother: String, flags: Dictionary = {}) -> Dictionary:
	var option_data := option(option_label, hint, effects, result, flags)
	option_data["liberal_army_reaction"] = true
	option_data["liberal_army_effect"] = int(effects.get("army", 0))
	option_data["hint_with_brother"] = hint
	option_data["result_with_brother"] = result
	option_data["hint_without_brother"] = hint_without_brother
	option_data["result_without_brother"] = result_without_brother
	return option_data
