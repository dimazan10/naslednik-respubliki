extends Control

const WRAPPED_TOOLTIP_SCRIPT := preload("res://scripts/wrapped_tooltip.gd")
const ENDING_LINE_CHART_SCRIPT := preload("res://scripts/ending_line_chart.gd")

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
const WAR_DEFENSIVE_RALLY_SUPPORT := 4
const WAR_DEFENSIVE_RALLY_WAR_SUPPORT := 6
const WAR_SHORTENED_FRONT_REDUCTION := 8000
const FINANCIAL_CRISIS_RESERVE := 2.0
const DEMO_WEEKS := 26
const GAME_VERSION := "0.9.3"
const DISCORD_INVITE_URL := "https://discord.gg/CTdHbNfZJR"
const EVENTS_PER_WEEK := 3
const PROLOGUE_MANDATE_TEXT := "Незадолго до смерти отец провёл ваше назначение вице-президентом через спорное голосование. Теперь вы временно исполняете обязанности главы государства. Через 26 недель должны состояться досрочные выборы."
const TUTORIAL_CARDS := {
	"pending": {"title": "ОЖИДАЕМЫЕ ИЗМЕНЕНИЯ", "body": "Голубые числа слева показывают ожидаемый результат ваших решений. Он будет применён при переходе к новой неделе."},
	"budget": {"title": "КАЗНА И РАСХОДЫ", "body": "Здесь видны доходы, расходы и прогноз следующей недели. Уровни бюджета меняются через карточки ниже; поправку должен одобрить парламент."},
	"week": {"title": "ЗАВЕРШЕНИЕ НЕДЕЛИ", "body": "Все доклады рассмотрены. Проверьте прогноз казны, затем нажмите выделенную кнопку «Новая неделя». Только тогда пройдут выплаты и проявятся последствия."},
	"report": {"title": "НЕДЕЛЬНАЯ СВОДКА", "body": "Во вкладке «Итоги» видны главные изменения недели. Отдельные вкладки показывают решения, деньги, общество, группы, армию и соседей. Новый закон выделяется отдельной карточкой."},
	"government": {"title": "ПАРЛАМЕНТ И МИНИСТРЫ", "body": "Большинство решает судьбу бюджетных поправок и назначений. Министры не принимают решения за вас, но меняют доступные события и возможности."},
	"law": {"title": "ПОДГОТОВКА ЗАКОНА", "body": "Можно вести один законопроект. После начала его подготовка продвигается автоматически каждую неделю при наличии очков решений; до принятия проект можно отменить."},
	"foreign": {"title": "ВНЕШНЯЯ ПОЛИТИКА", "body": "Во вкладке показаны действия с соседями. У каждого отношения от враждебных до партнёрских. Улучшая их с одной стороной, вы можете ухудшить их с другой."},
	"war": {"title": "ВОЙНА", "body": "Фронту нужны люди, снабжение и боеспособная техника. Каждая военная неделя приносит потери; призыв берёт людей из работоспособного населения."}
}
const TUTORIAL_WEEK_BRIEFINGS := {
	1: {"title": "ЧЕТЫРЕ ГЛАВНЫХ ПОКАЗАТЕЛЯ", "body": "Слева открылись четыре показателя. Их можно проверить наведением мыши.\n\nКАЗНА — деньги для выплат. Если после недели она опустеет, наступит дефолт и правление закончится.\nПОДДЕРЖКА ВЛАСТИ — сколько людей готовы терпеть ваше правление. При 0% президента свергнут.\nСТАБИЛЬНОСТЬ — способность страны исполнять решения. При 0% государство расколется.\nПОДДЕРЖКА ВОЙНЫ — готовность общества сопротивляться. Если во время войны она упадёт до 0%, страна капитулирует.\n\nГолубые числа — ожидаемые изменения. Они применятся после завершения недели."},
	2: {"title": "НЕДЕЛЯ 2  •  ГРУППЫ", "body": "Слева теперь показана поддержка олигархов, Церкви Веры, профсоюзов, регионов и армии.\n\nУ каждой группы свои интересы. От их поддержки зависят голоса в парламенте, доходы, риск протестов и возможности армии.\n\nОткройте «Кланы»: там показано, чем полезна каждая группа и чем грозит её недовольство. Изменения за неделю появятся в сводке."},
	3: {"title": "НЕДЕЛЯ 3  •  ДЕНЬГИ", "body": "Открылась вкладка «Экономика». Здесь видно, сколько денег приходит и уходит за неделю.\n\nПроверьте прогноз казны. Он показывает, сколько останется после выплат. Если денег мало, ищите доход или сокращайте расходы до нажатия «Новая неделя».\n\nНажмите на статью бюджета, чтобы сравнить уровни расходов. Изменение бюджета должен одобрить парламент."},
	4: {"title": "НЕДЕЛЯ 4  •  ПРАВИТЕЛЬСТВО", "body": "Открыт состав правительства. Министры приходят к вам с вопросами, но последнее решение всегда ваше. Замена министра требует выбора кандидата и поддержки парламента. Смена человека может открыть новые события, закон или способ действовать во внешней политике."},
	5: {"title": "НЕДЕЛЯ 5  •  ЗАКОНЫ", "body": "Теперь можно начать подготовку закона. Одновременно готовится один законопроект. После запуска работа продвигается сама при переходе к следующей неделе, если хватает очков решений. Незаконченный проект можно отменить, но уже потраченные очки не вернутся."},
	6: {"title": "НЕДЕЛЯ 6  •  АРМИЯ", "body": "Во вкладке армии выбирают способ призыва, выпуск наземной техники и сколько нефти отдать на снабжение. Призыв забирает людей из работоспособного населения, а их содержание требует денег. Самолёты внутри страны не производятся: их получают через закупки, помощь или события. Если армия потеряет лояльность до 0%, возможен военный переворот."},
	7: {"title": "НЕДЕЛЯ 7  •  ПРОТЕСТЫ", "body": "Непопулярное решение при слабой поддержке власти может вызвать протест. Низкая стабильность делает новый протест сильнее, высокая — слабее. После нарушения прав рабочих может начаться забастовка, уменьшающая доходы. Проверяйте не только немедленное изменение цифр, но и новые события после него."},
	8: {"title": "НЕДЕЛЯ 8  •  ВЫБОРЫ", "body": "Через 26 недель временный мандат должен закончиться досрочными выборами. Во вкладке правительства виден прогноз. На него влияют поддержка власти, стабильность и группы. Позже появятся отдельные решения о кандидатуре и правилах подсчёта."},
	9: {"title": "НЕДЕЛЯ 9  •  НАСЕЛЕНИЕ", "body": "В экономике показаны всё население и его работоспособная часть. Работающие создают доход и могут быть призваны. Остальные учитываются при расходах на социальную помощь. Больницы, образование и Церковь влияют на изменение населения; война уносит людей и уменьшает возможности экономики."},
	10: {"title": "НЕДЕЛЯ 10  •  ДОЛГ И КОРРУПЦИЯ", "body": "Приоритетное погашение долга дорого сегодня, зато постепенно уменьшает долг и процентную ставку. Недостаточное обслуживание сохраняет деньги сейчас, но проценты растут. Коррупция уменьшает доходы; наведите курсор на итоговую сумму, чтобы увидеть, из чего она получилась."},
	11: {"title": "НЕДЕЛЯ 11  •  ЦЕПОЧКИ СОБЫТИЙ", "body": "Некоторые решения вызывают новые события спустя недели: переговоры, забастовки, действия соседей или требования кредиторов. Итог первой карточки может быть только началом истории. Сводка покажет, что именно изменилось после завершения недели."},
	12: {"title": "НЕДЕЛЯ 12  •  САМОСТОЯТЕЛЬНОЕ УПРАВЛЕНИЕ", "body": "Основные разделы уже открыты. Перед новой неделей проверяйте три вещи: прогноз казны, голубые ожидаемые изменения и угрозы в текущих событиях. Необязательно улучшать все показатели сразу — выбирайте, какие уступки страна способна пережить."}
}
const STORY_SEED_SALT := 0x53544F52
const ROUTINE_SEED_SALT := 0x524F5554
const CABINET_SEED_SALT := 0x43414249
const BUDGET_LEVEL_NAMES := ["сокращённый", "базовый", "приоритетный"]
const BUDGET_LEVEL_MULTIPLIERS := {
	"budget_social": [0.50, 1.0, 1.35],
	"budget_health": [0.50, 1.0, 1.35],
	"budget_admin": [0.35, 1.0, 1.35],
	"budget_defense": [0.55, 1.0, 1.35],
	"budget_debt": [0.70, 1.0, 1.40],
	"budget_infrastructure": [0.10, 1.0, 1.60]
}
const PARLIAMENT_TOTAL_SEATS := 120
const PARLIAMENT_MAJORITY := 61
const PARLIAMENT_CONSTITUTIONAL_MAJORITY := 80
const EMERGENCY_POWERS_MAX_STABILITY := 60
const DEBT_INITIAL_WEEKLY_RATE := 0.006
const DEBT_MIN_WEEKLY_RATE := 0.003
const DEBT_UNDERPAY_RATE_INCREASE := 0.0004
const DEBT_PRIORITY_RATE_DECREASE := 0.00019
const WORKFORCE_TAX_PER_MILLION := 1.75
const SOCIAL_DEPENDENT_COST_PER_MILLION := 0.91
const MONTHLY_HEALTH_POPULATION_CHANGE := 12000
const HEALTH_POPULATION_WEEK_DELTA := 3000
const HEALTH_WORKFORCE_TAX_MULTIPLIERS := [0.90, 1.0, 1.08]
const MONTHLY_CHURCH_POPULATION_BONUS := 6000
const NEW_POPULATION_WORKABLE_SHARE := 0.90
const FOREIGN_MINISTER_INITIATIVE_WEEKS := 5
const KRES_IMPORTED_FUEL_BONUS := 4
const NARIN_CRISIS_DELAY_WEEKS := 2
const PARLIAMENT_FACTIONS := [
	{"key": "center", "title": "Президентский центр", "seats": 50, "group": "Партия президента"},
	{"key": "guard", "title": "Старая гвардия", "seats": 32, "group": "Партия президента"},
	{"key": "regions", "title": "Региональный список", "seats": 18, "group": "Вне коалиции"},
	{"key": "civic", "title": "Гражданская коалиция", "seats": 20, "group": "Оппозиция"}
]
const WEEKLY_BUDGET_LINES := [
	{"key": "budget_social", "title": "Социальная помощь", "impact": "Пенсии, пособия, поддержка людей с инвалидностью и семей с детьми."},
	{"key": "budget_health", "title": "Образование и медицина", "impact": "Школы, больницы, налоговая отдача работающих, демография и лечение раненых."},
	{"key": "budget_admin", "title": "Государственный аппарат", "impact": "Работа ведомств, канцелярии и подготовка законов."},
	{"key": "budget_defense", "title": "Армия и внутренние силы", "impact": "Содержание военнослужащих, техники, авиации и сил безопасности."},
	{"key": "budget_debt", "title": "Обслуживание долга", "impact": "Обязательные выплаты по государственному долгу."},
	{"key": "budget_infrastructure", "title": "Инфраструктура", "impact": "Ремонт сетей, дорог и региональной инфраструктуры."}
]
const CUSTOM_BUDGET_ICON_PATHS := {
	"budget_social": "res://assets/budget_icons/budget_social.png",
	"budget_health": "res://assets/budget_icons/budget_health.png",
	"budget_admin": "res://assets/budget_icons/budget_admin.png",
	"budget_defense": "res://assets/budget_icons/budget_defense.png",
	"budget_debt": "res://assets/budget_icons/budget_debt.png",
	"budget_infrastructure": "res://assets/budget_icons/budget_infrastructure.png"
}
const GENERAL_PORTRAIT := preload("res://assets/portraits/general.png")
const MANNEQUIN_PORTRAIT := preload("res://assets/portraits/mannequin.png")
const CHARACTER_INDEX := {
	"president": 0, "father": 1, "brother": 2,
	"radan": 3, "grad": 4, "sorec": 5,
	"volsky": 6, "kovach": 7, "sava": 8,
	"yun": 9, "zukan": 10, "narin": 11,
	"varek": 12, "kres": 13, "spouse": 14,
	"chef": 15, "doctor": 16, "chair": 17,
	"journalist": 18, "governor": 19, "official": 20,
	"military": 21, "diplomat": 22, "family": 23
}
const MINISTER_OFFICES := {
	"economy": "МИНИСТР ЭКОНОМИКИ",
	"interior": "МИНИСТР ВНУТРЕННИХ ДЕЛ",
	"defense": "МИНИСТР ОБОРОНЫ",
	"foreign": "МИНИСТР ИНОСТРАННЫХ ДЕЛ"
}
const MINISTER_CANDIDATES := {
	"economy": [
		{"id": "radan", "name": "Анна Радан", "ideology": "рыночный реформатор", "loyalty": "осторожная", "patron": "городской бизнес и международные кредиторы", "trait": "Доверие кредиторов", "known": "Открывает кредиты и приватизацию; сокращение социальных расходов сильнее злит профсоюзы.", "effects": {}},
		{"id": "grad", "name": "Виктор Град", "ideology": "государственник", "loyalty": "высокая к курсу отца", "patron": "директора государственных предприятий", "trait": "Чрезвычайный сбор", "known": "На старте или при первом назначении укрепляет профсоюзы и раздражает олигархов. Открывает национализацию и сырьевой сбор.", "effects": {"clan_workers": 4, "clan_oligarchs": -6}},
		{"id": "sorec", "name": "Мила Сорец", "ideology": "социальный компромисс", "loyalty": "условная", "patron": "профсоюзы", "trait": "Трёхстороннее соглашение", "known": "На старте или при первом назначении заметно укрепляет профсоюзы ценой отношений с олигархами. Улучшает переговоры в трудовых конфликтах и открывает закон о коллективных договорах; кредиторы предлагают более жёсткие условия.", "effects": {"clan_workers": 8, "clan_oligarchs": -8}}
	],
	"interior": [
		{"id": "volsky", "name": "Марек Вольский", "ideology": "крепкая рука", "loyalty": "высокая", "patron": "силовики", "trait": "Быстрый разгон", "known": "Предлагает точечные задержания организаторов протестов. Открывает закон «Ограничение СМИ»: пропаганда смягчает потери поддержки, но вызывает протест и усиливает авторитарный курс.", "effects": {}},
		{"id": "kovach", "name": "Ирина Ковач", "ideology": "гражданская реформа", "loyalty": "надёжная", "patron": "юристы и городские активисты", "trait": "Посредники", "known": "На старте или при первом назначении повышает поддержку власти; армия возмущается, пока обороной руководит брат. Легализует переговоры и открывает закон об общественном посредничестве: гражданские протесты начинаются слабее, но забастовки он не смягчает.", "effects": {"support": 2}},
		{"id": "sava", "name": "Антон Сава", "ideology": "административный нейтрал", "loyalty": "неизвестная", "patron": "губернаторы", "trait": "Тихая сеть", "known": "На старте или при первом назначении укрепляет губернаторов. Раскалывает протест через регионы и открывает закон о региональных комиссиях: гражданские выступления слабее бьют по стабильности, а передача переговоров больше не перегружает аппарат президента.", "effects": {"clan_regions": 6}}
	],
	"defense": [
		{"id": "brother", "name": "Старший брат", "ideology": "авторитарный государственник", "loyalty": "семье и наследию отца", "patron": "армейское командование", "trait": "Война на истощение", "known": "Сильный оборонительный командир. Обычным кадровым решением снять его нельзя.", "locked": true, "locked_reason": "Защищён положением в армии и сюжетом.", "effects": {}},
		{"id": "yun", "name": "Милош Юн", "ideology": "либеральный профессионал", "loyalty": "гражданской власти", "patron": "младшие офицеры", "trait": "Глухая оборона", "known": "Повышает качество обороны и гражданский контроль, но слабее в наступлении.", "locked": true, "locked_reason": "Станет доступен после сюжетного ослабления брата.", "effects": {}},
		{"id": "zukan", "name": "Грегор Жукан", "ideology": "сторонник массовой армии", "loyalty": "неизвестная", "patron": "ветеранские организации", "trait": "Пехотный вал", "known": "Получает выгоду от численности ценой больших людских потерь.", "locked": true, "locked_reason": "Станет доступен после сюжетного ослабления брата.", "effects": {}}
	],
	"foreign": [
		{"id": "narin", "name": "Лея Нарин", "ideology": "нейтралист", "loyalty": "надёжная", "patron": "профессиональная дипломатия", "trait": "Красные линии", "known": "Снижает цену дипломатической миссии с 3 до 2 млн. Один раз может открыть кризисный канал, который отложит подготовленное вторжение на две недели.", "effects": {}},
		{"id": "varek", "name": "Элиан Варек", "ideology": "прозападный либерал", "loyalty": "идее западного курса", "patron": "экспортёры и западные фонды", "trait": "Открытые двери", "known": "На старте или при первом назначении сближает республику с Западной Федерацией и отдаляет от Восточного Союза. Только при нём можно подписать западный протокол инвестиционного арбитража.", "effects": {"west_commitment": 1}},
		{"id": "kres", "name": "Дарья Крес", "ideology": "сторонница сделки с Востоком", "loyalty": "прагматичная", "patron": "энергетические компании", "trait": "Старая линия", "known": "На старте или при первом назначении сближает республику с Восточным Союзом и отдаляет от Западной Федерации. Только при ней можно передать Восточному Союзу приграничное нефтяное месторождение.", "effects": {"east_commitment": 1}}
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
const ARMISTICE_MIN_WAR_WEEKS := 6
const ARMISTICE_MIN_EFFECTIVENESS := 65
const ARMISTICE_MIN_EQUIPMENT_COVERAGE := 70
const ARMISTICE_MIN_SUPPLY := 90
const ARMISTICE_MIN_WAR_SUPPORT := 35
const ARMISTICE_PERSONNEL_RESERVE := 5000
const ARMISTICE_HOLD_WEEKS := 5
const ARMISTICE_MIN_FUTURE_EFFECTIVENESS := 55
const PRIVATIZED_OIL_OUTPUT_LOSS := 2
const PRIVATIZED_METAL_OUTPUT_LOSS := 2
const OIL_PRICE := 0.22
const METAL_PRICE := 0.30
const NATIONALIZATION_COMPENSATION_COST := 15.0
const NATIONALIZED_STATE_ENTERPRISE_INCOME_BONUS := 3.0
const NATIONALIZED_EQUIPMENT_OUTPUT_MULTIPLIER := 1.25
const SAVE_VERSION := 1
const SAVE_PATH := "user://campaign_save.json"
const SETTINGS_PATH := "user://display_settings.json"
const ACHIEVEMENTS_PATH := "user://ending_achievements.json"
# The music file itself is normalized to the same peak range as the effects.
# Keeping the player at unity gain makes the slider predictable and audible.
const MUSIC_BASE_VOLUME_DB := -2.0
const ENDING_ACHIEVEMENTS := [
	{"id": "power_retained", "title": "Удержать власть", "description": "Завершить 26 недель у власти с признанным мандатом или принятым переносом выборов."},
	{"id": "power_transferred", "title": "Передать власть", "description": "Завершить 26 недель и передать президентский пост победителю выборов."}
]
const SPECIAL_ACHIEVEMENTS := [
	{"id": "bills_without_rescuers", "title": "Счета без спасателей", "description": "Отказаться от печати денег и кредита в кризисе «Счета к оплате», затем прожить четыре игровые недели без дефолта."},
	{"id": "armistice_signed", "title": "Тишина на фронте", "description": "Заключить перемирие после затяжной войны, сохранив достаточно сильную армию для продолжения обороны."},
	{"id": "two_front_war", "title": "Между двух огней", "description": "Оказаться в состоянии войны одновременно с Восточным Союзом и Западной Федерацией."},
	{"id": "peaceful_campaign", "title": "Двадцать шесть недель мира", "description": "Завершить все 26 недель кампании, ни разу не вступив в войну."}
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
	var custom_texture: Texture2D

	func setup(new_role: String, new_accent: Color, new_texture: Texture2D = null) -> void:
		role = new_role
		accent = new_accent
		custom_texture = new_texture
		queue_redraw()

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var s := size
		if custom_texture != null:
			var texture_size := custom_texture.get_size()
			var target_size := Vector2(s.y * texture_size.x / texture_size.y, s.y)
			if target_size.x > s.x:
				target_size *= s.x / target_size.x
			var target := Rect2((s - target_size) * 0.5, target_size)
			draw_texture_rect(custom_texture, target, false)
			return
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
		var shoulders := PackedVector2Array()
		for point in [Vector2(0.115, 0.91), Vector2(0.13, 0.79), Vector2(0.17, 0.69), Vector2(0.23, 0.62), Vector2(0.30, 0.58), Vector2(0.40, 0.55), Vector2(0.50, 0.55), Vector2(0.60, 0.55), Vector2(0.70, 0.58), Vector2(0.77, 0.62), Vector2(0.83, 0.69), Vector2(0.87, 0.79), Vector2(0.885, 0.91)]:
			shoulders.append(Vector2(point.x * s.x, point.y * s.y))
		draw_polygon(shoulders, PackedColorArray([silhouette]))
		draw_rect(Rect2(Vector2(s.x * 0.449, s.y * 0.434), Vector2(s.x * 0.102, s.y * 0.116)), silhouette)
		draw_circle(head_pos, head_radius, silhouette)
		if role == "military":
			draw_rect(Rect2(head_pos.x - head_radius * 1.15, head_pos.y - head_radius * 0.9, head_radius * 2.3, head_radius * 0.35), accent)
			draw_line(Vector2(s.x * 0.23, s.y * 0.64), Vector2(s.x * 0.36, s.y * 0.62), accent, 5.0)
			draw_line(Vector2(s.x * 0.64, s.y * 0.62), Vector2(s.x * 0.77, s.y * 0.64), accent, 5.0)
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
	var custom_texture: Texture2D

	func setup(new_key: String, new_accent: Color, new_texture: Texture2D = null) -> void:
		budget_key = new_key
		accent = new_accent
		custom_texture = new_texture
		queue_redraw()

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var s := size
		var c := Vector2(s.x * 0.5, s.y * 0.5)
		var dark := Color("#24272b")
		draw_rect(Rect2(Vector2(2, 2), s - Vector2(4, 4)), Color(accent, 0.13), true)
		draw_rect(Rect2(Vector2(2, 2), s - Vector2(4, 4)), accent, false, 2.0)
		if custom_texture != null:
			var icon_size := maxf(1.0, minf(s.x, s.y) - 10.0)
			var icon_position := (s - Vector2(icon_size, icon_size)) * 0.5
			draw_texture_rect(custom_texture, Rect2(icon_position, Vector2(icon_size, icon_size)), false)
			return
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
var ending_track: Control
var ending_back_button: Button
var ending_next_button: Button
var ending_progress_label: Label
var ending_transition: Tween
var ending_chapter_index := 0
var ending_preview_active := false
var ending_preview_game_layer: Control
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
var sidebar_number_values: Dictionary = {}
var sidebar_number_targets: Dictionary = {}
var sidebar_number_tween: Tween
var sidebar_number_flush_pending := false
var sidebar_refresh_pending := false
var overlay: Control
var achievements_menu_button: Button
var overlay_can_cancel := false
var active_overlay_scroll: ScrollContainer
var debug_cheat_panel: Control
var debug_cheat_fields: Dictionary = {}
var event_resolved := false
var events_resolved_this_week := 0
var events_required_this_week := EVENTS_PER_WEEK
var save_path_override := ""
var fullscreen_enabled := false
var audio_enabled := true
var music_enabled := true
var audio_volume_percent := 100.0
var music_volume_percent := 100.0
var event_choice_hints_enabled := false
var language_code := "en"
var game_localization := preload("res://scripts/localization.gd").new()
var localization_elapsed := 0.0
var tutorial_enabled := true
var tutorial_seen: Array[String] = []
var tutorial_card: PanelContainer
var tutorial_dialog: Control
var tutorial_left_panel: PanelContainer
var tutorial_right_panel: PanelContainer
var tutorial_left_status_extra: VBoxContainer
var tutorial_left_clans_section: VBoxContainer
var tutorial_left_foreign_section: VBoxContainer
var tutorial_left_army_section: VBoxContainer
var tutorial_left_mask: PanelContainer
var tutorial_right_mask: PanelContainer
var tutorial_focus_layer: Control
var tutorial_minister_section: VBoxContainer
var tutorial_sections_header: HBoxContainer
var tutorial_section_grid: GridContainer
var tutorial_section_buttons: Dictionary = {}
var audio_streams: Dictionary = {}
var audio_players: Dictionary = {}
var music_player: AudioStreamPlayer
var music_watchdog_elapsed := 0.0


func _ready() -> void:
	DisplayServer.window_set_title("Heir to the Republic • v%s" % GAME_VERSION)
	theme = build_interface_theme()
	get_tree().node_added.connect(attach_wrapped_tooltip)
	load_display_settings()
	# Existing smoke checks assert Russian source text; the dedicated locale check
	# exercises both languages and the normal game still starts in English.
	var command_args := OS.get_cmdline_user_args()
	if "--localization-smoke-test" not in command_args:
		for argument in command_args:
			if str(argument).ends_with("-smoke-test"):
				language_code = "ru"
				break
	game_localization.set_language(language_code)
	setup_audio()
	build_event_database()
	show_start_screen()
	localize_visible_tree()
	call_deferred("capture_preview_if_requested")


func attach_wrapped_tooltip(node: Node) -> void:
	if node is Control and node != self and is_ancestor_of(node) and node.get_script() == null:
		node.set_script(WRAPPED_TOOLTIP_SCRIPT)


func _input(event: InputEvent) -> void:
	if not OS.is_debug_build() or not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	if ending_preview_active and key_event.keycode in [KEY_F2, KEY_ESCAPE]:
		close_debug_ending_preview()
		get_viewport().set_input_as_handled()
		return
	if key_event.keycode == KEY_F2 and not key_event.alt_pressed and not key_event.ctrl_pressed and not key_event.meta_pressed:
		if is_instance_valid(debug_cheat_panel):
			close_debug_cheats()
		elif is_instance_valid(game_root) and not state.is_empty():
			show_debug_cheats()
		get_viewport().set_input_as_handled()
	elif key_event.keycode == KEY_ESCAPE and is_instance_valid(debug_cheat_panel):
		close_debug_cheats()
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	localization_elapsed += delta
	if localization_elapsed >= 0.15:
		localization_elapsed = 0.0
		localize_visible_tree()
	if not music_enabled or not is_instance_valid(music_player):
		music_watchdog_elapsed = 0.0
		return
	music_watchdog_elapsed += delta
	if music_watchdog_elapsed >= 1.0:
		music_watchdog_elapsed = 0.0
		if not music_player.playing:
			music_player.play()


func capture_preview_if_requested() -> void:
	var args := OS.get_cmdline_user_args()
	if "--localization-smoke-test" in args:
		run_localization_smoke_test()
		return
	if "--debug-cheat-smoke-test" in args:
		run_debug_cheat_smoke_test()
		return
	if "--settings-smoke-test" in args:
		run_settings_smoke_test()
		return
	if "--tooltip-smoke-test" in args:
		run_tooltip_smoke_test()
		return
	if "--tutorial-smoke-test" in args:
		run_tutorial_smoke_test()
		return
	if "--prologue-smoke-test" in args:
		run_prologue_smoke_test()
		return
	if "--logic-smoke-test" in args:
		run_logic_smoke_test()
		return
	if "--arc-smoke-test" in args:
		run_arc_smoke_test()
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
	if "--ending-smoke-test" in args:
		run_ending_smoke_test()
		return
	if "--unrest-smoke-test" in args:
		run_unrest_smoke_test()
		return
	var game_captures := ["--capture-main-menu", "--capture-achievements", "--capture-new-game-menu", "--capture-new-game-seed", "--capture-new-game-cyborg", "--capture-settings", "--capture-credits", "--capture-prologue", "--capture-game", "--capture-tutorial", "--capture-guide", "--capture-week-two", "--capture-week-briefing", "--capture-clans", "--capture-economy", "--capture-tooltip-economy", "--capture-budget-icons", "--capture-budget-levels", "--capture-budget-vote", "--capture-army", "--capture-government", "--capture-candidates", "--capture-minister-vote", "--capture-laws", "--capture-foreign", "--capture-war", "--capture-war-crisis", "--capture-weekly", "--capture-weekly-law", "--capture-weekly-law-ru", "--capture-weekly-decisions-ru", "--capture-routine", "--capture-arc-factory", "--capture-arc-broadcast", "--capture-result", "--capture-new-week", "--capture-crisis", "--capture-creditor", "--capture-protest", "--capture-unrest", "--capture-debug-cheats", "--capture-ending-fate", "--capture-ending-country", "--capture-ending-legacy", "--capture-ending-metrics", "--capture-ending-statistics", "--capture-ending-thanks", "--capture-ending-russian", "--capture-ending-russian-metrics", "--capture-ending-russian-statistics", "--capture-ending-russian-thanks"]
	var requested_capture := ""
	for capture_arg in game_captures:
		if capture_arg in args:
			requested_capture = capture_arg
			break
	if not "--capture-preview" in args and requested_capture == "":
		return
	if requested_capture != "":
		if requested_capture not in ["--capture-main-menu", "--capture-achievements", "--capture-new-game-menu", "--capture-new-game-seed", "--capture-new-game-cyborg", "--capture-settings", "--capture-credits", "--capture-prologue"]:
			start_game("Сид: 1991", 1991)
		if requested_capture == "--capture-achievements":
			show_achievements()
		elif requested_capture == "--capture-new-game-menu":
			show_new_game_menu()
		elif requested_capture == "--capture-new-game-seed":
			show_new_game_menu()
			for menu_node in overlay.find_children("*", "Button", true, false):
				if str((menu_node as Button).get_meta("localized_text_source", "")) == "ИГРА С СИДОМ":
					(menu_node as Button).pressed.emit()
					break
		elif requested_capture == "--capture-new-game-cyborg":
			show_new_game_menu()
			for menu_node in overlay.find_children("*", "Button", true, false):
				if str((menu_node as Button).get_meta("localized_text_source", "")) == "РЕЖИМ КИБОРГА":
					(menu_node as Button).pressed.emit()
					break
		elif requested_capture == "--capture-settings":
			show_settings()
		elif requested_capture == "--capture-credits":
			show_credits()
		elif requested_capture == "--capture-prologue":
			start_new_game("Сид: 1991", 1991)
		elif requested_capture == "--capture-debug-cheats":
			show_debug_cheats()
		elif requested_capture == "--capture-tutorial":
			tutorial_enabled = true
			choose_option("left")
			await get_tree().create_timer(0.20).timeout
			continue_after_result()
		elif requested_capture == "--capture-guide":
			show_guide()
		elif requested_capture == "--capture-week-two":
			state.week = 2
			update_interface()
		elif requested_capture == "--capture-week-briefing":
			state.week = 2
			update_interface()
			show_tutorial_week_briefing()
		elif requested_capture == "--capture-clans":
			show_clans()
		elif requested_capture == "--capture-economy":
			show_economy()
		elif requested_capture == "--capture-tooltip-economy":
			show_economy()
			await get_tree().process_frame
			for node in overlay.find_children("*", "Label", true, false):
				var economy_label := node as Label
				if str(economy_label.get_meta("localized_text_source", economy_label.text)).begins_with("Коррупция:"):
					var hover_position := economy_label.get_global_rect().get_center()
					get_viewport().warp_mouse(hover_position)
					var mouse_motion := InputEventMouseMotion.new()
					mouse_motion.position = hover_position
					mouse_motion.global_position = hover_position
					get_viewport().push_input(mouse_motion, true)
					break
			await get_tree().create_timer(1.0).timeout
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
		elif requested_capture in ["--capture-weekly-law", "--capture-weekly-law-ru", "--capture-weekly-decisions-ru"]:
			if requested_capture in ["--capture-weekly-law-ru", "--capture-weekly-decisions-ru"]:
				language_code = "ru"
				game_localization.set_language(language_code)
			active_law = "Светское образование"
			law_progress = 1
			law_target = 2
			law_weekly_cost = 1
			event_resolved = true
			events_resolved_this_week = events_required_this_week
			weekly_event_queue.clear()
			state.financial_slot_consumed = true
			advance_week()
			if requested_capture == "--capture-weekly-decisions-ru":
				var decisions_tab := overlay.find_child("WeeklyTab_decisions", true, false) as Button
				if is_instance_valid(decisions_tab):
					decisions_tab.pressed.emit()
		elif requested_capture == "--capture-routine":
			event_resolved = true
			events_resolved_this_week = 1
			next_event()
		elif requested_capture in ["--capture-arc-factory", "--capture-arc-broadcast"]:
			state.week = 6
			state.campaign_arc = "factory" if requested_capture == "--capture-arc-factory" else "broadcast"
			current_event = campaign_arc_event_for_week()
			current_event["_kind"] = "routine"
			event_resolved = false
			display_current_event()
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
		elif requested_capture.begins_with("--capture-ending-"):
			if requested_capture.begins_with("--capture-ending-russian"):
				language_code = "ru"
				game_localization.set_language("ru")
			state.week = DEMO_WEEKS + 1
			state.election_method = "fair"
			state.final_alignment = "west"
			state.west_relation = 3
			state.east_relation = 1
			state.west_investment_arbitration = true
			state.media_restricted = true
			if requested_capture == "--capture-ending-legacy":
				state.campaign_arc_legacy = "broadcast_independent"
			if requested_capture.ends_with("statistics"):
				state.campaign_income = 242.6
				state.campaign_expenses = 259.3
				state.war_casualties = 8400
				state.campaign_history = []
				for week_index in range(DEMO_WEEKS + 1):
					state.campaign_history.append({"week": week_index, "money": 42.0 - float(week_index) * 0.63 + sin(float(week_index) * 0.66) * 7.0, "population": 4250000 - week_index * 3900 + roundi(sin(float(week_index) * 0.5) * 9000), "debt": 420.0 + float(week_index) * 1.8, "equipment": 300 - week_index * 3})
			if requested_capture == "--capture-ending-russian":
				state.war_casualties = 12000
				state.east_border_oil_concession = true
			show_ending()
			var chapter_index := ["--capture-ending-fate", "--capture-ending-country", "--capture-ending-legacy", "--capture-ending-metrics", "--capture-ending-statistics"].find(requested_capture)
			if requested_capture == "--capture-ending-russian":
				chapter_index = 2
			elif requested_capture == "--capture-ending-russian-metrics":
				chapter_index = 3
			elif requested_capture == "--capture-ending-russian-statistics":
				chapter_index = 4
			elif requested_capture in ["--capture-ending-thanks", "--capture-ending-russian-thanks"]:
				chapter_index = 5
			if chapter_index > 0:
				show_ending_chapter(chapter_index)
				await get_tree().create_timer(0.80).timeout
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var output_path := "res://preview.png"
	if requested_capture == "--capture-main-menu":
		output_path = "res://preview_main_menu.png"
	elif requested_capture == "--capture-achievements":
		output_path = "res://preview_achievements.png"
	elif requested_capture == "--capture-new-game-menu":
		output_path = "res://preview_new_game_menu.png"
	elif requested_capture == "--capture-new-game-seed":
		output_path = "res://preview_new_game_seed.png"
	elif requested_capture == "--capture-new-game-cyborg":
		output_path = "res://preview_new_game_cyborg.png"
	elif requested_capture == "--capture-settings":
		output_path = "res://preview_settings.png"
	elif requested_capture == "--capture-credits":
		output_path = "res://preview_credits.png"
	elif requested_capture == "--capture-prologue":
		output_path = "res://preview_prologue.png"
	elif requested_capture == "--capture-game":
		output_path = "res://preview_game.png"
	elif requested_capture == "--capture-arc-factory":
		output_path = "res://preview_arc_factory.png"
	elif requested_capture == "--capture-arc-broadcast":
		output_path = "res://preview_arc_broadcast.png"
	elif requested_capture == "--capture-tutorial":
		output_path = "res://preview_tutorial.png"
	elif requested_capture == "--capture-guide":
		output_path = "res://preview_guide.png"
	elif requested_capture == "--capture-week-two":
		output_path = "res://preview_week_two.png"
	elif requested_capture == "--capture-week-briefing":
		output_path = "res://preview_week_briefing.png"
	elif requested_capture == "--capture-clans":
		output_path = "res://preview_clans.png"
	elif requested_capture == "--capture-economy":
		output_path = "res://preview_economy.png"
	elif requested_capture == "--capture-tooltip-economy":
		output_path = "res://preview_tooltip_economy.png"
	elif requested_capture == "--capture-budget-icons":
		output_path = "res://preview_budget_icons.png"
	elif requested_capture == "--capture-budget-levels":
		output_path = "res://preview_budget_levels.png"
	elif requested_capture == "--capture-budget-vote":
		output_path = "res://preview_budget_vote.png"
	elif requested_capture == "--capture-army":
		output_path = "res://preview_army.png"
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
	elif requested_capture == "--capture-weekly-law":
		output_path = "res://preview_weekly_law.png"
	elif requested_capture == "--capture-weekly-law-ru":
		output_path = "res://preview_weekly_law_ru.png"
	elif requested_capture == "--capture-weekly-decisions-ru":
		output_path = "res://preview_weekly_decisions_ru.png"
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
	elif requested_capture == "--capture-debug-cheats":
		output_path = "res://preview_debug_cheats.png"
	elif requested_capture.begins_with("--capture-ending-"):
		output_path = "res://preview_%s.png" % requested_capture.trim_prefix("--capture-").replace("-", "_")
	image.save_png(output_path)
	get_tree().quit()


func run_logic_smoke_test() -> void:
	var failures: Array[String] = []
	if campaign_seed_from_text("1991") != 1991:
		failures.append("Числовой сид из меню должен совпадать с числом, используемым тестами и обменом кампаниями.")
	if campaign_seed_caption(1991) != "СИД: 1991" or campaign_seed_caption(-17) != "СИД: -17":
		failures.append("Точный сид кампании должен иметь постоянную видимую подпись при любом режиме запуска.")
	game_mode = "Железный режим"
	state = {"campaign_seed": 1991}
	if campaign_header_caption() != "ЖЕЛЕЗНЫЙ • СИД: 1991":
		failures.append("Железный режим должен показывать свой точный сид в верхней строке.")
	for office in MINISTER_CANDIDATES:
		for candidate in MINISTER_CANDIDATES[office]:
			if (candidate as Dictionary).has("competence"):
				failures.append("У кандидатов не должно быть механики компетентности.")
				break
	var seeded_cabinet_signature := starting_cabinet_signature(1991)
	if seeded_cabinet_signature != starting_cabinet_signature(1991):
		failures.append("Одинаковый сид не воспроизводит стартовый состав правительства.")
	var cabinet_variants := {}
	for cabinet_seed in range(1, 17):
		var cabinet := randomized_starting_ministers(cabinet_seed)
		cabinet_variants[starting_cabinet_signature(cabinet_seed)] = true
		if str(cabinet.get("defense", "")) != "brother":
			failures.append("Старший брат должен оставаться министром обороны при любом сиде.")
			break
	if cabinet_variants.size() < 4:
		failures.append("Новые сиды не создают достаточно разных стартовых кабинетов.")
	var aligned_foreign_seeds := {"kres": 0, "varek": 0}
	for alignment_seed in range(1, 257):
		var foreign_id := str(randomized_starting_ministers(alignment_seed).get("foreign", ""))
		if aligned_foreign_seeds.has(foreign_id) and int(aligned_foreign_seeds[foreign_id]) == 0:
			aligned_foreign_seeds[foreign_id] = alignment_seed
		if int(aligned_foreign_seeds["kres"]) != 0 and int(aligned_foreign_seeds["varek"]) != 0:
			break
	if int(aligned_foreign_seeds["kres"]) == 0 or int(aligned_foreign_seeds["varek"]) == 0:
		failures.append("Тестовые сиды не охватывают обоих внешнеполитических министров.")
	else:
		start_game("Сид: %d" % int(aligned_foreign_seeds["kres"]), int(aligned_foreign_seeds["kres"]))
		if str(selected_ministers.get("foreign", "")) != "kres" or int(state.get("east_relation", 0)) != 3 or int(state.get("west_relation", 0)) != 1:
			failures.append("Дарья Крес на старте должна давать партнёрские отношения с Востоком и натянутые с Западом.")
		start_game("Сид: %d" % int(aligned_foreign_seeds["varek"]), int(aligned_foreign_seeds["varek"]))
		if str(selected_ministers.get("foreign", "")) != "varek" or int(state.get("west_relation", 0)) != 3 or int(state.get("east_relation", 0)) != 1:
			failures.append("Элиан Варек на старте должен давать партнёрские отношения с Западом и натянутые с Востоком.")
	start_game("Сид: 1991", 1991)
	if starting_cabinet_signature(1991) != "%s|%s|%s|%s" % [str(selected_ministers.get("economy", "")), str(selected_ministers.get("interior", "")), str(selected_ministers.get("defense", "")), str(selected_ministers.get("foreign", ""))]:
		failures.append("Новая кампания не назначила министров из кабинетного сида.")
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
	state.strategic_industry_nationalized = false
	state.metal_to_equipment = 2
	state.budget_defense = 1
	var state_enterprise_income_before := state_enterprise_base_income()
	var equipment_before_nationalization := equipment_production_per_week()
	state.strategic_industry_nationalized = true
	if not is_equal_approx(state_enterprise_base_income(), state_enterprise_income_before + NATIONALIZED_STATE_ENTERPRISE_INCOME_BONUS):
		failures.append("Национализация не увеличивает постоянный доход государственных предприятий.")
	var optimistic_nationalization_income := adjusted_money_transaction(NATIONALIZED_STATE_ENTERPRISE_INCOME_BONUS, 0)
	if ceili(NATIONALIZATION_COMPENSATION_COST / optimistic_nationalization_income) < 6:
		failures.append("Национализация окупается менее чем за шесть выплат даже без учёта ответа олигархов.")
	if equipment_before_nationalization != 4 or equipment_production_per_week() != 5:
		failures.append("Национализация должна повышать выпуск наземной техники на 25%.")
	state.strategic_industry_nationalized = false
	state.collective_bargaining_law = false
	var strike_income_without_agreements := weekly_actual_income(3)
	state.collective_bargaining_law = true
	var strike_income_with_agreements := weekly_actual_income(3)
	if strike_income_with_agreements <= strike_income_without_agreements:
		failures.append("Закон Милы Сорец о коллективных договорах не смягчает экономический ущерб крупной забастовки.")
	state.collective_bargaining_law = false
	var achievement_ids := {}
	for achievement in ENDING_ACHIEVEMENTS:
		var achievement_id := str(achievement.get("id", ""))
		if achievement_id == "" or achievement_ids.has(achievement_id):
			failures.append("Каталог достижений содержит пустой или повторяющийся итог правления.")
			break
		achievement_ids[achievement_id] = true
	if achievement_ids.size() != 2 or not achievement_ids.has("power_retained") or not achievement_ids.has("power_transferred"):
		failures.append("За итог правления должны выдаваться только два достижения: удержание и передача власти.")
	for held_result in ["ИЗБРАННЫЙ ПРЕЗИДЕНТ", "УПРАВЛЯЕМАЯ ПОБЕДА", "ПОБЕДА ПО ПРОТОКОЛУ", "ОТЛОЖЕННЫЙ МАНДАТ"]:
		if ending_achievement_id(held_result, DEMO_WEEKS) != "power_retained":
			failures.append("Удержание власти не определяется по результату «%s»." % held_result)
	for transferred_result in ["МИРНАЯ ПЕРЕДАЧА ВЛАСТИ", "АППАРАТ НЕ СПАС"]:
		if ending_achievement_id(transferred_result, DEMO_WEEKS) != "power_transferred":
			failures.append("Передача власти не определяется по результату «%s»." % transferred_result)
	if ending_achievement_id("ИЗБРАННЫЙ ПРЕЗИДЕНТ", DEMO_WEEKS - 1) != "" or ending_achievement_id("КАПИТУЛЯЦИЯ", DEMO_WEEKS) != "" or ending_achievement_id("ИЗБИРАТЕЛЬНЫЙ КРИЗИС", DEMO_WEEKS) != "":
		failures.append("Досрочные и спорные финалы не должны открывать достижения за итог власти.")
	if week_count_text(1) != "1 неделю" or week_count_text(2) != "2 недели" or week_count_text(11) != "11 недель":
		failures.append("Финальный экран неверно склоняет количество прожитых недель.")
	if story_event_pool.size() != 55:
		failures.append("Авторский сюжетный пул должен содержать 55 событий.")
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
	if pool_mandatory_count != 12 or pool_bucket_counts != {"economy": 9, "army": 6, "society": 22, "world": 6}:
		failures.append("Сюжетный пул должен состоять из 12 обязательных и 43 квотируемых событий (9/6/22/6).")
	for new_political_title in ["Один эфир на всех", "Губернатор на ковре", "Повестка в телефоне", "Самолёт из эмиграции", "Пакеты на пленарном заседании"]:
		if not pool_story_ids.has(new_political_title):
			failures.append("В случайном пуле отсутствует новое политическое событие «%s»." % new_political_title)
	for church_title in ["Кресты у братской могилы", "Письмо к воскресной службе", "Ночь за монастырскими воротами"]:
		if not pool_story_ids.has(church_title):
			failures.append("В случайном пуле отсутствует церковное событие «%s»." % church_title)
			continue
		for church_event in story_event_pool:
			if str(church_event.get("title", "")) != church_title:
				continue
			var positive_church := false
			var negative_church := false
			for choice_key in ["left", "right", "third"]:
				var choice: Dictionary = church_event.get(choice_key, {})
				var church_change := int(amplify_decision_effects(choice.get("effects", {}), "core").get("clan_church", 0))
				positive_church = positive_church or church_change >= 8
				negative_church = negative_church or church_change <= -8
			if not positive_church or not negative_church:
				failures.append("Событие «%s» должно позволять заметно повысить или снизить поддержку Церкви." % church_title)
			break
	var church_scandal_template: Dictionary = {}
	for pool_event in story_event_pool:
		if str(pool_event.get("title", "")) == "Скандал с церковью":
			church_scandal_template = pool_event
			break
	if church_scandal_template.is_empty() or church_scandal_template.has("third"):
		failures.append("Событие «Скандал с церковью» должно находиться в случайном пуле и иметь ровно два решения.")
	else:
		var investigation_effects := amplify_decision_effects(church_scandal_template.get("left", {}).get("effects", {}), "core")
		var coverup_effects := amplify_decision_effects(church_scandal_template.get("right", {}).get("effects", {}), "core")
		if int(investigation_effects.get("clan_church", 0)) != -15 or int(coverup_effects.get("clan_church", 0)) != 15 or int(investigation_effects.get("support", 0)) <= 0 or int(coverup_effects.get("support", 0)) >= 0:
			failures.append("Решения церковного скандала не дают точные ±15 к Церкви и противоположную реакцию поддержки власти.")
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
	var political_templates: Array[Dictionary] = preload("res://scripts/political_dispatches.gd").templates()
	if political_templates.size() < 37:
		failures.append("Пул новых политических докладов слишком мал.")
	var political_ids := {}
	for political_template in political_templates:
		var political_id := str(political_template.get("id", ""))
		if political_id == "" or political_ids.has(political_id):
			failures.append("Политические доклады должны иметь разные непустые темы.")
			break
		political_ids[political_id] = true
		if option_effects_dominate(political_template["left"]["effects"], political_template["right"]["effects"]) or option_effects_dominate(political_template["right"]["effects"], political_template["left"]["effects"]):
			failures.append("В политическом докладе %s один вариант численно лучше другого во всём." % political_id)
			break
	var church_routine_counts := {"parish_kitchen": 0, "chaplains": 0}
	for routine_event in recurring_events:
		var routine_family := str(routine_event.get("_family", ""))
		if church_routine_counts.has(routine_family):
			church_routine_counts[routine_family] = int(church_routine_counts[routine_family]) + 1
	for routine_family in church_routine_counts:
		if int(church_routine_counts[routine_family]) > 1:
			failures.append("Малое церковное событие %s не должно повторяться за кампанию." % routine_family)
	if financial_crisis_event.is_empty():
		failures.append("Условное событие финансового кризиса не настроено.")
	if creditor_review_event.is_empty() or not creditor_review_event.has("third"):
		failures.append("Требования международных кредиторов не настроены как отдельный доклад с тремя решениями.")
	if social_protest_event.is_empty() or not social_protest_event.has("third"):
		failures.append("Социальные протесты не настроены как отдельный условный доклад с тремя решениями.")
	for branch_kind in ["reception_tape", "election_protocols", "heating_debt", "constitutional_court", "faith_schism", "volunteer_command", "opposition_return"]:
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
		failures.append("Пограничный кризис появился раньше сюжетного узла о двойном гражданстве.")
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
	if recurring_families.size() != DEMO_WEEKS * (EVENTS_PER_WEEK - 1):
		failures.append("Каждый малый доклад кампании должен иметь отдельный сюжет.")
	for routine_family in recurring_family_counts:
		if int(recurring_family_counts[routine_family]) != 1:
			failures.append("Малый доклад не должен повторяться в той же кампании с другим городом.")
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
	var workable_before := workable_population()
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
	var recruited_from_workforce := int(state.get("army_personnel", 0)) - 50000
	if workable_population() != workable_before - recruited_from_workforce:
		failures.append("Призыв не перевёл новобранцев из работоспособного населения.")
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
	var expected_interior_laws := {
		"volsky": "Ограничение СМИ",
		"kovach": "Закон об общественном посредничестве",
		"sava": "Закон о региональных комиссиях"
	}
	for minister_id in expected_interior_laws:
		selected_ministers.interior = minister_id
		if str(current_interior_law_data().get("name", "")) != str(expected_interior_laws[minister_id]):
			failures.append("Министр внутренних дел %s не открывает свой уникальный закон." % minister_id)
	var law_catalog := minister_law_catalog()
	if law_catalog.size() != 6:
		failures.append("Каталог должен постоянно показывать три экономических и три внутренних министерских закона.")
	selected_ministers.economy = "radan"
	selected_ministers.interior = "volsky"
	if minister_law_lock_reason(minister_law_data("Приватизация сырьевого сектора")) != "" or minister_law_lock_reason(minister_law_data("Ограничение СМИ")) != "":
		failures.append("Законы действующих министров ошибочно показаны недоступными.")
	if not minister_law_lock_reason(minister_law_data("Национализация стратегической промышленности")).contains("Виктор Град") or not minister_law_lock_reason(minister_law_data("Закон об общественном посредничестве")).contains("Ирина Ковач"):
		failures.append("Закрытые министерские законы не объясняют, какой кандидат требуется.")
	var locked_law_influence := int(state.get("influence", 0))
	begin_law("Национализация стратегической промышленности", 3, 1)
	if active_law != "" or int(state.get("influence", 0)) != locked_law_influence:
		failures.append("Закрытый закон другого министра удалось начать в обход интерфейса.")
	state.support = 35
	state.stability = 50
	state.clan_workers = 50
	state.civic_mediation_law = false
	var civic_level_without_law := calculate_unrest_level({"kind": "civic", "base_level": 1})
	var labor_level_without_law := calculate_unrest_level({"kind": "labor", "base_level": 1})
	state.civic_mediation_law = true
	if calculate_unrest_level({"kind": "civic", "base_level": 1}) != civic_level_without_law - 1:
		failures.append("Закон Ковач не уменьшает начальный уровень гражданского протеста.")
	if calculate_unrest_level({"kind": "labor", "base_level": 1}) != labor_level_without_law:
		failures.append("Закон Ковач ошибочно ослабляет трудовые забастовки.")
	state.civic_mediation_law = false
	state.support = 50
	state.stability = 50
	var ordinary_protest_level := calculate_unrest_level({"kind": "civic", "base_level": 2})
	state.stability = 75
	if calculate_unrest_level({"kind": "civic", "base_level": 2}) != ordinary_protest_level - 1:
		failures.append("Высокая стабильность не сдерживает масштаб нового протеста.")
	state.stability = 25
	if calculate_unrest_level({"kind": "civic", "base_level": 2}) != ordinary_protest_level + 1:
		failures.append("Низкая стабильность не усиливает новый протест.")
	state.stability = 50
	state.regional_commissions_law = false
	var civic_stability_loss := unrest_stability_loss(2, false)
	var labor_stability_loss := unrest_stability_loss(2, true)
	state.regional_commissions_law = true
	if unrest_stability_loss(2, false) != civic_stability_loss - 1 or unrest_stability_loss(2, true) != labor_stability_loss:
		failures.append("Закон Савы неверно смягчает недельные последствия протестов или забастовок.")
	selected_ministers.interior = "sava"
	var sava_law_event := build_unrest_event({"cause": "проверка закона", "kind": "civic", "labor": false, "level": 2, "reversible": false})
	if bool(sava_law_event.get("right", {}).get("set", {}).get("regional_administration_disruption", true)):
		failures.append("Региональные комиссии не сняли штраф к очкам решений с ответа Антона Савы.")
	if failures.is_empty():
		print("UNREST_SMOKE_TEST: OK | strike_income=%.2f<%.2f | stability_loss=4 | minister_laws=3 | mediation=yes | commissions=yes" % [strike_income, normal_income])
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
	var starting_foreign_minister := str(selected_ministers.get("foreign", "narin"))
	var expected_starting_relations: Vector2i = {
		"narin": Vector2i(2, 2),
		"varek": Vector2i(1, 3),
		"kres": Vector2i(3, 1)
	}.get(starting_foreign_minister, Vector2i(2, 2))
	if int(state.get("east_relation", 0)) != expected_starting_relations.x or int(state.get("west_relation", 0)) != expected_starting_relations.y:
		failures.append("Стартовые отношения не отражают курс выпавшего министра иностранных дел.")
	state.east_relation = 2
	state.west_relation = 2
	state.east_relation = 1
	if neighbor_relation_band("east") != "натянутые":
		failures.append("Прямая категория отношений не показывает натянутое состояние.")
	state.east_relation = 3
	if neighbor_relation_band("east") != "партнёрские":
		failures.append("Прямая категория отношений не показывает партнёрское состояние.")
	state.east_relation = 0
	state.west_relation = 2
	if neighbor_relation_band("east") != "враждебные":
		failures.append("Прямая категория отношений не показывает враждебное состояние.")
	var support_before_invasion := int(state.support)
	var invasion_note := start_invasion_if_needed()
	if not bool(state.get("at_war", false)) or str(state.get("war_enemy", "")) != "east" or invasion_note == "":
		failures.append("Враждебные отношения не запускают вторжение Восточного Союза.")
	if int(state.support) != mini(100, support_before_invasion + WAR_DEFENSIVE_RALLY_SUPPORT):
		failures.append("Начало оборонительной войны не сплачивает общество разовым приростом поддержки власти.")
	var support_after_invasion := int(state.support)
	start_invasion_if_needed()
	if int(state.support) != support_after_invasion:
		failures.append("Повторная проверка войны начисляет бонус поддержки второй раз.")
	if not should_trigger_war_crisis() or str(build_war_crisis_event().get("title", "")) != "Вторжение":
		failures.append("Начало войны не создаёт обязательный кризисный доклад о вторжении.")
	var one_front_need := frontline_required_personnel()
	var before_battle := state.duplicate(true)
	var single_front_battle := process_war_week(true)
	state = before_battle
	state.west_relation = 0
	var second_invasion_note := start_invasion_if_needed()
	if not two_front_war_active() or not at_war_with("east") or not at_war_with("west") or second_invasion_note == "" or not bool(state.get("war_ever_started", false)):
		failures.append("Враждебный второй сосед не открывает второй фронт.")
	if frontline_required_personnel() <= one_front_need or str(build_war_crisis_event().get("title", "")) != "Второй фронт":
		failures.append("Двухфронтовая война не увеличивает потребность в людях или не создаёт отдельный кризисный доклад.")
	var two_front_state := state.duplicate(true)
	var double_front_battle := process_war_week(true)
	state = two_front_state
	if int(double_front_battle.get("personnel_loss", 0)) <= int(single_front_battle.get("personnel_loss", 0)) or int(double_front_battle.get("equipment_loss", 0)) <= int(single_front_battle.get("equipment_loss", 0)):
		failures.append("Война на два фронта не увеличивает еженедельные потери людей и техники.")
	if not (armistice_readiness().get("missing", []) as Array).has("Перемирие с одним соседом не завершит войну на втором фронте"):
		failures.append("Перемирие с одним соседом ошибочно завершает войну на двух фронтах.")
	start_game("Сид: 1991", 1991)
	state.east_relation = 0
	state.west_relation = 0
	start_invasion_if_needed()
	if not two_front_war_active():
		failures.append("Одновременная враждебность обоих соседей не открывает два фронта сразу.")
	start_game("Сид: 1991", 1991)
	state.at_war = true
	state.war_enemy = "east"
	state.east_relation = 0
	state.west_relation = 2
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
	if war_stability_loss(20) != 4 or war_stability_loss(50) != 2 or war_stability_loss(80) != 1:
		failures.append("Военная потеря стабильности не зависит от поддержки войны по трём уровням.")
	if war_casualty_support_loss(1000, 50000) != 0 or war_casualty_support_loss(1600, 50000) != 1 or war_casualty_support_loss(3200, 50000) != 2:
		failures.append("Большие военные потери не снижают поддержку власти по доле погибших.")
	var personnel_before := int(state.get("army_personnel", 0))
	var equipment_before := int(state.get("army_equipment", 0))
	var stability_before_war := int(state.get("stability", 0))
	var support_before_war := int(state.get("support", 0))
	var war_result := process_war_week()
	if war_result.is_empty() or int(state.get("army_personnel", 0)) >= personnel_before or int(state.get("army_equipment", 0)) >= equipment_before or int(state.get("army_aircraft", 0)) >= 12:
		failures.append("Военная неделя не наносит потери людям, наземной технике и авиации.")
	if stability_before_war - int(state.get("stability", 0)) != int(war_result.get("stability_loss", -1)):
		failures.append("Военные потери стабильности не совпадают с отчётом о неделе.")
	if support_before_war - int(state.get("support", 0)) < int(war_result.get("casualty_support_loss", 0)):
		failures.append("Военные потери не отразились на поддержке власти.")
	state.army_personnel = 0
	if army_effectiveness() != 0:
		failures.append("При отсутствии людей фронтовая боеспособность должна падать до нуля.")
	start_game("Сид: 1991", 1991)
	state.east_relation = 1
	state.west_relation = 2
	var influence_before := int(state.get("influence", 0))
	selected_ministers.foreign = "kres"
	perform_foreign_action("east", "mission")
	if int(state.get("influence", 0)) != influence_before or not pending_week_changes.is_empty():
		failures.append("Министр, отличный от Леи Нарин, провёл закрытую для него дипломатическую миссию.")
	selected_ministers.foreign = "narin"
	perform_foreign_action("east", "mission")
	if projected_pending_value("east_relation") != 2 or projected_pending_value("west_relation") != 1 or int(state.get("influence", 0)) != influence_before - 1 or not foreign_action_used_this_week():
		failures.append("Дипломатическая миссия должна улучшать выбранные отношения, ухудшать противоположные и отнимать очко решения.")
	start_game("Сид: 1991", 1991)
	state.east_relation = 2
	state.west_relation = 2
	selected_ministers.foreign = "narin"
	perform_foreign_action("east", "mission")
	if projected_pending_value("east_relation") != 3 or projected_pending_value("west_relation") != 1:
		failures.append("Переход к партнёрским отношениям неверно меняет дипломатические категории.")
	resolve_pending_week_changes()
	if int(foreign_minister_alignment_effect("east").get("west_relation", 0)) != -1:
		failures.append("Инициатива сторонника уже партнёрского соседа не создаёт политическую цену выбора стороны.")
	start_game("Сид: 1991", 1991)
	selected_ministers.foreign = "kres"
	if not foreign_concession_available("east") or foreign_concession_available("west"):
		failures.append("Дарья Крес должна открывать только восточную нефтяную концессию.")
	perform_foreign_action("east", "concession")
	resolve_pending_week_changes()
	if not bool(state.get("east_border_oil_concession", false)) or current_oil_output() != OIL_OUTPUT - 4:
		failures.append("Восточная уступка не уменьшила доступную добычу нефти на 4 единицы до конца кампании.")
	start_game("Сид: 1991", 1991)
	selected_ministers.foreign = "varek"
	if not foreign_concession_available("west") or foreign_concession_available("east"):
		failures.append("Элиан Варек должен открывать только западный арбитражный протокол.")
	perform_foreign_action("west", "concession")
	resolve_pending_week_changes()
	if not bool(state.get("west_investment_arbitration", false)):
		failures.append("Западный арбитражный протокол не создаёт постоянное соглашение.")
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
	start_game("Сид: 1991", 1991)
	selected_ministers.foreign = "narin"
	state.east_relation = 0
	state.narin_crisis_channel_armed = true
	var delayed_invasion_note := start_invasion_if_needed()
	if bool(state.get("at_war", false)) or bool(state.get("narin_crisis_channel_armed", true)) or not bool(state.get("narin_crisis_channel_used", false)) or int(state.get("narin_crisis_delay_weeks", -1)) != 1 or delayed_invasion_note == "":
		failures.append("Кризисный канал Леи Нарин не запускает двухнедельную отсрочку вторжения.")
	start_invasion_if_needed()
	if bool(state.get("at_war", false)) or int(state.get("narin_crisis_delay_weeks", -1)) != 0:
		failures.append("Кризисный канал Леи Нарин не удерживает вторжение всю вторую неделю.")
	start_invasion_if_needed()
	if not bool(state.get("at_war", false)) or str(state.get("war_enemy", "")) != "east":
		failures.append("После двух недель кризисного канала враждебный сосед не начинает вторжение.")
	start_game("Сид: 1991", 1991)
	selected_ministers.foreign = "varek"
	state.west_relation = 0
	start_invasion_if_needed()
	var varek_resignation := build_foreign_minister_resignation_event()
	var varek_replacements := [
		str(varek_resignation.get("left", {}).get("set", {}).get("free_foreign_appointment", "")),
		str(varek_resignation.get("right", {}).get("set", {}).get("free_foreign_appointment", ""))
	]
	if not should_trigger_foreign_minister_resignation() or str(state.get("resigning_foreign_minister", "")) != "varek" or "varek" in varek_replacements or "narin" not in varek_replacements or "kres" not in varek_replacements:
		failures.append("Война с Западом не создаёт обязательную отставку Варека с бесплатным выбором двух оставшихся дипломатов.")
	var influence_before_free_replacement := int(state.get("influence", 0))
	apply_free_foreign_appointment("narin")
	if str(selected_ministers.get("foreign", "")) != "narin" or int(state.get("influence", 0)) != influence_before_free_replacement:
		failures.append("Срочная замена ушедшего министра иностранных дел должна проходить без очков решений.")
	start_game("Сид: 1991", 1991)
	selected_ministers.foreign = "kres"
	state.east_relation = 0
	start_invasion_if_needed()
	if not should_trigger_foreign_minister_resignation() or str(state.get("resigning_foreign_minister", "")) != "kres" or not is_minister_locked("foreign", minister_data("foreign", "kres")):
		failures.append("Война с Востоком не создаёт отставку Крес либо позволяет снова назначить её к государству-противнику.")
	start_game("Сид: 1991", 1991)
	selected_ministers.foreign = "varek"
	if foreign_minister_initiative_lock_reason() == "" or str(foreign_minister_initiative_data().get("title", "")) != "КРИЗИСНЫЙ КАНАЛ":
		failures.append("Старые отдельные инициативы Варека и Крес всё ещё доступны вместо министерских соглашений.")
	var passports_event: Dictionary = {}
	for story_event in story_event_pool:
		if str(story_event.get("title", "")) == "Два паспорта":
			passports_event = story_event
			break
	var neutral_passport_effects: Dictionary = passports_event.get("third", {}).get("effects", {})
	var converted_passport_effects := convert_legacy_foreign_effects(neutral_passport_effects)
	if passports_event.is_empty() or converted_passport_effects.has("east_relation") or converted_passport_effects.has("west_relation"):
		failures.append("Независимый учёт в событии «Два паспорта» должен сохранять отношения с обоими соседями.")
	start_game("Сид: 1991", 1991)
	selected_ministers.foreign = "narin"
	state.money = 500.0
	state.at_war = true
	state.war_enemy = "east"
	state.war_weeks = 6
	state.east_relation = 0
	if armistice_took_effect_this_week(true, false):
		failures.append("Достижение за перемирие появляется до вступления договора в силу.")
	queue_week_change("Тест перемирия", {"money": -5}, {"at_war": false, "war_armistice_signed": true, "war_ceasefire_until_week": 7, "war_ceasefire_enemy": "east", "east_relation": 1})
	event_resolved = true
	events_resolved_this_week = EVENTS_PER_WEEK
	events_required_this_week = EVENTS_PER_WEEK
	weekly_event_queue.clear()
	advance_week()
	if not armistice_took_effect_this_week(true, false) or bool(state.get("at_war", true)) or not bool(state.get("war_armistice_signed", false)):
		failures.append("Перемирие не вступило в силу при закрытии недели.")
	if armistice_took_effect_this_week(true, true) or armistice_took_effect_this_week(false, false):
		failures.append("Повторное или довоенное состояние ошибочно открывает достижение за перемирие.")
	if failures.is_empty():
		print("FOREIGN_SMOKE_TEST: OK | relation=%s | front_high=%d | front_low=%d | losses=%d/%d | armistice_achievement=week_end" % [neighbor_relation_band("east", true), frontline_required_personnel(80), frontline_required_personnel(25), int(war_result.get("personnel_loss", 0)), int(war_result.get("equipment_loss", 0))])
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("FOREIGN_SMOKE_TEST: " + failure)
		get_tree().quit(1)


func run_prologue_smoke_test() -> void:
	var failures: Array[String] = []
	start_new_game("Сид: 1991", 1991)
	if not is_instance_valid(overlay) or overlay_can_cancel:
		failures.append("Новая игра должна открывать обязательный пролог.")
	else:
		var prologue_text := ""
		var begin_button: Button = null
		for item in overlay.find_children("*", "Label", true, false):
			prologue_text += (item as Label).text + " "
		for item in overlay.find_children("*", "Button", true, false):
			if (item as Button).text == "ОТКРЫТЬ ПЕРВЫЙ ДОКЛАД":
				begin_button = item as Button
		if not prologue_text.contains("погиб при покушении") or not prologue_text.contains("26 недель"):
			failures.append("Пролог не раскрывает гибель отца и срок выборов.")
		if begin_button == null:
			failures.append("В прологе нет кнопки перехода к первому докладу.")
		else:
			begin_button.pressed.emit()
			if is_instance_valid(overlay) or str(current_event.get("title", "")) != "День после похорон":
				failures.append("После пролога не открывается первый доклад.")
	if int(state.get("week", 0)) != 1 or events_resolved_this_week != 0 or weekly_event_queue.size() != EVENTS_PER_WEEK - 1:
		failures.append("Пролог не должен расходовать событие или продвигать неделю.")
	if failures.is_empty():
		print("PROLOGUE_SMOKE_TEST: OK | first_report=yes | week=1 | events_unchanged=yes")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("PROLOGUE_SMOKE_TEST: " + failure)
		get_tree().quit(1)


func run_election_smoke_test() -> void:
	var failures: Array[String] = []
	start_game("Сид: 1991", 1991)
	if str(current_event.get("title", "")) != "День после похорон" or not PROLOGUE_MANDATE_TEXT.contains("26 недель"):
		failures.append("Пролог не объясняет временное президентство и срок досрочных выборов.")
	if str(current_event.get("body", "")).contains("26 недель"):
		failures.append("Первый доклад повторяет сведения о выборах из пролога.")
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


func run_arc_smoke_test() -> void:
	var failures: Array[String] = []
	start_game("Сид: 1992", 1992)
	if str(state.get("campaign_arc", "")) != "factory":
		failures.append("Чётный сид не выбрал историю завода.")
	state.week = 6
	if str(campaign_arc_event_for_week().get("title", "")) != "Ведомость за закрытой дверью":
		failures.append("Заводская история не начинается на шестой неделе.")
	state.week = 7
	if not campaign_arc_event_for_week().is_empty():
		failures.append("Продолжение пришло без первого решения.")
	state.campaign_arc_started = true
	state.factory_advance = true
	if not str(campaign_arc_event_for_week().get("body", "")).contains("выдали заводу аванс"):
		failures.append("Второй доклад не помнит выданный аванс.")
	state.factory_advance = false
	if not str(campaign_arc_event_for_week().get("body", "")).contains("самостоятельно"):
		failures.append("Второй доклад не помнит отказ от аванса.")
	state.week = 9
	state.factory_public_audit = true
	if not campaign_arc_event_for_week().has("third"):
		failures.append("Открытая проверка не открыла парламентский вариант.")
	state.factory_public_audit = false
	if campaign_arc_event_for_week().has("third"):
		failures.append("Парламентский вариант доступен без открытой проверки.")
	state.week = 11
	state.factory_worker_committee = true
	state.factory_advance = false
	if not str(campaign_arc_event_for_week().get("body", "")).contains("снижение цены"):
		failures.append("Финальный контракт обещает вернуть аванс, которого не было.")
	if not str(campaign_arc_event_for_week().get("body_en", "")).contains("cut the cost"):
		failures.append("Составной финальный доклад завода не переведён на английский.")
	state.campaign_arc_legacy = "factory_council"
	var accepted_council := election_acceptance_score()
	var votes_with_council := election_honest_score(false)
	state.campaign_arc_legacy = "factory_director"
	if accepted_council - election_acceptance_score() != 6:
		failures.append("Заводская развязка не меняет признание выборов.")
	if votes_with_council - election_honest_score(false) != 3:
		failures.append("Заводская развязка не меняет число честных голосов.")
	start_game("Сид: 1991", 1991)
	if str(state.get("campaign_arc", "")) != "broadcast":
		failures.append("Нечётный сид не выбрал историю телеканала.")
	state.campaign_arc_started = true
	state.week = 11
	state.broadcast_editor_protected = true
	state.broadcast_open_air = true
	if str(campaign_arc_event_for_week().get("third", {}).get("label", "")) != "Передать эфир комиссии":
		failures.append("Защищённая редакция и открытые частоты не открыли независимый эфир.")
	state.broadcast_open_air = false
	if campaign_arc_event_for_week().has("third"):
		failures.append("Независимый эфир доступен после надзора за частотами.")
	state.campaign_arc_legacy = "broadcast_independent"
	var independent_acceptance := election_acceptance_score()
	var independent_votes := election_honest_score(false)
	state.campaign_arc_legacy = "broadcast_managed"
	if independent_acceptance - election_acceptance_score() != 10:
		failures.append("История телеканала не меняет признание выборов.")
	if independent_votes - election_honest_score(false) != 5:
		failures.append("История телеканала не меняет число честных голосов.")
	var managed_bonus := election_effective_score(false, "managed") - election_honest_score(false)
	state.campaign_arc_legacy = "broadcast_open"
	if managed_bonus - (election_effective_score(false, "managed") - election_honest_score(false)) != 3:
		failures.append("Управляемый эфир не влияет на официальный подсчёт.")
	state.campaign_arc_legacy = "broadcast_independent"
	current_event = election_event_template()
	customize_event_for_ministers()
	if not str(current_event.get("body", "")).contains("Нина Белецкая") or not str(current_event.get("body_en", "")).contains("Nina Beletskaya"):
		failures.append("Финальный доклад не вспоминает историю канала на обоих языках.")
	if not ending_decision_legacy().contains("Предвыборную сетку государственного канала"):
		failures.append("Глава последствий концовки не вспоминает выбранную развязку.")
	game_localization.set_language("en")
	for arc_name in ["factory", "broadcast"]:
		for stage in [1, 2, 3, 4]:
			for branch in [false, true]:
				var sample_state := {
					"factory_advance": branch, "factory_public_audit": branch, "factory_worker_committee": branch,
					"factory_parliament_hearing": branch, "broadcast_contract_open": branch,
					"broadcast_editor_protected": branch, "broadcast_open_air": branch
				}
				var sample: Dictionary = preload("res://scripts/campaign_arcs.gd").build(arc_name, stage, sample_state)
				var translated_body := str(sample.get("body_en", game_localization.text(str(sample.get("body", "")))))
				if game_localization.contains_russian(translated_body):
					failures.append("Английский текст не переведён: %s, часть %d." % [arc_name, stage])
				for side in ["left", "right", "third"]:
					if not sample.has(side):
						continue
					for field in ["label", "hint", "result"]:
						if game_localization.contains_russian(game_localization.text(str(sample[side].get(field, "")))):
							failures.append("Не переведён %s в варианте %s истории %s." % [field, side, arc_name])
	if failures.is_empty():
		print("ARC_SMOKE_TEST: OK | factory=4 reports | broadcast=4 reports | election_memory=yes")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("ARC_SMOKE_TEST: " + failure)
		get_tree().quit(1)


func run_parliament_smoke_test() -> void:
	var failures: Array[String] = []
	start_game("Сид: 1991", 1991)
	selected_ministers.economy = "radan"
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
	selected_ministers.economy = "radan"
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
	selected_ministers.economy = "radan"
	var successful_minister_vote := parliament_vote_forecast("minister", "grad")
	appoint_minister("economy", "grad")
	if not bool(successful_minister_vote.get("passed", false)) or str(selected_ministers.get("economy", "")) != "grad" or int(state.get("influence", 0)) != weekly_influence_cap() - 2:
		failures.append("Одобренная парламентом кандидатура не была назначена.")
	start_game("Сид: 1991", 1991)
	selected_ministers.economy = "radan"
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
	if not is_equal_approx(health_war_loss_multiplier(0), 1.25) or not is_equal_approx(health_war_loss_multiplier(2), 0.80) or monthly_health_population_change(0) != -12000 or monthly_health_population_change(2) != 12000:
		failures.append("Финансирование образования и медицины неверно влияет на население или военные потери.")
	start_game("Сид: 1991", 1991)
	if total_population() != 4250000 or workable_population() != 2510000 or dependent_population() != 1690000:
		failures.append("Стартовые два показателя населения или расчёт неработоспособных неверны.")
	if not is_equal_approx(float(weekly_income_breakdown()[0].get("amount", 0.0)), 4.39) or not is_equal_approx(budget_base_amount("budget_social"), 1.54):
		failures.append("Работоспособные и неработоспособные неверно влияют на налоги или социальные расходы.")
	state.budget_health = 0
	if float(weekly_income_breakdown()[0].get("amount", 0.0)) > 3.96:
		failures.append("Сокращение образования и медицины не уменьшает налоговую отдачу работающих.")
	state.budget_health = 2
	if float(weekly_income_breakdown()[0].get("amount", 0.0)) < 4.73:
		failures.append("Приоритет образования и медицины не повышает налоговую отдачу работающих.")
	state.clan_church = 50
	state.health_funding_balance = 4
	var demographic_total_before := total_population()
	var demographic_workable_before := workable_population()
	process_population_month()
	if total_population() != demographic_total_before + 12000 or workable_population() != demographic_workable_before + 10800:
		failures.append("Приоритетные образование и медицина неверно увеличивают население и его работоспособную часть.")
	state.population_total = demographic_total_before
	state.population_workable = demographic_workable_before
	state.budget_health = 0
	state.health_funding_balance = -4
	process_population_month()
	if total_population() != demographic_total_before - 12000 or workable_population() != demographic_workable_before - 10800:
		failures.append("Сокращение образования и медицины должно в основном уменьшать работоспособное население.")
	state.population_total = demographic_total_before
	state.population_workable = demographic_workable_before
	state.budget_health = 1
	for _week in range(3):
		record_health_funding_week()
	state.budget_health = 2
	record_health_funding_week()
	process_population_month()
	if total_population() != demographic_total_before + 3000 or workable_population() != demographic_workable_before + 2700 or int(state.get("health_funding_balance", -1)) != 0:
		failures.append("Одной недели приоритета недостаточно для полного месячного прироста населения.")
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
	selected_ministers.interior = "volsky"
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
	if int(church_effects.get("war_support", 0)) != 2 or monthly_church_population_bonus() != 12000:
		failures.append("Критическая поддержка Церкви не повышает поддержку войны и население.")
	state.secular_education = true
	church_effects = weekly_clan_effects()
	if int(church_effects.get("war_support", 0)) != 1 or monthly_church_population_bonus() != 6000:
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
	var support_before_social_cut := int(state.get("support", 0))
	var workers_before_social_cut := int(state.get("clan_workers", 0))
	process_weekly_budget_consequences(2)
	if int(state.get("support", 0)) != support_before_social_cut - 1 or int(state.get("clan_workers", 0)) != workers_before_social_cut - 2:
		failures.append("Сокращение социальной помощи не проявилось при первом двухнедельном расчёте.")
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
	selected_ministers.interior = "volsky"
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
	var test_seed := 1991
	for argument in OS.get_cmdline_user_args():
		if str(argument).begins_with("--test-seed="):
			test_seed = str(argument).trim_prefix("--test-seed=").to_int()
	start_game("Сид: %d" % test_seed, test_seed)
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
		and (state.get("campaign_history", []) as Array).size() == DEMO_WEEKS + 1
		and is_equal_approx(float((state.campaign_history as Array)[DEMO_WEEKS].get("money", -1.0)), float(state.get("money", 0.0)))
		and float(state.get("campaign_income", 0.0)) > 0.0
		and float(state.get("campaign_expenses", 0.0)) > 0.0
	)
	if survived:
		print("CAMPAIGN_SMOKE_TEST: OK | seed=%d | resolved=%d | core=%d | routine=%d | urgent=%d | min_week=%d | money=%.2f | support=%d | stability=%d" % [test_seed, resolved_events, int(resolved_by_kind["core"]), int(resolved_by_kind["routine"]), urgent_events, minimum_events_in_week, float(state.get("money", 0.0)), int(state.get("support", 0)), int(state.get("stability", 0))])
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
	if starting_delta > -0.50 or starting_delta < -3.00:
		failures.append("Стартовый недельный баланс с учётом выпавшего кабинета должен оставаться умеренным дефицитом, а не профицитом или немедленной катастрофой.")
	for budget_key in ["budget_social", "budget_health", "budget_admin", "budget_defense", "budget_infrastructure"]:
		var base_amount := budget_final_for_level(budget_key, 1, int(state.get("corruption_tier", 0)))
		var reduced_amount := budget_final_for_level(budget_key, 0, int(state.get("corruption_tier", 0)))
		var priority_amount := budget_final_for_level(budget_key, 2, int(state.get("corruption_tier", 0)))
		if base_amount - reduced_amount < 0.45:
			failures.append("Сокращение статьи «%s» даёт слишком малую недельную экономию." % budget_title(budget_key))
		if priority_amount <= base_amount:
			failures.append("Приоритет статьи «%s» не увеличивает недельный расход." % budget_title(budget_key))
	for key in ["budget_social", "budget_health", "budget_admin", "budget_defense", "budget_debt", "budget_infrastructure"]:
		state[key] = 0
	var austerity_support_start := int(state.get("support", 0))
	var austerity_stability_start := int(state.get("stability", 0))
	var austerity_debt_start := float(state.get("debt", 0.0))
	var austerity_rate_start := debt_weekly_interest_rate()
	for closed_week in range(1, 9):
		process_weekly_budget_consequences(closed_week)
	var austerity_support_end := int(state.get("support", 0))
	var austerity_stability_end := int(state.get("stability", 0))
	var austerity_debt_end := float(state.get("debt", 0.0))
	var austerity_rate_end := debt_weekly_interest_rate()
	var austerity_support_loss := austerity_support_start - austerity_support_end
	var austerity_stability_loss := austerity_stability_start - austerity_stability_end
	if austerity_support_loss < 3 or austerity_support_loss > 6:
		failures.append("Восемь недель сокращения социальной помощи должны создавать заметную, но не обвальную потерю поддержки.")
	if austerity_stability_loss < 5 or austerity_stability_loss > 8:
		failures.append("Одновременное сокращение школ, больниц и инфраструктуры должно быть опасным, но обратимым.")
	if austerity_debt_end - austerity_debt_start < 48.0:
		failures.append("Сокращённое обслуживание долга не накапливает обязательства каждую неделю.")
	if austerity_rate_end - austerity_rate_start < DEBT_UNDERPAY_RATE_INCREASE * 7.9:
		failures.append("Сокращённое обслуживание долга не повышает процентную ставку каждую неделю.")
	start_game("Сид: %d" % test_seed, test_seed)
	state.budget_debt = 2
	var priority_paid := 0.0
	for closed_week in range(1, DEMO_WEEKS + 1):
		priority_paid += budget_amount_by_key("budget_debt")
		process_weekly_budget_consequences(closed_week)
	var baseline_paid := 420.0 * DEBT_INITIAL_WEEKLY_RATE * float(DEMO_WEEKS)
	if priority_paid >= baseline_paid or debt_weekly_interest_rate() > DEBT_MIN_WEEKLY_RATE + 0.00001 or float(state.get("debt", 0.0)) >= 405.0:
		failures.append("Приоритетное обслуживание не окупается как долгосрочная стратегия за полную кампанию.")
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
		failures.append("Жадная стратегия проигрывает слишком рано: неделя %d, казна %.2f, поддержка %d, стабильность %d, армия %d, поддержка войны %d." % [int(state.get("week", 0)), float(state.get("money", 0.0)), int(state.get("support", 0)), int(state.get("stability", 0)), int(state.get("army", 0)), int(state.get("war_support", 0))])
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
	# Проверяем, что осмотрительный маршрут существует в полной кампании;
	# другие сиды могут требовать иной бюджет и политические решения.
	var test_seed := 19
	for argument in OS.get_cmdline_user_args():
		if str(argument).begins_with("--test-seed="):
			test_seed = str(argument).trim_prefix("--test-seed=").to_int()
	start_game("Сид: %d" % test_seed, test_seed)
	# Осмотрительный нейтральный маршрут сразу снимает стартовый перекос
	# профильного дипломата: разовая миссия дешевле 26 недель пограничных издержек.
	if int(state.get("east_relation", 2)) == 1 and int(state.get("west_relation", 2)) == 3:
		perform_foreign_action("east", "mission")
	elif int(state.get("west_relation", 2)) == 1 and int(state.get("east_relation", 2)) == 3:
		perform_foreign_action("west", "mission")
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
		failures.append("Событие «Счета к оплате» повторно появилось без отказа от помощи.")
	apply_state_flags({"financial_crisis_ignored": true})
	if int(state.get("financial_crisis_refusal_week", 0)) != 1 or not bool(state.get("financial_crisis_survival_pending", false)):
		failures.append("Отказ не запустил четырёхнедельное ожидание достижения.")
	state.week = 4
	if should_trigger_financial_crisis() or financial_rescue_survived_four_weeks():
		failures.append("Кризис или достижение появились раньше четырёх недель после отказа.")
	state.week = 5
	if not should_trigger_financial_crisis() or not financial_rescue_survived_four_weeks():
		failures.append("Через четыре недели отказ не позволил повторный кризис или достижение.")
	state.money = 0.0
	if financial_rescue_survived_four_weeks():
		failures.append("Достижение выдано после опустошения казны.")
	state.money = 0.01
	apply_state_flags({"printed_money": true})
	if should_trigger_financial_crisis():
		failures.append("Печать денег не закрыла повторный финансовый кризис.")
	event_resolved = true
	events_resolved_this_week += 1
	if events_resolved_this_week != EVENTS_PER_WEEK + 1 or not weekly_event_queue.is_empty() or not week_ready_for_new_week():
		failures.append("Неделя с кризисом не завершилась после четырёх решений.")
	start_game("Сид: 1991", 1991)
	state.money = 500.0
	apply_state_flags({"financial_crisis_ignored": true})
	for completed_weeks in range(1, 5):
		event_resolved = true
		events_resolved_this_week = EVENTS_PER_WEEK
		events_required_this_week = EVENTS_PER_WEEK
		weekly_event_queue.clear()
		advance_week()
		if int(state.get("week", 0)) != completed_weeks + 1:
			failures.append("Тест отказа не перешёл к следующей неделе.")
			break
		if bool(state.get("financial_crisis_survival_pending", false)) != (completed_weeks < 4):
			failures.append("Достижение не завершило ожидание ровно после четырёх переходов.")
			break
	show_achievements()
	var special_card_found := false
	for node in overlay.find_children("*", "Label", true, false):
		if (node as Label).text.contains("Счета без спасателей"):
			special_card_found = true
			break
	if not special_card_found or SPECIAL_ACHIEVEMENTS.size() != 4:
		failures.append("Особое достижение не отображается отдельно от концовок.")
	if failures.is_empty():
		print("FINANCIAL_CRISIS_SMOKE_TEST: OK | refusal_cooldown=4 | achievement_survival=4 | special_card=yes")
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
	var custom_budget_art_count := 0
	for node in overlay.find_children("BudgetArtwork_*", "Control", true, false):
		if bool(node.get_meta("uses_custom_art", false)):
			custom_budget_art_count += 1
	if custom_budget_art_count != CUSTOM_BUDGET_ICON_PATHS.size():
		failures.append("Пользовательские изображения подключены не ко всем трём выбранным статьям бюджета.")
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
		var sidebar_before_result := sidebar_number_values.duplicate(true)
		choose_option("left")
		await get_tree().create_timer(0.20).timeout
		await get_tree().process_frame
		if not is_instance_valid(overlay):
			failures.append("После решения не появилось окно результата.")
			break
		for metric_key in sidebar_before_result:
			if not is_equal_approx(float(sidebar_number_values.get(metric_key, 0.0)), float(sidebar_before_result[metric_key])):
				failures.append("Боковые показатели начали меняться до закрытия окна результата.")
				break
		if not failures.is_empty():
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
	state.debt_weekly_interest_rate = 0.00525
	state.health_funding_balance = 2
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
	state.debt_weekly_interest_rate = 0.02
	state.health_funding_balance = 0
	selected_ministers.economy = "radan"
	active_law = ""
	event_queue.clear()
	pending_week_changes.clear()
	current_event.clear()
	if not load_campaign():
		failures.append("Сохранённую кампанию не удалось загрузить.")
	else:
		if not is_equal_approx(float(state.get("money", 0.0)), 77.25) or int(state.get("support", 0)) != 73 or not is_equal_approx(float(state.get("debt_weekly_interest_rate", 0.0)), 0.00525):
			failures.append("Основные показатели восстановлены неверно.")
		if int(state.get("health_funding_balance", 0)) != 2:
			failures.append("Накопленный месячный эффект школ и больниц потерян при загрузке.")
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
	game_mode = "Режим киборга"
	state.money = 77.0
	autosave_if_iron()
	state.money = 2.0
	if not load_campaign() or not is_equal_approx(float(state.get("money", 0.0)), 77.0) or game_mode != "Режим киборга" or campaign_header_caption() != "КИБОРГ • СИД: 1991":
		failures.append("Режим киборга не восстановился после выхода через «Продолжить».")
	game_mode = "Без сохранений"
	state.money = 999.0
	if save_campaign(false):
		failures.append("Режим без сохранений разрешил ручную запись кампании.")
	autosave_if_iron()
	var preserved_save := read_save_data()
	if not is_equal_approx(float((preserved_save.get("state", {}) as Dictionary).get("money", 0.0)), 77.0):
		failures.append("Режим без сохранений изменил прежний файл продолжения.")
	if FileAccess.file_exists(campaign_save_path()):
		DirAccess.remove_absolute(absolute_test_path)
	save_path_override = ""
	if failures.is_empty():
		print("SAVE_SMOKE_TEST: OK | state=yes | event_queue=yes | budget_draft=yes | cyborg_resume=yes | legacy_iron_autosave=yes | no_save_preserves_previous=yes")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("SAVE_SMOKE_TEST: " + failure)
		get_tree().quit(1)


func run_tooltip_smoke_test() -> void:
	var failures: Array[String] = []
	var checked := 0
	var longest := 0
	start_game("Сид: 1991", 1991)
	for tab in ["show_clans", "show_economy", "show_army", "show_ministers", "show_foreign_policy", "show_law_selection", "show_settings"]:
		call(tab)
		for node in overlay.find_children("*", "Control", true, false):
			var control := node as Control
			if control == null or control.tooltip_text.is_empty():
				continue
			checked += 1
			longest = maxi(longest, control.tooltip_text.length())
			if control.get_script() != WRAPPED_TOOLTIP_SCRIPT:
				failures.append("Во вкладке %s осталась стандартная подсказка: %s." % [tab, control.name])
				continue
			var tooltip := control.call("_make_custom_tooltip", control.tooltip_text) as Label
			if tooltip == null:
				failures.append("Во вкладке %s подсказка %s не создалась." % [tab, control.name])
				continue
			if tooltip.autowrap_mode == TextServer.AUTOWRAP_OFF or tooltip.custom_minimum_size.x > 520.0 or tooltip.custom_maximum_size.x > 520.0:
				failures.append("Во вкладке %s подсказка %s не ограничена по ширине." % [tab, control.name])
			tooltip.free()
		close_overlay(false)
	if checked < 50:
		failures.append("Проверено слишком мало подсказок во вкладках: %d." % checked)
	if failures.is_empty():
		print("TOOLTIP_SMOKE_TEST: OK | tabs=7 | tooltips=%d | longest=%d | wrap=yes | max_width=520" % [checked, longest])
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("TOOLTIP_SMOKE_TEST: " + failure)
		get_tree().quit(1)


func run_settings_smoke_test() -> void:
	var failures: Array[String] = []
	var main_menu_buttons: Array[String] = []
	for menu_node in screen_layer.find_children("*", "Button", true, false):
		var menu_control := menu_node as Button
		if is_instance_valid(menu_control):
			main_menu_buttons.append(menu_control.text)
	if main_menu_buttons != ["НОВАЯ ИГРА", "ПРОДОЛЖИТЬ", "ДОСТИЖЕНИЯ", "НАСТРОЙКИ", "АВТОРЫ", "ВЫХОД", "DISCORD"]:
		failures.append("В главном меню должны быть шесть основных кнопок и ссылка на Discord.")
	var discord_menu_button := screen_layer.find_child("DiscordServerButton", true, false) as Button
	if not is_instance_valid(discord_menu_button) or discord_menu_button.icon == null:
		failures.append("В правом нижнем углу главного меню отсутствует иконка Discord.")
	style_achievements_menu_button(true)
	var achievement_button_style := achievements_menu_button.get_theme_stylebox("normal") as StyleBoxFlat
	if not achievements_menu_button.text.contains("НОВОЕ") or achievement_button_style == null or achievement_button_style.bg_color != GOLD:
		failures.append("Новое достижение должно подсветить кнопку главного меню.")
	style_achievements_menu_button(false)
	if achievements_menu_button.text != "ДОСТИЖЕНИЯ":
		failures.append("После просмотра достижения подсветка кнопки должна исчезнуть.")
	show_credits()
	if overlay.find_children("*", "Label", true, false).filter(func(node: Node): return (node as Label).text == "dimazan10").is_empty():
		failures.append("На экране авторов отсутствует ник автора проекта.")
	close_overlay()
	show_new_game_menu()
	var new_game_buttons: Array[String] = []
	for menu_node in overlay.find_children("*", "Button", true, false):
		new_game_buttons.append((menu_node as Button).text)
	if new_game_buttons != ["ОБУЧЕНИЕ", "ИГРА С СИДОМ", "СЛУЧАЙНАЯ ИГРА", "РЕЖИМ КИБОРГА", "НАЗАД", "НАЧАТЬ ОБУЧЕНИЕ"]:
		failures.append("Экран новой игры не предлагает четыре режима и кнопку начала выбранной кампании.")
	close_overlay()
	var tooltip_panel := theme.get_stylebox("panel", "TooltipPanel") as StyleBoxFlat
	if tooltip_panel == null or tooltip_panel.bg_color.a < 0.94:
		failures.append("Фон подсказки остаётся слишком прозрачным.")
	if audio_streams.size() < 12 or audio_players.size() != audio_streams.size():
		failures.append("Набор звуков интерфейса создан не полностью.")
	for sound_name in audio_streams.keys():
		var sound_stream := audio_streams[sound_name] as AudioStreamWAV
		if sound_stream == null or sound_stream.data.is_empty():
			failures.append("Звук %s не содержит аудиоданных." % str(sound_name))
	var counter_stream := audio_streams.get("money_print") as AudioStreamWAV
	if counter_stream == null or counter_stream.get_length() < 3.8:
		failures.append("Вместо записи счётной машинки загружен короткий запасной сигнал.")
	var siren_stream := audio_streams.get("war_siren") as AudioStreamWAV
	if not FileAccess.file_exists("res://audio/cc0/war_siren_sumy.wav") or siren_stream == null or siren_stream.get_length() < 4.8:
		failures.append("Сирена начала войны не загружена или слишком короткая.")
	if not is_instance_valid(music_player) or not music_player.stream is AudioStreamWAV:
		failures.append("Фоновая музыкальная петля не создана.")
	elif music_enabled and not music_player.playing:
		failures.append("Фоновая музыка загружена, но плеер не начал воспроизведение.")
	else:
		var tested_music_stream := music_player.stream as AudioStreamWAV
		if tested_music_stream.loop_mode != AudioStreamWAV.LOOP_FORWARD or tested_music_stream.loop_end <= tested_music_stream.loop_begin:
			failures.append("У фоновой музыки задан пустой диапазон цикла.")
	if is_instance_valid(music_player) and music_player.bus != &"Master":
		failures.append("Музыка должна выводиться напрямую в общую звуковую шину.")
	var hover_player := audio_players.get("hover") as AudioStreamPlayer
	if not is_instance_valid(hover_player) or not is_instance_valid(music_player) or hover_player.bus != music_player.bus:
		failures.append("Музыка и звук наведения должны использовать одну звуковую шину.")
	if is_instance_valid(music_player) and music_player.autoplay:
		failures.append("Музыка не должна запускаться до применения сохранённой громкости.")
	if is_instance_valid(music_player) and not is_equal_approx(music_player.volume_db, MUSIC_BASE_VOLUME_DB + volume_offset_db(music_volume_percent)):
		failures.append("Сохранённая громкость музыки не применена до воспроизведения.")
	if is_instance_valid(hover_player) and not is_equal_approx(hover_player.volume_db, float(hover_player.get_meta("base_volume_db", -8.0)) + volume_offset_db(audio_volume_percent)):
		failures.append("Сохранённая громкость эффектов не применена до воспроизведения.")
	var original_audio_volume := audio_volume_percent
	var original_music_volume := music_volume_percent
	audio_volume_percent = 50.0
	music_volume_percent = 25.0
	apply_audio_volume()
	apply_music_volume()
	var decision_player := audio_players.get("decision") as AudioStreamPlayer
	if not is_instance_valid(decision_player) or not is_equal_approx(decision_player.volume_db, float(decision_player.get_meta("base_volume_db", -3.0)) + linear_to_db(0.5)):
		failures.append("Громкость звуковых эффектов не применяется к плеерам.")
	if not is_equal_approx(music_player.volume_db, MUSIC_BASE_VOLUME_DB + linear_to_db(0.25)):
		failures.append("Громкость музыки не применяется независимо от эффектов.")
	audio_volume_percent = 100.0
	music_volume_percent = 100.0
	apply_audio_volume()
	apply_music_volume()
	if is_instance_valid(hover_player) and is_instance_valid(music_player) and music_player.volume_db < hover_player.volume_db:
		failures.append("При одинаковом положении ползунков музыка тише звука наведения.")
	audio_volume_percent = original_audio_volume
	music_volume_percent = original_music_volume
	apply_audio_volume()
	apply_music_volume()
	show_settings()
	if overlay.find_children("*", "HSlider", true, false).size() != 2:
		failures.append("Во вкладке настроек должны быть два ползунка громкости.")
	for settings_button in overlay.find_children("*", "Button", true, false):
		if (settings_button as Button).text.contains("ОБУЧЕНИЕ") or (settings_button as Button).text == "КАК ИГРАТЬ":
			failures.append("Обучение и справка не должны находиться в настройках.")
	close_overlay()
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
	var original_hint_setting := event_choice_hints_enabled
	event_choice_hints_enabled = false
	if event_choice_hints_status_text() != "Последствия решений заранее скрыты." or event_choice_hints_toggle_button_text() != "ПОКАЗЫВАТЬ ПОДСКАЗКИ РЕШЕНИЙ":
		failures.append("Отключённые подсказки решений неверно отражены в настройках.")
	event_choice_hints_enabled = true
	if event_choice_hints_status_text() != "Подсказки под решениями показываются." or event_choice_hints_toggle_button_text() != "СКРЫТЬ ПОДСКАЗКИ РЕШЕНИЙ":
		failures.append("Включённые подсказки решений неверно отражены в настройках.")
	event_choice_hints_enabled = original_hint_setting
	if failures.is_empty():
		print("SETTINGS_SMOKE_TEST: OK | exit_button=yes | audio=13+music | separate_volume_sliders=yes | event_hints=optional_default_off | paper_tabs=yes | war=yes | war_siren=yes | protest=yes | save=yes | money_print=yes | F4=yes | F11=yes | Esc=closes_tabs | Alt+F4=reserved")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("SETTINGS_SMOKE_TEST: " + failure)
		get_tree().quit(1)


func run_localization_smoke_test() -> void:
	var failures: Array[String] = []
	var original_language := language_code
	if event_choice_hints_enabled:
		failures.append("Decision hints should be off until explicitly enabled.")
	language_code = "en"
	game_localization.set_language("en")
	localize_visible_tree()
	var buttons: Array[String] = []
	for menu_node in screen_layer.find_children("*", "Button", true, false):
		buttons.append((menu_node as Button).text)
	if buttons.size() < 6 or buttons[0] != "NEW GAME" or buttons[1] != "CONTINUE" or buttons[3] != "SETTINGS":
		failures.append("The main menu did not switch to English: %s" % str(buttons))
	if game_localization.text("Счета к оплате") != "Bills due":
		failures.append("A story event did not use its English catalog entry.")
	show_settings()
	localize_visible_tree()
	var saved_effect_volume := audio_volume_percent
	var saved_music_volume := music_volume_percent
	var effect_label: Label = null
	var music_label: Label = null
	for node in overlay.find_children("*", "Label", true, false):
		if (node as Label).text.begins_with("Effects volume:"):
			effect_label = node as Label
		elif (node as Label).text.begins_with("Music volume:"):
			music_label = node as Label
	if not is_instance_valid(effect_label) or not is_instance_valid(music_label):
		failures.append("Volume labels are missing in English settings.")
	else:
		change_audio_volume(47.0, effect_label)
		change_music_volume(63.0, music_label)
		if language_code != "en" or effect_label.text != "Effects volume: 47%" or music_label.text != "Music volume: 63%":
			failures.append("Moving volume sliders immediately showed the wrong language.")
		localize_visible_tree()
		if effect_label.text != "Effects volume: 47%" or music_label.text != "Music volume: 63%":
			failures.append("The English volume labels changed after refreshing localization.")
		change_audio_volume(saved_effect_volume, effect_label)
		change_music_volume(saved_music_volume, music_label)
	for toggle_source in [fullscreen_toggle_button_text(), audio_toggle_button_text(), music_toggle_button_text(), event_choice_hints_toggle_button_text()]:
		var toggle_button: Button = null
		var caption := game_localization.text(toggle_source)
		for node in overlay.find_children("*", "Button", true, false):
			if (node as Button).text == caption:
				toggle_button = node as Button
				break
		if not is_instance_valid(toggle_button):
			failures.append("Settings toggle is missing: " + caption)
			continue
		for press_index in range(2):
			toggle_button.pressed.emit()
			var untranslated: Array[String] = []
			for node in overlay.find_children("*", "Control", true, false):
				if node is Label or node is BaseButton:
					var visible_text := str(node.get("text"))
					if game_localization.contains_russian(visible_text):
						untranslated.append(visible_text)
			if not untranslated.is_empty():
				failures.append("A settings toggle briefly showed Russian text in English mode: " + str(untranslated))
	var language_buttons: Array[Button] = []
	for node in overlay.find_children("*", "Button", true, false):
		if (node as Button).text in ["ENGLISH", "RUSSIAN"]:
			language_buttons.append(node as Button)
	if language_buttons.size() != 2:
		failures.append("Both language choices must appear in settings.")
	change_language_from_settings("ru")
	if language_code != "ru" or game_localization.text("НАСТРОЙКИ") != "НАСТРОЙКИ":
		failures.append("Switching back to Russian failed.")
	for node in overlay.find_children("*", "Label", true, false):
		if (node as Label).text.begins_with("Громкость эффектов:"):
			effect_label = node as Label
		elif (node as Label).text.begins_with("Громкость музыки:"):
			music_label = node as Label
	if is_instance_valid(effect_label) and is_instance_valid(music_label):
		change_audio_volume(47.0, effect_label)
		change_music_volume(63.0, music_label)
		localize_visible_tree()
		if language_code != "ru" or effect_label.text != "Громкость эффектов: 47%" or music_label.text != "Громкость музыки: 63%":
			failures.append("Ползунки громкости переключили язык русского интерфейса.")
		change_audio_volume(saved_effect_volume, effect_label)
		change_music_volume(saved_music_volume, music_label)
	change_language_from_settings("en")
	if language_code != "en":
		failures.append("Switching to English failed.")
	change_language_from_settings(original_language)
	if failures.is_empty():
		print("LOCALIZATION_SMOKE_TEST: OK | English default | Russian switch | English events | decision hints off")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("LOCALIZATION_SMOKE_TEST: " + failure)
		get_tree().quit(1)


func run_tutorial_smoke_test() -> void:
	var failures: Array[String] = []
	start_game("Обучение", 1991)
	if str(selected_ministers.get("foreign", "")) != "narin" or int(state.get("east_relation", 0)) != 2 or int(state.get("west_relation", 0)) != 2:
		failures.append("Обучение должно начинаться с Леей Нарин и средними отношениями с обоими соседями.")
	if float(state.get("money", 0.0)) != 60.0 or int(state.get("support", 0)) < 68 or int(state.get("stability", 0)) < 54 or int(state.get("corruption_tier", 0)) != 2:
		failures.append("Учебная кампания не получила умеренный стартовый запас.")
	var accusation_effects := convert_legacy_foreign_effects({"east_pressure": 6, "west_commitment": 1})
	if 2 + int(accusation_effects.get("east_relation", 0)) <= 0 or 2 + int(accusation_effects.get("west_relation", 0)) <= 0:
		failures.append("Первое резкое внешнеполитическое решение не должно сразу переводить соседа во враждебное состояние.")
	refresh_tutorial_focus()
	var state_before := state.duplicate(true)
	var event_before := current_event.duplicate(true)
	if not tutorial_left_mask.visible or not tutorial_right_mask.visible:
		failures.append("Первый доклад не скрывает боковые панели.")
	if tutorial_left_status_extra.visible or tutorial_left_clans_section.visible or tutorial_left_foreign_section.visible or tutorial_left_army_section.visible:
		failures.append("Перед первым решением показаны дополнительные блоки слева.")
	if (tutorial_section_buttons["economy"] as Button).visible or law_button.visible:
		failures.append("Разделы управления открылись до обучения.")
	for stat_key in ["money", "support", "stability", "war_support"]:
		var stat_tooltip := (stat_labels[stat_key] as Label).tooltip_text
		if not stat_tooltip.contains("\n") or stat_tooltip.length() == 0:
			failures.append("Подсказка показателя %s не разбита по уровням." % stat_key)
	for sidebar_label in sidebar_summary_labels.values():
		if not is_instance_valid(sidebar_label):
			continue
		for tooltip_line in (sidebar_label as Label).tooltip_text.split("\n"):
			if tooltip_line.length() > 46:
				failures.append("Подсказка левой панели выходит за заданную ширину.")
				break
	show_economy()
	var corruption_hint_found := false
	for node in overlay.find_children("*", "Label", true, false):
		var economy_label := node as Label
		if not economy_label.text.begins_with("Коррупция:"):
			continue
		corruption_hint_found = economy_label.mouse_filter == Control.MOUSE_FILTER_STOP
		for tier in range(CORRUPTION_LABELS.size()):
			if not economy_label.tooltip_text.contains(CORRUPTION_LABELS[tier].capitalize()) or not economy_label.tooltip_text.contains("−%d%%" % CORRUPTION_TRANSACTION_RATES[tier]):
				corruption_hint_found = false
		break
	if not corruption_hint_found:
		failures.append("Экономика не показывает доступную подсказку со всеми категориями коррупции.")
	close_overlay()
	var first_data: Dictionary = TUTORIAL_WEEK_BRIEFINGS[1]
	show_tutorial_briefing("chapter_1", str(first_data["title"]), str(first_data["body"]))
	if not is_instance_valid(tutorial_dialog) or tutorial_left_mask.visible or not tutorial_right_mask.visible:
		failures.append("После первого решения левая панель не вышла в фокус.")
	if tutorial_left_status_extra.visible or tutorial_left_clans_section.visible or tutorial_left_foreign_section.visible or tutorial_left_army_section.visible:
		failures.append("После первого решения должны быть видны только четыре главных показателя.")
	if state != state_before or current_event != event_before:
		failures.append("Обучение изменило состояние игры или доклад.")
	if not "chapter_1" in campaign_snapshot().get("tutorial_seen", []):
		failures.append("Прогресс обучения не попал в сохранение.")
	if not bool(campaign_snapshot().get("tutorial_enabled", false)):
		failures.append("Сохранение не помнит, что это обучающая кампания.")
	finish_tutorial_dialog()
	var report_sample := {
		"week": 1, "closing_money": 60.0,
		"totals": ["Финансы: казна +1 • долг +2", "Страна: поддержка +1", "Группы: олигархи +1", "Население: всего +1", "Вооружённые силы: техника +1", "Отношения: Восток улучшились", "Институты: коррупция снизилась"],
		"sections": {"decisions": ["Первый указ — Поддержка власти +1 • Олигархи +1.", "Доклад «Письмо без подписи — Каменец»: опубликовать — Стабильность -2 • Церковь Веры +3."], "finance": ["Доходы выросли"], "society": ["Поддержка выросла"], "groups": ["Олигархи укрепились"], "security": ["Техника поступила"], "foreign": ["Посол ответил"]}
	}
	var first_report_content := visible_weekly_report_content(report_sample)
	if bool(first_report_content["finance"]) or bool(first_report_content["army"]) or bool(first_report_content["population"]) or (first_report_content["totals"] as Array).size() != 2 or not str(first_report_content["totals"][0]).begins_with("Казна:") or str(first_report_content["totals"][0]).contains("долг") or not (first_report_content["sections"]["groups"] as Array).is_empty() or not (first_report_content["sections"]["foreign"] as Array).is_empty():
		failures.append("Первая недельная сводка раскрывает ещё закрытые механики.")
	if (first_report_content["sections"]["decisions"] as Array).size() != 2 or not str(first_report_content["sections"]["decisions"][0]).contains("Поддержка власти +1") or str(first_report_content["sections"]["decisions"][0]).contains("Олигархи") or not str(first_report_content["sections"]["decisions"][1]).contains("Письмо без подписи — Каменец»") or str(first_report_content["sections"]["decisions"][1]).contains("Церковь Веры"):
		failures.append("Ранняя сводка должна оставить открытый эффект решения и скрыть закрытый.")
	var previous_report: Dictionary = state.get("last_weekly_report", {}).duplicate(true)
	state.last_weekly_report = report_sample.duplicate(true)
	show_weekly_report()
	var summary_text := ""
	for node in overlay.find_children("*", "Label", true, false):
		summary_text += (node as Label).text + "\n"
	if summary_text.contains("ФИНАНСЫ  ⓘ") or summary_text.contains("АРМИЯ И БЕЗОПАСНОСТЬ") or summary_text.contains("ВНЕШНЯЯ ПОЛИТИКА") or summary_text.contains("Олигархи") or not summary_text.contains("Поддержка власти +1"):
		failures.append("Экран первой недельной сводки показывает закрытые разделы или прячет открытые изменения.")
	var decisions_tab := overlay.find_child("WeeklyTab_decisions", true, false) as Button
	if not is_instance_valid(decisions_tab) or is_instance_valid(overlay.find_child("WeeklyTab_finance", true, false)):
		failures.append("Обучающая сводка не открывает вкладку решений или преждевременно открывает финансы.")
	else:
		decisions_tab.pressed.emit()
		var decisions_page := overlay.find_child("WeeklyPage_decisions", true, false) as Control
		var overview_page := overlay.find_child("WeeklyPage_overview", true, false) as Control
		if not is_instance_valid(decisions_page) or not decisions_page.visible or not is_instance_valid(overview_page) or overview_page.visible:
			failures.append("Вкладка решений не переключает содержание недельной сводки.")
	close_overlay()
	state.last_weekly_report = previous_report
	event_resolved = true
	events_resolved_this_week = EVENTS_PER_WEEK
	weekly_event_queue.clear()
	state.financial_slot_consumed = true
	refresh_tutorial_focus()
	if tutorial_right_mask.visible:
		failures.append("Кнопка новой недели осталась закрыта после докладов.")
	state.week = 2
	event_resolved = false
	events_resolved_this_week = 0
	refresh_tutorial_focus()
	tutorial_seen.append("chapter_2")
	report_sample["week"] = 2
	var second_report_content := visible_weekly_report_content(report_sample)
	if bool(second_report_content["finance"]) or bool(second_report_content["population"]) or (second_report_content["sections"]["groups"] as Array).is_empty():
		failures.append("Сводка второй недели не совпадает с открытием групп.")
	if not (tutorial_section_buttons["clans"] as Button).visible or not tutorial_left_clans_section.visible or (tutorial_section_buttons["economy"] as Button).visible or tutorial_left_status_extra.visible or (tutorial_section_buttons["government"] as Button).visible:
		failures.append("На второй неделе должны открыться группы, но не экономика и правительство.")
	state.week = 3
	refresh_tutorial_focus()
	tutorial_seen.append("chapter_3")
	report_sample["week"] = 3
	var third_report_content := visible_weekly_report_content(report_sample)
	if not bool(third_report_content["finance"]) or not bool(third_report_content["population"]):
		failures.append("Сводка не открыла финансы после третьей недели.")
	if not (tutorial_section_buttons["economy"] as Button).visible or not tutorial_left_status_extra.visible or (tutorial_section_buttons["government"] as Button).visible:
		failures.append("На третьей неделе должна открыться экономика.")
	state.week = 4
	refresh_tutorial_focus()
	if not (tutorial_section_buttons["government"] as Button).visible or law_button.visible or (tutorial_section_buttons["foreign"] as Button).visible:
		failures.append("Правительство открывается перед законами; дипломатия ждёт своего события.")
	var foreign_event_sample := event("Таможенное ведомство", "official", "#536f82", "Пограничные пошлины", "Восточный Союз задержал груз.", option("Ответить", "Отношения изменятся", {"east_pressure": 1}, "Посол ответил."), option("Подождать", "Без изменений", {}, "Груз ждёт."))
	var before_foreign_briefing := state.duplicate(true)
	current_event = foreign_event_sample
	display_current_event()
	if not is_instance_valid(tutorial_dialog) or not (tutorial_section_buttons["foreign"] as Button).visible or not tutorial_left_foreign_section.visible or state != before_foreign_briefing or not "foreign_event" in tutorial_seen:
		failures.append("Событие о соседях не открыло отношения, внешнюю политику и пояснение.")
	if (visible_weekly_report_content(report_sample)["sections"]["foreign"] as Array).is_empty():
		failures.append("Открытая дипломатия не появилась в недельной сводке.")
	finish_tutorial_dialog()
	state.week = 5
	refresh_tutorial_focus()
	if not law_button.visible or (tutorial_section_buttons["army"] as Button).visible:
		failures.append("На пятой неделе должен открыться закон, но не армия.")
	state.week = 6
	refresh_tutorial_focus()
	tutorial_seen.append("chapter_6")
	report_sample["week"] = 6
	if not bool(visible_weekly_report_content(report_sample)["army"]):
		failures.append("Сводка не открыла армию вместе с военной вкладкой.")
	if not (tutorial_section_buttons["army"] as Button).visible or not tutorial_left_army_section.visible or not TUTORIAL_WEEK_BRIEFINGS.has(12):
		failures.append("На шестой неделе должна открыться армия.")
	state.week = 2
	state.at_war = true
	refresh_tutorial_focus()
	if not (tutorial_section_buttons["army"] as Button).visible or not (tutorial_section_buttons["foreign"] as Button).visible or not tutorial_left_army_section.visible:
		failures.append("Война не открыла срочный доступ к армии и дипломатии.")
	state.at_war = false
	show_guide()
	if not is_instance_valid(overlay):
		failures.append("Справка не открылась.")
	close_overlay()
	tutorial_enabled = false
	refresh_tutorial_focus()
	var ordinary_report_content := visible_weekly_report_content(report_sample)
	if (ordinary_report_content["totals"] as Array).size() != (report_sample["totals"] as Array).size() or not bool(ordinary_report_content["full_detail"]) or (ordinary_report_content["sections"]["security"] as Array).is_empty():
		failures.append("Обычная игра потеряла полную недельную сводку из-за учебного фильтра.")
	offer_tutorial("foreign")
	if is_instance_valid(tutorial_card) or "foreign" in tutorial_seen or not (tutorial_section_buttons["government"] as Button).visible:
		failures.append("Выключенное обучение продолжает показывать подсказки.")
	start_game("Без сида", 1991)
	if tutorial_enabled or str(selected_ministers.get("foreign", "")) != str(randomized_starting_ministers(1991).get("foreign", "")):
		failures.append("Обычная игра наследует обучение или фиксированный кабинет учебного режима.")
	start_game("Обучение", 1991)
	for week_number in range(1, 4):
		if week_number > 1:
			state.week = week_number
			prepare_week_event_queue()
		var this_week_events: Array[Dictionary] = []
		if week_number == 1:
			this_week_events.append(current_event)
		this_week_events.append_array(weekly_event_queue)
		for scheduled_event in this_week_events:
			if tutorial_event_touches_foreign_policy(scheduled_event):
				failures.append("Обучение открывает отношения с соседями до четвёртой недели.")
			break
	state.week = 4
	prepare_week_event_queue()
	if weekly_event_queue.is_empty() or str(weekly_event_queue[0].get("title", "")) != "Мороз без топлива":
		failures.append("Доклад о поставках Восточного Союза не перенесён с третьей на четвёртую неделю.")
	start_game("Обучение", 1991)
	state.week = 3
	event_queue.pop_front()
	current_event = event_queue.pop_front().duplicate(true)
	current_event["_kind"] = "core"
	weekly_event_queue.clear()
	migrate_loaded_tutorial_neighbor_events()
	if str(current_event.get("title", "")) != "Офицеры помнят отца" or event_queue.is_empty() or str(event_queue[0].get("title", "")) != "Мороз без топлива":
		failures.append("Сохранённый доклад третьей недели не переносится при загрузке.")
	if failures.is_empty():
		print("TUTORIAL_SMOKE_TEST: OK | four_stats=yes | staged_groups=yes | staged_weekly_report=yes | event_foreign=yes | emergency_access=yes | easier_start=yes | saved_progress=yes | guide=yes")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("TUTORIAL_SMOKE_TEST: " + failure)
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
	localize_property(node, "text", "localized_text")
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	node.horizontal_alignment = alignment
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return node


func localize_visible_tree() -> void:
	if not is_inside_tree():
		return
	localize_node(self)


func localize_node(node: Node) -> void:
	if node is Label or node is BaseButton:
		localize_property(node, "text", "localized_text")
	if node is LineEdit:
		localize_property(node, "placeholder_text", "localized_placeholder")
	if node is Control:
		localize_property(node, "tooltip_text", "localized_tooltip")
	for child in node.get_children():
		localize_node(child)


func localize_property(node: Object, property_name: String, metadata_name: String) -> void:
	var current := str(node.get(property_name))
	var previous := str(node.get_meta(metadata_name + "_shown", ""))
	var source := str(node.get_meta(metadata_name + "_source", ""))
	if current != previous or source == "":
		source = current
	var rendered := source if language_code == "ru" else game_localization.text(source)
	if language_code == "en" and property_name == "text" and not current_event.is_empty():
		if node == body_label and current_event.has("body_en"):
			rendered = str(current_event["body_en"])
		elif node == third_button and current_event.has("third") and (current_event["third"] as Dictionary).has("label_en"):
			rendered = str(current_event["third"]["label_en"])
	if current != rendered:
		node.set(property_name, rendered)
	node.set_meta(metadata_name + "_source", source)
	node.set_meta(metadata_name + "_shown", rendered)


func add_hover_detail(control: Control, detail: String) -> void:
	if detail == "":
		return
	control.tooltip_text = detail
	control.mouse_default_cursor_shape = Control.CURSOR_HELP


func compact_tooltip(text_value: String, max_line_length := 46) -> String:
	if language_code == "en":
		text_value = game_localization.text(text_value)
	var wrapped_lines: Array[String] = []
	for paragraph in text_value.split("\n", true):
		var line := ""
		for word in paragraph.split(" ", false):
			if line != "" and line.length() + word.length() + 1 > max_line_length:
				wrapped_lines.append(line)
				line = word
			else:
				line += (" " if line != "" else "") + word
		wrapped_lines.append(line)
	return "\n".join(wrapped_lines)


func main_stat_tooltip(key: String) -> String:
	match key:
		"money":
			return "КАЗНА\nКритично: денег не хватит после следующей недели — дефолт.\nНизкий запас: до двух недель расходов — название красное.\nОбычный запас: между двумя и шестью неделями расходов.\nВысокий запас: от шести недель расходов — название зелёное."
		"support":
			return "ПОДДЕРЖКА ВЛАСТИ\n0%: президента свергают.\n1–40%: название красное; непопулярное решение может вызвать протест.\n41–50%: непопулярное решение тоже может вызвать протест.\n51–69%: без постоянного бонуса.\n70–100%: стабильность +1 каждую неделю."
		"stability":
			return "СТАБИЛЬНОСТЬ\n0%: государство раскалывается.\n1–30%: −1 очко решений; новые протесты начинаются на уровень сильнее.\n31–69%: без постоянного бонуса.\n70–100%: +1 очко решений; новые протесты начинаются на уровень слабее."
		"war_support":
			return "ПОДДЕРЖКА ВОЙНЫ\n0% во время войны: капитуляция.\n1–30%: набор медленнее; есть уклонисты и дезертиры. Расширение призыва вызывает протест. Война снимает 4 стабильности в неделю.\n31–64%: обычный набор; война снимает 2 стабильности в неделю.\n65–100%: набор быстрее, армия лояльнее; война снимает 1 стабильность в неделю. Нехватка людей на фронте добавляет потери стабильности."
	return ""


func minister_data(slot: String, candidate_id := "") -> Dictionary:
	var wanted_id := candidate_id if candidate_id != "" else str(selected_ministers.get(slot, ""))
	for candidate in MINISTER_CANDIDATES.get(slot, []):
		if str(candidate.get("id", "")) == wanted_id:
			return candidate
	return {}


func current_minister_name(slot: String) -> String:
	var data := minister_data(slot)
	return str(data.get("name", "Вакансия"))


func character_portrait(character_id: String) -> Texture2D:
	return GENERAL_PORTRAIT if character_id in ["brother", "yun", "zukan"] else MANNEQUIN_PORTRAIT


func event_character_id(event_data: Dictionary) -> String:
	var source := str(event_data.get("source", ""))
	match source:
		"Старший брат": return "brother"
		"СОВЕТ ОБОРОНЫ", "ГЕНЕРАЛЬНЫЙ ШТАБ", "СТАВКА ВЕРХОВНОГО КОМАНДОВАНИЯ": return str(selected_ministers.get("defense", "brother"))
		"Супруга президента": return "spouse"
		"Повар резиденции": return "chef"
		"Личный врач президента": return "doctor"
		"Председатель парламента": return "chair"
		"Министерство экономики": return str(selected_ministers.get("economy", "radan"))
		"Министерство внутренних дел": return str(selected_ministers.get("interior", "volsky"))
		"Министерство обороны": return str(selected_ministers.get("defense", "brother"))
		"Министр иностранных дел": return str(selected_ministers.get("foreign", "narin"))
	for slot in MINISTER_CANDIDATES.keys():
		for candidate in MINISTER_CANDIDATES[slot]:
			if source == str(candidate["name"]):
				return str(candidate["id"])
	if source.contains("Редакция") or source.contains("телевидение"):
		return "journalist"
	if source.contains("Губернатор") or source.begins_with("Мэр "):
		return "governor"
	var role := str(event_data.get("role", "official"))
	return role if CHARACTER_INDEX.has(role) else "official"


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
	match str(state.get("campaign_arc_legacy", "")):
		"factory_council", "broadcast_open": score += 2.0
		"factory_settlement": score += 1.0
		"broadcast_independent": score += 3.0
		"factory_director": score -= 1.0
		"factory_security", "broadcast_managed": score -= 2.0
	return clampi(roundi(score), 5, 85)


func election_effective_score(projected := true, rules_override := "") -> int:
	var score := election_honest_score(projected)
	var rules := rules_override if rules_override != "" else str(state.get("election_rules", "undecided"))
	if rules == "negotiated":
		score += 2
	elif rules == "managed":
		score += 8
		if str(state.get("campaign_arc_legacy", "")) == "broadcast_managed":
			score += 3
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
	var score := roundi(
		float(state.get("stability", 0)) * 0.40
		+ float(state.get("support", 0)) * 0.20
		+ float(state.get("army", 0)) * 0.15
		+ clan_average * 0.25
	)
	match str(state.get("campaign_arc_legacy", "")):
		"factory_council", "factory_settlement": score += 3
		"factory_director", "factory_security": score -= 3
		"broadcast_open": score += 4
		"broadcast_independent": score += 6
		"broadcast_managed": score -= 4
	return clampi(score, 0, 100)


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
	if language_code == "en":
		text = "Early election in %d weeks. Forecast: %s.\n\nGovernment support has the greatest effect on a fair result. Stability and the support of workers, regions, the Church and oligarchs also matter.\nCurrent figures: government support %d%% • stability %d%% • average group support %d%%.\nCampaign: %s. Rules: %s." % [weeks_left, game_localization.text(election_forecast_label(projected)), support_value, stability_value, group_average, game_localization.text(election_campaign_name(str(state.get("election_campaign", "")))), game_localization.text(election_rules_name(str(state.get("election_rules", "undecided"))))]
	if str(state.get("election_rules", "")) == "managed":
		text += "\n\nA loyal election commission raises the official result. Media restrictions, authoritarian policies and oligarch support strengthen administrative control but do not raise genuine support. The result may go unrecognized." if language_code == "en" else "\n\nЛояльная комиссия повышает официальный результат. Ограничение СМИ, авторитарный курс и поддержка олигархов усиливают административный ресурс, но не повышают реальную поддержку и могут сделать итог непризнанным."
	else:
		text += "\n\nThe exact vote share will be revealed after the campaign." if language_code == "en" else "\n\nТочная доля голосов будет раскрыта только после завершения кампании."
	var arc_legacy := str(state.get("campaign_arc_legacy", ""))
	if arc_legacy in ["factory_council", "factory_settlement", "broadcast_open", "broadcast_independent"]:
		text += "\n\nThe way you settled a long-running public dispute adds votes and trust to the final election result." if language_code == "en" else "\n\nВаше решение в затяжном общественном конфликте добавляет голоса и повышает доверие к итогам выборов."
	elif arc_legacy in ["factory_director", "factory_security", "broadcast_managed"]:
		text += "\n\nThe way you settled a long-running public dispute costs votes and makes the final result harder to accept." if language_code == "en" else "\n\nВаше решение в затяжном общественном конфликте отнимает голоса и осложняет признание итогов выборов."
	if arc_legacy == "broadcast_managed":
		text += " Managed counting also gains 3 official points from the coordinated broadcast." if language_code == "en" else " При управляемом подсчёте согласованный эфир дополнительно даёт 3 официальных пункта."
	return text


func minister_initial_effects(slot: String, candidate_id: String, candidate: Dictionary) -> Dictionary:
	var effects: Dictionary = (candidate.get("effects", {}) as Dictionary).duplicate(true)
	if slot == "interior" and candidate_id == "kovach" and brother_is_defense_minister():
		effects["army"] = -4
	return amplify_decision_effects(effects, "general")


func is_minister_locked(slot: String, candidate: Dictionary) -> bool:
	if slot == "defense" and bool(state.get("defense_alternatives_unlocked", false)):
		return false
	if slot == "foreign" and foreign_minister_conflicts_with_war(str(candidate.get("id", ""))):
		return true
	return bool(candidate.get("locked", false))


func minister_lock_reason(slot: String, candidate: Dictionary) -> String:
	if slot == "foreign" and foreign_minister_conflicts_with_war(str(candidate.get("id", ""))):
		return "%s не может представлять республику во время войны с государством, курс на которое поддерживает." % str(candidate.get("name", "Этот кандидат"))
	return str(candidate.get("locked_reason", "сюжетное ограничение"))


func foreign_minister_conflicts_with_war(candidate_id: String) -> bool:
	if not bool(state.get("at_war", false)):
		return false
	return (candidate_id == "varek" and at_war_with("west")) or (candidate_id == "kres" and at_war_with("east"))


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
	if language_code == "en":
		if modifier == 0:
			return "%s remain neutral (%d%%): +0." % [game_localization.text(group_name), value]
		return "%s — %s (%d%%): %+d to faction position." % [game_localization.text(group_name), game_localization.text(clan_band(value)), value, modifier]
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
	if language_code == "en":
		var translated_reasons: Array[String] = []
		for reason in reasons:
			translated_reasons.append(game_localization.text(reason))
		return "\n".join(translated_reasons)
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
				lines.append("%s %s: %+d" % [game_localization.text(str(item["title"])) if language_code == "en" else str(item["title"]), "↑" if delta > 0 else "↓", step_modifier * absi(delta)])
		if language_code == "en":
			return "Effect of budget lines on this faction: " + ("; ".join(lines) if not lines.is_empty() else "neutral") + "."
		return "Влияние статей на фракцию: " + ("; ".join(lines) if not lines.is_empty() else "нейтрально") + "."
	if proposal_type == "minister":
		var modifier := int(minister_parliament_modifiers(proposal_id).get(faction_key, 0))
		if language_code == "en":
			return "Candidate ideology, patrons and reputation: %+d." % modifier
		return "Идеология, покровители и репутация кандидата: %+d." % modifier
	if language_code == "en":
		return "The proposal does not change this faction's position."
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
		detail_lines.append("%s: %d of %d in favor • %s (current position %+d, proposal %+d).\n%s\n%s" % [game_localization.text(str(faction["title"])), faction_votes, seats, game_localization.text(parliament_position_name(final_score)), base_score, project_score, parliament_faction_reasons(faction_key), parliament_project_reason(proposal_type, proposal_id, faction_key)] if language_code == "en" else "%s: %d из %d за • %s (текущая позиция %+d, проект %+d).\n%s\n%s" % [str(faction["title"]), faction_votes, seats, parliament_position_name(final_score), base_score, project_score, parliament_faction_reasons(faction_key), parliament_project_reason(proposal_type, proposal_id, faction_key)])
	var no_votes := PARLIAMENT_TOTAL_SEATS - yes_votes
	return {
		"yes": yes_votes,
		"no": no_votes,
		"passed": yes_votes >= PARLIAMENT_MAJORITY,
		"rows": rows,
		"detail": "Requires %d votes out of %d.\n\n%s" % [PARLIAMENT_MAJORITY, PARLIAMENT_TOTAL_SEATS, "\n\n".join(detail_lines)] if language_code == "en" else "Требуется %d голос из %d.\n\n%s" % [PARLIAMENT_MAJORITY, PARLIAMENT_TOTAL_SEATS, "\n\n".join(detail_lines)]
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
	achievements_menu_button = null
	if is_instance_valid(ending_transition):
		ending_transition.kill()
	ending_transition = null
	ending_track = null
	ending_back_button = null
	ending_next_button = null
	ending_progress_label = null
	ending_chapter_index = 0
	ending_preview_active = false
	ending_preview_game_layer = null
	clear_tutorial_card()
	clear_tutorial_dialog()
	tutorial_left_panel = null
	tutorial_right_panel = null
	tutorial_left_status_extra = null
	tutorial_left_clans_section = null
	tutorial_left_foreign_section = null
	tutorial_left_army_section = null
	tutorial_left_mask = null
	tutorial_right_mask = null
	tutorial_focus_layer = null
	tutorial_minister_section = null
	tutorial_sections_header = null
	tutorial_section_grid = null
	tutorial_section_buttons.clear()
	stop_sidebar_number_animation()
	sidebar_number_values.clear()
	sidebar_number_targets.clear()
	sidebar_number_flush_pending = false
	sidebar_refresh_pending = false
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
	localize_property(button, "text", "localized_text")
	button.custom_minimum_size = Vector2(150, 62)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", CREAM)
	button.add_theme_stylebox_override("normal", style(Color("#283139"), 14, Color("#4c5c66"), 1))
	button.add_theme_stylebox_override("hover", style(Color("#34414a"), 14, GOLD, 1))
	button.add_theme_stylebox_override("pressed", style(Color("#1d2429"), 14, GOLD, 2))
	return button


func discord_link_button(text_value: String) -> Button:
	var button := menu_button(text_value)
	button.icon = load("res://assets/social/discord_symbol.svg") as Texture2D
	button.expand_icon = true
	button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(190, 58)
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_stylebox_override("normal", style(Color("#5865f2"), 12, Color("#e0e3ff"), 1))
	button.add_theme_stylebox_override("hover", style(Color("#6975f5"), 12, CREAM, 2))
	button.add_theme_stylebox_override("pressed", style(Color("#4652c4"), 12, CREAM, 2))
	button.tooltip_text = "Join the game's development server" if language_code == "en" else "Сервер разработки игры"
	button.pressed.connect(open_discord_server)
	return button


func open_discord_server() -> void:
	var result := OS.shell_open(DISCORD_INVITE_URL)
	if result != OK:
		push_warning("Could not open Discord invite: %s" % DISCORD_INVITE_URL)


func style_achievements_menu_button(has_new: bool) -> void:
	if not is_instance_valid(achievements_menu_button):
		return
	achievements_menu_button.text = "ДОСТИЖЕНИЯ • НОВОЕ" if has_new else "ДОСТИЖЕНИЯ"
	if has_new:
		achievements_menu_button.add_theme_color_override("font_color", Color("#1d2429"))
		achievements_menu_button.add_theme_stylebox_override("normal", style(GOLD, 14, CREAM, 2))
		achievements_menu_button.add_theme_stylebox_override("hover", style(CREAM, 14, GOLD, 3))
	else:
		achievements_menu_button.add_theme_color_override("font_color", CREAM)
		achievements_menu_button.add_theme_stylebox_override("normal", style(Color("#283139"), 14, Color("#4c5c66"), 1))
		achievements_menu_button.add_theme_stylebox_override("hover", style(Color("#34414a"), 14, GOLD, 1))
	localize_property(achievements_menu_button, "text", "localized_text")


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
	var centered := CenterContainer.new()
	centered.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen_layer.add_child(centered)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 32)
	centered.add_child(layout)
	var title := label("НАСЛЕДНИК\nРЕСПУБЛИКИ", 76, CREAM, HORIZONTAL_ALIGNMENT_CENTER)
	title.add_theme_constant_override("line_spacing", -10)
	layout.add_child(title)
	layout.add_child(label("v%s" % GAME_VERSION, 16, GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	var mode_panel := PanelContainer.new()
	mode_panel.custom_minimum_size = Vector2(520, 0)
	mode_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
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
	var new_game_button := menu_button("НОВАЯ ИГРА")
	new_game_button.pressed.connect(show_new_game_menu)
	column.add_child(new_game_button)
	var saved_campaign := read_save_data()
	var continue_button := menu_button("ПРОДОЛЖИТЬ")
	if saved_campaign.is_empty():
		continue_button.disabled = true
		continue_button.tooltip_text = "Пока нет сохранённой кампании."
	else:
		var saved_state: Dictionary = saved_campaign.get("state", {})
		continue_button.tooltip_text = "%s • week %d • treasury %.2f M • saved %s" % [game_localization.text(str(saved_campaign.get("game_mode", "Кампания"))), int(saved_state.get("week", 1)), float(saved_state.get("money", 0.0)), str(saved_campaign.get("saved_at", "date unknown"))] if language_code == "en" else "%s • неделя %d • казна %.2f млн • сохранено %s" % [str(saved_campaign.get("game_mode", "Кампания")), int(saved_state.get("week", 1)), float(saved_state.get("money", 0.0)), str(saved_campaign.get("saved_at", "дата неизвестна"))]
		continue_button.pressed.connect(load_campaign)
	column.add_child(continue_button)
	achievements_menu_button = menu_button("ДОСТИЖЕНИЯ")
	style_achievements_menu_button(not read_unseen_achievements().is_empty())
	achievements_menu_button.pressed.connect(show_achievements)
	column.add_child(achievements_menu_button)
	var settings_button := menu_button("НАСТРОЙКИ")
	settings_button.pressed.connect(show_settings)
	column.add_child(settings_button)
	var credits_button := menu_button("АВТОРЫ")
	credits_button.pressed.connect(show_credits)
	column.add_child(credits_button)
	var exit_button := menu_button("ВЫХОД")
	exit_button.add_theme_stylebox_override("normal", style(Color("#3b2929"), 14, Color("#76504b"), 1))
	exit_button.add_theme_stylebox_override("hover", style(Color("#573331"), 14, RED, 2))
	exit_button.pressed.connect(quit_game)
	column.add_child(exit_button)
	var discord_button := discord_link_button("DISCORD")
	discord_button.name = "DiscordServerButton"
	discord_button.anchor_left = 1.0
	discord_button.anchor_top = 1.0
	discord_button.anchor_right = 1.0
	discord_button.anchor_bottom = 1.0
	discord_button.offset_left = -218.0
	discord_button.offset_top = -90.0
	discord_button.offset_right = -28.0
	discord_button.offset_bottom = -32.0
	screen_layer.add_child(discord_button)
	localize_visible_tree()


func show_new_game_menu() -> void:
	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(880, 0)
	content.add_theme_constant_override("separation", 18)
	content.add_child(label("НОВАЯ ИГРА", 30, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var columns := HBoxContainer.new()
	columns.custom_minimum_size = Vector2(0, 450)
	columns.add_theme_constant_override("separation", 16)
	content.add_child(columns)
	var mode_panel := PanelContainer.new()
	mode_panel.custom_minimum_size = Vector2(310, 0)
	mode_panel.add_theme_stylebox_override("panel", style(Color("#242c32"), 16, Color("#8f7d5c"), 1))
	columns.add_child(mode_panel)
	var mode_margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		mode_margin.add_theme_constant_override("margin_" + side, 16)
	mode_panel.add_child(mode_margin)
	var mode_column := VBoxContainer.new()
	mode_column.add_theme_constant_override("separation", 12)
	mode_margin.add_child(mode_column)
	mode_column.add_child(label("ВЫБЕРИТЕ РЕЖИМ", 16, GOLD))
	var mode_buttons := {}
	for choice in [["tutorial", "ОБУЧЕНИЕ"], ["seed", "ИГРА С СИДОМ"], ["random", "СЛУЧАЙНАЯ ИГРА"], ["cyborg", "РЕЖИМ КИБОРГА"]]:
		var mode_button := menu_button(str(choice[1]))
		mode_buttons[str(choice[0])] = mode_button
		mode_column.add_child(mode_button)
	var mode_spacer := Control.new()
	mode_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mode_column.add_child(mode_spacer)
	var back_button := menu_button("НАЗАД")
	back_button.pressed.connect(close_overlay)
	mode_column.add_child(back_button)
	var detail_panel := PanelContainer.new()
	detail_panel.custom_minimum_size = Vector2(540, 0)
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_panel.add_theme_stylebox_override("panel", style(Color("#f2ead8"), 16, Color("#c9b996"), 1))
	columns.add_child(detail_panel)
	var detail_margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		detail_margin.add_theme_constant_override("margin_" + side, 18)
	detail_panel.add_child(detail_margin)
	var detail_column := VBoxContainer.new()
	detail_column.add_theme_constant_override("separation", 14)
	detail_margin.add_child(detail_column)
	detail_column.add_child(label("ВЫБРАННЫЙ РЕЖИМ", 15, Color("#8b6c4b")))
	var detail_title := label("", 28, INK)
	detail_column.add_child(detail_title)
	detail_column.add_child(HSeparator.new())
	var detail_body := label("", 19, Color("#4c4941"))
	detail_body.custom_minimum_size = Vector2(0, 112)
	detail_column.add_child(detail_body)
	var detail_note := label("", 16, Color("#765f38"))
	detail_column.add_child(detail_note)
	var seed_caption := label("СИД КАМПАНИИ", 15, Color("#8b6c4b"))
	detail_column.add_child(seed_caption)
	var seed_input := LineEdit.new()
	seed_input.placeholder_text = "Число или слово, например 1991"
	seed_input.text = "1991"
	seed_input.custom_minimum_size = Vector2(0, 58)
	seed_input.add_theme_font_size_override("font_size", 20)
	seed_input.add_theme_color_override("font_color", CREAM)
	seed_input.add_theme_color_override("font_placeholder_color", MUTED)
	seed_input.add_theme_stylebox_override("normal", style(Color("#252a30"), 14, Color("#515861"), 1))
	detail_column.add_child(seed_input)
	var detail_spacer := Control.new()
	detail_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_column.add_child(detail_spacer)
	var start_button := menu_button("НАЧАТЬ ОБУЧЕНИЕ")
	start_button.custom_minimum_size = Vector2(150, 68)
	start_button.add_theme_color_override("font_color", INK)
	start_button.add_theme_color_override("font_hover_color", INK)
	start_button.add_theme_color_override("font_pressed_color", INK)
	start_button.add_theme_stylebox_override("normal", style(GOLD, 14, Color("#8b744b"), 1))
	start_button.add_theme_stylebox_override("hover", style(CREAM, 14, GOLD, 2))
	start_button.add_theme_stylebox_override("pressed", style(Color("#ad915b"), 14, GOLD, 2))
	start_button.pressed.connect(start_selected_new_game.bind(start_button, seed_input))
	detail_column.add_child(start_button)
	seed_input.text_changed.connect(func(value: String):
		if str(start_button.get_meta("selected_mode", "")) == "seed":
			start_button.disabled = value.strip_edges().is_empty()
	)
	for mode_key in mode_buttons.keys():
		(mode_buttons[mode_key] as Button).pressed.connect(update_new_game_selection.bind(str(mode_key), mode_buttons, detail_title, detail_body, detail_note, seed_caption, seed_input, start_button))
	update_new_game_selection("tutorial", mode_buttons, detail_title, detail_body, detail_note, seed_caption, seed_input, start_button)
	show_overlay(content, PAPER, true, 930)


func update_new_game_selection(mode: String, mode_buttons: Dictionary, title_label: Label, body_label: Label, note_label: Label, seed_caption: Label, seed_input: LineEdit, start_button: Button) -> void:
	start_button.set_meta("selected_mode", mode)
	seed_caption.visible = mode == "seed"
	seed_input.visible = mode == "seed"
	start_button.disabled = mode == "seed" and seed_input.text.strip_edges().is_empty()
	match mode:
		"tutorial":
			title_label.text = "Обучение"
			body_label.text = "Игра знакомит с управлением постепенно. В первые недели открываются показатели, группы и разделы правительства."
			note_label.text = "Сохранение доступно · Сид: 1991 · МИД: Лея Нарин"
			start_button.text = "НАЧАТЬ ОБУЧЕНИЕ"
		"seed":
			title_label.text = "Игра с сидом"
			body_label.text = "Один и тот же сид повторяет стартовые условия и подбор случайных событий. Его можно передать другому игроку."
			note_label.text = "Сохранение доступно · Сид всегда виден в игре"
			start_button.text = "НАЧАТЬ С СИДОМ"
		"random":
			title_label.text = "Случайная игра"
			body_label.text = "Новый сид, другой стартовый кабинет и новый набор событий. Сид будет показан в игре."
			note_label.text = "Ручное и недельное сохранение доступны"
			start_button.text = "НАЧАТЬ ИГРУ"
		"cyborg":
			title_label.text = "Режим киборга"
			body_label.text = "Прогресс автоматически сохраняется после решений и в конце недели. После выхода вернитесь через «Продолжить». Откатить сделанный выбор нельзя."
			note_label.text = "Новая кампания заменит прежнее сохранение"
			start_button.text = "НАЧАТЬ РЕЖИМ КИБОРГА"
	for mode_key in mode_buttons.keys():
		var button := mode_buttons[mode_key] as Button
		var selected := str(mode_key) == mode
		button.add_theme_color_override("font_color", INK if selected else CREAM)
		button.add_theme_color_override("font_hover_color", INK if selected else CREAM)
		button.add_theme_color_override("font_pressed_color", INK if selected else CREAM)
		button.add_theme_stylebox_override("normal", style(GOLD if selected else Color("#283139"), 14, Color("#8b744b") if selected else Color("#4c5c66"), 1))
		button.add_theme_stylebox_override("hover", style(CREAM if selected else Color("#34414a"), 14, GOLD, 1))
		button.add_theme_stylebox_override("pressed", style(Color("#ad915b") if selected else Color("#1d2429"), 14, GOLD, 2))


func start_selected_new_game(start_button: Button, seed_input: LineEdit) -> void:
	match str(start_button.get_meta("selected_mode", "tutorial")):
		"tutorial":
			start_new_game("Обучение", 1991)
		"seed":
			if not seed_input.text.strip_edges().is_empty():
				start_new_game("Сид: " + seed_input.text.strip_edges(), campaign_seed_from_text(seed_input.text))
		"random":
			start_new_game("Без сида", fresh_campaign_seed())
		"cyborg":
			start_new_game("Режим киборга", fresh_campaign_seed())


func start_new_game(mode: String, seed_value: int) -> void:
	close_overlay(false)
	start_game(mode, seed_value, true)


func show_prologue() -> void:
	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(760, 0)
	content.add_theme_constant_override("separation", 14)
	content.add_child(label("ПРОЛОГ   /   ПЕРЕД ПЕРВЫМ ДОКЛАДОМ", 16, Color("#8b6c4b")))
	content.add_child(HSeparator.new())
	content.add_child(label("ПОСЛЕ ПОХОРОН", 39, INK))
	var scene := PanelContainer.new()
	scene.add_theme_stylebox_override("panel", style(Color("#252a30"), 16, GOLD, 1))
	content.add_child(scene)
	var scene_margin := MarginContainer.new()
	scene_margin.add_theme_constant_override("margin_left", 24)
	scene_margin.add_theme_constant_override("margin_right", 24)
	scene_margin.add_theme_constant_override("margin_top", 22)
	scene_margin.add_theme_constant_override("margin_bottom", 22)
	scene.add_child(scene_margin)
	var memory_row := HBoxContainer.new()
	memory_row.add_theme_constant_override("separation", 18)
	scene_margin.add_child(memory_row)
	var father_portrait := PortraitArt.new()
	father_portrait.custom_minimum_size = Vector2(88, 88)
	father_portrait.setup("official", GOLD, character_portrait("father"))
	memory_row.add_child(father_portrait)
	var memory_text := label("Траурные венки у дворца промокли под дождём. В кабинете остались незаконченная речь отца и папка с вашим назначением.", 22, CREAM)
	memory_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	memory_row.add_child(memory_text)
	var president_portrait := PortraitArt.new()
	president_portrait.custom_minimum_size = Vector2(88, 88)
	president_portrait.setup("official", GOLD, character_portrait("president"))
	memory_row.add_child(president_portrait)
	content.add_child(label("Ваш отец — первый президент независимой республики — погиб при покушении. Страна ещё не знает, кто стоит за его смертью.", 20, INK))
	content.add_child(label(PROLOGUE_MANDATE_TEXT, 20, INK))
	content.add_child(HSeparator.new())
	content.add_child(label("Министры ждут вашей подписи. Первый доклад уже на столе.", 17, Color("#6d6455")))
	var begin_button := menu_button("ОТКРЫТЬ ПЕРВЫЙ ДОКЛАД")
	begin_button.add_theme_color_override("font_color", INK)
	begin_button.add_theme_color_override("font_hover_color", INK)
	begin_button.add_theme_stylebox_override("normal", style(GOLD, 14, Color("#8b6c4b"), 1))
	begin_button.add_theme_stylebox_override("hover", style(CREAM, 14, GOLD, 2))
	begin_button.pressed.connect(finish_prologue)
	content.add_child(begin_button)
	show_overlay(content, PAPER, false, 860)


func finish_prologue() -> void:
	close_overlay(false)
	display_current_event()


func quit_game() -> void:
	get_tree().quit()


func fullscreen_status_text() -> String:
	return "Полноэкранный режим включён." if fullscreen_enabled else "Игра запущена в оконном режиме."


func fullscreen_toggle_button_text() -> String:
	return "ПЕРЕЙТИ В ОКОННЫЙ РЕЖИМ" if fullscreen_enabled else "ОТКРЫТЬ НА ВЕСЬ ЭКРАН"


func audio_status_text() -> String:
	return "Звуки интерфейса и событий включены." if audio_enabled else "Звуки отключены."


func audio_toggle_button_text() -> String:
	return "ВЫКЛЮЧИТЬ ЗВУКИ" if audio_enabled else "ВКЛЮЧИТЬ ЗВУКИ"


func music_status_text() -> String:
	return "Фоновая музыка включена." if music_enabled else "Фоновая музыка отключена."


func music_toggle_button_text() -> String:
	return "ВЫКЛЮЧИТЬ МУЗЫКУ" if music_enabled else "ВКЛЮЧИТЬ МУЗЫКУ"


func event_choice_hints_status_text() -> String:
	return "Подсказки под решениями показываются." if event_choice_hints_enabled else "Последствия решений заранее скрыты."


func event_choice_hints_toggle_button_text() -> String:
	return "СКРЫТЬ ПОДСКАЗКИ РЕШЕНИЙ" if event_choice_hints_enabled else "ПОКАЗЫВАТЬ ПОДСКАЗКИ РЕШЕНИЙ"


func show_credits() -> void:
	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(840, 0)
	content.add_theme_constant_override("separation", 14)
	content.add_child(label("АВТОРЫ", 30, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var author_panel := PanelContainer.new()
	author_panel.add_theme_stylebox_override("panel", style(Color("#242c32"), 18, Color("#8f7d5c"), 1))
	content.add_child(author_panel)
	var author_margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		author_margin.add_theme_constant_override("margin_" + side, 12)
	author_panel.add_child(author_margin)
	var author_text := VBoxContainer.new()
	author_text.add_theme_constant_override("separation", 2)
	author_margin.add_child(author_text)
	author_text.add_child(label("АВТОР ПРОЕКТА", 15, GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	author_text.add_child(label("dimazan10", 52, CREAM, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label("АВТОРЫ МАТЕРИАЛОВ ИЗ ОТКРЫТЫХ ИСТОЧНИКОВ", 18, Color("#765f38"), HORIZONTAL_ALIGNMENT_CENTER))
	var sources := GridContainer.new()
	sources.columns = 2
	sources.add_theme_constant_override("h_separation", 12)
	sources.add_theme_constant_override("v_separation", 8)
	content.add_child(sources)
	var contributors: Array[Dictionary] = [
		{"name": "Kenney", "detail": "Звуки интерфейса · CC0 1.0\nhttps://kenney.nl/assets/interface-sounds"},
		{"name": "kermite607", "detail": "Звук печати решения · CC0 1.0\nhttps://freesound.org/people/kermite607/sounds/362624/"},
		{"name": "Luckius", "detail": "Звуки листания бумаги · CC0 1.0\nhttps://opengameart.org/content/various-paper-sound-effects"},
		{"name": "ZvukiPro.com", "detail": "Щелчки пишущей машинки · по условиям сайта\nhttps://zvukipro.com/predmet/190-zvuki-pishuschey-mashinki-pechatnoy.html\nhttps://zvukipro.com/uslovija-ispolzovanija.html"},
		{"name": "ramsamba", "detail": "Звонок пишущей машинки · CC0 1.0\nhttps://freesound.org/people/ramsamba/sounds/318687/"},
		{"name": "Alexander / Orange Free Sounds · CC BY 4.0", "detail": "Звук счётной машинки · CC BY 4.0; запись укорочена, переведена в моно и приглушена на входе и выходе\nhttps://orangefreesounds.com/money-counting-machine/\nhttps://creativecommons.org/licenses/by/4.0/"},
		{"name": "NenadSimic", "detail": "Звук взрыва · CC0 1.0\nhttps://opengameart.org/content/muffled-distant-explosion"},
		{"name": "KVV_Audio", "detail": "Сирена воздушной тревоги, Сумы · CC0 1.0; начало записи с плавным затуханием\nhttps://freesound.org/people/KVV_Audio/sounds/727588/"},
		{"name": "pauliuw", "detail": "Вариант звука взрыва · CC0 1.0\nhttps://opengameart.org/content/explosion-somewhere-far"},
		{"name": "Kostrava", "detail": "Вариант звука взрыва · CC0 1.0\nhttps://freesound.org/people/Kostrava/sounds/320788/"},
		{"name": "StarNinjas", "detail": "Варианты звучания толпы · CC0 1.0\nhttps://opengameart.org/content/crowd-shoutingspeaking-ambience"},
		{"name": "InspectorJ", "detail": "Вариант звука протеста · CC0 1.0\nhttps://freesound.org/people/InspectorJ/sounds/485621/"},
		{"name": "CHallSmith", "detail": "Вариант звука протеста · CC0 1.0\nhttps://freesound.org/people/CHallSmith/packs/46342/"},
		{"name": "bevibeldesign", "detail": "Звучание разъярённой толпы · CC0 1.0\nhttps://freesound.org/people/bevibeldesign/sounds/316640/"},
		{"name": "NeoSpica", "detail": "Звук массового освистывания · CC0 1.0\nhttps://freesound.org/people/NeoSpica/sounds/504621/"}
	]
	for contributor in contributors:
		var entry := PanelContainer.new()
		entry.custom_minimum_size = Vector2(0, 34)
		entry.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var entry_style := style(Color("#f2ead8"), 8, Color("#c9b996"), 1)
		entry_style.content_margin_left = 12
		entry_style.content_margin_right = 12
		entry_style.content_margin_top = 6
		entry_style.content_margin_bottom = 6
		entry.add_theme_stylebox_override("panel", entry_style)
		sources.add_child(entry)
		var name_label := label(str(contributor["name"]), 15, INK)
		entry.add_child(name_label)
		add_hover_detail(entry, str(contributor["detail"]))
		add_hover_detail(name_label, str(contributor["detail"]))
	var close := menu_button("ВЕРНУТЬСЯ")
	close.pressed.connect(close_overlay)
	content.add_child(close)
	show_overlay(content, PAPER, true, 900)


func show_settings() -> void:
	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(880, 0)
	content.add_theme_constant_override("separation", 16)
	content.add_child(label("НАСТРОЙКИ", 30, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 16)
	content.add_child(columns)
	var left_column := VBoxContainer.new()
	left_column.custom_minimum_size = Vector2(430, 0)
	left_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_column.add_theme_constant_override("separation", 16)
	columns.add_child(left_column)
	var right_column := VBoxContainer.new()
	right_column.custom_minimum_size = Vector2(430, 0)
	right_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_column.add_theme_constant_override("separation", 16)
	columns.add_child(right_column)

	var screen_section := settings_section(left_column, "ЭКРАН")
	var status_label := label(fullscreen_status_text(), 16, Color("#4c4941"))
	screen_section.add_child(status_label)
	var fullscreen_button := menu_button(fullscreen_toggle_button_text())
	fullscreen_button.pressed.connect(toggle_fullscreen_from_settings.bind(fullscreen_button, status_label))
	screen_section.add_child(fullscreen_button)
	screen_section.add_child(label("F4 / F11 — переключить режим экрана", 14, Color("#6d6455")))

	var hints_section := settings_section(left_column, "ПОДСКАЗКИ РЕШЕНИЙ")
	var hints_status_label := label(event_choice_hints_status_text(), 16, Color("#4c4941"))
	hints_section.add_child(hints_status_label)
	var hints_button := menu_button(event_choice_hints_toggle_button_text())
	hints_button.pressed.connect(toggle_event_choice_hints_from_settings.bind(hints_button, hints_status_label))
	hints_section.add_child(hints_button)
	hints_section.add_child(label("Примерные последствия под вариантами ответа.", 14, Color("#6d6455")))

	var sound_section := settings_section(right_column, "ЗВУК")
	var audio_status_label := label(audio_status_text(), 16, Color("#4c4941"))
	sound_section.add_child(audio_status_label)
	var audio_button := menu_button(audio_toggle_button_text())
	audio_button.pressed.connect(toggle_audio_from_settings.bind(audio_button, audio_status_label))
	sound_section.add_child(audio_button)
	var audio_volume_label := label(effect_volume_caption(), 16, Color("#4c4941"))
	sound_section.add_child(audio_volume_label)
	var audio_volume_slider := HSlider.new()
	audio_volume_slider.custom_minimum_size = Vector2(0, 28)
	audio_volume_slider.min_value = 0.0
	audio_volume_slider.max_value = 100.0
	audio_volume_slider.step = 1.0
	audio_volume_slider.value = audio_volume_percent
	audio_volume_slider.value_changed.connect(change_audio_volume.bind(audio_volume_label))
	audio_volume_slider.drag_ended.connect(preview_audio_volume)
	sound_section.add_child(audio_volume_slider)
	sound_section.add_child(HSeparator.new())
	var music_status_label := label(music_status_text(), 16, Color("#4c4941"))
	sound_section.add_child(music_status_label)
	var music_button := menu_button(music_toggle_button_text())
	music_button.pressed.connect(toggle_music_from_settings.bind(music_button, music_status_label))
	sound_section.add_child(music_button)
	var music_volume_label := label(music_volume_caption(), 16, Color("#4c4941"))
	sound_section.add_child(music_volume_label)
	var music_volume_slider := HSlider.new()
	music_volume_slider.custom_minimum_size = Vector2(0, 28)
	music_volume_slider.min_value = 0.0
	music_volume_slider.max_value = 100.0
	music_volume_slider.step = 1.0
	music_volume_slider.value = music_volume_percent
	music_volume_slider.value_changed.connect(change_music_volume.bind(music_volume_label))
	sound_section.add_child(music_volume_slider)
	var language_section := settings_section(right_column, "ЯЗЫК")
	language_section.add_child(label("Выберите язык игры.", 16, Color("#4c4941")))
	var language_buttons := HBoxContainer.new()
	language_buttons.add_theme_constant_override("separation", 10)
	language_section.add_child(language_buttons)
	for language_choice in [["en", "ENGLISH"], ["ru", "РУССКИЙ"]]:
		var language_button := menu_button(str(language_choice[1]))
		language_button.disabled = language_code == str(language_choice[0])
		language_button.pressed.connect(change_language_from_settings.bind(str(language_choice[0])))
		language_buttons.add_child(language_button)
	var close := menu_button("ГОТОВО")
	close.pressed.connect(close_overlay)
	content.add_child(close)
	show_overlay(content, PAPER, true, 940)


func settings_section(parent: Container, title: String) -> VBoxContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", style(Color("#f2ead8"), 16, Color("#c9b996"), 1))
	parent.add_child(card)
	var padding := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		padding.add_theme_constant_override("margin_" + side, 16)
	card.add_child(padding)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	padding.add_child(column)
	column.add_child(label(title, 17, Color("#765f38")))
	return column


func toggle_fullscreen_from_settings(toggle_button: Button, status_label: Label) -> void:
	toggle_fullscreen()
	toggle_button.text = fullscreen_toggle_button_text()
	status_label.text = fullscreen_status_text()
	localize_settings_toggle(toggle_button, status_label)


func toggle_audio_from_settings(toggle_button: Button, status_label: Label) -> void:
	audio_enabled = not audio_enabled
	save_display_settings()
	toggle_button.text = audio_toggle_button_text()
	status_label.text = audio_status_text()
	localize_settings_toggle(toggle_button, status_label)
	if audio_enabled:
		play_game_sound("decision")


func toggle_music_from_settings(toggle_button: Button, status_label: Label) -> void:
	music_enabled = not music_enabled
	save_display_settings()
	toggle_button.text = music_toggle_button_text()
	status_label.text = music_status_text()
	localize_settings_toggle(toggle_button, status_label)
	update_background_music()


func localize_settings_toggle(toggle_button: Button, status_label: Label) -> void:
	localize_property(toggle_button, "text", "localized_text")
	localize_property(status_label, "text", "localized_text")


func change_audio_volume(value: float, value_label: Label) -> void:
	audio_volume_percent = clampf(value, 0.0, 100.0)
	value_label.text = effect_volume_caption()
	apply_audio_volume()
	save_display_settings()


func preview_audio_volume(changed: bool) -> void:
	if changed and audio_enabled:
		play_game_sound("decision")


func change_music_volume(value: float, value_label: Label) -> void:
	music_volume_percent = clampf(value, 0.0, 100.0)
	value_label.text = music_volume_caption()
	apply_music_volume()
	save_display_settings()


func effect_volume_caption() -> String:
	return ("Effects volume: %d%%" if language_code == "en" else "Громкость эффектов: %d%%") % roundi(audio_volume_percent)


func music_volume_caption() -> String:
	return ("Music volume: %d%%" if language_code == "en" else "Громкость музыки: %d%%") % roundi(music_volume_percent)


func toggle_event_choice_hints_from_settings(toggle_button: Button, status_label: Label) -> void:
	event_choice_hints_enabled = not event_choice_hints_enabled
	save_display_settings()
	toggle_button.text = event_choice_hints_toggle_button_text()
	status_label.text = event_choice_hints_status_text()
	localize_settings_toggle(toggle_button, status_label)
	update_event_choice_hint_visibility()


func change_language_from_settings(code: String) -> void:
	if code == language_code:
		return
	language_code = "ru" if code == "ru" else "en"
	game_localization.set_language(language_code)
	save_display_settings()
	if not state.is_empty():
		update_interface()
	localize_visible_tree()
	show_settings()
	localize_visible_tree()


func setup_audio() -> void:
	audio_streams = {
		"hover": load_audio_wav("res://audio/cc0/hover_01.wav", make_ui_tone(620.0, 780.0, 0.040, 0.075, 0.10)),
		"click": load_audio_wav("res://audio/cc0/click_01.wav", make_ui_tone(255.0, 145.0, 0.070, 0.17, 0.18)),
		"page": load_audio_wav("res://audio/cc0/page_01.wav", make_ui_tone(310.0, 460.0, 0.130, 0.11, 0.28)),
		"report": load_audio_wav("res://audio/cc0/report_01.wav", make_ui_tone(280.0, 430.0, 0.145, 0.13, 0.12)),
		"decision": load_audio_wav("res://audio/cc0/decision_01.wav", make_ui_tone(410.0, 680.0, 0.190, 0.16, 0.20)),
		"warning": load_audio_wav("res://audio/cc0/warning_01.wav", make_ui_tone(205.0, 105.0, 0.280, 0.17, 0.24)),
		"week": load_audio_wav("res://audio/cc0/week_report.wav", make_ui_tone(300.0, 590.0, 0.340, 0.15, 0.18)),
		"ending": load_audio_wav("res://audio/cc0/ending_01.wav", make_ui_tone(360.0, 115.0, 0.520, 0.17, 0.22)),
		"war": load_audio_wav("res://audio/cc0/war_01.wav", make_ui_tone(105.0, 48.0, 1.200, 0.22, 0.45)),
		"war_siren": load_audio_wav("res://audio/cc0/war_siren_sumy.wav", make_ui_tone(535.0, 390.0, 5.100, 0.10, 0.42)),
		"protest": load_audio_wav("res://audio/cc0/protest_01.wav", make_ui_tone(190.0, 125.0, 0.850, 0.14, 0.38)),
		"save": load_audio_wav("res://audio/licensed/save.wav", make_ui_tone(520.0, 320.0, 0.220, 0.14, 0.18)),
		"money_print": load_audio_wav("res://audio/attributed/money_counter.wav", make_ui_tone(135.0, 105.0, 0.900, 0.16, 0.42))
	}
	var volume_by_sound := {"hover": -8.0, "click": -5.0, "page": -4.0, "report": -4.0, "decision": -3.0, "warning": -2.0, "week": -3.0, "ending": -2.0, "war": 1.0, "war_siren": -3.0, "protest": -5.0, "save": -3.0, "money_print": -4.0}
	for sound_name in audio_streams.keys():
		var player := AudioStreamPlayer.new()
		player.name = "Audio_%s" % str(sound_name)
		player.stream = audio_streams[sound_name]
		# Effects and music intentionally share the exact same output path. This
		# prevents a device- or bus-specific gain difference between the hover
		# reference sound and the background track.
		player.bus = &"Master"
		var base_volume_db := float(volume_by_sound.get(sound_name, -4.0))
		player.volume_db = base_volume_db
		player.set_meta("base_volume_db", base_volume_db)
		player.set_meta("persistent_audio", true)
		add_child(player)
		audio_players[sound_name] = player
	apply_audio_volume()
	music_player = get_node_or_null("BackgroundMusic") as AudioStreamPlayer
	if not is_instance_valid(music_player):
		music_player = AudioStreamPlayer.new()
		music_player.name = "BackgroundMusic"
		add_child(music_player)
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.bus = &"Master"
	music_player.volume_db = MUSIC_BASE_VOLUME_DB
	var music_stream := load_audio_wav("res://audio/variants/music_03_documents.wav", make_ui_tone(73.0, 73.0, 4.0, 0.035, 0.35))
	music_stream.loop_begin = 0
	# Imported WAV resources default loop_end to zero. Enabling a forward loop
	# without filling it makes Godot loop a zero-length region forever: the
	# player reports `playing`, but no music reaches the speakers.
	music_stream.loop_end = maxi(1, roundi(music_stream.get_length() * float(music_stream.mix_rate)))
	music_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	music_player.stream = music_stream
	music_player.set_meta("persistent_audio", true)
	apply_music_volume()
	# Settings are loaded before setup_audio(). Start only on the next frame so
	# the saved gain is applied before the first audible music sample.
	call_deferred("update_background_music")
	get_tree().node_added.connect(bind_audio_to_new_node)


func load_audio_wav(path: String, fallback: AudioStreamWAV) -> AudioStreamWAV:
	var loaded := load(path)
	return loaded as AudioStreamWAV if loaded is AudioStreamWAV else fallback


func update_background_music() -> void:
	if not is_instance_valid(music_player):
		return
	if music_enabled:
		apply_music_volume()
		if not music_player.playing:
			music_player.play()
	else:
		music_player.stop()


func volume_offset_db(percent: float) -> float:
	if percent <= 0.0:
		return -80.0
	return linear_to_db(clampf(percent, 0.0, 100.0) / 100.0)


func apply_audio_volume() -> void:
	var offset := volume_offset_db(audio_volume_percent)
	for player_value in audio_players.values():
		var player := player_value as AudioStreamPlayer
		if is_instance_valid(player):
			player.volume_db = float(player.get_meta("base_volume_db", -4.0)) + offset


func apply_music_volume() -> void:
	if is_instance_valid(music_player):
		music_player.volume_db = MUSIC_BASE_VOLUME_DB + volume_offset_db(music_volume_percent)


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
		play_game_sound(str(button.get_meta("ui_click_sound", "click")))


func play_game_sound(sound_name: String) -> void:
	if not audio_enabled or DisplayServer.get_name() == "headless":
		return
	var player := audio_players.get(sound_name) as AudioStreamPlayer
	if not is_instance_valid(player):
		return
	# Always apply the current setting before playback. This also prevents a
	# one-frame full-volume click after loading or changing the preferences.
	player.volume_db = float(player.get_meta("base_volume_db", -4.0)) + volume_offset_db(audio_volume_percent)
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


func campaign_seed_caption(seed_value := int(state.get("campaign_seed", 0))) -> String:
	return "СИД: %d" % int(seed_value)


func campaign_header_caption() -> String:
	var mode_caption := "ПОВТОР"
	if game_mode == "Обучение":
		mode_caption = "ОБУЧЕНИЕ"
	elif game_mode == "Режим киборга":
		mode_caption = "КИБОРГ"
	elif is_iron_mode():
		mode_caption = "ЖЕЛЕЗНЫЙ"
	elif is_no_save_mode():
		mode_caption = "БЕЗ СОХРАНЕНИЙ"
	elif game_mode == "Без сида":
		mode_caption = "СЛУЧАЙНЫЙ"
	return "%s • %s" % [game_localization.text(mode_caption), game_localization.text(campaign_seed_caption())]


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


func achievement_definition(achievement_id: String) -> Dictionary:
	for achievement in ENDING_ACHIEVEMENTS:
		if str(achievement.get("id", "")) == achievement_id:
			return (achievement as Dictionary).duplicate(true)
	return {}


func ending_achievement_id(president_title: String, survived_weeks: int) -> String:
	if survived_weeks < DEMO_WEEKS:
		return ""
	if president_title in ["ИЗБРАННЫЙ ПРЕЗИДЕНТ", "УПРАВЛЯЕМАЯ ПОБЕДА", "ПОБЕДА ПО ПРОТОКОЛУ", "ОТЛОЖЕННЫЙ МАНДАТ"]:
		return "power_retained"
	if president_title in ["МИРНАЯ ПЕРЕДАЧА ВЛАСТИ", "АППАРАТ НЕ СПАС"]:
		return "power_transferred"
	return ""


func peaceful_campaign_achievement_eligible(survived_weeks: int, forced_title: String) -> bool:
	return forced_title == "" and survived_weeks >= DEMO_WEEKS and not bool(state.get("war_ever_started", false)) and not bool(state.get("at_war", false))


func read_achievement_record() -> Dictionary:
	if not persistence_allowed() or not FileAccess.file_exists(ACHIEVEMENTS_PATH):
		return {}
	var file := FileAccess.open(ACHIEVEMENTS_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return {}
	return (parsed as Dictionary).duplicate(true)


func read_unlocked_achievements() -> Dictionary:
	var stored: Variant = read_achievement_record().get("unlocked", {})
	var unlocked := (stored as Dictionary).duplicate(true) if stored is Dictionary else {}
	# Old saves used individual ending titles as keys. Keep their earned dates where
	# the old result unambiguously describes retaining or transferring power.
	for achievement in ENDING_ACHIEVEMENTS:
		var achievement_id := str(achievement.get("id", ""))
		if unlocked.has(achievement_id):
			continue
		var legacy_titles: Array = ["ИЗБРАННЫЙ ПРЕЗИДЕНТ", "УПРАВЛЯЕМАЯ ПОБЕДА", "ПОБЕДА ПО ПРОТОКОЛУ", "ОТЛОЖЕННЫЙ МАНДАТ"] if achievement_id == "power_retained" else ["МИРНАЯ ПЕРЕДАЧА ВЛАСТИ", "АППАРАТ НЕ СПАС"]
		for old_title in legacy_titles:
			if unlocked.has(old_title):
				unlocked[achievement_id] = unlocked[old_title]
				break
	return unlocked


func read_unseen_achievements() -> Array:
	var stored: Variant = read_achievement_record().get("unseen", [])
	var unseen: Array = (stored as Array).duplicate() if stored is Array else []
	var valid: Array = []
	for achievement_id in unseen:
		if not achievement_definition(str(achievement_id)).is_empty():
			valid.append(achievement_id)
			continue
		for achievement in SPECIAL_ACHIEVEMENTS:
			if str(achievement.get("id", "")) == str(achievement_id):
				valid.append(achievement_id)
				break
	return valid


func save_unlocked_achievements(unlocked: Dictionary, unseen: Array) -> bool:
	if not persistence_allowed():
		return false
	var file := FileAccess.open(ACHIEVEMENTS_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({"version": 2, "unlocked": unlocked, "unseen": unseen}, "\t"))
	file.flush()
	return true


func unlock_ending_achievement(achievement_id: String) -> bool:
	if achievement_definition(achievement_id).is_empty() or not persistence_allowed():
		return false
	var unlocked := read_unlocked_achievements()
	if unlocked.has(achievement_id):
		return false
	unlocked[achievement_id] = Time.get_datetime_string_from_system(false, true)
	var unseen := read_unseen_achievements()
	unseen.append(achievement_id)
	return save_unlocked_achievements(unlocked, unseen)


func unlock_special_achievement(achievement_id: String) -> bool:
	if not persistence_allowed():
		return false
	var exists := false
	for achievement in SPECIAL_ACHIEVEMENTS:
		if str(achievement.get("id", "")) == achievement_id:
			exists = true
			break
	if not exists:
		return false
	var unlocked := read_unlocked_achievements()
	if unlocked.has(achievement_id):
		return false
	unlocked[achievement_id] = Time.get_datetime_string_from_system(false, true)
	var unseen := read_unseen_achievements()
	unseen.append(achievement_id)
	return save_unlocked_achievements(unlocked, unseen)


func unlocked_achievement_count() -> int:
	var unlocked := read_unlocked_achievements()
	var count := 0
	for achievement in ENDING_ACHIEVEMENTS:
		if unlocked.has(str(achievement.get("id", ""))):
			count += 1
	for achievement in SPECIAL_ACHIEVEMENTS:
		if unlocked.has(str(achievement.get("id", ""))):
			count += 1
	return count


func show_achievements() -> void:
	var unlocked := read_unlocked_achievements()
	var unseen := read_unseen_achievements()
	if unseen.is_empty() or save_unlocked_achievements(unlocked, []):
		style_achievements_menu_button(false)
	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(850, 0)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 16)
	content.add_child(label("ДОСТИЖЕНИЯ", 30, INK, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label("Открыто %d из %d. Два исхода власти и особые достижения." % [unlocked_achievement_count(), ENDING_ACHIEVEMENTS.size() + SPECIAL_ACHIEVEMENTS.size()], 16, Color("#5f594d"), HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label("ИТОГ ПРАВЛЕНИЯ", 19, Color("#765f38")))
	var outcomes := HBoxContainer.new()
	outcomes.add_theme_constant_override("separation", 12)
	content.add_child(outcomes)
	for achievement in ENDING_ACHIEVEMENTS:
		var achievement_id := str(achievement.get("id", ""))
		outcomes.add_child(achievement_card(achievement, unlocked.has(achievement_id), str(unlocked.get(achievement_id, ""))))
	content.add_child(label("ОСОБЫЕ ДОСТИЖЕНИЯ", 19, Color("#765f38")))
	var special_grid := GridContainer.new()
	special_grid.columns = 2
	special_grid.add_theme_constant_override("h_separation", 12)
	special_grid.add_theme_constant_override("v_separation", 10)
	content.add_child(special_grid)
	for achievement in SPECIAL_ACHIEVEMENTS:
		var achievement_id := str(achievement.get("id", ""))
		special_grid.add_child(achievement_card(achievement, unlocked.has(achievement_id), str(unlocked.get(achievement_id, ""))))
	var close := menu_button("ВЕРНУТЬСЯ")
	close.pressed.connect(close_overlay)
	content.add_child(close)
	show_overlay(content, PAPER, true, 910)


func achievement_card(achievement: Dictionary, is_unlocked: bool, earned_at: String) -> PanelContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", style(Color("#ded4bf") if is_unlocked else Color("#d2c9b7"), 12, GOLD if is_unlocked else Color("#938a7b"), 2 if is_unlocked else 1))
	var card_margin := MarginContainer.new()
	for side in ["left", "right"]:
		card_margin.add_theme_constant_override("margin_" + side, 14)
	for side in ["top", "bottom"]:
		card_margin.add_theme_constant_override("margin_" + side, 11)
	card.add_child(card_margin)
	var card_box := VBoxContainer.new()
	card_box.add_theme_constant_override("separation", 4)
	card_margin.add_child(card_box)
	card_box.add_child(label(("ОТКРЫТО • " if is_unlocked else "ЗАКРЫТО • ") + str(achievement.get("title", "Достижение")), 17, GREEN if is_unlocked else MUTED))
	card_box.add_child(label(str(achievement.get("description", "")), 14, INK if is_unlocked else Color("#625e56")))
	if is_unlocked:
		card_box.add_child(label("Получено %s" % earned_at, 13, Color("#6f6557")))
	return card


func load_display_settings() -> void:
	fullscreen_enabled = false
	audio_enabled = true
	music_enabled = true
	audio_volume_percent = 100.0
	music_volume_percent = 100.0
	event_choice_hints_enabled = false
	language_code = "en"
	tutorial_enabled = true
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
		music_enabled = bool((parsed as Dictionary).get("music_enabled", true))
		audio_volume_percent = clampf(float((parsed as Dictionary).get("audio_volume_percent", 100.0)), 0.0, 100.0)
		music_volume_percent = clampf(float((parsed as Dictionary).get("music_volume_percent", 100.0)), 0.0, 100.0)
		# Older settings stored the former on-by-default value. Only an explicit
		# choice made after this change keeps the hints enabled.
		event_choice_hints_enabled = bool((parsed as Dictionary).get("event_choice_hints_opted_in", false))
		language_code = "ru" if str((parsed as Dictionary).get("language", "en")) == "ru" else "en"
		tutorial_enabled = bool((parsed as Dictionary).get("tutorial_enabled", true))
	apply_fullscreen_mode()


func save_display_settings() -> void:
	if not persistence_allowed():
		return
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify({"fullscreen": fullscreen_enabled, "audio_enabled": audio_enabled, "music_enabled": music_enabled, "audio_volume_percent": audio_volume_percent, "music_volume_percent": music_volume_percent, "event_choice_hints_enabled": event_choice_hints_enabled, "event_choice_hints_opted_in": event_choice_hints_enabled, "language": language_code, "tutorial_enabled": tutorial_enabled}, "\t"))
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
	return game_mode == "Железный режим" or game_mode == "Режим киборга"


func is_no_save_mode() -> bool:
	return game_mode == "Без сохранений"


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
		"tutorial_enabled": tutorial_enabled,
		"tutorial_flow_version": 4,
		"tutorial_seen": tutorial_seen.duplicate(),
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
	if state.is_empty() or is_no_save_mode() or not persistence_allowed():
		return false
	var file := FileAccess.open(campaign_save_path(), FileAccess.WRITE)
	if file == null:
		if show_feedback and is_instance_valid(game_root):
			show_notice("Не удалось открыть файл сохранения.")
		return false
	file.store_string(JSON.stringify(campaign_snapshot(), "\t"))
	file.flush()
	if show_feedback and is_instance_valid(game_root):
		play_game_sound("save")
		show_notice("Кампания сохранена. Продолжить её можно из главного меню.", "", false)
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
	var converted := convert_legacy_population_effects(effects)
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
	if at_war_with("east") and east_intent > 0:
		east_intent = 0
	if at_war_with("west") and west_intent > 0:
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


func convert_legacy_population_effects(effects: Dictionary) -> Dictionary:
	var converted := effects.duplicate(true)
	var legacy_keys := ["pop_children", "pop_employed", "pop_unemployed", "pop_pensioners", "pop_migrants"]
	var has_legacy := false
	for key in legacy_keys:
		if converted.has(key):
			has_legacy = true
			break
	if not has_legacy:
		return converted
	var total_delta := int(converted.get("army_personnel", 0))
	for key in legacy_keys:
		total_delta += int(converted.get(key, 0))
	var workable_delta := int(converted.get("pop_employed", 0)) + int(converted.get("pop_unemployed", 0))
	for key in legacy_keys:
		converted.erase(key)
	if total_delta != 0:
		converted["population_total"] = int(converted.get("population_total", 0)) + total_delta
	if workable_delta != 0:
		converted["population_workable"] = int(converted.get("population_workable", 0)) + workable_delta
	return converted


func relation_shift_effect(side: String, direction: int) -> Dictionary:
	if side not in ["east", "west"] or direction == 0:
		return {}
	if direction > 0 and at_war_with(side):
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


func foreign_minister_alignment_effect(side: String) -> Dictionary:
	var result := relation_shift_effect(side, 1)
	if not result.is_empty():
		return result
	# Министр всё равно публично выбирает сторону, даже если отношения с ней уже
	# партнёрские: противоположный сосед воспринимает инициативу как потерю нейтралитета.
	var opposite := "west" if side == "east" else "east"
	if not at_war_with(side) and projected_pending_value(opposite + "_relation") > 0:
		return {opposite + "_relation": -1}
	return {}


func relation_improvement_summary(side: String, aligned_choice := false) -> String:
	var current := projected_pending_value(side + "_relation")
	var opposite := "west" if side == "east" else "east"
	if current >= 3:
		if aligned_choice and projected_pending_value(opposite + "_relation") > 0:
			return "Отношения с государством «%s» уже партнёрские, но публичный выбор стороны ухудшит отношения с государством «%s» на одну категорию." % [neighbor_title(side), neighbor_title(opposite)]
		return "Отношения с государством «%s» уже партнёрские и не изменятся." % neighbor_title(side)
	return "Отношения с государством «%s» улучшатся на одну категорию, а с государством «%s» ухудшатся на одну." % [neighbor_title(side), neighbor_title(opposite)]


func block_war_enemy_relation_improvement(effects: Dictionary) -> Dictionary:
	var protected_effects := effects.duplicate(true)
	if not bool(state.get("at_war", false)):
		return protected_effects
	for side in ["east", "west"]:
		var relation_key: String = str(side) + "_relation"
		if at_war_with(side) and int(protected_effects.get(relation_key, 0)) > 0:
			protected_effects.erase(relation_key)
	return protected_effects


func normalize_loaded_pending_relations() -> void:
	for index in range(pending_week_changes.size()):
		var change: Dictionary = pending_week_changes[index]
		change["effects"] = convert_legacy_foreign_effects(change.get("effects", {}))
		pending_week_changes[index] = change


func normalize_event_population_effects(event_data: Dictionary) -> Dictionary:
	var normalized := event_data.duplicate(true)
	for side in ["left", "right", "third"]:
		var option_data = normalized.get(side, {})
		if option_data is Dictionary and not (option_data as Dictionary).is_empty():
			var updated_option := (option_data as Dictionary).duplicate(true)
			updated_option["effects"] = convert_legacy_population_effects(updated_option.get("effects", {}))
			normalized[side] = updated_option
	return normalized


func normalize_event_array_population(items: Array[Dictionary]) -> void:
	for index in range(items.size()):
		items[index] = normalize_event_population_effects(items[index])


func normalize_loaded_state() -> void:
	if not state.has("population_total"):
		state.population_total = (
			int(state.get("pop_children", 820000))
			+ int(state.get("pop_employed", 2200000))
			+ int(state.get("pop_unemployed", 240000))
			+ int(state.get("pop_pensioners", 870000))
			+ int(state.get("pop_migrants", 70000))
			+ int(state.get("army_personnel", 50000))
		)
	if not state.has("population_workable"):
		state.population_workable = int(state.get("pop_employed", 2200000)) + int(state.get("pop_unemployed", 240000)) + int(state.get("pop_migrants", 70000))
	if not state.has("health_funding_balance"):
		# До этого обновления месячный итог зависел лишь от последней недели.
		# Для старого сохранения считаем прошедшие недели по текущему уровню.
		state.health_funding_balance = posmod(int(state.get("week", 1)) - 1, 4) * (clampi(int(state.get("budget_health", 1)), 0, 2) - 1)
	var integer_keys := [
		"week", "campaign_seed", "support", "stability", "army", "war_support", "corruption_tier", "influence",
		"creditor_obligations", "creditor_review_due_week", "creditor_priority_weeks", "clan_oligarchs", "clan_church",
		"clan_workers", "clan_regions", "population_total", "population_workable",
		"army_personnel", "army_equipment", "army_aircraft", "metal_to_equipment", "oil_to_army", "metal_price_weeks",
		"oil_price_weeks", "budget_social", "budget_health", "health_funding_balance", "budget_admin", "budget_defense", "budget_debt",
		"budget_infrastructure", "east_relation", "west_relation", "east_pressure", "west_pressure", "east_commitment", "west_commitment", "neutrality",
		"brother_trust", "authoritarian", "social_protest_due_week", "social_budget_lock_until_week", "regional_administration_penalty_until_week",
		"war_started_week", "war_weeks", "war_casualties", "war_pressure_next_week", "war_frontline_reductions", "war_frontline_pressure", "war_ceasefire_until_week",
		"war_medical_priority_until_week", "war_ammo_conservation_until_week", "foreign_action_week", "narin_crisis_delay_weeks", "emission_shock_weeks", "emission_shock_elapsed",
		"creditor_budget_lock_level", "creditor_budget_lock_until_week", "east_energy_discount_until_week",
		"west_market_access_until_week", "kres_fuel_supply_until_week", "double_standards_until_week", "active_unrest_level", "active_unrest_weeks", "financial_crisis_refusal_week"
	]
	for key in integer_keys:
		if state.has(key):
			state[key] = int(state[key])
	for key in ["money", "debt", "debt_weekly_interest_rate", "metal_price_factor", "oil_price_factor"]:
		if state.has(key):
			state[key] = float(state[key])
	var loaded_defaults := {
		"war_enemy": "", "war_second_enemy": "", "war_ever_started": bool(state.get("at_war", false)) or int(state.get("war_started_week", 0)) > 0 or int(state.get("war_weeks", 0)) > 0 or bool(state.get("war_armistice_signed", false)), "war_started_week": 0, "war_weeks": 0, "war_casualties": 0,
		"war_crisis_pending": bool(state.get("at_war", false)), "war_crisis_shown": false,
		"war_pressure_next_week": maxi(WAR_PRESSURE_INTERVAL, int(state.get("war_weeks", 0)) + WAR_PRESSURE_INTERVAL),
		"war_frontline_reductions": 0, "war_frontline_pressure": 0, "war_armistice_signed": false, "war_ceasefire_until_week": 0, "war_ceasefire_enemy": "", "war_medical_priority_until_week": 0, "war_ammo_conservation_until_week": 0,
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
		"campaign_arc": "", "campaign_arc_started": false, "campaign_arc_legacy": "",
		"active_unrest_level": 0, "active_unrest_weeks": 0, "active_unrest_cause": "",
		"active_unrest_kind": "", "active_unrest_labor": false, "active_unrest_reversible": false,
		"active_unrest_reversal": "",
		"civic_mediation_law": false, "regional_commissions_law": false, "collective_bargaining_law": false,
		"narin_crisis_channel_armed": false, "narin_crisis_channel_used": false, "narin_crisis_delay_weeks": 0,
		"varek_corridor_used": false, "kres_fuel_used": false, "kres_fuel_supply_until_week": 0,
		"foreign_minister_resignation_pending": false, "foreign_minister_resignation_shown": false,
		"resigning_foreign_minister": "",
		"election_nomination_shown": int(state.get("week", 1)) >= 10,
		"election_rules_shown": int(state.get("week", 1)) >= 19,
		"election_campaign": "", "election_rules": "undecided", "election_method": "",
		"final_alignment": "", "final_course_reserved": false,
		"financial_crisis_refusal_week": int(state.get("week", 1)) if bool(state.get("financial_crisis_ignored", false)) else 0,
		"financial_crisis_survival_pending": false,
		"debt_weekly_interest_rate": DEBT_INITIAL_WEEKLY_RATE
	}
	for key in loaded_defaults:
		if not state.has(key):
			state[key] = loaded_defaults[key]
	state.debt_weekly_interest_rate = maxf(DEBT_MIN_WEEKLY_RATE, float(state.get("debt_weekly_interest_rate", DEBT_INITIAL_WEEKLY_RATE)))
	state.population_total = maxi(int(state.get("army_personnel", 0)), int(state.get("population_total", 4250000)))
	state.population_workable = clampi(int(state.get("population_workable", 2510000)), 0, maxi(0, int(state.population_total) - int(state.get("army_personnel", 0))))
	for legacy_population_key in ["pop_children", "pop_employed", "pop_unemployed", "pop_pensioners", "pop_migrants"]:
		state.erase(legacy_population_key)
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
	tutorial_enabled = bool(data.get("tutorial_enabled", tutorial_enabled))
	state = (data.get("state", {}) as Dictionary).duplicate(true)
	normalize_loaded_state()
	ensure_campaign_history()
	selected_ministers = (data.get("selected_ministers", {}) as Dictionary).duplicate(true)
	schedule_foreign_minister_resignation_if_needed()
	budget_draft = (data.get("budget_draft", {}) as Dictionary).duplicate(true)
	active_law = str(data.get("active_law", ""))
	law_progress = int(data.get("law_progress", 0))
	law_target = int(data.get("law_target", 0))
	law_weekly_cost = int(data.get("law_weekly_cost", 1))
	law_worked_this_week = bool(data.get("law_worked_this_week", false))
	recruitment_changed_this_week = bool(data.get("recruitment_changed_this_week", false))
	pending_week_changes = dictionary_array_from_save(data.get("pending_week_changes", []))
	tutorial_seen.clear()
	for tutorial_id in data.get("tutorial_seen", []):
		tutorial_seen.append(str(tutorial_id))
	if tutorial_enabled and int(data.get("tutorial_flow_version", 1)) < 2 and "chapter_5" in tutorial_seen and not "foreign_event" in tutorial_seen:
		# В старом обучении пятая глава уже открывала дипломатию.
		tutorial_seen.append("foreign_event")
	if tutorial_enabled and int(data.get("tutorial_flow_version", 1)) < 3 and "chapter_2" in tutorial_seen and not "chapter_3" in tutorial_seen:
		# Во второй версии второй урок уже открывал экономику. Не закрываем
		# её в продолженной учебной кампании после перестановки уроков.
		tutorial_seen.append("chapter_3")
	normalize_loaded_pending_relations()
	event_resolved = bool(data.get("event_resolved", false))
	events_resolved_this_week = int(data.get("events_resolved_this_week", 0))
	events_required_this_week = int(data.get("events_required_this_week", EVENTS_PER_WEEK))
	events = dictionary_array_from_save(data.get("events", []))
	recurring_events = dictionary_array_from_save(data.get("recurring_events", []))
	event_queue = dictionary_array_from_save(data.get("event_queue", []))
	recurring_event_queue = dictionary_array_from_save(data.get("recurring_event_queue", []))
	weekly_event_queue = dictionary_array_from_save(data.get("weekly_event_queue", []))
	normalize_event_array_population(events)
	normalize_event_array_population(recurring_events)
	normalize_event_array_population(event_queue)
	normalize_event_array_population(recurring_event_queue)
	normalize_event_array_population(weekly_event_queue)
	current_event = normalize_event_population_effects((data.get("current_event", {}) as Dictionary).duplicate(true))
	migrate_legacy_final_event(events)
	migrate_legacy_final_event(event_queue)
	migrate_legacy_final_event(weekly_event_queue)
	if str(current_event.get("title", "")) == "Последняя развилка":
		var previous_kind := str(current_event.get("_kind", ""))
		current_event = election_event_template()
		if previous_kind != "" and not current_event.is_empty():
			current_event["_kind"] = previous_kind
	if tutorial_enabled and int(data.get("tutorial_flow_version", 1)) < 4:
		migrate_loaded_tutorial_neighbor_events()
	if not event_resolved and not current_event.is_empty() and event_blocked_by_current_war(current_event):
		current_event = build_wartime_replacement_event(current_event)
	build_game_screen()
	if check_terminal_state():
		return true
	if int(state.get("week", 1)) > DEMO_WEEKS:
		show_ending()
		return true
	if event_resolved and not week_ready_for_new_week():
		next_event(not tutorial_enabled, not tutorial_enabled)
	elif current_event.is_empty():
		next_event(not tutorial_enabled, not tutorial_enabled)
	else:
		display_current_event(not tutorial_enabled, not tutorial_enabled)
	if tutorial_enabled:
		if int(state.get("week", 1)) == 1 and events_resolved_this_week > 0:
			var first_data: Dictionary = TUTORIAL_WEEK_BRIEFINGS[1]
			show_tutorial_briefing("chapter_1", str(first_data["title"]), str(first_data["body"]))
		elif int(state.get("week", 1)) >= 2:
			show_tutorial_week_briefing()
		if not is_instance_valid(tutorial_dialog):
			maybe_show_foreign_event_tutorial()
	return true


func autosave_if_iron() -> void:
	if is_iron_mode():
		save_campaign(false)


func randomized_starting_ministers(seed_value: int) -> Dictionary:
	var cabinet_rng := RandomNumberGenerator.new()
	cabinet_rng.seed = seed_value ^ CABINET_SEED_SALT
	var cabinet := {"defense": "brother"}
	for slot in ["economy", "interior", "foreign"]:
		var candidates: Array = MINISTER_CANDIDATES.get(slot, [])
		if candidates.is_empty():
			continue
		var candidate: Dictionary = candidates[cabinet_rng.randi_range(0, candidates.size() - 1)]
		cabinet[slot] = str(candidate.get("id", ""))
	return cabinet


func starting_cabinet_signature(seed_value: int) -> String:
	var cabinet := randomized_starting_ministers(seed_value)
	return "%s|%s|%s|%s" % [
		str(cabinet.get("economy", "")),
		str(cabinet.get("interior", "")),
		str(cabinet.get("defense", "")),
		str(cabinet.get("foreign", ""))
	]


func apply_starting_minister_effects() -> Dictionary:
	var applied_by_office: Dictionary = {}
	for slot in ["economy", "interior", "defense", "foreign"]:
		var candidate_id := str(selected_ministers.get(slot, ""))
		var candidate := minister_data(slot, candidate_id)
		if candidate.is_empty():
			continue
		var effects := minister_initial_effects(slot, candidate_id, candidate)
		effects = apply_media_support_filter(effects)
		applied_by_office[slot] = apply_effects(effects) if not effects.is_empty() else {}
	return applied_by_office


func start_game(mode: String, seed_value: int, show_opening_prologue := false) -> void:
	game_mode = mode
	tutorial_enabled = mode == "Обучение"
	tutorial_seen.clear()
	clear_tutorial_card()
	story_rng.seed = seed_value ^ STORY_SEED_SALT
	routine_rng.seed = seed_value ^ ROUTINE_SEED_SALT
	selected_ministers = randomized_starting_ministers(seed_value)
	if mode == "Обучение":
		selected_ministers["foreign"] = "narin"
	pending_week_changes.clear()
	state = {
		"week": 1, "campaign_seed": seed_value, "money": 42.0, "support": 58, "stability": 42, "army": 52,
		"war_support": 24, "corruption_tier": 3, "influence": 3, "debt": 420.0,
		"debt_weekly_interest_rate": DEBT_INITIAL_WEEKLY_RATE,
		"creditor_obligations": 0, "creditor_review_pending": false,
		"creditor_review_due_week": 0, "creditor_review_shown": false, "creditor_priority_weeks": 0,
		"creditor_demand_budget_key": "", "creditor_budget_lock_key": "",
		"creditor_budget_lock_level": -1, "creditor_budget_lock_until_week": 0,
		"clan_oligarchs": 58, "clan_church": 61, "clan_workers": 47,
		"clan_regions": 50,
		"population_total": 4250000, "population_workable": 2510000, "army_personnel": 50000,
		"recruitment_model": "mixed", "army_equipment": 300, "army_aircraft": 12,
		"metal_to_equipment": 2, "oil_to_army": 8, "at_war": false,
		"war_enemy": "", "war_second_enemy": "", "war_ever_started": false, "war_started_week": 0, "war_weeks": 0, "war_casualties": 0,
		"war_crisis_pending": false, "war_crisis_shown": false, "war_pressure_next_week": WAR_PRESSURE_INTERVAL,
		"war_frontline_reductions": 0, "war_frontline_pressure": 0, "war_armistice_signed": false, "war_ceasefire_until_week": 0, "war_ceasefire_enemy": "", "war_medical_priority_until_week": 0, "war_ammo_conservation_until_week": 0,
		"last_war_report": "Война не началась.", "foreign_action_week": 0,
		"east_concession_signed": false, "west_concession_signed": false,
		"east_border_oil_concession": false, "west_investment_arbitration": false,
		"east_wartime_aid_received": false, "west_wartime_aid_received": false,
		"military_threat": false, "metal_price_factor": 1.0, "metal_price_weeks": 0,
		"oil_price_factor": 1.0, "oil_price_weeks": 0,
		"budget_social": 1, "budget_health": 1, "health_funding_balance": 0, "budget_admin": 1,
		"budget_defense": 1, "budget_debt": 1, "budget_infrastructure": 1,
		"last_population_report": "Первый месячный пересчёт состоится на 4-й неделе.",
		"east_relation": 2, "west_relation": 2, "brother_trust": 2,
		"east_energy_discount_until_week": 0, "west_market_access_until_week": 0,
		"kres_fuel_supply_until_week": 0,
		"double_standards_until_week": 0, "foreign_followups": [], "story_followups": [],
		"campaign_arc": "factory" if tutorial_enabled or posmod(seed_value, 2) == 0 else "broadcast", "campaign_arc_started": false, "campaign_arc_legacy": "",
		"unrest_queue": [], "active_unrest_level": 0, "active_unrest_weeks": 0,
		"active_unrest_cause": "", "active_unrest_kind": "", "active_unrest_labor": false,
		"active_unrest_reversible": false, "active_unrest_reversal": "",
		"printed_money": false, "emission_shock_weeks": 0, "emission_shock_elapsed": 0,
		"foreign_base": "", "parliament_free": false,
		"media_restricted": false, "civic_mediation_law": false, "regional_commissions_law": false,
		"collective_bargaining_law": false,
		"narin_crisis_channel_armed": false, "narin_crisis_channel_used": false, "narin_crisis_delay_weeks": 0,
		"varek_corridor_used": false, "kres_fuel_used": false,
		"foreign_minister_resignation_pending": false, "foreign_minister_resignation_shown": false,
		"resigning_foreign_minister": "",
		"social_protest_pending": false, "social_protest_due_week": 0,
		"emergency_powers_protest_pending": false, "emergency_powers_protest_due_week": 0,
		"social_budget_lock_until_week": 0, "regional_administration_penalty_until_week": 0,
		"authoritarian": 0,
		"election_nomination_shown": false, "election_rules_shown": false,
		"election_campaign": "", "election_rules": "undecided", "election_method": "",
		"final_alignment": "", "final_course_reserved": false,
		"last_parliament_vote": "",
		"last_parliament_vote_detail": "",
		"financial_slot_consumed": false, "financial_crisis_shown": false,
		"financial_crisis_ignored": false, "financial_crisis_refusal_week": 0,
		"financial_crisis_survival_pending": false,
		"appointed_ministers": {
			"economy": [str(selected_ministers.get("economy", "radan"))],
			"interior": [str(selected_ministers.get("interior", "volsky"))],
			"defense": ["brother"],
			"foreign": [str(selected_ministers.get("foreign", "narin"))]
		},
		"last_weekly_report": {}, "enacted_laws": [],
		"campaign_income": 0.0, "campaign_expenses": 0.0,
		"campaign_history": []
	}
	# Случайный стартовый кабинет уже находится у власти к первой сцене, поэтому
	# его разовые политические эффекты входят непосредственно в стартовые значения.
	# Они не занимают очки решений и не ждут завершения первой недели.
	apply_starting_minister_effects()
	if tutorial_enabled:
		# Учебная кампания даёт немного времени на знакомство с интерфейсом.
		# Все пороги поражения и последствия решений остаются обычными.
		state.money = 60.0
		state.support = maxi(int(state.get("support", 0)), 68)
		state.stability = maxi(int(state.get("stability", 0)), 54)
		state.war_support = 34
		state.corruption_tier = 2
	ensure_campaign_history()
	active_law = ""
	law_progress = 0
	law_target = 0
	law_weekly_cost = 1
	law_worked_this_week = false
	recruitment_changed_this_week = false
	event_resolved = false
	events_resolved_this_week = 0
	events_required_this_week = EVENTS_PER_WEEK
	reset_budget_draft()
	generate_story_campaign()
	build_recurring_event_database()
	prepare_event_queue()
	prepare_recurring_event_queue()
	build_game_screen()
	prepare_week_event_queue()
	next_event(not show_opening_prologue, not show_opening_prologue)
	if show_opening_prologue:
		show_prologue()
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
	core_event = defer_tutorial_neighbor_event(core_event, event_queue)
	core_event["_kind"] = "core"
	var first_routine: Dictionary = recurring_event_queue.pop_front().duplicate(true)
	var second_routine: Dictionary = recurring_event_queue.pop_front().duplicate(true)
	first_routine = defer_tutorial_neighbor_event(first_routine, recurring_event_queue)
	second_routine = defer_tutorial_neighbor_event(second_routine, recurring_event_queue)
	var arc_event := campaign_arc_event_for_week()
	if not arc_event.is_empty():
		first_routine = arc_event
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


func campaign_arc_event_for_week() -> Dictionary:
	var stage: int = {6: 1, 7: 2, 9: 3, 11: 4}.get(int(state.get("week", 1)), 0)
	if stage == 0 or (stage > 1 and not bool(state.get("campaign_arc_started", false))):
		return {}
	var arc := str(state.get("campaign_arc", ""))
	if arc not in ["factory", "broadcast"]:
		return {}
	var report: Dictionary = preload("res://scripts/campaign_arcs.gd").build(arc, stage, state)
	if not report.is_empty():
		report["_family"] = arc + "_arc_" + str(stage)
	return report


func defer_tutorial_neighbor_event(candidate: Dictionary, source_queue: Array[Dictionary]) -> Dictionary:
	# До четвёртой недели обучение знакомит с внутренними делами. Доклады
	# о соседях откладываются без удаления и возвращаются с четвёртой недели.
	if not tutorial_enabled or int(state.get("week", 1)) >= 4 or not tutorial_event_touches_foreign_policy(candidate):
		return candidate
	for index in range(source_queue.size()):
		if tutorial_event_touches_foreign_policy(source_queue[index]):
			continue
		var replacement: Dictionary = source_queue[index].duplicate(true)
		source_queue.remove_at(index)
		source_queue.push_front(candidate)
		return replacement
	return candidate


func migrate_loaded_tutorial_neighbor_events() -> void:
	# Сохранённые доклады третьей недели уже лежат вне обычных очередей.
	# Переставляем только те, на которые игрок ещё не ответил.
	if int(state.get("week", 1)) >= 4 or "foreign_event" in tutorial_seen:
		return
	if not event_resolved and tutorial_event_touches_foreign_policy(current_event):
		var current_kind := str(current_event.get("_kind", ""))
		if current_kind == "core":
			current_event = defer_tutorial_neighbor_event(current_event, event_queue)
		elif current_kind == "routine":
			current_event = defer_tutorial_neighbor_event(current_event, recurring_event_queue)
		current_event["_kind"] = current_kind
	for index in range(weekly_event_queue.size()):
		var queued_event: Dictionary = weekly_event_queue[index]
		if not tutorial_event_touches_foreign_policy(queued_event):
			continue
		var queued_kind := str(queued_event.get("_kind", ""))
		if queued_kind == "core":
			weekly_event_queue[index] = defer_tutorial_neighbor_event(queued_event, event_queue)
		elif queued_kind == "routine":
			weekly_event_queue[index] = defer_tutorial_neighbor_event(queued_event, recurring_event_queue)
		(weekly_event_queue[index] as Dictionary)["_kind"] = queued_kind


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
	var game_title := label("НАСЛЕДНИК РЕСПУБЛИКИ  •  v%s" % GAME_VERSION, 23, CREAM)
	game_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(game_title)
	week_label = label("НЕДЕЛЯ 1", 19, PAPER, HORIZONTAL_ALIGNMENT_CENTER)
	week_label.custom_minimum_size = Vector2(330, 0)
	top.add_child(week_label)
	mode_label = label(campaign_header_caption(), 12, GOLD, HORIZONTAL_ALIGNMENT_RIGHT)
	mode_label.custom_minimum_size = Vector2(300, 0)
	mode_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	mode_label.tooltip_text = "Сид определяет случайную выборку и порядок событий. Его можно использовать, чтобы повторить или передать эту кампанию."
	top.add_child(mode_label)
	var workspace := HBoxContainer.new()
	workspace.add_theme_constant_override("separation", 16)
	workspace.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(workspace)

	var left_panel := PanelContainer.new()
	tutorial_left_panel = left_panel
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
	var status_extra := VBoxContainer.new()
	status_extra.add_theme_constant_override("separation", 8)
	tutorial_left_status_extra = status_extra
	left_box.add_child(status_extra)
	add_sidebar_summary_row(status_extra, "unrest_status", "Протесты", "нет")
	add_sidebar_summary_row(status_extra, "election_status", "Досрочные выборы", "через 26 нед.")
	var clans_section := VBoxContainer.new()
	clans_section.add_theme_constant_override("separation", 8)
	tutorial_left_clans_section = clans_section
	left_box.add_child(clans_section)
	clans_section.add_child(HSeparator.new())
	clans_section.add_child(label("ВНУТРЕННИЕ СИЛЫ", 13, GOLD))
	add_sidebar_summary_row(clans_section, "clan_oligarchs", "Олигархи", "58%")
	add_sidebar_summary_row(clans_section, "clan_church", "Церковь Веры", "61%")
	add_sidebar_summary_row(clans_section, "clan_workers", "Профсоюзы", "47%")
	add_sidebar_summary_row(clans_section, "clan_regions", "Регионы", "50%")
	add_sidebar_summary_row(clans_section, "army_loyalty", "Армия", "52%")
	var foreign_section := VBoxContainer.new()
	foreign_section.add_theme_constant_override("separation", 8)
	tutorial_left_foreign_section = foreign_section
	left_box.add_child(foreign_section)
	foreign_section.add_child(HSeparator.new())
	foreign_section.add_child(label("СОСЕДНИЕ ДЕРЖАВЫ", 13, GOLD))
	add_sidebar_summary_row(foreign_section, "east_relation", "Восточный Союз", neighbor_relation_band("east"))
	add_sidebar_summary_row(foreign_section, "west_relation", "Западная Федерация", neighbor_relation_band("west"))
	var army_section := VBoxContainer.new()
	army_section.add_theme_constant_override("separation", 8)
	tutorial_left_army_section = army_section
	left_box.add_child(army_section)
	army_section.add_child(HSeparator.new())
	army_section.add_child(label("ВООРУЖЁННЫЕ СИЛЫ", 13, GOLD))
	add_sidebar_summary_row(army_section, "army_effectiveness", "Боеспособность", "%d%%" % army_effectiveness())
	add_sidebar_summary_row(army_section, "army_supply", "Снабжение", "%d%%" % army_supply())
	add_sidebar_summary_row(army_section, "army_personnel", "Личный состав", format_people(int(state.get("army_personnel", 0))))
	add_sidebar_summary_row(army_section, "army_assets", "Техника / авиация", "%d / %d" % [int(state.get("army_equipment", 0)), int(state.get("army_aircraft", 0))])

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
	left_hint.visible = event_choice_hints_enabled
	choice_grid.add_child(left_hint)
	right_hint = label("Примерный эффект", 13, Color("#cfc3aa"), HORIZONTAL_ALIGNMENT_CENTER)
	right_hint.custom_minimum_size = Vector2(0, 36)
	right_hint.visible = event_choice_hints_enabled
	choice_grid.add_child(right_hint)
	third_hint = label("Примерный эффект", 13, Color("#cfc3aa"), HORIZONTAL_ALIGNMENT_CENTER)
	third_hint.custom_minimum_size = Vector2(0, 36)
	third_hint.visible = false
	choice_grid.add_child(third_hint)

	var right_panel := PanelContainer.new()
	tutorial_right_panel = right_panel
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
	var minister_section := VBoxContainer.new()
	minister_section.add_theme_constant_override("separation", 8)
	tutorial_minister_section = minister_section
	right_box.add_child(minister_section)
	minister_section.add_child(label("МИНИСТР ЭКОНОМИКИ", 12, MUTED))
	economy_name_label = label(current_minister_name("economy"), 18, PAPER)
	minister_section.add_child(economy_name_label)
	minister_section.add_child(label("МИНИСТР ВНУТРЕННИХ ДЕЛ", 12, MUTED))
	interior_name_label = label(current_minister_name("interior"), 18, PAPER)
	minister_section.add_child(interior_name_label)
	minister_section.add_child(label("МИНИСТР ОБОРОНЫ", 12, MUTED))
	defense_name_label = label(current_minister_name("defense"), 18, PAPER)
	minister_section.add_child(defense_name_label)
	minister_section.add_child(label("МИНИСТР ИНОСТРАННЫХ ДЕЛ", 12, MUTED))
	foreign_name_label = label(current_minister_name("foreign"), 18, PAPER)
	minister_section.add_child(foreign_name_label)
	minister_section.add_child(HSeparator.new())
	var sections_header := HBoxContainer.new()
	tutorial_sections_header = sections_header
	right_box.add_child(sections_header)
	var sections_caption := label("РАЗДЕЛЫ", 12, MUTED)
	sections_caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sections_header.add_child(sections_caption)
	var guide_button := small_button("?  СПРАВКА")
	guide_button.custom_minimum_size = Vector2(112, 32)
	guide_button.add_theme_font_size_override("font_size", 12)
	guide_button.set_meta("ui_click_sound", "page")
	guide_button.pressed.connect(show_guide)
	sections_header.add_child(guide_button)
	var section_grid := GridContainer.new()
	tutorial_section_grid = section_grid
	section_grid.columns = 2
	section_grid.add_theme_constant_override("h_separation", 8)
	section_grid.add_theme_constant_override("v_separation", 8)
	right_box.add_child(section_grid)
	var ministers_button := small_button("ПРАВИТЕЛЬСТВО")
	ministers_button.set_meta("ui_click_sound", "page")
	ministers_button.pressed.connect(show_ministers)
	section_grid.add_child(ministers_button)
	tutorial_section_buttons["government"] = ministers_button
	var clans_button := small_button("КЛАНЫ")
	clans_button.set_meta("ui_click_sound", "page")
	clans_button.pressed.connect(show_clans)
	section_grid.add_child(clans_button)
	tutorial_section_buttons["clans"] = clans_button
	var economy_button := small_button("ЭКОНОМИКА")
	economy_button.set_meta("ui_click_sound", "page")
	economy_button.pressed.connect(show_economy)
	section_grid.add_child(economy_button)
	tutorial_section_buttons["economy"] = economy_button
	var army_button := small_button("АРМИЯ")
	army_button.set_meta("ui_click_sound", "page")
	army_button.pressed.connect(show_army)
	section_grid.add_child(army_button)
	tutorial_section_buttons["army"] = army_button
	var foreign_button := small_button("ВНЕШНЯЯ ПОЛИТИКА")
	foreign_button.set_meta("ui_click_sound", "page")
	foreign_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	foreign_button.pressed.connect(show_foreign_policy)
	section_grid.add_child(foreign_button)
	tutorial_section_buttons["foreign"] = foreign_button
	var report_button := small_button("СВОДКА")
	# The report screen plays the same page sound itself, including when it is
	# opened automatically after the week ends. Avoid playing it twice here.
	report_button.set_meta("ui_click_sound", "")
	report_button.pressed.connect(show_weekly_report)
	section_grid.add_child(report_button)
	tutorial_section_buttons["report"] = report_button
	law_button = small_button("ПОДГОТОВИТЬ ЗАКОН")
	law_button.set_meta("ui_click_sound", "page")
	law_button.custom_minimum_size = Vector2(0, 54)
	law_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	law_button.pressed.connect(on_law_button_pressed)
	right_box.add_child(law_button)
	end_week_button = small_button("ДОКЛАД 1 / 3")
	# When the week closes, the weekly summary supplies the page sound. The
	# generic button click would otherwise add the unwanted electronic signal.
	end_week_button.set_meta("ui_click_sound", "")
	end_week_button.disabled = true
	end_week_button.pressed.connect(on_week_action_pressed)
	right_box.add_child(end_week_button)
	var side_spacer := Control.new()
	side_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_box.add_child(side_spacer)
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 8)
	right_box.add_child(footer)
	var save_button := small_button("БЕЗ СОХРАНЕНИЙ" if is_no_save_mode() else "АВТОСОХРАНЕНИЕ" if is_iron_mode() else "СОХРАНИТЬ")
	save_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_button.disabled = is_iron_mode() or is_no_save_mode()
	save_button.tooltip_text = "В этом режиме кампания не сохраняется. Старый файл продолжения остаётся нетронутым." if is_no_save_mode() else "Режим киборга автоматически сохраняет прогресс после решений и в конце недели. После выхода выберите «Продолжить». Ручной точки отката нет." if game_mode == "Режим киборга" else "Железный режим автоматически обновляет единственное сохранение после решений и не позволяет создать точку для отката." if is_iron_mode() else "Сохранить текущее состояние кампании. Недельное автосохранение также создаётся при переходе к новой неделе."
	if not is_iron_mode() and not is_no_save_mode():
		save_button.pressed.connect(save_campaign.bind(true))
	footer.add_child(save_button)
	var settings_button := small_button("НАСТРОЙКИ")
	settings_button.set_meta("ui_click_sound", "page")
	settings_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_button.tooltip_text = "Полноэкранный режим и горячие клавиши F4 / F11."
	settings_button.pressed.connect(show_settings)
	footer.add_child(settings_button)
	var restart_button := small_button("МЕНЮ")
	restart_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	restart_button.pressed.connect(show_start_screen)
	footer.add_child(restart_button)
	build_tutorial_focus_layer()
	call_deferred("refresh_tutorial_focus")


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
	value_label.mouse_filter = Control.MOUSE_FILTER_STOP
	box.add_child(value_label)
	panel.tooltip_text = compact_tooltip(main_stat_tooltip(key))
	stat_labels[key] = value_label
	stat_caption_labels[key] = caption_label


func add_sidebar_summary_row(parent: Container, key: String, caption: String, value: String) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 19)
	row.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(row)
	var caption_label := label(caption, 13, MUTED)
	caption_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	caption_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	row.add_child(caption_label)
	var value_label := label(value, 14, CREAM, HORIZONTAL_ALIGNMENT_RIGHT)
	value_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	value_label.mouse_filter = Control.MOUSE_FILTER_STOP
	row.add_child(value_label)
	sidebar_summary_labels[key] = value_label


func sidebar_number_label(metric_key: String) -> Label:
	if stat_labels.has(metric_key):
		return stat_labels[metric_key] as Label
	if metric_key in ["army_equipment", "army_aircraft"]:
		return sidebar_summary_labels.get("army_assets") as Label
	return sidebar_summary_labels.get(metric_key) as Label


func render_sidebar_number(metric_key: String) -> void:
	var value_label := sidebar_number_label(metric_key)
	if not is_instance_valid(value_label):
		return
	if metric_key == "money":
		value_label.text = "%.1f млн" % float(sidebar_number_values.get(metric_key, 0.0))
	elif metric_key == "army_personnel":
		value_label.text = format_people(roundi(float(sidebar_number_values.get(metric_key, 0.0))))
	elif metric_key in ["army_equipment", "army_aircraft"]:
		value_label.text = "%d / %d" % [
			roundi(float(sidebar_number_values.get("army_equipment", 0.0))),
			roundi(float(sidebar_number_values.get("army_aircraft", 0.0)))
		]
	else:
		value_label.text = "%d%%" % roundi(float(sidebar_number_values.get(metric_key, 0.0)))
	localize_property(value_label, "text", "localized_text")


func set_sidebar_number_animation_value(value: float, metric_key: String) -> void:
	sidebar_number_values[metric_key] = value
	render_sidebar_number(metric_key)


func queue_sidebar_number(metric_key: String, target_value: float) -> void:
	sidebar_number_targets[metric_key] = target_value
	if not sidebar_number_values.has(metric_key) or DisplayServer.get_name() == "headless":
		sidebar_number_values[metric_key] = target_value
		render_sidebar_number(metric_key)
		return
	if not sidebar_number_flush_pending:
		sidebar_number_flush_pending = true
		call_deferred("flush_sidebar_number_animations")


func stop_sidebar_number_animation() -> void:
	if is_instance_valid(sidebar_number_tween):
		sidebar_number_tween.kill()
	sidebar_number_tween = null


func flush_sidebar_number_animations() -> void:
	sidebar_number_flush_pending = false
	if DisplayServer.get_name() == "headless":
		for metric_key in sidebar_number_targets:
			sidebar_number_values[metric_key] = float(sidebar_number_targets[metric_key])
			render_sidebar_number(str(metric_key))
		return
	if not is_instance_valid(game_root) or is_instance_valid(overlay) or is_instance_valid(debug_cheat_panel):
		return
	stop_sidebar_number_animation()
	var changed_metrics: Array[String] = []
	for metric_key_value in sidebar_number_targets:
		var metric_key := str(metric_key_value)
		var current_value := float(sidebar_number_values.get(metric_key, sidebar_number_targets[metric_key]))
		var target_value := float(sidebar_number_targets[metric_key])
		if not is_equal_approx(current_value, target_value):
			changed_metrics.append(metric_key)
		else:
			render_sidebar_number(metric_key)
	if changed_metrics.is_empty():
		return
	sidebar_number_tween = create_tween().set_parallel(true)
	for metric_key in changed_metrics:
		var current_value := float(sidebar_number_values[metric_key])
		var target_value := float(sidebar_number_targets[metric_key])
		sidebar_number_tween.tween_method(set_sidebar_number_animation_value.bind(metric_key), current_value, target_value, 0.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func request_sidebar_refresh() -> void:
	if DisplayServer.get_name() == "headless":
		refresh_sidebar_content()
		return
	if sidebar_refresh_pending:
		return
	sidebar_refresh_pending = true
	call_deferred("flush_sidebar_refresh")


func flush_sidebar_refresh() -> void:
	if is_instance_valid(overlay):
		return
	sidebar_refresh_pending = false
	refresh_sidebar_content()


func refresh_sidebar_content() -> void:
	if not is_instance_valid(game_root) or not is_instance_valid(week_label):
		return
	update_projected_main_stat("money", "Казна", true)
	update_projected_main_stat("support", "Поддержка власти")
	update_projected_main_stat("stability", "Стабильность")
	update_projected_main_stat("war_support", "Поддержка войны")
	update_main_stat_caption_colors()
	update_sidebar_summary()
	localize_visible_tree()


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
			unrest_label.tooltip_text = "%s\nПричина: %s\nКаждую неделю стабильность −%d.%s%s" % [unrest_level_title(unrest_level, labor).capitalize(), str(state.get("active_unrest_cause", "")), unrest_stability_loss(unrest_level, labor), " Забастовка также уменьшает доходы от труда и производства." if labor else "", " Региональные комиссии уменьшают потерю стабильности на 1." if bool(state.get("regional_commissions_law", false)) and not labor else ""]
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
		queue_sidebar_number(str(key), value)
		value_label.add_theme_color_override("font_color", PENDING_BLUE if pending else GREEN if value >= CLAN_HIGH_SUPPORT else RED if value <= CLAN_LOW_SUPPORT else CREAM)
		value_label.tooltip_text = clan_support_levels_tooltip(str(key), str(clan_titles[key]), current_value, value)
		value_label.mouse_default_cursor_shape = Control.CURSOR_HELP
	for side in ["east", "west"]:
		var relation_key: String = str(side) + "_relation"
		var current_band := neighbor_relation_band(side)
		var projected_band := neighbor_relation_band(side, true)
		var relation_pending := current_band != projected_band
		var relation_label: Label = sidebar_summary_labels[relation_key]
		var war_suffix := (" • WAR" if language_code == "en" else " • ВОЙНА") if at_war_with(side) else ""
		relation_label.text = projected_band.to_upper() + war_suffix
		relation_label.add_theme_color_override("font_color", PENDING_BLUE if relation_pending else neighbor_relation_color(side))
		relation_label.tooltip_text = (pending_value_tooltip(neighbor_title(side), current_band, projected_band) + "\n\n" + neighbor_relation_explanation(side, true)) if relation_pending else neighbor_relation_explanation(side)
		relation_label.mouse_default_cursor_shape = Control.CURSOR_HELP
	var current_loyalty := int(state.get("army", 50))
	var loyalty := projected_pending_value("army")
	var loyalty_pending := loyalty != current_loyalty
	var loyalty_label: Label = sidebar_summary_labels["army_loyalty"]
	queue_sidebar_number("army_loyalty", loyalty)
	loyalty_label.add_theme_color_override("font_color", PENDING_BLUE if loyalty_pending else GREEN if loyalty >= 65 else RED if loyalty <= 40 else CREAM)
	loyalty_label.tooltip_text = army_loyalty_levels_tooltip(current_loyalty, loyalty)
	loyalty_label.mouse_default_cursor_shape = Control.CURSOR_HELP
	var projected_army := projected_army_snapshot()
	var current_effectiveness := army_effectiveness()
	var effectiveness := int(projected_army["effectiveness"])
	var effectiveness_pending := effectiveness != current_effectiveness
	var effectiveness_label: Label = sidebar_summary_labels["army_effectiveness"]
	queue_sidebar_number("army_effectiveness", effectiveness)
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
	queue_sidebar_number("army_supply", supply)
	supply_label.add_theme_color_override("font_color", PENDING_BLUE if supply_pending else GREEN if supply >= 75 else RED if supply < 50 else CREAM)
	supply_label.tooltip_text = (pending_value_tooltip("Снабжение армии", "%d%%" % current_supply, "%d%%" % supply) + "\n\nЗависит от доли недельной добычи нефти, направленной армии.") if supply_pending else "Зависит от доли недельной добычи нефти, направленной армии. Ниже 75% падает лояльность, ниже 50% дополнительно страдает стабильность."
	supply_label.mouse_default_cursor_shape = Control.CURSOR_HELP
	var current_personnel := int(state.get("army_personnel", 0))
	var projected_personnel := int(projected_army["personnel"])
	var personnel_label: Label = sidebar_summary_labels["army_personnel"]
	queue_sidebar_number("army_personnel", projected_personnel)
	personnel_label.add_theme_color_override("font_color", PENDING_BLUE if projected_personnel != current_personnel else CREAM)
	personnel_label.tooltip_text = (pending_value_tooltip("Военнослужащие", format_people(current_personnel), format_people(projected_personnel)) + "\n\nЦель выбранной модели: %s." % format_people(recruitment_target())) if projected_personnel != current_personnel else "Текущее число военнослужащих. Цель выбранной модели комплектования: %s." % format_people(recruitment_target())
	personnel_label.mouse_default_cursor_shape = Control.CURSOR_HELP
	var current_equipment := int(state.get("army_equipment", 0))
	var current_aircraft := int(state.get("army_aircraft", 0))
	var projected_equipment := int(projected_army["equipment"])
	var projected_aircraft := int(projected_army["aircraft"])
	var assets_pending := projected_equipment != current_equipment or projected_aircraft != current_aircraft
	var assets_label: Label = sidebar_summary_labels["army_assets"]
	queue_sidebar_number("army_equipment", projected_equipment)
	queue_sidebar_number("army_aircraft", projected_aircraft)
	assets_label.add_theme_color_override("font_color", PENDING_BLUE if assets_pending else CREAM)
	assets_label.tooltip_text = (pending_value_tooltip("Техника / авиация", "%d / %d" % [current_equipment, current_aircraft], "%d / %d" % [projected_equipment, projected_aircraft]) + "\n\nПотребность ожидаемой армии: %d / %d. Авиацию республика не производит." % [int(projected_army["required_equipment"]), int(projected_army["required_aircraft"])]) if assets_pending else "Наземная техника / авиация. Потребность текущей армии: %d / %d. Авиацию республика не производит." % [army_required_equipment(), army_required_aircraft()]
	assets_label.mouse_default_cursor_shape = Control.CURSOR_HELP
	for summary_label in sidebar_summary_labels.values():
		if is_instance_valid(summary_label):
			summary_label.tooltip_text = compact_tooltip(summary_label.tooltip_text)
			(summary_label.get_parent() as Control).tooltip_text = summary_label.tooltip_text


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
	localize_property(button, "text", "localized_text")
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



func unrest_stability_loss(level: int, labor := false) -> int:
	var loss := 2
	match clampi(level, 1, 3):
		1:
			loss = 2
		2:
			loss = 4
		_:
			loss = 7
	if bool(state.get("regional_commissions_law", false)) and not labor:
		loss = maxi(1, loss - 1)
	return loss


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
	if support <= 20:
		level += 1
	# Стабильные институты сдерживают масштаб кризиса даже при непопулярной
	# власти; при распаде управления тот же конфликт распространяется шире.
	if stability <= 30:
		level += 1
	elif stability >= 70:
		level -= 1
	if kind == "labor" and int(state.get("clan_workers", 50)) <= 35:
		level += 1
	elif kind == "regional" and int(state.get("clan_regions", 50)) <= 35:
		level += 1
	if bool(state.get("civic_mediation_law", false)) and kind != "labor":
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


func process_active_unrest_week(snapshot: Dictionary, effect_collector: Dictionary = {}, defer_effects := false) -> String:
	if snapshot.is_empty():
		return ""
	var level := int(snapshot.get("level", 1))
	var labor := bool(snapshot.get("labor", false))
	var stability_loss := unrest_stability_loss(level, labor)
	if defer_effects:
		effect_collector["stability"] = int(effect_collector.get("stability", 0)) - stability_loss
	else:
		apply_effects({"stability": -stability_loss})
	var note := "%s из-за решения «%s»: стабильность −%d." % [unrest_level_title(level, labor).capitalize(), str(snapshot.get("cause", "")), stability_loss]
	if bool(state.get("regional_commissions_law", false)) and not labor:
		note += " Региональные согласительные комиссии уменьшили политический ущерб на 1 пункт."
	if labor:
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
		var commissions_active := bool(state.get("regional_commissions_law", false))
		var sava_hint := "Центральный протест прекратится • губернаторы усилятся • действующие комиссии не перегрузят аппарат президента" if commissions_active else "Центральный протест прекратится • губернаторы усилятся • центр потеряет одно очко решений на следующей неделе"
		var sava_result := "Антон Сава распределил требования между уже действующими согласительными комиссиями. Общая коалиция распалась, а аппарат президента сохранил рабочий ритм, хотя губернаторы вновь усилили собственные позиции." if commissions_active else "Антон Сава передал требования отдельным губернаторам. Общая коалиция распалась, однако местные администрации получили новые полномочия и начали торговаться с центром самостоятельно."
		second = option("Разделить переговоры по регионам", sava_hint, {"stability": 3, "clan_regions": 8, "clan_workers": -4 if labor else 0}, sava_result, {"unrest_resolved": true, "regional_administration_disruption": not commissions_active})
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
				option("Отключить убыточные промышленные линии", "Поставки населению сохранятся • экспорт и выпуск пострадают • вероятна забастовка", {"money": 3, "support": -4, "stability": -4, "clan_workers": -10}, "Газ перенаправили с заводов в городские котельные. В квартирах стало теплее, но заводские проходные закрылись, и профсоюзы объявили общую смену протеста.", {"industry_heat_cut": true, "unrest": {"cause": "остановка промышленных линий ради отопления городов", "kind": "labor", "labor": true, "base_level": 2, "condition": "workers_low", "reversible": false}}))
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
			var volunteers_were_integrated := bool(state.get("volunteers_integrated", false))
			if bool(state.get("volunteers_disarmed", false)):
				volunteer_body = "После разоружения часть добровольцев не сдала оружие и создала ветеранские союзы в трёх городах. Они требуют амнистии и права войти в резерв единым подразделением, а полиция предупреждает о тайных складах."
			elif bool(state.get("volunteers_regional", false)):
				volunteer_body = "Территориальные отряды подчиняются губернаторам и отказываются передавать технику армейскому штабу. На карте обороны появились хорошо вооружённые районы, которые президент не может быстро перебросить."
			return event("Совет обороны", "military", "#536f82", "Чей приказ последний", volunteer_body,
				option("Единое командование после проверки", "Потребуются деньги и время • батальон останется в составе армии под единым командованием", {"money": -6, "army": 6, "stability": 2, "war_support": 3}, "Каждый доброволец прошёл проверку и подписал индивидуальный контракт. Батальон потерял собственное название, но появился в армейском расписании.", {"volunteers_vetted": true}),
				option("Сделать батальон президентской гвардией", "Президент получит личную силу • армия и порядок пострадают • авторитаризм усилится", {"support": -3, "stability": -4, "army": -7, "war_support": 5, "authoritarian": 1}, "Батальон присягнул лично президенту и занял базу у столицы. Добровольцы довольны статусом, а генеральный штаб больше не включает их в общие планы.", {"presidential_guard_battalion": true}),
				option("Амнистия в обмен на роспуск", "Оружие вернётся на склады • поддержка войны и армия ослабнут • гражданский порядок укрепится", {"support": 3, "stability": 6, "army": -5, "war_support": -7, "army_personnel": -3000, "population_workable": 3000} if volunteers_were_integrated else {"support": 3, "stability": 6, "army": -5, "war_support": -7}, "Участники сдали тяжёлое оружие и получили амнистию. Большинство разошлось, но их командиры сразу зарегистрировали политическое движение ветеранов.", {"volunteer_party_formed": true}))
		"opposition_return":
			if bool(state.get("opposition_returned_free", false)):
				return event("Столичная мэрия", "official", "#668269", "Марш без сцены", "Вернувшийся политик созвал сторонников на центральной площади. Мэрия согласна выдать разрешение только для набережной, организаторы требуют пройти мимо парламента, а полиция предупреждает: отмена шествия соберёт людей без маршрута и ответственных.",
					option("Разрешить маршрут у парламента", "Оппозиция получит сцену • поддержка открытой политики вырастет • стабильность окажется под угрозой", {"support": 5, "stability": -6, "clan_workers": 4}, "Марш прошёл перед парламентом под камерами. Столкновений не произошло, но оппозиция впервые показала, что способна заполнить центр без разрешения президентской администрации.", {"opposition_march_permitted": true}),
					option("Согласовать набережную", "Потребуются переговоры и охрана • порядок сохранится • обе стороны сочтут компромисс уступкой", {"money": -4, "support": 2, "stability": 3, "clan_oligarchs": -3}, "Организаторы приняли запасной маршрут и получили прямой эфир на общественном канале. Полиция не перекрывала центр, но самые непримиримые сторонники обвинили лидера в сделке с властью.", {"opposition_march_compromise": true}),
					option("Закрыть центр на ремонт", "Шествие потеряет маршрут • стабильность временно вырастет • поддержка упадёт и возможен протест", {"support": -6, "stability": 5, "authoritarian": 1}, "Ночью вокруг площади появились ограждения и свежие таблички о ремонте. Колонна распалась на несколько улиц, а фотография рабочих, укладывающих одну плитку перед телекамерами, стала символом запрета.", {"opposition_march_blocked": true, "unrest": {"cause": "запрет оппозиционного марша под видом ремонта", "kind": "civic", "base_level": 1, "condition": "low_support", "reversible": false}}))
			elif bool(state.get("opposition_returned_detained", false)):
				return event("Следственный суд", "official", "#a9473f", "Окна изолятора", "Срок первичного задержания истекает ночью. Прокуратура просит закрыть слушание из-за секретных материалов, адвокаты требуют прямой трансляции, а западные посольства предупреждают о персональных ограничениях для чиновников, подписавших новый арест.",
					liberal_option("Открыть судебное заседание", "Общество увидит доказательства • поддержка вырастет • слабое дело может рассыпаться и ухудшить порядок", {"support": 5, "stability": -5, "west_commitment": 1, "army": -3}, "Суд пустил камеры и зачитал материалы обвинения. Часть эпизодов выдержала проверку, часть оказалась газетными вырезками; политик остался под подпиской о невыезде и сразу выступил на ступенях суда.", "Общество увидит доказательства • поддержка вырастет • исход дела останется непредсказуемым", "Суд пустил камеры и зачитал материалы обвинения. Часть эпизодов выдержала проверку, часть оказалась газетными вырезками; политик остался под подпиской о невыезде и сразу выступил на ступенях суда.", {"opposition_open_trial": true}),
					option("Предложить выезд из страны", "Уличный конфликт ослабнет • Запад сочтёт это политической высылкой • поддержка снизится", {"support": -3, "stability": 4, "west_pressure": 4}, "Задержанному предложили свободу в обмен на билет без обратной даты. Он согласился, но опубликовал документ ещё до взлёта; сторонники называют отъезд изгнанием.", {"opposition_exiled": true}),
					option("Продлить закрытый арест", "Порядок укрепится сейчас • поддержка и отношения с Западом резко ухудшатся • протест возможен", {"support": -7, "stability": 6, "west_pressure": 6, "authoritarian": 1}, "Судья продлил арест без прессы. У изолятора погасили фонари, однако люди включили телефоны и остались до утра.", {"opposition_detention_extended": true, "unrest": {"cause": "продление закрытого ареста оппозиционного политика", "kind": "civic", "base_level": 2, "condition": "low_support", "reversible": false}}))
			return event("Общественное телевидение", "official", "#536f82", "Эфир без паузы", "Запись обещанных дебатов длится почти три часа. Оппозиционный политик предъявил документы о закупках администрации, президент — сведения о зарубежном финансировании его штаба. Каналы ждут приказа: показать всё, собрать короткую версию или отменить передачу, пока обе стороны не проверят обвинения.",
				option("Показать запись полностью", "Поддержка открытой политики вырастет • скандалы обеих сторон ударят по стабильности и олигархам", {"support": 4, "stability": -5, "clan_oligarchs": -7}, "Страна увидела все три часа без монтажа. Ни одна сторона не получила чистой победы, зато прокуратура открыла дела по документам, которые ещё утром считались реквизитом студии.", {"opposition_debate_raw": true}),
				option("Собрать короткую версию", "Повестка останется управляемой • монтаж потребует денег • разоблачение купюр ударит по поддержке", {"money": -3, "support": -3, "stability": 4}, "В эфир вышли сорок спокойных минут. Уже ночью участник съёмочной группы передал независимому каналу вырезанные фрагменты, и спор о монтаже заменил спор о программах.", {"opposition_debate_edited": true}),
				option("Отложить эфир до проверки", "Немедленный скандал будет отложен • обе стороны обвинят власть в страхе • порядок и поддержка снизятся", {"support": -4, "stability": -3, "clan_workers": -3}, "Каналы поставили повтор концерта, а штабы одновременно выложили собственные фрагменты. Вместо одного эфира страна получила две несовместимые версии дебатов.", {"opposition_debate_delayed": true}))
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


func next_event(play_default_report_sound := true, play_special_event_sound := true) -> void:
	if check_terminal_state():
		return
	if int(state.week) > DEMO_WEEKS:
		show_ending()
		return
	remove_wartime_incompatible_followups()
	if should_trigger_war_crisis():
		current_event = build_war_crisis_event()
		current_event["_kind"] = "urgent"
		current_event["_sound"] = "war"
		state.war_crisis_pending = false
		state.war_crisis_shown = true
		events_required_this_week += 1
	elif should_trigger_foreign_minister_resignation():
		current_event = build_foreign_minister_resignation_event()
		current_event["_kind"] = "urgent"
		state.foreign_minister_resignation_shown = true
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
		current_event["_sound"] = "protest"
		state.emergency_powers_protest_pending = false
		events_required_this_week += 1
	elif should_trigger_social_protest():
		current_event = social_protest_event.duplicate(true)
		current_event["_kind"] = "urgent"
		current_event["_sound"] = "protest"
		state.social_protest_pending = false
		events_required_this_week += 1
	elif should_trigger_unrest():
		current_event = take_unrest_event()
		current_event["_kind"] = "urgent"
		current_event["_sound"] = "protest"
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
	display_current_event(play_default_report_sound, play_special_event_sound)


func display_current_event(play_default_report_sound := true, play_special_event_sound := true) -> void:
	update_interface()
	if current_event.is_empty():
		return
	var report_sound := str(current_event.get("_sound", "report"))
	# «Продолжить» после результата не должно давать двойной электронный
	# сигнал. Особые звуки войны и протестов всё равно воспроизводятся.
	if (report_sound == "report" and play_default_report_sound) or (report_sound != "report" and play_special_event_sound):
		play_game_sound(report_sound)
		if report_sound == "war":
			play_game_sound("war_siren")
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
	if has_third:
		third_button.text = str(current_event["third"]["label"]).to_upper()
		third_hint.text = str(current_event["third"]["hint"])
	update_event_choice_hint_visibility(has_third)
	portrait.setup(str(current_event["role"]), Color(str(current_event["accent"])), character_portrait(event_character_id(current_event)))
	left_button.disabled = event_resolved or bool(current_event["left"].get("unavailable", false))
	right_button.disabled = event_resolved or bool(current_event["right"].get("unavailable", false))
	third_button.disabled = event_resolved or not has_third or (has_third and bool(current_event["third"].get("unavailable", false)))
	if play_default_report_sound or play_special_event_sound:
		maybe_show_foreign_event_tutorial()
	localize_visible_tree()


func maybe_show_foreign_event_tutorial() -> void:
	if tutorial_enabled and not event_resolved and "chapter_1" in tutorial_seen and not is_instance_valid(tutorial_dialog) and tutorial_event_touches_foreign_policy(current_event):
		show_tutorial_briefing("foreign_event", "СОСЕДИ И СУВЕРЕНИТЕТ", "Этот доклад связан с соседним государством. Теперь слева показаны отношения с Восточным Союзом и Западной Федерацией, а справа открыта вкладка «Внешняя политика».\n\nУ каждого соседа четыре уровня отношений: враждебные, натянутые, средние и партнёрские. Решение может изменить уровень после завершения недели. Если отношения станут враждебными, сосед начнёт вторжение. Перед ответом откройте вкладку и посмотрите, что можно сделать дипломатически.")


func tutorial_event_touches_foreign_policy(report: Dictionary) -> bool:
	if str(report.get("role", "")) == "diplomat" or not event_peace_requirements(report).is_empty():
		return true
	for side in ["left", "right", "third"]:
		if not report.has(side):
			continue
		var option_data: Dictionary = report[side]
		var effects: Dictionary = option_data.get("effects", {})
		for key in ["east_relation", "west_relation", "east_pressure", "west_pressure", "east_commitment", "west_commitment", "neutrality"]:
			if effects.has(key):
				return true
	return false


func update_event_choice_hint_visibility(has_third_option := false) -> void:
	if is_instance_valid(left_hint):
		left_hint.visible = event_choice_hints_enabled
	if is_instance_valid(right_hint):
		right_hint.visible = event_choice_hints_enabled
	if is_instance_valid(third_hint):
		var third_exists := has_third_option
		if not third_exists and not current_event.is_empty():
			third_exists = current_event.has("third") and not (current_event["third"] as Dictionary).is_empty()
		third_hint.visible = event_choice_hints_enabled and third_exists


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
	var refused_and_ready := (
		bool(state.get("financial_crisis_ignored", false))
		and int(state.get("financial_crisis_refusal_week", 0)) > 0
		and int(state.get("week", 1)) >= int(state.get("financial_crisis_refusal_week", 0)) + 4
	)
	return (
		not final_story_resolved
		and two_days_before_payment
		and (not bool(state.get("financial_crisis_shown", false)) or refused_and_ready)
		and not bool(state.get("financial_slot_consumed", false))
		and not financial_crisis_event.is_empty()
		and weekly_balance_forecast() <= FINANCIAL_CRISIS_RESERVE
	)


func financial_rescue_survived_four_weeks() -> bool:
	var refusal_week := int(state.get("financial_crisis_refusal_week", 0))
	return (
		bool(state.get("financial_crisis_survival_pending", false))
		and refusal_week > 0
		and int(state.get("week", 1)) >= refusal_week + 4
		and float(state.get("money", 0.0)) > 0.0
	)


func armistice_took_effect_this_week(was_at_war: bool, was_signed: bool) -> bool:
	return was_at_war and not was_signed and bool(state.get("war_armistice_signed", false)) and not bool(state.get("at_war", false))


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
		+ (1 if should_trigger_foreign_minister_resignation() else 0)
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
		if int(state.get("week", 1)) == 1:
			show_tutorial_briefing("week_end", "ПЕРВАЯ НЕДЕЛЯ ЗАВЕРШЕНА", "Теперь все три доклада рассмотрены. Выбранные последствия и обязательные выплаты применятся, когда вы нажмёте «Новая неделя» справа. Перед этим можно ещё проверить ожидаемые голубые изменения слева.")
		return
	next_event(false)
	if int(state.get("week", 1)) == 1 and events_resolved_this_week == 1:
		var first_data: Dictionary = TUTORIAL_WEEK_BRIEFINGS[1]
		show_tutorial_briefing("chapter_1", str(first_data["title"]), str(first_data["body"]))


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
		current_event["body_en"] = "Twenty-six weeks of acting as president are over. You entered the election as %s, with the count prepared under %s rules. The current forecast is %s, but the final vote share will only be known after the polls close. Your last decision will determine which result the republic recognizes as legitimate." % [game_localization.text(election_campaign_name(str(state.get("election_campaign", "")))), game_localization.text(election_rules_name(rules)), game_localization.text(forecast)]
		var election_memory: Dictionary = preload("res://scripts/campaign_arcs.gd").election_memory(str(state.get("campaign_arc_legacy", "")))
		if not election_memory.is_empty():
			current_event["body"] += "\n\n" + str(election_memory["ru"])
			current_event["body_en"] += "\n\n" + str(election_memory["en"])
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
	var option_flags: Dictionary = (option.get("set", {}) as Dictionary).duplicate(true)
	if bool(option_flags.get("printed_money", false)):
		play_game_sound("money_print")
	var free_foreign_appointment := str(option_flags.get("free_foreign_appointment", ""))
	if free_foreign_appointment != "":
		apply_free_foreign_appointment(free_foreign_appointment)
		option_flags.erase("free_foreign_appointment")
	var applied_effects := queue_week_change(change_source, decision_effects, option_flags)
	event_resolved = true
	events_resolved_this_week += 1
	autosave_if_iron()
	# Не обновляем боковые показатели до показа результата. Их новые ожидаемые
	# значения и анимация появятся только после закрытия окна «Решение принято»,
	# когда игрок снова окажется на основном экране.
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
	if bool(option_flags.get("financial_crisis_ignored", false)):
		state.financial_crisis_refusal_week = int(state.get("week", 1))
		state.financial_crisis_survival_pending = true
	elif bool(option_flags.get("printed_money", false)) or bool(option_flags.get("fund_debt", false)):
		state.financial_crisis_ignored = false
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
	if bool(option_flags.get("opposition_returned_free", false)) or bool(option_flags.get("opposition_returned_detained", false)) or bool(option_flags.get("opposition_returned_debate", false)):
		schedule_story_followup("opposition_return", 2)
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
		elif key in ["population_total", "population_workable", "army_personnel", "army_equipment", "army_aircraft"]:
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
	var supply_oil := int(state.get("oil_to_army", 0)) + imported_army_fuel_bonus()
	var supply := clampi(roundi(float(supply_oil) / float(oil_need) * 100.0), 0, 100)
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
	return projected_pending_value("population_total")


func projected_workable_population() -> int:
	return mini(
		projected_pending_value("population_workable"),
		maxi(0, projected_total_population() - projected_pending_value("army_personnel"))
	)


func projected_dependent_population() -> int:
	return maxi(0, projected_total_population() - projected_workable_population() - projected_pending_value("army_personnel"))


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
		elif key in ["population_total", "population_workable", "army_personnel", "army_equipment", "army_aircraft"]:
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
	for key in ["population_total", "population_workable", "army_personnel", "army_equipment", "army_aircraft"]:
		if state.has(key):
			state[key] = maxi(0, int(state[key]))
	state.population_total = maxi(int(state.get("army_personnel", 0)), int(state.get("population_total", 0)))
	state.population_workable = clampi(int(state.get("population_workable", 0)), 0, maxi(0, int(state.population_total) - int(state.get("army_personnel", 0))))
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
	if language_code == "en":
		if value > CLAN_LOW_SUPPORT and value < CLAN_HIGH_SUPPORT:
			return "No recurring weekly effect"
		var critical_high_en := value >= CLAN_CRITICAL_HIGH_SUPPORT
		var high_en := value >= CLAN_HIGH_SUPPORT
		match key:
			"clan_oligarchs":
				var gross_en := 3.0 if critical_high_en else 1.5 if high_en else -4.0 if value <= CLAN_CRITICAL_LOW_SUPPORT else -2.0
				return "Treasury %+.2f M per week" % adjusted_money_transaction(gross_en, int(state.get("corruption_tier", 0)))
			"clan_church":
				if high_en:
					var cadence := "every two weeks" if not critical_high_en and bool(state.get("secular_education", false)) else "per week"
					return "War support +%d %s; population +%s per month" % [church_war_support_effect(value), cadence, format_people(monthly_church_population_bonus(value))]
				return "Government support %d per week" % church_public_support_effect(value)
			"clan_workers":
				return "Government support %+d per week" % workers_public_support_effect(value)
			"clan_regions":
				return "Stability %+d per week" % regional_stability_effect(value)
		return "No recurring weekly effect"
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
				return "поддержка войны +%d каждую неделю; население +%s раз в месяц" % [church_war_support_effect(value), format_people(monthly_church_population_bonus(value))]
			if high:
				if bool(state.get("secular_education", false)):
					return "поддержка войны +1 раз в две недели; население +%s раз в месяц" % format_people(monthly_church_population_bonus(value))
				var war_effect := church_war_support_effect(value)
				return "поддержка войны +%d каждую неделю; население +%s раз в месяц" % [war_effect, format_people(monthly_church_population_bonus(value))]
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
	if language_code == "en":
		var influence_note_en := "; secular education halves the Church's public effects" if key == "clan_church" and bool(state.get("secular_education", false)) else ""
		return "%s%s; %s gets %+d on parliamentary votes" % [clan_weekly_effect_description(key, value), influence_note_en, game_localization.text(clan_parliament_faction_title(key)), modifier]
	var influence_note := "; светское образование уменьшает общественные эффекты Церкви вдвое" if key == "clan_church" and bool(state.get("secular_education", false)) else ""
	return "%s%s; фракция «%s» получает %+d к позиции на голосованиях" % [clan_weekly_effect_description(key, value), influence_note, clan_parliament_faction_title(key), modifier]


func clan_support_levels_tooltip(key: String, title: String, current_value: int, projected_value: int) -> String:
	var lines: Array[String] = []
	var display_title := game_localization.text(title) if language_code == "en" else title
	if current_value != projected_value:
		lines.append(pending_value_tooltip(display_title, "%d%%" % current_value, "%d%%" % projected_value))
	else:
		lines.append("%s: %d%%" % [display_title, current_value])
	lines.append("Faction: %s" % game_localization.text(clan_parliament_faction_title(key)) if language_code == "en" else "Фракция: %s" % clan_parliament_faction_title(key))
	lines.append("")
	var levels := [
		{"range": "0–20%", "min": 0, "max": 20, "sample": 10},
		{"range": "21–40%", "min": 21, "max": 40, "sample": 30},
		{"range": "41–59%", "min": 41, "max": 59, "sample": 50},
		{"range": "60–79%", "min": 60, "max": 79, "sample": 70},
		{"range": "80–100%", "min": 80, "max": 100, "sample": 90}
	]
	for level in levels:
		var sample := int(level["sample"])
		var marker := "► " if projected_value >= int(level["min"]) and projected_value <= int(level["max"]) else "  "
		lines.append("%s%s · %s" % [marker, str(level["range"]), game_localization.text(clan_band(sample)) if language_code == "en" else clan_band(sample)])
		var weekly_effect := clan_weekly_effect_description(key, sample)
		if language_code == "en":
			lines.append("  %s; faction %+d" % [weekly_effect, clan_position_modifier(sample)])
		else:
			weekly_effect = weekly_effect.replace("поддержка власти", "власть").replace("поддержка войны", "война")
			weekly_effect = weekly_effect.replace("каждую неделю", "/нед.").replace("раз в месяц", "/мес.")
			weekly_effect = weekly_effect.replace("раз в две недели", "/2 нед.").replace("постоянного недельного эффекта нет", "без недельного эффекта")
			lines.append("  %s; фракция %+d" % [weekly_effect, clan_position_modifier(sample)])
	if key == "clan_church" and bool(state.get("secular_education", false)):
		lines.append("Secular education weakens the Church's effects." if language_code == "en" else "Светское образование ослабляет эффекты Церкви.")
	return compact_tooltip("\n".join(lines))


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
	continue_button.set_meta("ui_click_sound", "")
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
		"debt": "Государственный долг", "creditor_obligations": "Обязательства перед кредиторами",
		"population_total": "Население", "population_workable": "Работоспособное население",
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
			var population_keys := ["population_total", "population_workable", "army_personnel"]
			if key in population_keys:
				parts.append("%s %s%s" % [names[key], "+" if value > 0 else "−" if value < 0 else "", format_people(absi(value))])
			elif key == "debt":
				parts.append("%s %s%d млн" % [names[key], "+" if value > 0 else "", value])
			else:
				parts.append("%s %s%d" % [names[key], "+" if value > 0 else "", value])
	return " • ".join(parts) if not parts.is_empty() else "Числовых изменений нет."


func corruption_level(value: int) -> String:
	return CORRUPTION_LABELS[clampi(value, 0, CORRUPTION_LABELS.size() - 1)]


func corruption_levels_tooltip(current_tier: int) -> String:
	if language_code == "en":
		var english_lines: Array[String] = ["CORRUPTION · LOST REVENUE", "Each treasury income is reduced by category:"]
		for tier in range(CORRUPTION_LABELS.size()):
			english_lines.append("%s%s: −%d%% of income" % ["► " if tier == current_tier else "  ", game_localization.text(CORRUPTION_LABELS[tier]).capitalize(), CORRUPTION_TRANSACTION_RATES[tier]])
		english_lines.append("")
		english_lines.append("Corruption does not change expenses, prices or decision points.")
		return compact_tooltip("\n".join(english_lines))
	var lines: Array[String] = ["КОРРУПЦИЯ · ПОТЕРИ ДОХОДОВ", "Каждое поступление в казну уменьшается по категории:"]
	for tier in range(CORRUPTION_LABELS.size()):
		lines.append("%s%s: −%d%% дохода" % ["► " if tier == current_tier else "  ", CORRUPTION_LABELS[tier].capitalize(), CORRUPTION_TRANSACTION_RATES[tier]])
	lines.append("")
	lines.append("Расходы, цены и очки решений коррупция не меняет.")
	return compact_tooltip("\n".join(lines))


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
	if language_code == "en":
		var english_lines: Array[String] = [game_localization.text(title)]
		if calculation != "":
			english_lines.append(game_localization.text(calculation))
		if gross_amount > 0.0:
			english_lines.append("Income before corruption: %.2f M" % gross_amount)
			english_lines.append("Corruption (%s): income −%d%%" % [game_localization.text(corruption_level(corruption_tier)), rate])
		elif gross_amount < 0.0:
			english_lines.append("Base expense: %.2f M" % absf(gross_amount))
			english_lines.append("Corruption does not change expenses or prices.")
		else:
			english_lines.append("Amount: 0.00 M")
		english_lines.append("Total: %.2f M" % absf(final_amount))
		return "\n".join(english_lines)
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
	var level_multiplier := budget_level_multiplier(key, level)
	var planned := budget_amount_by_key(key)
	var final_amount := absf(adjusted_money_transaction(-planned, corruption_tier))
	var base_calculation := "Базовая потребность: %.2f млн" % raw_need
	if key == "budget_social":
		base_calculation = "База: %s неработоспособных × %.2f млн за 1 млн = %.2f млн" % [format_people(dependent_population()), SOCIAL_DEPENDENT_COST_PER_MILLION, raw_need]
	elif key == "budget_health":
		base_calculation = "База: %s жителей × 0,35 млн за 1 млн = %.2f млн" % [format_people(total_population()), raw_need]
	if language_code == "en":
		var calculation_en := "Base need: %.2f M" % raw_need
		if key == "budget_social":
			calculation_en = "Base: %s dependents × %.2f M per million = %.2f M" % [format_people(dependent_population()), SOCIAL_DEPENDENT_COST_PER_MILLION, raw_need]
		elif key == "budget_health":
			calculation_en = "Base: %s residents × 0.35 M per million = %.2f M" % [format_people(total_population()), raw_need]
		return "%s\n%s\n%s\n%s\nFunding level %s: ×%.2f = %.2f M\nCorruption does not affect expenses or prices.\nTotal: %.2f M per week" % [
			game_localization.text(str(item.get("title", "Расход"))), game_localization.text(str(item.get("impact", ""))),
			budget_level_consequence_text(key, level), calculation_en, game_localization.text(BUDGET_LEVEL_NAMES[level]), level_multiplier, planned, final_amount
		]
	return "%s\n%s\n%s\n%s\nУровень «%s»: ×%.2f = %.2f млн\nКоррупция «%s»: на расходы и цены не влияет\nИтого: %.2f млн в неделю" % [
		str(item.get("title", "Расход")), str(item.get("impact", "")), budget_level_consequence_text(key, level), base_calculation,
		BUDGET_LEVEL_NAMES[level], level_multiplier, planned, corruption_level(corruption_tier),
		final_amount
	]


func budget_level_consequence_text(key: String, level: int) -> String:
	if language_code == "en":
		match key:
			"budget_social":
				return ["Every 2 weeks: government support −1, unions −2. A cut can trigger protests when support is low.", "Covers current needs with no recurring bonus or penalty.", "Every 2 weeks: government support +1, unions +2."][level]
			"budget_health":
				return ["Labor taxes −10%; stability −1 every 2 weeks; each week reduces monthly population by 3 K, including 2.7 K workers; wartime personnel losses +25%.", "Normal labor taxes. No recurring change to population, stability or wartime losses. The monthly result uses all 4 weeks of funding.", "Labor taxes +8%; stability +1 every 2 weeks; each week adds 3 K to monthly population, including 2.7 K workers; wartime personnel losses −20%."][level]
			"budget_admin":
				return "%d decision points at the start of each week. Stability of 70+ adds 1; stability of 30 or less removes 1." % [2, 3, 4][level]
			"budget_defense":
				return ["Army loyalty −1 every 2 weeks, or weekly during a military threat. Equipment production is halved.", "Covers current needs with no recurring bonus or penalty.", "Army loyalty +2 every 2 weeks; equipment production increases."][level]
			"budget_debt":
				var rate_en := debt_weekly_interest_rate()
				if level == 0:
					return "Debt +8 M. Weekly interest rate %.3f%% → %.3f%%. Future payments rise permanently and creditor terms tighten." % [debt_weekly_interest_percent(rate_en), debt_weekly_interest_percent(rate_en + DEBT_UNDERPAY_RATE_INCREASE)]
				if level == 1:
					return "Principal and weekly interest rate %.3f%% stay unchanged." % debt_weekly_interest_percent(rate_en)
				return "Payments above interest reduce principal. Weekly rate %.3f%% → %.3f%% (floor %.2f%%). Early payments cost more, but sustained priority lowers later payments. Creditor terms ease every fourth week." % [debt_weekly_interest_percent(rate_en), debt_weekly_interest_percent(maxf(DEBT_MIN_WEEKLY_RATE, rate_en - DEBT_PRIORITY_RATE_DECREASE)), debt_weekly_interest_percent(DEBT_MIN_WEEKLY_RATE)]
			"budget_infrastructure":
				return ["Regions −1 weekly; stability −1 every 4 weeks.", "Covers current needs with no recurring bonus or penalty.", "Regions +2 every 2 weeks; stability +1 every 4 weeks."][level]
		return ""
	if key == "budget_social":
		return ["Последствие: раз в 2 недели −1 к поддержке и −2 к профсоюзам; при низкой поддержке сокращение может вызвать протест.", "Последствие: покрывает текущую потребность без постоянного бонуса или штрафа.", "Последствие: раз в 2 недели +1 к поддержке и +2 к профсоюзам."][level]
	if key == "budget_health":
		return ["Последствие: налоги от труда −10%; раз в 2 недели стабильность −1; каждая неделя сокращения даёт −3 тыс. к месячному населению (−2,7 тыс. работоспособных); людские потери на войне +25%.", "Последствие: обычные налоги от труда; без изменения месячного населения, стабильности и военных потерь. Месячный итог учитывает все 4 недели финансирования.", "Последствие: налоги от труда +8%; раз в 2 недели стабильность +1; каждая неделя приоритета даёт +3 тыс. к месячному населению (+2,7 тыс. работоспособных); людские потери на войне −20%."][level]
	if key == "budget_admin":
		var base_points: int = [2, 3, 4][level]
		var stability_note := " Высокая стабильность даёт ещё +1 очко." if high_stability_influence_bonus() > 0 else " Низкая стабильность отнимает 1 очко." if low_stability_influence_penalty() > 0 else " При стабильности 70 и выше добавится ещё +1 очко, при 30 и ниже будет отнято 1."
		return "Последствие: %d очк. решений в начале недели.%s" % [base_points, stability_note]
	if key == "budget_defense":
		return ["Последствие: −1 к лояльности армии раз в 2 недели, а при военной угрозе — каждую неделю; выпуск техники работает вполовину.", "Последствие: покрывает текущую потребность без постоянного бонуса или штрафа.", "Последствие: раз в 2 недели +2 к лояльности армии; выпуск техники ускорен."][level]
	if key == "budget_debt":
		var current_rate := debt_weekly_interest_rate()
		if level == 0:
			var increased_rate := current_rate + DEBT_UNDERPAY_RATE_INCREASE
			return "Последствие: долг +8 млн, недельная ставка %.3f%% → %.3f%%. Следующие платежи постоянно дорожают; действующие условия кредиторов становятся жёстче." % [debt_weekly_interest_percent(current_rate), debt_weekly_interest_percent(increased_rate)]
		if level == 1:
			return "Последствие: основной долг и недельная ставка %.3f%% не меняются." % debt_weekly_interest_percent(current_rate)
		var reduced_rate := maxf(DEBT_MIN_WEEKLY_RATE, current_rate - DEBT_PRIORITY_RATE_DECREASE)
		return "Последствие: часть платежа сверх процентов уменьшает основной долг; недельная ставка %.3f%% → %.3f%% (минимум %.2f%%). Первые выплаты дороже, но длительный приоритет уменьшает следующие платежи; каждая четвёртая неделя смягчает условия кредиторов." % [debt_weekly_interest_percent(current_rate), debt_weekly_interest_percent(reduced_rate), debt_weekly_interest_percent(DEBT_MIN_WEEKLY_RATE)]
	if key == "budget_infrastructure":
		return ["Последствие: каждую неделю −1 к регионам; раз в 4 недели ещё −1 к стабильности.", "Последствие: покрывает текущую потребность без постоянного бонуса или штрафа.", "Последствие: раз в 2 недели +2 к регионам; раз в 4 недели +1 к стабильности."][level]
	return ""


func total_population() -> int:
	return int(state.get("population_total", 0))


func workable_population() -> int:
	return int(state.get("population_workable", 0))


func dependent_population() -> int:
	return maxi(0, total_population() - workable_population() - int(state.get("army_personnel", 0)))


func format_people(value: int) -> String:
	if value >= 1000000:
		return "%.2f M" % (float(value) / 1000000.0) if language_code == "en" else "%.2f млн" % (float(value) / 1000000.0)
	return "%d K" % roundi(float(value) / 1000.0) if language_code == "en" else "%d тыс." % roundi(float(value) / 1000.0)


func format_people_en(value: int) -> String:
	return "%.2f M" % (float(value) / 1000000.0) if value >= 1000000 else "%d K" % roundi(float(value) / 1000.0)


func recruitment_target() -> int:
	var adult_citizens := workable_population() + int(state.get("army_personnel", 0))
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


func war_stability_loss(war_support_override := -1) -> int:
	var value := int(state.get("war_support", 0)) if war_support_override < 0 else war_support_override
	if value <= WAR_SUPPORT_LOW:
		return 4
	if value >= WAR_SUPPORT_HIGH:
		return 1
	return 2


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


func war_casualty_support_loss(personnel_loss: int, personnel_before: int) -> int:
	var casualty_share := float(personnel_loss) / float(maxi(personnel_before, 1))
	return 2 if casualty_share >= 0.06 else 1 if casualty_share >= 0.03 else 0


func health_workforce_tax_multiplier(level_override := -1) -> float:
	var level := budget_level("budget_health") if level_override < 0 else clampi(level_override, 0, 2)
	return HEALTH_WORKFORCE_TAX_MULTIPLIERS[level]


func monthly_health_population_change(level_override := -1) -> int:
	if level_override >= 0:
		return [-MONTHLY_HEALTH_POPULATION_CHANGE, 0, MONTHLY_HEALTH_POPULATION_CHANGE][clampi(level_override, 0, 2)]
	return clampi(int(state.get("health_funding_balance", 0)), -4, 4) * HEALTH_POPULATION_WEEK_DELTA


func record_health_funding_week() -> void:
	state.health_funding_balance = clampi(int(state.get("health_funding_balance", 0)) + budget_level("budget_health") - 1, -4, 4)


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
	return clampi(roundi(float(int(state.get("oil_to_army", 0)) + imported_army_fuel_bonus()) / float(army_oil_need()) * 100.0), 0, 100)


func imported_army_fuel_bonus() -> int:
	return KRES_IMPORTED_FUEL_BONUS if agreement_weeks_left("kres_fuel_supply_until_week") > 0 else 0


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


func at_war_with(side: String) -> bool:
	return bool(state.get("at_war", false)) and side in [str(state.get("war_enemy", "")), str(state.get("war_second_enemy", ""))]


func two_front_war_active() -> bool:
	return bool(state.get("at_war", false)) and str(state.get("war_second_enemy", "")) in ["east", "west"]


func war_opponents_text() -> String:
	var primary := str(state.get("war_enemy", "east"))
	return "%s и %s" % [neighbor_title(primary), neighbor_title(str(state.get("war_second_enemy", "west")))] if two_front_war_active() else neighbor_title(primary)


func frontline_required_personnel(quality := -1) -> int:
	var effective_quality := army_quality_effectiveness() if quality < 0 else clampi(quality, 0, 100)
	# Хорошо обученная и полностью оснащённая армия способна держать тот же фронт
	# меньшим числом людей. Даже при идеальном качестве требуется минимум 35 тысяч.
	var shortened_front := mini(3, maxi(0, int(state.get("war_frontline_reductions", 0)))) * WAR_SHORTENED_FRONT_REDUCTION
	var single_front := maxi(35000, roundi(110000.0 - float(effective_quality) * 750.0) - shortened_front)
	return roundi(float(single_front) * 1.45) if two_front_war_active() else single_front


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
	if language_code == "en":
		return "Defense cost breakdown:\nStanding services: 0.40 M\nPersonnel (%s): %.2f M\nGround equipment maintenance: %.2f M\nImported aircraft maintenance: %.2f M\nGround equipment orders: %.2f M\nBase need: %.2f M\nFunding level %s: ×%.2f = %.2f M\nCorruption does not affect expenses or prices.\nTotal: %.2f M" % [game_localization.text(str(model.get("title", "Смешанная"))), personnel_cost, equipment_cost, aviation_cost, orders_cost, raw_total, game_localization.text(BUDGET_LEVEL_NAMES[level]), budget_level_multiplier("budget_defense", level), planned, final_amount]
	return "Почему оборона стоит именно столько:\nПостоянные службы: 0.40 млн\nЛичный состав (%s): %.2f млн\nСодержание наземной техники: %.2f млн\nСодержание импортной авиации: %.2f млн\nЗаказ наземной техники: %.2f млн\nПотребность до уровня бюджета: %.2f млн\nУровень «%s»: ×%.2f = %.2f млн\nКоррупция «%s»: на расходы и цены не влияет\nИтого: %.2f млн" % [
		str(model.get("title", "Смешанная")), personnel_cost, equipment_cost, aviation_cost,
		orders_cost, raw_total, BUDGET_LEVEL_NAMES[level], budget_level_multiplier("budget_defense", level), planned,
		corruption_level(corruption_tier), final_amount
	]


func production_order_cost() -> float:
	return snappedf(float(state.get("metal_to_equipment", 0)) * 0.15, 0.01)


func equipment_order_final_cost(corruption_tier: int) -> float:
	var planned := production_order_cost() * budget_level_multiplier("budget_defense", budget_level("budget_defense"))
	return absf(adjusted_money_transaction(-planned, corruption_tier))


func equipment_lost_export_income(corruption_tier: int) -> float:
	var forgone_gross := float(state.get("metal_to_equipment", 0)) * current_metal_price()
	return adjusted_money_transaction(forgone_gross, corruption_tier)


func equipment_balance_load(corruption_tier: int) -> float:
	return snappedf(equipment_order_final_cost(corruption_tier) + equipment_lost_export_income(corruption_tier), 0.01)


func equipment_production_tooltip(corruption_tier: int) -> String:
	if language_code == "en":
		return "Production and weekly cost breakdown:\nMetal allocated: %d of %d%s\nBase output: 2 equipment units per metal unit\nIndustrial control: ×%.2f%s\nDefense funding (%s): output ×%.2f\nOutput: %d units\nDirect order expense after funding: %.2f M (corruption does not raise it)\nLost metal export income after corruption: %.2f M\nTotal weekly balance cost: %.2f M" % [
			int(state.get("metal_to_equipment", 0)), current_metal_output(),
			" (privatization removes 2 production units)" if bool(state.get("raw_sector_privatized", false)) else "",
			strategic_industry_equipment_multiplier(), " — nationalized factories" if bool(state.get("strategic_industry_nationalized", false)) else "",
			game_localization.text(BUDGET_LEVEL_NAMES[budget_level("budget_defense")]), production_factor(), equipment_production_per_week(),
			equipment_order_final_cost(corruption_tier), equipment_lost_export_income(corruption_tier), equipment_balance_load(corruption_tier)
		]
	return "Почему выпуск и нагрузка на баланс именно такие:\nВыделено металла: %d из %d%s\nБазовый выпуск: 2 ед. техники на 1 ед. металла\nКонтроль промышленности: ×%.2f%s\nФинансирование обороны «%s»: выпуск ×%.2f\nВыпуск: %d ед.\nПрямой расход по заказу после уровня бюджета: %.2f млн (коррупция его не увеличивает)\nУпущенный доход от экспорта металла после потерь от коррупции: %.2f млн\nОбщая нагрузка на недельный баланс: %.2f млн" % [
		int(state.get("metal_to_equipment", 0)), current_metal_output(),
		" (приватизация забирает 2 ед. добычи)" if bool(state.get("raw_sector_privatized", false)) else "",
		strategic_industry_equipment_multiplier(), " — национализированные заводы" if bool(state.get("strategic_industry_nationalized", false)) else "",
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


func budget_level_multiplier(key: String, level: int) -> float:
	var multipliers: Array = BUDGET_LEVEL_MULTIPLIERS.get(key, [0.70, 1.0, 1.40])
	return float(multipliers[clampi(level, 0, 2)])


func debt_weekly_interest_rate() -> float:
	return maxf(DEBT_MIN_WEEKLY_RATE, float(state.get("debt_weekly_interest_rate", DEBT_INITIAL_WEEKLY_RATE)))


func debt_weekly_interest_percent(rate_override := -1.0) -> float:
	var rate := debt_weekly_interest_rate() if rate_override < 0.0 else rate_override
	return rate * 100.0


func debt_service_amount(debt_override := -1.0, rate_override := -1.0, level_override := -1) -> float:
	var debt_value := float(state.get("debt", 0.0)) if debt_override < 0.0 else debt_override
	var rate := debt_weekly_interest_rate() if rate_override < 0.0 else rate_override
	var level := budget_level("budget_debt") if level_override < 0 else clampi(level_override, 0, 2)
	var base_payment := maxf(0.5, snappedf(debt_value * rate, 0.01))
	return snappedf(base_payment * budget_level_multiplier("budget_debt", level), 0.01)


func budget_base_amount(key: String, total_override := -1, dependents_override := -1) -> float:
	var population_value := total_population() if total_override < 0 else total_override
	var dependents_value := dependent_population() if dependents_override < 0 else dependents_override
	if key == "budget_social":
		return snappedf(float(dependents_value) / 1000000.0 * SOCIAL_DEPENDENT_COST_PER_MILLION, 0.01)
	if key == "budget_health":
		return float(population_value) / 1000000.0 * 0.35
	if key == "budget_admin":
		return 0.85
	if key == "budget_defense":
		return army_base_cost()
	if key == "budget_debt":
		return maxf(0.5, snappedf(float(state.get("debt", 0.0)) * debt_weekly_interest_rate(), 0.01))
	if key == "budget_infrastructure":
		return 0.55
	return 0.0


func budget_amount_by_key(key: String) -> float:
	return snappedf(budget_base_amount(key) * budget_level_multiplier(key, budget_level(key)), 0.01)


func budget_final_for_level(key: String, level: int, corruption_tier: int) -> float:
	var planned := snappedf(budget_base_amount(key) * budget_level_multiplier(key, level), 0.01)
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


func neighbor_title_en(side: String) -> String:
	return "Eastern Union" if side == "east" else "Western Federation"


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
	if language_code == "en":
		var band_en := str({"враждебные": "hostile", "натянутые": "strained", "средние": "normal", "партнёрские": "cooperative"}.get(band, "normal"))
		var response_en := "Routine diplomatic contact continues. Improving relations with this neighbor by one level will worsen relations with the other by one level."
		if band == "партнёрские":
			response_en = "This neighbor is willing to discuss military aid and long-term agreements. Relations cannot improve beyond this level."
		elif band == "натянутые":
			response_en = "This neighbor is increasing demands, inspections and economic pressure. A further decline will trigger an invasion when the week ends."
		elif band == "враждебные":
			response_en = "Diplomatic options have run out. If war has not begun, an invasion will follow when the week ends."
		return "%s: %s relations. %s" % [neighbor_title_en(side), band_en, response_en]
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


func foreign_concession_minister_id(side: String) -> String:
	return "kres" if side == "east" else "varek"


func foreign_concession_minister_name(side: String) -> String:
	return str(minister_data("foreign", foreign_concession_minister_id(side)).get("name", "нужный министр"))


func foreign_concession_available(side: String) -> bool:
	return str(selected_ministers.get("foreign", "narin")) == foreign_concession_minister_id(side)


func active_foreign_dependencies() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if agreement_weeks_left("east_energy_discount_until_week") > 0:
		result.append({"title": "Восточная энергетическая скидка", "effect": "+1.40 млн валовой выгоды в неделю", "detail": "Льготная цена действует ещё %d нед. Восточный Союз использует поставки как рычаг для новых политических требований." % agreement_weeks_left("east_energy_discount_until_week"), "color": GOLD})
	if agreement_weeks_left("west_market_access_until_week") > 0:
		result.append({"title": "Ускоренный доступ к западному рынку", "effect": "+1.20 млн валового дохода в неделю", "detail": "Доступ действует ещё %d нед. Продление зависит от выполнения институциональных и торговых условий Западной Федерации." % agreement_weeks_left("west_market_access_until_week"), "color": BLUE})
	if agreement_weeks_left("kres_fuel_supply_until_week") > 0:
		result.append({"title": "Восточный топливный клиринг", "effect": "+%d ед. импортного топлива для армии" % KRES_IMPORTED_FUEL_BONUS, "detail": "Поставки действуют ещё %d нед. Импортное топливо прибавляется к армейскому снабжению, но не считается собственной нефтью и не может быть продано." % agreement_weeks_left("kres_fuel_supply_until_week"), "color": GOLD})
	if bool(state.get("narin_crisis_channel_armed", false)):
		result.append({"title": "Кризисный канал Леи Нарин", "effect": "Одно вторжение будет отложено на две недели", "detail": "Если отношения с соседом станут враждебными при завершении недели, канал даст две полные игровые недели для дипломатического выхода. Отношения останутся враждебными и сами не улучшатся.", "color": GREEN})
	elif int(state.get("narin_crisis_delay_weeks", 0)) > 0:
		result.append({"title": "Кризисный канал Леи Нарин", "effect": "До вторжения остаётся %d нед." % (int(state.get("narin_crisis_delay_weeks", 0)) + 1), "detail": "Отношения уже враждебные. Если их не улучшить до завершения отсрочки, сосед начнёт вторжение.", "color": RED})
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


func schedule_foreign_minister_resignation_if_needed() -> void:
	if bool(state.get("foreign_minister_resignation_pending", false)) or bool(state.get("foreign_minister_resignation_shown", false)):
		return
	var minister_id := str(selected_ministers.get("foreign", "narin"))
	if not foreign_minister_conflicts_with_war(minister_id):
		return
	state.foreign_minister_resignation_pending = true
	state.resigning_foreign_minister = minister_id


func should_trigger_foreign_minister_resignation() -> bool:
	schedule_foreign_minister_resignation_if_needed()
	return (
		bool(state.get("at_war", false))
		and bool(state.get("foreign_minister_resignation_pending", false))
		and not bool(state.get("foreign_minister_resignation_shown", false))
	)


func free_foreign_replacement_effects(candidate_id: String) -> Dictionary:
	var candidate := minister_data("foreign", candidate_id)
	if candidate.is_empty():
		return {}
	return minister_initial_effects("foreign", candidate_id, candidate)


func free_foreign_replacement_option(candidate_id: String) -> Dictionary:
	var candidate := minister_data("foreign", candidate_id)
	var candidate_name := str(candidate.get("name", "Кандидат"))
	var effects := free_foreign_replacement_effects(candidate_id)
	var alignment_hint := "Нейтральный дипломатический курс сохранится."
	if candidate_id == "varek":
		alignment_hint = relation_improvement_summary("west")
	elif candidate_id == "kres":
		alignment_hint = relation_improvement_summary("east")
	return option(
		"Назначить: %s" % candidate_name,
		"Без голосования и очков решений • %s" % alignment_hint,
		effects,
		"%s принял%s пост министра иностранных дел без парламентского голосования и платы очками решений. Война потребовала немедленной замены, поэтому правительство оформило назначение как временное, но со всеми обычными полномочиями министра." % [candidate_name, "а" if candidate_id in ["narin", "kres"] else ""],
		{
			"free_foreign_appointment": candidate_id,
			"foreign_minister_resignation_pending": false,
			"resigning_foreign_minister": ""
		}
	)


func build_foreign_minister_resignation_event() -> Dictionary:
	var outgoing_id := str(state.get("resigning_foreign_minister", selected_ministers.get("foreign", "")))
	var outgoing := minister_data("foreign", outgoing_id)
	var outgoing_name := str(outgoing.get("name", "Министр иностранных дел"))
	var enemy := "west" if outgoing_id == "varek" and at_war_with("west") else "east" if outgoing_id == "kres" and at_war_with("east") else str(state.get("war_enemy", "east"))
	var body := "%s передаёт президенту заявление об отставке. Министр объясняет, что годами строил политическую карьеру на сближении с государством «%s» и теперь не может убедительно представлять правительство, которое ведёт с ним войну. Отставка добровольная, но дипломатическое ведомство нельзя оставить без руководителя: из двух оставшихся доступных кандидатов нужно немедленно назначить преемника." % [outgoing_name, neighbor_title(enemy)]
	var candidates: Array[String] = []
	for raw_candidate in MINISTER_CANDIDATES.get("foreign", []):
		var candidate: Dictionary = raw_candidate
		var candidate_id := str(candidate.get("id", ""))
		if candidate_id != outgoing_id and not is_minister_locked("foreign", candidate):
			candidates.append(candidate_id)
	if candidates.size() < 2:
		push_error("Для срочной замены министра иностранных дел требуется два доступных кандидата.")
		return {}
	return event(
		outgoing_name,
		"diplomat",
		"#a9473f",
		"Отставка во время войны",
		body,
		free_foreign_replacement_option(candidates[0]),
		free_foreign_replacement_option(candidates[1])
	)


func apply_free_foreign_appointment(candidate_id: String) -> void:
	var candidate := minister_data("foreign", candidate_id)
	if candidate.is_empty() or is_minister_locked("foreign", candidate):
		return
	selected_ministers.foreign = candidate_id
	var appointed: Dictionary = state.get("appointed_ministers", {})
	var seen_candidates: Array = appointed.get("foreign", [])
	if candidate_id not in seen_candidates:
		seen_candidates.append(candidate_id)
		appointed["foreign"] = seen_candidates
		state.appointed_ministers = appointed
	state.last_parliament_vote = "После добровольной отставки прежнего главы МИД должность без голосования получает %s." % str(candidate.get("name", "Кандидат"))
	state.last_parliament_vote_detail = "Назначение не потребовало голосования парламента и не потратило очки решений."


func build_war_crisis_event() -> Dictionary:
	var enemy := str(state.get("war_enemy", "east"))
	var other := "west" if enemy == "east" else "east"
	var enemy_name := neighbor_title(enemy)
	var other_name := neighbor_title(other)
	var report := str(state.get("last_war_report", "Первые сообщения с границы ещё уточняются."))
	var required := frontline_required_personnel()
	var personnel := int(state.get("army_personnel", 0))
	var body := "На рассвете войска государства «%s» пересекли границу и атаковали пограничные части. Дипломатические отношения больше не действуют: республика находится в состоянии войны. Генеральный штаб требует немедленно выбрать, чем закрыть первый разрыв фронта.\n\n%s\n\nДля удержания линии при текущем качестве армии требуется не менее %s военнослужащих; в строю осталось %s." % [enemy_name, report, format_people(required), format_people(personnel)]
	var body_en := "At dawn, troops from the %s crossed the border and attacked frontier units. Diplomatic relations have ended: the republic is at war. The General Staff needs an immediate answer to the first breach.\n\n%s\n\nHolding the line at the army's current readiness requires at least %s troops. %s remain in service." % [neighbor_title_en(enemy), str(state.get("last_war_report_en", "The General Staff is still assessing the first losses.")), format_people_en(required), format_people_en(personnel)]
	var mobilization := option(
		"Начать экстренную мобилизацию",
		"25 тыс. человек перейдут из гражданской экономики в армию • поддержка, стабильность и поддержка войны снизятся • лояльность штаба вырастет",
		{"population_workable": -25000, "army_personnel": 25000, "support": -6, "stability": -3, "war_support": -4, "army": 4},
		"Правительство объявило экстренную мобилизацию. Военкоматы получили списки работоспособных граждан, предприятия лишились части смен, а первые пополнения направились к линии фронта без полного цикла подготовки.",
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
	aid["label_en"] = "REQUEST AID FROM THE %s" % neighbor_title_en(other)
	if neighbor_relation_band(other) in ["враждебные", "натянутые"]:
		aid["unavailable"] = true
		aid["hint"] = "НЕДОСТУПНО: отношения с государством «%s» слишком плохи для срочной военной помощи." % other_name
	if two_front_war_active():
		var second_body := "После вторжения государства «%s» границу пересекли и войска государства «%s». Республика воюет на двух фронтах. Генштабу теперь нужно не менее %s военнослужащих; в строю %s. Потери людей и техники на каждой неделе выросли. Нужно решить, где взять резерв для новой линии обороны." % [enemy_name, other_name, format_people(required), format_people(personnel)]
		var second_crisis := event("СОВЕТ ОБОРОНЫ", "military", "#a9473f", "Второй фронт", second_body, mobilization, procurement,
			option("Сократить линию обороны", "Армии потребуется меньше людей • поддержка, стабильность и приграничные регионы пострадают", {"support": -8, "stability": -6, "war_support": -4, "clan_regions": -12, "army": 3}, "Правительство приказало оставить несколько приграничных районов и сосредоточить части вокруг главных дорог. Фронт стал короче, но эвакуированные спрашивают, почему их дома не защищали.", {"war_frontline_retreat": true}))
		second_crisis["body_en"] = "After the %s invaded, troops from the %s crossed the other border. The republic is fighting on two fronts. The army now needs at least %s troops; %s remain in service. Personnel and equipment losses rise each week. The General Staff demands a new reserve." % [neighbor_title_en(enemy), neighbor_title_en(other), format_people_en(required), format_people_en(personnel)]
		return second_crisis
	var crisis := event("СОВЕТ ОБОРОНЫ", "military", "#a9473f", "Вторжение", body, mobilization, procurement, aid)
	crisis["body_en"] = body_en
	return crisis


func build_war_pressure_event() -> Dictionary:
	var war_week := int(state.get("war_weeks", 0))
	var enemy := str(state.get("war_enemy", "east"))
	var other := "west" if enemy == "east" else "east"
	var enemy_name := neighbor_title(enemy)
	var other_name := neighbor_title(other)
	var situation := "Идёт %d-я неделя войны. Противники: %s. Боеспособность — %d%%, личный состав — %s, поддержка войны — %d%%.\n\n%s" % [war_week, war_opponents_text(), army_effectiveness(), format_people(int(state.get("army_personnel", 0))), int(state.get("war_support", 0)), str(state.get("last_war_report", "Штаб уточняет потери."))]
	var opponents_en := "%s and the %s" % [neighbor_title_en(enemy), neighbor_title_en(other)] if two_front_war_active() else neighbor_title_en(enemy)
	var situation_en := "Week %d of the war with the %s. Combat readiness: %d%%; personnel: %s; war support: %d%%.\n\n%s" % [war_week, opponents_en, army_effectiveness(), format_people_en(int(state.get("army_personnel", 0))), int(state.get("war_support", 0)), str(state.get("last_war_report_en", "The General Staff is assessing the latest losses."))]
	if war_week <= 3:
		return war_pressure_event(situation_en, "The enemy is pressing three border towns at once. The General Staff can defend each town at the cost of equipment, shorten the front or arm territorial battalions.", event("СОВЕТ ОБОРОНЫ", "military", "#a9473f", "Тонкая линия", situation + "\n\nПротивник давит сразу на три приграничных города. Генштаб может удерживать каждый населённый пункт только ценой техники, сократить линию фронта либо раздать оружие территориальным батальонам.",
			option("Удерживать все города", "Крупные расходы и потери техники • поддержка войны и приграничья укрепятся", {"money": -8, "army_equipment": -10, "war_support": 4, "clan_regions": 6, "army": 2}, "Резервы разошлись по трём дорогам. Города остались под флагом республики, но ремонтные роты уже разбирают последние исправные машины на запчасти."),
			option("Сократить линию фронта", "Часть территории будет оставлена • фронту навсегда потребуется меньше людей • общество и регионы ответят резко", {"support": -7, "stability": -5, "war_support": -4, "clan_regions": -10, "army": 4}, "Армия отошла за реку и взорвала мосты. Новую линию удерживать проще, но жители оставленных районов увидели государственные флаги только на уходящих машинах.", {"war_frontline_retreat": true}),
			option("Вооружить территориальные батальоны", "Армия получит 8 тыс. человек • единое командование ослабнет • начнутся протесты против призыва", {"population_workable": -8000, "army_personnel": 8000, "army": -5, "war_support": -3, "clan_regions": 8}, "Губернаторы получили оружие и списки добровольцев. На фронте стало больше людей, однако часть батальонов принимает приказы только от местных администраций.", {"unrest": {"cause": "вооружение территориальных батальонов", "kind": "antiwar", "base_level": 1, "reversible": false}})))
	if war_week <= 7:
		return war_pressure_event(situation_en, "Front-line brigades have not been relieved. Commanders demand a paid rotation; the government can keep them in place or call up another wave of reservists.", event("ГЕНЕРАЛЬНЫЙ ШТАБ", "military", "#a9473f", "Ротация, которой нет", situation + "\n\nПередовые бригады находятся в окопах без смены. Командиры требуют оплачиваемую ротацию, правительство может оставить части на позициях либо вызвать новую волну резервистов.",
			option("Провести полную ротацию", "Большие расходы и дополнительный износ техники • лояльность армии и поддержка укрепятся", {"money": -9, "army_equipment": -4, "army": 6, "support": 2, "war_support": 2}, "Бригады вывели с позиций, выплатили задержанные надбавки и заменили свежими частями. Железные дороги встали под воинскими эшелонами, но солдаты впервые за месяцы увидели семьи."),
			option("Отменить ротацию", "Казна и резерв сохранятся • армия и общественная готовность продолжать войну резко упадут", {"army": -8, "war_support": -5, "support": -3}, "Приказ о смене отменили за ночь. Части остались на позициях, а командиры начали скрывать число самовольных уходов, чтобы не получить обвинение в потере управления."),
			option("Призвать десять тысяч резервистов", "Фронт получит людей • экономика, профсоюзы и поддержка войны пострадают • начнётся антивоенный протест", {"population_workable": -10000, "army_personnel": 10000, "support": -5, "war_support": -6, "clan_workers": -7, "stability": -2}, "Повестки отправили на заводы и в учебные центры. Новые батальоны закрыли ротацию, но рабочие комитеты объявили, что правительство заменяет военную стратегию бесконечным набором людей.", {"unrest": {"cause": "новая волна призыва резервистов", "kind": "antiwar", "base_level": 2, "reversible": false}})))
	if war_week <= 11:
		if two_front_war_active():
			return war_pressure_event(situation_en, "Both fronts are running short of ammunition. Convert civilian plants to military orders, buy equipment through neutral intermediaries, or ration artillery fire.", event("ВОЕННО-ПРОМЫШЛЕННАЯ КОМИССИЯ", "official", "#8b6c4b", "Снарядный голод", situation + "\n\nОба фронта расходуют боеприпасы быстрее заводского выпуска. Можно перевести гражданские предприятия на военные заказы, закупить технику через нейтральных посредников либо приказать армии экономить огонь.",
				option("Перевести заводы на военные рельсы", "Армия получит технику • рабочие ответят тяжёлой забастовкой", {"money": -7, "army_equipment": 22, "support": -4, "stability": -3, "clan_workers": -12}, "Заводы сняли гражданские заказы и отправили новые машины на оба фронта.", {"unrest": {"cause": "принудительный перевод заводов на военные рельсы", "kind": "labor", "labor": true, "base_level": 2, "reversible": false}}),
				option("Купить через посредников", "Очень крупные расходы • техника и два самолёта без дипломатических уступок", {"money": -14, "army_equipment": 16, "army_aircraft": 2, "support": -3}, "Нейтральные посредники доставили технику без официальных переговоров с соседями."),
				option("Ввести лимит боеприпасов", "На три недели потери техники уменьшатся • лояльность армии и поддержка войны упадут", {"army": -6, "war_support": -5}, "Оба фронта получили приказ беречь боеприпасы; пехота требует объяснить, как удержать позиции с новым лимитом.", {"war_ammo_conservation": true})))
		var foreign_supply_effects := {"money": -11, "army_equipment": 16, "army_aircraft": 2, "support": -3}
		merge_numeric_effects(foreign_supply_effects, relation_shift_effect(other, 1))
		return war_pressure_event(situation_en, "Ammunition is leaving the depots faster than factories can replace it. Convert civilian plants to military orders, buy an urgent shipment from the %s or order the army to ration fire." % neighbor_title_en(other), event("ВОЕННО-ПРОМЫШЛЕННАЯ КОМИССИЯ", "official", "#8b6c4b", "Снарядный голод", situation + "\n\nСклады расходуют боеприпасы быстрее заводского выпуска. Можно перевести гражданские предприятия на военные заказы, купить срочную партию у государства «%s» либо приказать армии экономить огонь." % other_name,
			option("Перевести заводы на военные рельсы", "Армия получит 22 единицы техники • потребуются деньги • рабочие ответят тяжёлой забастовкой", {"money": -7, "army_equipment": 22, "support": -4, "stability": -3, "clan_workers": -12}, "Гражданские заказы сняли с линий, смены продлили без согласования. Первые машины ушли на фронт, а проходные крупнейших предприятий утром оказались закрыты рабочими.", {"unrest": {"cause": "принудительный перевод заводов на военные рельсы", "kind": "labor", "labor": true, "base_level": 2, "reversible": false}}),
			option("Купить иностранную партию", "Очень крупные расходы • техника и два самолёта • отношения с оставшимся соседом улучшатся ценой зависимости", foreign_supply_effects, "Груз прибыл без опознавательных знаков. Республика получила машины и самолёты, а военная миссия государства «%s» — постоянный кабинет рядом с оперативным штабом." % other_name, {"foreign_wartime_supply": other}),
			option("Ввести лимит боеприпасов", "На три недели потери техники уменьшатся на 35% • лояльность армии и поддержка войны упадут", {"army": -6, "war_support": -5}, "Артиллерии разрешили отвечать только после подтверждения цели двумя наблюдателями. Склады перестали пустеть, но пехота считает, что правительство экономит металл ценой её жизней.", {"war_ammo_conservation": true})))
	if war_week <= 15:
		return war_pressure_event(situation_en, "Hospitals are full, and medical trains are stuck behind military traffic. Pay for priority evacuation, return lightly wounded soldiers to service, or conceal casualty lists and clear civilian hospitals by decree.", event("ВОЕННО-МЕДИЦИНСКАЯ СЛУЖБА", "official", "#536f82", "Коридор для раненых", situation + "\n\nГоспитали переполнены, санитарные эшелоны стоят вместе с военными. Можно оплатить приоритетную эвакуацию, вернуть легкораненых в строй либо засекретить списки потерь и освободить гражданские больницы приказом.",
			option("Оплатить медицинский коридор", "Очень крупные расходы • на три недели людские потери уменьшатся на 25% • поддержка войны немного восстановится", {"money": -11, "support": 3, "war_support": 4}, "Отдельные санитарные поезда получили зелёный коридор, а гражданские клиники — военные авансы. Раненых стали вывозить быстрее, но казначейство предупредило, что такой режим невозможно оплачивать постоянно.", {"war_medical_priority": true}),
			option("Вернуть легкораненых в строй", "Армия немедленно получит 5 тыс. человек • лояльность, поддержка и порядок пострадают", {"army_personnel": 5000, "army": -7, "support": -4, "stability": -2, "war_support": -4}, "Медицинские комиссии переписали категории годности. Пять тысяч человек вернулись в части, многие — с незажившими ранами и публичными письмами к семьям."),
			option("Засекретить списки потерь", "Поддержка власти резко упадёт • военные настроения временно укрепятся • авторитарный курс и протест усилятся", {"support": -8, "stability": 3, "war_support": 3, "authoritarian": 1}, "Больницы перестали сообщать фамилии, а похороны провели без прессы. На несколько дней сводки стали спокойнее, затем родственники собрали собственный список и вышли к министерству.", {"unrest": {"cause": "засекречивание списков военных потерь", "kind": "antiwar", "base_level": 2, "reversible": false}})))
	return war_pressure_event(situation_en, "Ordinary reserves are exhausted. High command proposes general mobilization, another withdrawal from a district, or moving garrisons away from rear areas and critical infrastructure.", event("СТАВКА ВЕРХОВНОГО КОМАНДОВАНИЯ", "military", "#a9473f", "Последний резерв", situation + "\n\nОбычные резервы исчерпаны. Ставка предлагает общую мобилизацию, новый отход с оставлением ещё одного района либо снятие частей с охраны тыла и критической инфраструктуры.",
		option("Объявить общую мобилизацию", "Армия получит 20 тыс. человек • экономика и все общественные показатели рухнут • начнутся крупные протесты", {"population_workable": -20000, "army_personnel": 20000, "support": -9, "stability": -5, "war_support": -8, "army": 5, "clan_workers": -8}, "Военкоматы получили право останавливать транспорт и проверять документы. Фронт пополнился, но заводы потеряли смены, а города заполнили семьи мобилизованных.", {"unrest": {"cause": "общая мобилизация после истощения резервов", "kind": "antiwar", "base_level": 3, "reversible": false}}),
		option("Оставить ещё один район", "Фронту навсегда потребуется на 8 тыс. меньше людей • поддержка, стабильность и регионы понесут катастрофический удар", {"support": -10, "stability": -7, "war_support": -6, "clan_regions": -14, "army": 5}, "Армия отошла на следующую естественную преграду. Карта фронта стала короче, а карта контролируемой республики — ещё меньше; колонны беженцев движутся к столице.", {"war_frontline_retreat": true}),
		option("Снять гарнизоны с тыла", "Фронт получит 7 тыс. человек • лояльность штаба, порядок и регионы резко ослабнут", {"population_workable": -7000, "army_personnel": 7000, "army": -10, "stability": -6, "clan_regions": -10, "war_support": -3}, "Охрану мостов, складов и электростанций отправили на передовую. Генштаб получил людей, а губернаторы начали создавать собственные караулы без разрешения центра.")))


func war_pressure_event(situation_en: String, detail_en: String, report_event: Dictionary) -> Dictionary:
	report_event["body_en"] = situation_en + "\n\n" + detail_en
	return report_event


func start_invasion_if_needed() -> String:
	if bool(state.get("at_war", false)):
		return open_second_front_if_needed()
	if neighbor_relation_band("east") == "натянутые" or neighbor_relation_band("west") == "натянутые":
		state.military_threat = true
	var enemy := hostile_neighbor_for_invasion()
	if enemy == "":
		return ""
	if str(state.get("war_ceasefire_enemy", "")) == enemy and int(state.get("week", 1)) <= int(state.get("war_ceasefire_until_week", 0)):
		state.military_threat = true
		return "Договор о перемирии удержал государство «%s» от нового вторжения; защита действует до конца %d-й недели." % [neighbor_title(enemy), int(state.get("war_ceasefire_until_week", 0))]
	if bool(state.get("narin_crisis_channel_armed", false)):
		state.narin_crisis_channel_armed = false
		state.narin_crisis_channel_used = true
		state.narin_crisis_delay_weeks = NARIN_CRISIS_DELAY_WEEKS
	if int(state.get("narin_crisis_delay_weeks", 0)) > 0:
		state.narin_crisis_delay_weeks = int(state.get("narin_crisis_delay_weeks", 0)) - 1
		state.military_threat = true
		var action_weeks_left := int(state.get("narin_crisis_delay_weeks", 0)) + 1
		state.last_foreign_action = "Кризисный канал сдерживает вторжение государства «%s». Отношения остаются враждебными; на дипломатический выход осталось %d нед." % [neighbor_title(enemy), action_weeks_left]
		return "Лея Нарин удержала кризисный канал открытым и отложила вторжение государства «%s». На улучшение отношений осталось %d нед." % [neighbor_title(enemy), action_weeks_left]
	state.at_war = true
	state.war_ever_started = true
	state.military_threat = true
	state.war_enemy = enemy
	state.war_second_enemy = ""
	var rally_effects := apply_effects({"support": WAR_DEFENSIVE_RALLY_SUPPORT, "war_support": WAR_DEFENSIVE_RALLY_WAR_SUPPORT})
	var rally_gain := int(rally_effects.get("support", 0))
	var resistance_gain := int(rally_effects.get("war_support", 0))
	schedule_foreign_minister_resignation_if_needed()
	state.war_started_week = int(state.get("week", 1))
	state.war_weeks = 0
	state.war_crisis_pending = true
	state.war_crisis_shown = false
	state.war_pressure_next_week = WAR_PRESSURE_INTERVAL
	state.war_frontline_reductions = 0
	state.war_frontline_pressure = 0
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
	var rally_note := " Перед лицом вторжения общество сплотилось: поддержка власти +%d, поддержка войны +%d." % [rally_gain, resistance_gain] if rally_gain > 0 or resistance_gain > 0 else ""
	state.last_war_report = "%s начал вторжение после перехода отношений во враждебное состояние.%s%s" % [neighbor_title(enemy), dependency_note, rally_note]
	var first_front_note := "%s разорвал дипломатические гарантии и начал вторжение. Республика вступила в войну.%s%s" % [neighbor_title(enemy), dependency_note, rally_note]
	var second_front_note := open_second_front_if_needed()
	return first_front_note + (" " + second_front_note if second_front_note != "" else "")


func open_second_front_if_needed() -> String:
	if not bool(state.get("at_war", false)) or two_front_war_active():
		return ""
	var primary := str(state.get("war_enemy", ""))
	if primary not in ["east", "west"]:
		return ""
	var second := "west" if primary == "east" else "east"
	if neighbor_relation_band(second) != "враждебные":
		return ""
	if str(state.get("war_ceasefire_enemy", "")) == second and int(state.get("week", 1)) <= int(state.get("war_ceasefire_until_week", 0)):
		return ""
	state.war_second_enemy = second
	state.war_ever_started = true
	schedule_foreign_minister_resignation_if_needed()
	state.war_crisis_pending = true
	state.war_crisis_shown = false
	var shock := apply_effects({"support": -5, "stability": -5, "war_support": -4})
	var note := "%s открыл второй фронт. Республика ведёт войну с обоими соседями; поддержка власти −%d, стабильность −%d, поддержка войны −%d." % [neighbor_title(second), absi(int(shock.get("support", 0))), absi(int(shock.get("stability", 0))), absi(int(shock.get("war_support", 0)))]
	state.last_war_report = note
	state.last_war_report_en = "The %s opened a second front. The republic is now at war with both neighbors." % neighbor_title_en(second)
	if unlock_special_achievement("two_front_war"):
		note += " Достижение открыто: «Между двух огней»."
		state.last_war_report_en += " Achievement unlocked: Caught Between Two Fronts."
	return note


func process_war_week(defer_effects := false) -> Dictionary:
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
	var fronts_multiplier := 1.45 if two_front_war_active() else 1.0
	var personnel_loss := mini(personnel_before, maxi(0, roundi(float(personnel_loss_before_medicine) * medical_multiplier * duration_personnel_multiplier * fronts_multiplier)))
	var equipment_before := int(state.get("army_equipment", 0))
	var equipment_loss_base := 1.0 + float(100 - combat_effectiveness) / 22.0 + shortage_ratio * 4.0
	var equipment_loss := mini(equipment_before, maxi(0, roundi(equipment_loss_base * duration_equipment_multiplier * temporary_ammo_conservation_multiplier() * fronts_multiplier)))
	state.war_weeks = war_week
	var aircraft_before := int(state.get("army_aircraft", 0))
	var aircraft_loss := 1 if aircraft_before > 0 else 0
	if combat_effectiveness < 35 and aircraft_before - aircraft_loss > 0:
		aircraft_loss += 1
	if combat_effectiveness <= 10 and aircraft_before - aircraft_loss > 0:
		aircraft_loss += 1
	if two_front_war_active() and aircraft_before - aircraft_loss > 0:
		aircraft_loss += 1
	aircraft_loss = mini(aircraft_before, aircraft_loss)
	state.army_personnel = personnel_before - personnel_loss
	state.population_total = maxi(0, total_population() - personnel_loss)
	state.army_equipment = equipment_before - equipment_loss
	state.army_aircraft = aircraft_before - aircraft_loss
	state.war_casualties = int(state.get("war_casualties", 0)) + personnel_loss
	var fatigue_loss := war_fatigue_loss(war_week)
	var support_before_battles := int(state.get("war_support", 0))
	var stability_loss := war_stability_loss(support_before_battles)
	var political_effects := {"war_support": -fatigue_loss - (1 if two_front_war_active() else 0), "stability": -stability_loss - (1 if two_front_war_active() else 0)}
	var casualty_support_loss := war_casualty_support_loss(personnel_loss, personnel_before)
	if casualty_support_loss > 0:
		political_effects["support"] = -casualty_support_loss
	var high_support_note := ""
	if int(state.get("war_support", 0)) >= WAR_SUPPORT_HIGH:
		political_effects["army"] = 1
		high_support_note = " Высокая поддержка войны укрепила лояльность армии на 1."
	if shortage_ratio > 0.0:
		political_effects["stability"] = int(political_effects["stability"]) - (1 if shortage_ratio < 0.25 else 2)
		political_effects["support"] = int(political_effects.get("support", 0)) - 1
	var frontline_pressure := int(state.get("war_frontline_pressure", 0))
	var pressure_note := ""
	if combat_effectiveness < 25 and war_week >= 4:
		frontline_pressure = mini(6, frontline_pressure + 1)
		political_effects["stability"] = int(political_effects["stability"]) - 1
		political_effects["war_support"] = int(political_effects["war_support"]) - 1
		political_effects["clan_regions"] = -2
		state.population_total = maxi(int(state.get("army_personnel", 0)), total_population() - 1500)
		state.population_workable = maxi(0, workable_population() - 750)
		pressure_note = " Фронт ниже 25%%: из прифронтовых районов уехали 1 500 человек, регионы −2, стабильность −1, поддержка войны −1. Военное разорение теперь стоит %.2f млн в неделю." % (float(frontline_pressure) * 0.45)
	elif combat_effectiveness >= 40 and frontline_pressure > 0:
		frontline_pressure -= 1
		pressure_note = " Укрепление фронта сократило военное разорение до %.2f млн в неделю." % (float(frontline_pressure) * 0.45)
	state.war_frontline_pressure = frontline_pressure
	if not defer_effects:
		apply_effects(political_effects)
	var coverage_percent := clampi(roundi(float(personnel_before) / float(maxi(required, 1)) * 100.0), 0, 100)
	var shortage_stability_loss := absi(int(political_effects["stability"])) - stability_loss - (1 if two_front_war_active() else 0)
	var escalation_note := " Истощение войны: людские потери ×%.2f, потери техники ×%.2f, поддержка войны −%d. Поддержка войны перед боями %d%%: стабильность −%d%s." % [duration_personnel_multiplier, duration_equipment_multiplier * temporary_ammo_conservation_multiplier(), fatigue_loss, support_before_battles, stability_loss, "; нехватка людей на фронте добавила ещё −%d" % shortage_stability_loss if shortage_ratio > 0.0 else ""]
	if two_front_war_active():
		escalation_note += " Второй фронт: потребность в людях и боевые потери ×1.45; поддержка войны и стабильность дополнительно −1."
	var casualty_note := " Большие потери среди военнослужащих: поддержка власти −%d." % casualty_support_loss if casualty_support_loss > 0 else ""
	var medicine_note := " Медицинское обеспечение: ×%.2f к людским потерям." % medical_multiplier
	var report := "%s • неделя войны %d. Боеспособность перед боями: %d%%. Фронту требовалось %s, имелось %s (%d%%). Потери: %s военнослужащих, %d техники, %d авиации.%s%s%s%s%s" % [war_opponents_text(), int(state.get("war_weeks", 0)), combat_effectiveness, format_people(required), format_people(personnel_before), coverage_percent, format_people(personnel_loss), equipment_loss, aircraft_loss, escalation_note, casualty_note, medicine_note, high_support_note, pressure_note]
	state.last_war_report = report
	var report_enemy_en := "%s and the %s" % [neighbor_title_en(enemy), neighbor_title_en(str(state.get("war_second_enemy", "west")))] if two_front_war_active() else neighbor_title_en(enemy)
	var report_en := "%s • war week %d. Readiness before battle: %d%%. The front needed %s troops; %s were available (%d%%). Losses: %s personnel, %d vehicles, %d aircraft. War attrition: personnel ×%.2f, vehicles ×%.2f. War support −%d; stability −%d." % [report_enemy_en, int(state.get("war_weeks", 0)), combat_effectiveness, format_people_en(required), format_people_en(personnel_before), coverage_percent, format_people_en(personnel_loss), equipment_loss, aircraft_loss, duration_personnel_multiplier, duration_equipment_multiplier * temporary_ammo_conservation_multiplier(), fatigue_loss, absi(int(political_effects["stability"]))]
	if casualty_support_loss > 0:
		report_en += " Heavy casualties reduced government support by %d." % casualty_support_loss
	if pressure_note != "":
		report_en += " Pressure on the front increased the economic burden."
	if two_front_war_active():
		report_en += " The second front increased troop requirements and multiplied personnel and vehicle losses by 1.45."
	state.last_war_report_en = report_en
	return {
		"note": report,
		"personnel_loss": personnel_loss,
		"casualty_support_loss": casualty_support_loss,
		"equipment_loss": equipment_loss,
		"aircraft_loss": aircraft_loss,
		"political_effects": political_effects,
		"stability_loss": absi(int(political_effects["stability"])),
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
	if bool(state.get("at_war", false)) and int(state.get("war_frontline_pressure", 0)) > 0:
		var pressure_cost := float(int(state.get("war_frontline_pressure", 0))) * 0.45
		result.append({"title": "Разорение прифронтовых районов", "amount": -pressure_cost, "calculation": "Каждая неделя с боеспособностью фронта ниже 25% накапливает 0,45 млн еженедельных расходов, максимум 2,70 млн. При боеспособности от 40% ущерб постепенно сокращается."})
	if bool(state.get("war_armistice_signed", false)):
		result.append({"title": "Выплаты по перемирию", "amount": -0.60, "calculation": "Согласованное прекращение огня требует 0,60 млн в неделю на компенсации и международный контроль до конца кампании."})
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


func weekly_income_breakdown(strike_level_override := -1, workforce_override := -1) -> Array[Dictionary]:
	var strike_level := strike_level_override
	if strike_level < 0:
		strike_level = int(state.get("active_unrest_level", 0)) if bool(state.get("active_unrest_labor", false)) else 0
	strike_level = clampi(strike_level, 0, 3)
	var labor_tax_multiplier := 1.0
	var state_enterprise_multiplier := 1.0
	var export_multiplier := 1.0
	var collective_agreements := bool(state.get("collective_bargaining_law", false))
	if strike_level == 1:
		labor_tax_multiplier = 0.95 if collective_agreements else 0.90
		state_enterprise_multiplier = 0.85 if collective_agreements else 0.75
	elif strike_level == 2:
		labor_tax_multiplier = 0.90 if collective_agreements else 0.80
		state_enterprise_multiplier = 0.85 if collective_agreements else 0.75
	elif strike_level >= 3:
		labor_tax_multiplier = 0.80 if collective_agreements else 0.65
		state_enterprise_multiplier = 0.70 if collective_agreements else 0.50
		export_multiplier = 0.90 if collective_agreements else 0.80
	var strike_suffix := ""
	if strike_level > 0:
		strike_suffix = " После влияния состояния «%s»%s." % [unrest_level_title(strike_level, true), " и закона о коллективных договорах" if collective_agreements else ""]
	var workforce_value := workable_population() if workforce_override < 0 else workforce_override
	var health_tax_multiplier := health_workforce_tax_multiplier()
	var labor_calculation := "%s работоспособных × %.2f млн за 1 млн человек × %.0f%% (образование и медицина)" % [format_people(workforce_value), WORKFORCE_TAX_PER_MILLION, health_tax_multiplier * 100.0]
	if language_code == "en":
		labor_calculation = "%s workers × %.2f M per million people × %.0f%% (education and healthcare)" % [format_people(workforce_value), WORKFORCE_TAX_PER_MILLION, health_tax_multiplier * 100.0]
	if strike_level > 0:
		labor_calculation += " × %.0f%% (%s)" % [labor_tax_multiplier * 100.0, game_localization.text(unrest_level_title(strike_level, true)) if language_code == "en" else unrest_level_title(strike_level, true)]
	var enterprise_base := state_enterprise_base_income()
	var enterprise_calculation := "Базовая перечисляемая прибыль %.2f млн%s × %.0f%%%s" % [
		enterprise_base,
		" (включая +%.2f млн от национализированной промышленности)" % NATIONALIZED_STATE_ENTERPRISE_INCOME_BONUS if bool(state.get("strategic_industry_nationalized", false)) else "",
		state_enterprise_multiplier * 100.0,
		strike_suffix
	]
	var result: Array[Dictionary] = [
		{"title": "Налоги работоспособных", "amount": snappedf(float(workforce_value) / 1000000.0 * WORKFORCE_TAX_PER_MILLION * labor_tax_multiplier * health_tax_multiplier, 0.01), "calculation": labor_calculation},
		{"title": "Налог на бизнес", "amount": 1.0, "calculation": "Текущая базовая ставка налога на бизнес"},
		{"title": "Государственные предприятия", "amount": snappedf(enterprise_base * state_enterprise_multiplier, 0.01), "calculation": enterprise_calculation},
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


func state_enterprise_base_income() -> float:
	return 0.5 + (NATIONALIZED_STATE_ENTERPRISE_INCOME_BONUS if bool(state.get("strategic_industry_nationalized", false)) else 0.0)


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
	# Preview the same sequence as advance_week on disposable copies. Flags can
	# change the budget, exports, war state and recruitment before the bills arrive.
	var live_state := state
	var live_pending := pending_week_changes
	var live_budget_draft := budget_draft
	state = live_state.duplicate(true)
	pending_week_changes = live_pending.duplicate(true)
	budget_draft = live_budget_draft.duplicate(true)
	var unrest_snapshot := active_unrest_snapshot()
	var strike_level := int(unrest_snapshot.get("level", 0)) if bool(unrest_snapshot.get("labor", false)) else 0
	resolve_pending_week_changes()
	enforce_creditor_budget_lock()
	start_invasion_if_needed()
	process_army_recruitment()
	process_military_production()
	process_war_week()
	var tier := int(state.get("corruption_tier", 0))
	for item in weekly_income_breakdown(strike_level):
		state.money = snappedf(float(state.money) + adjusted_money_transaction(float(item.get("amount", 0.0)), tier), 0.01)
	for item in WEEKLY_BUDGET_LINES:
		state.money = snappedf(float(state.money) + adjusted_money_transaction(-budget_amount_by_key(str(item.get("key", ""))), tier), 0.01)
	for item in weekly_nonbudget_expense_breakdown():
		state.money = snappedf(float(state.money) + adjusted_money_transaction(float(item.get("amount", 0.0)), tier), 0.01)
	state.money = snappedf(float(state.money) + adjusted_money_transaction(weekly_clan_money_flow(), tier), 0.01)
	var result := float(state.money)
	state = live_state
	pending_week_changes = live_pending
	budget_draft = live_budget_draft
	return result


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


func monthly_church_population_bonus(value_override := -1) -> int:
	var value := int(state.get("clan_church", 50)) if value_override < 0 else value_override
	var base := MONTHLY_CHURCH_POPULATION_BONUS * 2 if value >= CLAN_CRITICAL_HIGH_SUPPORT else MONTHLY_CHURCH_POPULATION_BONUS if value >= CLAN_HIGH_SUPPORT else 0
	return roundi(float(base) * church_influence_scale())


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
		notes.append("Церковь благословила государственный курс: поддержка войны +%d; семейные и приходские программы дают население +%s при месячном пересчёте." % [church_war_support_effect(church), format_people(monthly_church_population_bonus(church))])
	elif church >= CLAN_HIGH_SUPPORT:
		var war_effect := church_war_support_effect(church)
		if war_effect > 0:
			notes.append("Церковь поддержала государственный курс: поддержка войны +%d; семейные и приходские программы дают население +%s при месячном пересчёте." % [war_effect, format_people(monthly_church_population_bonus(church))])
		else:
			notes.append("Церковь поддержала семьи прихожан: население +%s при месячном пересчёте; после светского образования бонус поддержки войны приходит раз в две недели." % format_people(monthly_church_population_bonus(church)))
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
	if language_code == "en":
		var weekly_effect_en := "No recurring weekly effect"
		if value >= 80:
			weekly_effect_en = "Combat readiness +10 points"
		elif value >= 65:
			weekly_effect_en = "Combat readiness +5 points"
		elif value <= 20:
			weekly_effect_en = "Combat readiness −15 points"
		elif value <= 40:
			weekly_effect_en = "Combat readiness −7 points"
		var parliament_effect_en := "The Old Guard receives no army modifier"
		if army_parliament_modifier(value) > 0:
			parliament_effect_en = "The Old Guard gets +1 on votes; this does not stack with the hardline bonus"
		elif army_parliament_modifier(value) < 0:
			parliament_effect_en = "The Old Guard gets −1 on votes"
		return "%s; %s" % [weekly_effect_en, parliament_effect_en]
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


func army_loyalty_levels_tooltip(current_value: int, projected_value: int) -> String:
	var lines: Array[String] = []
	if current_value != projected_value:
		lines.append(pending_value_tooltip("Army loyalty" if language_code == "en" else "Лояльность армии", "%d%%" % current_value, "%d%%" % projected_value))
	else:
		lines.append("Army loyalty: %d%%" % current_value if language_code == "en" else "Лояльность армии: %d%%" % current_value)
	lines.append("")
	var levels := [
		{"range": "0–20%", "min": 0, "max": 20, "sample": 10},
		{"range": "21–40%", "min": 21, "max": 40, "sample": 30},
		{"range": "41–64%", "min": 41, "max": 64, "sample": 50},
		{"range": "65–79%", "min": 65, "max": 79, "sample": 70},
		{"range": "80–100%", "min": 80, "max": 100, "sample": 90}
	]
	for level in levels:
		var sample := int(level["sample"])
		var marker := "► " if projected_value >= int(level["min"]) and projected_value <= int(level["max"]) else "  "
		lines.append("%s%s · %s" % [marker, str(level["range"]), game_localization.text(army_group_band(sample)) if language_code == "en" else army_group_band(sample)])
		var combat_bonus := 10 if sample >= 80 else 5 if sample >= 65 else -15 if sample <= 20 else -7 if sample <= 40 else 0
		lines.append("  Combat readiness %+d points; Old Guard %+d" % [combat_bonus, army_parliament_modifier(sample)] if language_code == "en" else "  Боеспособность %+d п.п.; Гвардия %+d" % [combat_bonus, army_parliament_modifier(sample)])
	return compact_tooltip("\n".join(lines))


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
		var requested := mini(mini(difference, speed), workable_population())
		if speed_multiplier < 1.0:
			evaders = maxi(0, mini(difference, base_speed) - requested)
		state.population_workable = workable_population() - requested
		state.army_personnel = current + requested
		recruited = requested
	elif difference < 0:
		demobilized = mini(-difference, speed)
		state.army_personnel = current - demobilized
		state.population_workable = workable_population() + demobilized
	var deserters := 0
	var desertion_rate := wartime_desertion_rate()
	if bool(state.get("at_war", false)) and desertion_rate > 0.0:
		var mobilization_multiplier := 1.5 if str(state.get("recruitment_model", "mixed")) == "mobilization" else 1.0
		var duration_multiplier := 1.0 + float(mini(int(state.get("war_weeks", 0)), 12)) * 0.05
		deserters = mini(int(state.get("army_personnel", 0)), maxi(100, roundi(float(state.get("army_personnel", 0)) * desertion_rate * mobilization_multiplier * duration_multiplier)))
		state.army_personnel = int(state.get("army_personnel", 0)) - deserters
		state.population_workable = workable_population() + deserters
	var notes: Array[String] = []
	if speed_multiplier > 1.0 and recruited > 0:
		notes.append("Высокая поддержка войны ускорила набор до %d%% обычного темпа." % roundi(speed_multiplier * 100.0))
	if evaders > 0:
		notes.append("Из-за низкой поддержки войны от призыва уклонились %s потенциальных новобранцев." % format_people(evaders))
	if deserters > 0:
		notes.append("Из частей дезертировали %s военнослужащих; они вернулись в работоспособное население." % format_people(deserters))
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


func strategic_industry_equipment_multiplier() -> float:
	return NATIONALIZED_EQUIPMENT_OUTPUT_MULTIPLIER if bool(state.get("strategic_industry_nationalized", false)) else 1.0


func equipment_production_per_week() -> int:
	return maxi(0, roundi(float(state.get("metal_to_equipment", 0)) * 2.0 * production_factor() * strategic_industry_equipment_multiplier()))


func process_military_production() -> Dictionary:
	var equipment_gain := equipment_production_per_week()
	state.army_equipment = int(state.get("army_equipment", 0)) + equipment_gain
	return {"equipment": equipment_gain}


func process_weekly_budget_consequences(closed_week: int, effect_collector: Dictionary = {}, defer_effects := false) -> Array[String]:
	var effects: Dictionary = {}
	var notes: Array[String] = []
	if int(state.get("support", 0)) + int(effect_collector.get("support", 0)) >= 70:
		effects["stability"] = int(effects.get("stability", 0)) + 1
		notes.append("Поддержка власти не ниже 70%: общественное спокойствие укрепило стабильность на 1.")
	if budget_level("budget_social") == 0 and closed_week % 2 == 0:
		effects["support"] = int(effects.get("support", 0)) - 1
		effects["clan_workers"] = int(effects.get("clan_workers", 0)) - 2
		notes.append("Задержки части социальных выплат: поддержка власти −1.")
		notes.append("Профсоюзы выступили против сокращения социальной помощи: отношение −2.")
	elif budget_level("budget_social") == 2 and closed_week % 2 == 0:
		effects["support"] = int(effects.get("support", 0)) + 1
		effects["clan_workers"] = int(effects.get("clan_workers", 0)) + 2
		notes.append("Приоритетная социальная помощь: поддержка власти +1.")
		notes.append("Профсоюзы поддержали расширение социальной помощи: отношение +2.")
	if budget_level("budget_health") == 0 and closed_week % 2 == 0:
		effects["stability"] = int(effects.get("stability", 0)) - 1
		notes.append("Накопившиеся перебои в школах и больницах: стабильность −1.")
	elif budget_level("budget_health") == 2 and closed_week % 2 == 0:
		effects["stability"] = int(effects.get("stability", 0)) + 1
		notes.append("Приоритет школ и больниц: стабильность +1.")
	if budget_level("budget_defense") == 0:
		var defense_loss := 1 if bool(state.get("military_threat", false)) or closed_week % 2 == 0 else 0
		if defense_loss > 0:
			effects["army"] = int(effects.get("army", 0)) - defense_loss
			notes.append("Сокращённое финансирование армии: лояльность командования −%d." % defense_loss)
	elif budget_level("budget_defense") == 2 and closed_week % 2 == 0:
		effects["army"] = int(effects.get("army", 0)) + 2
		notes.append("Приоритетное финансирование армии: лояльность штаба +2.")
	if budget_level("budget_infrastructure") == 0:
		effects["clan_regions"] = int(effects.get("clan_regions", 0)) - 1
		if closed_week % 4 == 0:
			effects["stability"] = int(effects.get("stability", 0)) - 1
		notes.append("Регионы недовольны отложенными ремонтами: отношение −1.")
		if closed_week % 4 == 0:
			notes.append("Накопившиеся проблемы с инфраструктурой: стабильность −1.")
	elif budget_level("budget_infrastructure") == 2 and closed_week % 2 == 0:
		effects["clan_regions"] = int(effects.get("clan_regions", 0)) + 2
		notes.append("Регионы поддержали программу приоритетных ремонтов: отношение +2.")
		if closed_week % 4 == 0:
			effects["stability"] = int(effects.get("stability", 0)) + 1
			notes.append("Приоритетные ремонты повысили устойчивость инфраструктуры: стабильность +1.")
	if budget_level("budget_debt") == 0:
		state.creditor_priority_weeks = 0
		state.debt = snappedf(float(state.get("debt", 0.0)) + 8.0, 0.01)
		var previous_rate := debt_weekly_interest_rate()
		state.debt_weekly_interest_rate = snappedf(previous_rate + DEBT_UNDERPAY_RATE_INCREASE, 0.00001)
		notes.append("Недоплата кредиторам прибавила 8 млн к долгу и повысила недельную ставку с %.3f%% до %.3f%%." % [debt_weekly_interest_percent(previous_rate), debt_weekly_interest_percent()])
		if int(state.get("creditor_obligations", 0)) > 0:
			var previous_obligations := int(state.get("creditor_obligations", 0))
			state.creditor_obligations = mini(CREDITOR_OBLIGATION_LABELS.size() - 1, previous_obligations + 1)
			if int(state.get("creditor_obligations", 0)) != previous_obligations:
				notes.append("Нарушение условий займа ужесточило режим международных кредиторов до категории «%s»." % creditor_obligation_level(int(state.get("creditor_obligations", 0))))
	elif budget_level("budget_debt") == 2:
		var interest_due := maxf(0.5, snappedf(float(state.get("debt", 0.0)) * debt_weekly_interest_rate(), 0.01))
		var principal_payment := minf(float(state.get("debt", 0.0)), maxf(0.0, debt_service_amount() - interest_due))
		state.debt = maxf(0.0, snappedf(float(state.get("debt", 0.0)) - principal_payment, 0.01))
		var previous_rate := debt_weekly_interest_rate()
		state.debt_weekly_interest_rate = snappedf(maxf(DEBT_MIN_WEEKLY_RATE, previous_rate - DEBT_PRIORITY_RATE_DECREASE), 0.00001)
		if is_equal_approx(previous_rate, debt_weekly_interest_rate()):
			notes.append("Приоритетное обслуживание погасило %.2f млн основного долга; недельная ставка уже находится на минимуме %.2f%%." % [principal_payment, debt_weekly_interest_percent()])
		else:
			notes.append("Приоритетное обслуживание погасило %.2f млн основного долга и снизило недельную ставку с %.3f%% до %.3f%%." % [principal_payment, debt_weekly_interest_percent(previous_rate), debt_weekly_interest_percent()])
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
		if defer_effects:
			for key in effects.keys():
				effect_collector[key] = int(effect_collector.get(key, 0)) + int(effects[key])
		else:
			apply_effects(effects)
	return notes


func process_population_month() -> void:
	var population_before := total_population()
	var workable_before := workable_population()
	var church_change := monthly_church_population_bonus()
	var health_change := monthly_health_population_change()
	state.health_funding_balance = 0
	var total_change := church_change + health_change
	var workable_change := roundi(float(total_change) * NEW_POPULATION_WORKABLE_SHARE)
	state.population_total = maxi(int(state.get("army_personnel", 0)), population_before + total_change)
	state.population_workable = clampi(workable_before + workable_change, 0, maxi(0, total_population() - int(state.get("army_personnel", 0))))
	var population_after := total_population()
	var workable_after := workable_population()
	state.last_population_report = "Месячный пересчёт: Церковь %s%s • образование и медицина %s%s • население %s%s • работоспособные %s%s" % [
		"+" if church_change >= 0 else "−", format_people(absi(church_change)),
		"+" if health_change >= 0 else "−", format_people(absi(health_change)),
		"+" if population_after - population_before >= 0 else "−", format_people(absi(population_after - population_before)),
		"+" if workable_after - workable_before >= 0 else "−", format_people(absi(workable_after - workable_before))
	]


func request_end_week() -> void:
	if not week_ready_for_new_week():
		show_notice("Сначала нужно рассмотреть все доклады этой недели.")
		return
	advance_week()


func campaign_history_point() -> Dictionary:
	return {
		"week": maxi(0, int(state.get("week", 1)) - 1),
		"money": float(state.get("money", 0.0)),
		"population": total_population(),
		"workable": workable_population(),
		"debt": float(state.get("debt", 0.0)),
		"army": int(state.get("army_personnel", 0)),
		"equipment": int(state.get("army_equipment", 0)),
		"aircraft": int(state.get("army_aircraft", 0)),
		"support": int(state.get("support", 0)),
		"stability": int(state.get("stability", 0))
	}


func ensure_campaign_history() -> void:
	if not state.has("campaign_income"):
		state.campaign_income = 0.0
	if not state.has("campaign_expenses"):
		state.campaign_expenses = 0.0
	if not state.has("campaign_history") or not state.campaign_history is Array:
		state.campaign_history = []
	if (state.campaign_history as Array).is_empty():
		(state.campaign_history as Array).append(campaign_history_point())


func advance_week() -> void:
	if not week_ready_for_new_week():
		return
	close_overlay()
	var closed_week := int(state.get("week", 1))
	var was_at_war := bool(state.get("at_war", false))
	var armistice_was_signed := bool(state.get("war_armistice_signed", false))
	var opening_snapshot := weekly_report_snapshot()
	var opening_money := float(state.get("money", 0.0))
	var opening_population := total_population()
	ensure_campaign_history()
	var unrest_snapshot := active_unrest_snapshot()
	var strike_level_for_week := int(unrest_snapshot.get("level", 0)) if bool(unrest_snapshot.get("labor", false)) else 0
	var decision_resolution := resolve_pending_week_changes()
	enforce_creditor_budget_lock()
	var invasion_note := start_invasion_if_needed()
	var recruitment_result := process_army_recruitment()
	var production := process_military_production()
	var war_result := process_war_week(true)
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
	var weekly_political_effects: Dictionary = (war_result.get("political_effects", {}) as Dictionary).duplicate(true)
	var clan_effects := weekly_clan_effects()
	for key in clan_effects.keys():
		weekly_political_effects[key] = int(weekly_political_effects.get(key, 0)) + int(clan_effects[key])
	var emission_result := process_emission_shock_week()
	if int(emission_result.get("support_loss", 0)) > 0:
		weekly_political_effects["support"] = int(weekly_political_effects.get("support", 0)) - int(emission_result.get("support_loss", 0))
	var consequence_notes: Array[String] = []
	var report_highlights: Array[Dictionary] = []
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
		report_highlights.append({"kind": "invasion", "title": "Началось вторжение", "detail_ru": "Страна вступила в оборонительную войну. Теперь каждая неделя приносит потери.", "detail_en": "The country is at war. Each week on the front now brings losses."})
	if str(recruitment_result.get("note", "")) != "":
		add_weekly_report_note(consequence_notes, report_sections, "security", str(recruitment_result.get("note", "")))
	if not war_result.is_empty():
		add_weekly_report_note(consequence_notes, report_sections, "security", str(war_result.get("note", "")))
	var unrest_note := process_active_unrest_week(unrest_snapshot, weekly_political_effects, true)
	if unrest_note != "":
		add_weekly_report_note(consequence_notes, report_sections, "society", unrest_note)
	for action_note in weekly_action_notes():
		var action_text := str(action_note)
		add_weekly_report_note(consequence_notes, report_sections, weekly_report_note_category(action_text), action_text)
	if not emission_result.is_empty():
		add_weekly_report_note(consequence_notes, report_sections, "finance", str(emission_result.get("note", "")))
	for clan_note in clan_notes:
		add_weekly_report_note(consequence_notes, report_sections, "groups", str(clan_note))
	for budget_note in process_weekly_budget_consequences(closed_week, weekly_political_effects, true):
		var budget_text := str(budget_note)
		add_weekly_report_note(consequence_notes, report_sections, weekly_report_note_category(budget_text), budget_text)
	if not weekly_political_effects.is_empty():
		apply_effects(weekly_political_effects)
	record_health_funding_week()
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
		"sections": report_sections,
		"highlights": report_highlights
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
	var law_in_progress := active_law
	var law_note := progress_active_law_stage(false)
	if law_note != "":
		add_weekly_report_note(consequence_notes, report_sections, "decisions", law_note)
		state.last_weekly_report["consequences"] = consequence_notes
		state.last_weekly_report["sections"] = report_sections
		if law_in_progress != "" and active_law == "" and law_enacted(law_in_progress):
			var effects_start := law_note.find(": ")
			var effects: PackedStringArray = law_note.substr(effects_start + 2).split(" • ", false) if effects_start >= 0 else PackedStringArray()
			var short_effects: Array[String] = []
			for effect_index in range(mini(2, effects.size())):
				short_effects.append(str(effects[effect_index]))
			report_highlights.append({"kind": "law", "title": law_in_progress, "detail_ru": " • ".join(short_effects), "detail_en": "The law is in force. Its effects are included in this week's changes."})
			state.last_weekly_report["highlights"] = report_highlights
	state.last_weekly_report["closing_money"] = float(state.get("money", 0.0))
	state.last_weekly_report["population_delta"] = total_population() - opening_population
	state.last_weekly_report["totals"] = weekly_report_total_lines(opening_snapshot)
	state.campaign_income = snappedf(float(state.get("campaign_income", 0.0)) + actual_income, 0.01)
	state.campaign_expenses = snappedf(float(state.get("campaign_expenses", 0.0)) + actual_expenses, 0.01)
	(state.campaign_history as Array).append(campaign_history_point())
	if check_terminal_state():
		save_campaign(false)
		return
	if financial_rescue_survived_four_weeks():
		state.financial_crisis_survival_pending = false
		if unlock_special_achievement("bills_without_rescuers"):
			add_weekly_report_note(consequence_notes, report_sections, "decisions", "Достижение открыто: «Счета без спасателей». Четыре недели после отказа от экстренной помощи страна прожила без дефолта.")
			state.last_weekly_report["consequences"] = consequence_notes
			state.last_weekly_report["sections"] = report_sections
	if armistice_took_effect_this_week(was_at_war, armistice_was_signed):
		report_highlights.append({"kind": "armistice", "title": "Перемирие вступило в силу", "detail_ru": "Боевые действия остановлены. Республика получила время на восстановление.", "detail_en": "The fighting has stopped. The republic has time to recover."})
		state.last_weekly_report["highlights"] = report_highlights
		if unlock_special_achievement("armistice_signed"):
			add_weekly_report_note(consequence_notes, report_sections, "foreign", "Достижение открыто: «Тишина на фронте». Перемирие вступило в силу после завершения недели.")
			state.last_weekly_report["consequences"] = consequence_notes
			state.last_weekly_report["sections"] = report_sections
	if int(state.get("week", 1)) <= DEMO_WEEKS:
		prepare_week_event_queue()
	# The first report of the new week is prepared behind the weekly summary.
	# Its default electronic report sound must not play under the page sound.
	next_event(false, false)
	save_campaign(false)
	if int(state.get("week", 1)) <= DEMO_WEEKS and is_instance_valid(game_root):
		show_weekly_report(true)


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
		"money", "debt", "debt_weekly_interest_rate", "support", "stability", "war_support",
		"clan_oligarchs", "clan_church", "clan_workers", "clan_regions",
		"army", "army_personnel", "army_equipment", "army_aircraft",
		"population_total", "population_workable",
		"east_relation", "west_relation", "corruption_tier", "creditor_obligations"
	]:
		snapshot[key] = state.get(key, 0)
	snapshot["population_dependents"] = dependent_population()
	return snapshot


func weekly_report_total_lines(opening: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	var finance_parts: Array[String] = []
	var money_delta := snappedf(float(state.get("money", 0.0)) - float(opening.get("money", 0.0)), 0.01)
	var debt_delta := snappedf(float(state.get("debt", 0.0)) - float(opening.get("debt", 0.0)), 0.01)
	var interest_rate_delta := float(state.get("debt_weekly_interest_rate", DEBT_INITIAL_WEEKLY_RATE)) - float(opening.get("debt_weekly_interest_rate", DEBT_INITIAL_WEEKLY_RATE))
	if not is_zero_approx(money_delta):
		finance_parts.append("казна %+.2f млн" % money_delta)
	if not is_zero_approx(debt_delta):
		finance_parts.append("долг %+.2f млн" % debt_delta)
	if not is_zero_approx(interest_rate_delta):
		finance_parts.append("недельная ставка %+.3f п.п." % (interest_rate_delta * 100.0))
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
	var population_delta := total_population() - int(opening.get("population_total", total_population()))
	if population_delta != 0:
		population_parts.append("всего %s%s" % ["+" if population_delta > 0 else "−", format_people(absi(population_delta))])
	var workable_delta := workable_population() - int(opening.get("population_workable", workable_population()))
	if workable_delta != 0:
		population_parts.append("работоспособные %s%s" % ["+" if workable_delta > 0 else "−", format_people(absi(workable_delta))])
	var dependents_delta := dependent_population() - int(opening.get("population_dependents", dependent_population()))
	if dependents_delta != 0:
		population_parts.append("неработоспособные %s%s" % ["+" if dependents_delta > 0 else "−", format_people(absi(dependents_delta))])
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


func tutorial_decision_part_visible(part: String, finance_open: bool, groups_open: bool, army_open: bool, foreign_open: bool) -> bool:
	var visible_prefixes := ["Казна", "Поддержка власти", "Стабильность", "Поддержка войны"]
	if finance_open:
		visible_prefixes.append_array(["Государственный долг", "Коррупция", "Международные кредиторы", "Население", "Работоспособное население"])
	if groups_open:
		visible_prefixes.append_array(["Олигархи", "Церковь Веры", "Рабочие и профсоюзы", "Фермеры и регионы", "Лояльность армии"])
	if army_open:
		visible_prefixes.append_array(["Военнослужащие", "Наземная техника", "Авиация"])
	if foreign_open:
		visible_prefixes.append_array(["Восточный Союз", "Западная Федерация"])
	for prefix in visible_prefixes:
		if part.begins_with(str(prefix)):
			return true
	return false


func visible_weekly_report_content(report: Dictionary) -> Dictionary:
	var guided := tutorial_enabled
	var finance_open := not guided or "chapter_3" in tutorial_seen or bool(state.get("financial_crisis_shown", false)) or float(report.get("closing_money", 1.0)) <= FINANCIAL_CRISIS_RESERVE
	var groups_open := not guided or "chapter_2" in tutorial_seen
	var army_open := not guided or "chapter_6" in tutorial_seen or bool(state.get("at_war", false)) or bool(state.get("military_threat", false))
	var foreign_open := not guided or "foreign_event" in tutorial_seen or bool(state.get("at_war", false)) or bool(state.get("military_threat", false)) or int(state.get("east_relation", 2)) == 0 or int(state.get("west_relation", 2)) == 0
	var access := {"decisions": true, "finance": finance_open, "society": true, "groups": groups_open, "security": army_open, "foreign": foreign_open}
	var totals: Array[String] = []
	for line_variant in report.get("totals", []):
		var line := str(line_variant)
		if line.begins_with("Финансы:") and not finance_open:
			for finance_part_variant in line.trim_prefix("Финансы: ").split(" • ", false):
				var finance_part := str(finance_part_variant)
				if finance_part.begins_with("казна "):
					totals.append("Казна: " + finance_part.trim_prefix("казна "))
			continue
		if line.begins_with("Группы:") and not groups_open:
			continue
		if line.begins_with("Население:") and not finance_open:
			continue
		if line.begins_with("Вооружённые силы:") and not army_open:
			continue
		if line.begins_with("Отношения:") and not foreign_open:
			continue
		if line.begins_with("Институты:") and not finance_open:
			continue
		totals.append(line)
	if totals.is_empty():
		totals.append("Открытые показатели за неделю не изменились.")
	var source_sections := weekly_report_sections(report)
	var sections: Dictionary = {}
	for key in access.keys():
		var section_key := str(key)
		sections[section_key] = (source_sections.get(section_key, []) as Array).duplicate() if bool(access[section_key]) else []
	if guided and not (finance_open and groups_open and army_open and foreign_open):
		var visible_decisions: Array[String] = []
		for note_variant in sections["decisions"]:
			var note := str(note_variant)
			var source_end := note.find("»: ") if note.begins_with("Доклад «") else -1
			var separator := note.find(" — ", source_end + 3 if source_end >= 0 else 0)
			if separator >= 0:
				var source := note.substr(0, separator)
				var visible_parts: Array[String] = []
				for part_variant in note.substr(separator + 3).trim_suffix(".").split(" • ", false):
					var part := str(part_variant)
					if tutorial_decision_part_visible(part, finance_open, groups_open, army_open, foreign_open):
						visible_parts.append(part)
				visible_decisions.append("%s — %s." % [source, " • ".join(visible_parts) if not visible_parts.is_empty() else "решение вступило в силу"])
		sections["decisions"] = visible_decisions
	return {"totals": totals, "sections": sections, "highlights": report.get("highlights", []), "finance": finance_open, "army": army_open, "population": finance_open, "full_detail": not guided or (finance_open and groups_open and army_open and foreign_open)}


func weekly_report_feature_card(highlight: Dictionary) -> PanelContainer:
	var kind := str(highlight.get("kind", "law"))
	var accent := RED if kind == "invasion" else GREEN if kind == "armistice" else GOLD
	var kicker := "НАЧАЛАСЬ ВОЙНА" if kind == "invasion" else "ПЕРЕМИРИЕ" if kind == "armistice" else "НОВЫЙ ЗАКОН"
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", style(Color("#263039"), 16, accent, 3))
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 17)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	margin.add_child(box)
	box.add_child(label(kicker, 14, accent))
	box.add_child(label(str(highlight.get("title", "")), 23, CREAM))
	var detail := str(highlight.get("detail_en", "")) if language_code == "en" else str(highlight.get("detail_ru", ""))
	if detail != "":
		box.add_child(label(detail, 15, Color("#d5d0c3")))
	return panel


func weekly_report_total_grid(lines: Array) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 2 if lines.size() > 1 else 1
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	for line_variant in lines:
		var full_line := str(line_variant)
		var separator := full_line.find(": ")
		var heading := full_line.substr(0, separator).to_upper() if separator >= 0 else "ИТОГ"
		var value := full_line.substr(separator + 2) if separator >= 0 else full_line
		if language_code == "en" and heading == "ОТНОШЕНИЯ":
			for term in ["Восточный Союз", "Западная Федерация", "враждебные", "натянутые", "средние", "партнёрские"]:
				value = value.replace(term, game_localization.text(term))
		var accent := GOLD if heading in ["ФИНАНСЫ", "КАЗНА", "ИНСТИТУТЫ"] else BLUE if heading in ["ОТНОШЕНИЯ", "ВООРУЖЁННЫЕ СИЛЫ"] else Color("#7c6688") if heading == "ГРУППЫ" else GREEN
		grid.add_child(weekly_report_panel(heading, [value], accent))
	return grid


func select_weekly_report_tab(tab_key: String, pages: Dictionary, buttons: Dictionary, body_scroll: ScrollContainer) -> void:
	for key_variant in pages.keys():
		var key := str(key_variant)
		var selected := key == tab_key
		(pages[key] as Control).visible = selected
		var button := buttons[key] as Button
		button.add_theme_stylebox_override("normal", style(GOLD if selected else Color("#29333b"), 11, GOLD if selected else Color("#52606a"), 2 if selected else 1))
		button.add_theme_stylebox_override("hover", style(Color("#e8d7ab") if selected else Color("#394650"), 11, GOLD, 2))
		button.add_theme_color_override("font_color", INK if selected else CREAM)
	body_scroll.scroll_vertical = 0
	localize_visible_tree()


func show_weekly_report(week_just_closed := false) -> void:
	var report: Dictionary = state.get("last_weekly_report", {})
	if report.is_empty():
		show_notice("Первая недельная сводка появится после завершения текущего хода.")
		return
	# During a war, every completed week ends with the distant explosion cue.
	# Manual visits to the report keep the ordinary page sound.
	play_game_sound("war" if week_just_closed and bool(state.get("at_war", false)) else "page")
	var root := VBoxContainer.new()
	root.custom_minimum_size = Vector2(920, 660)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 12)
	root.add_child(label("СВОДКА ЗА %d-Ю НЕДЕЛЮ" % int(report.get("week", 0)), 27, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var visible_content := visible_weekly_report_content(report)
	var sections: Dictionary = visible_content["sections"]
	var tab_specs: Array[Dictionary] = [{"key": "overview", "title": "ИТОГИ"}]
	if not (sections.get("decisions", []) as Array).is_empty():
		tab_specs.append({"key": "decisions", "title": "РЕШЕНИЯ"})
	if bool(visible_content["finance"]):
		tab_specs.append({"key": "finance", "title": "ДЕНЬГИ"})
	if not (sections.get("society", []) as Array).is_empty() or bool(visible_content["population"]) and str(report.get("monthly", "")) != "":
		tab_specs.append({"key": "society", "title": "ОБЩЕСТВО"})
	if not (sections.get("groups", []) as Array).is_empty():
		tab_specs.append({"key": "groups", "title": "ГРУППЫ"})
	if bool(visible_content["army"]):
		tab_specs.append({"key": "security", "title": "АРМИЯ"})
	if not (sections.get("foreign", []) as Array).is_empty():
		tab_specs.append({"key": "foreign", "title": "СОСЕДИ"})
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 6)
	root.add_child(tabs)
	var body_scroll := ScrollContainer.new()
	body_scroll.custom_minimum_size = Vector2(920, 440)
	body_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(body_scroll)
	var pages_host := VBoxContainer.new()
	pages_host.custom_minimum_size.x = 890
	pages_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_scroll.add_child(pages_host)
	var pages: Dictionary = {}
	var buttons: Dictionary = {}
	for spec in tab_specs:
		var key := str(spec["key"])
		var tab_button := small_button(str(spec["title"]))
		tab_button.name = "WeeklyTab_" + key
		tab_button.custom_minimum_size.y = 44
		tab_button.pressed.connect(select_weekly_report_tab.bind(key, pages, buttons, body_scroll))
		tabs.add_child(tab_button)
		buttons[key] = tab_button
		var page := VBoxContainer.new()
		page.name = "WeeklyPage_" + key
		page.visible = false
		page.custom_minimum_size.x = 890
		page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		page.add_theme_constant_override("separation", 12)
		pages_host.add_child(page)
		pages[key] = page
	var overview_page := pages["overview"] as VBoxContainer
	for highlight_variant in visible_content["highlights"]:
		overview_page.add_child(weekly_report_feature_card(highlight_variant as Dictionary))
	overview_page.add_child(label("СУММАРНО ЗА НЕДЕЛЮ", 16, Color("#6f3e37")))
	overview_page.add_child(weekly_report_total_grid(visible_content["totals"] as Array))
	if pages.has("decisions"):
		(pages["decisions"] as VBoxContainer).add_child(weekly_report_panel("ПРИНЯТЫЕ РЕШЕНИЯ", sections["decisions"], Color("#6f3e37")))
	if pages.has("finance"):
		var money_change := float(report.get("closing_money", 0.0)) - float(report.get("opening_money", 0.0))
		var money_lines: Array = [
			"Казна: %.2f → %.2f млн (%+.2f)" % [float(report.get("opening_money", 0.0)), float(report.get("closing_money", 0.0)), money_change],
			"Доходы +%.2f млн • расходы −%.2f млн" % [float(report.get("income", 0.0)), float(report.get("expenses", 0.0))],
			"Государственный долг: %.2f млн" % float(state.get("debt", 0.0))
		]
		var finance_tooltip := str(report.get("money_tooltip", "")) if bool(visible_content["full_detail"]) else "Полный расчёт доходов и расходов можно посмотреть во вкладке «Экономика»."
		(pages["finance"] as VBoxContainer).add_child(weekly_report_panel("ФИНАНСЫ  ⓘ", money_lines, GOLD, finance_tooltip))
		if not (sections.get("finance", []) as Array).is_empty():
			(pages["finance"] as VBoxContainer).add_child(weekly_report_panel("ФИНАНСЫ И БЮДЖЕТ", sections["finance"], GOLD))
	if pages.has("society"):
		if not (sections.get("society", []) as Array).is_empty():
			(pages["society"] as VBoxContainer).add_child(weekly_report_panel("ОБЩЕСТВО И РЕАКЦИЯ НА ФИНАНСИРОВАНИЕ", sections["society"], GREEN))
		if bool(visible_content["population"]) and str(report.get("monthly", "")) != "":
			(pages["society"] as VBoxContainer).add_child(weekly_report_panel("НАСЕЛЕНИЕ", [str(report.get("monthly", ""))], Color("#7c6688")))
	if pages.has("groups"):
		(pages["groups"] as VBoxContainer).add_child(weekly_report_panel("КЛАНЫ И ВНУТРЕННИЕ ГРУППЫ", sections["groups"], Color("#7c6688")))
	if pages.has("security"):
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
		(pages["security"] as VBoxContainer).add_child(weekly_report_panel("АРМИЯ", army_lines, BLUE))
		if not (sections.get("security", []) as Array).is_empty():
			(pages["security"] as VBoxContainer).add_child(weekly_report_panel("АРМИЯ И БЕЗОПАСНОСТЬ", sections["security"], RED))
	if pages.has("foreign"):
		(pages["foreign"] as VBoxContainer).add_child(weekly_report_panel("ВНЕШНЯЯ ПОЛИТИКА", sections["foreign"], BLUE))
	var close := menu_button("ПЕРЕЙТИ К ДОКЛАДУ НОВОЙ НЕДЕЛИ" if week_just_closed else "ЗАКРЫТЬ СВОДКУ")
	if week_just_closed:
		close.pressed.connect(finish_weekly_report)
	else:
		close.pressed.connect(close_overlay)
	root.add_child(close)
	show_overlay(root, PAPER, not week_just_closed, 980)
	active_overlay_scroll = body_scroll
	select_weekly_report_tab("overview", pages, buttons, body_scroll)
	if bool(state.get("at_war", false)):
		offer_tutorial("war")


func finish_weekly_report() -> void:
	close_overlay()
	show_tutorial_week_briefing()
	if not is_instance_valid(tutorial_dialog):
		maybe_show_foreign_event_tutorial()


func update_projected_main_stat(key: String, title: String, is_money := false) -> void:
	if not stat_labels.has(key):
		return
	var value_label: Label = stat_labels[key]
	if is_money:
		var current_money := float(state.get(key, 0.0))
		var projected_money := projected_pending_float(key)
		var changed := not is_equal_approx(current_money, projected_money)
		queue_sidebar_number(key, projected_money)
		value_label.add_theme_color_override("font_color", PENDING_BLUE if changed else CREAM)
		value_label.tooltip_text = compact_tooltip((pending_value_tooltip(title, "%.2f млн" % current_money, "%.2f млн" % projected_money) + "\n\n" if changed else "") + main_stat_tooltip(key))
	else:
		var current_value := int(state.get(key, 0))
		var projected_value := projected_pending_value(key)
		var changed := current_value != projected_value
		queue_sidebar_number(key, projected_value)
		value_label.add_theme_color_override("font_color", PENDING_BLUE if changed else CREAM)
		value_label.tooltip_text = compact_tooltip((pending_value_tooltip(title, "%d%%" % current_value, "%d%%" % projected_value) + "\n\n" if changed else "") + main_stat_tooltip(key))
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
	if is_instance_valid(mode_label):
		mode_label.text = campaign_header_caption()
	request_sidebar_refresh()
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
	refresh_tutorial_focus()
	localize_visible_tree()


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


func minister_law_catalog() -> Array[Dictionary]:
	return [
		{
			"name": "Приватизация сырьевого сектора", "slot": "economy", "minister_id": "radan", "weeks": 3, "cost": 1,
			"hint": "Даст быстрые деньги и влияние бизнесу, но навсегда уменьшит доступную добычу нефти и металлов на 2 ед.; коррупционный риск вырастет."
		},
		{
			"name": "Национализация стратегической промышленности", "slot": "economy", "minister_id": "grad", "weeks": 3, "cost": 1,
			"hint": "Потребует 15 млн компенсаций, но навсегда добавит 3 млн валового недельного дохода госпредприятий и ускорит выпуск наземной техники на 25%. Коррупция, забастовки и ответ олигархов могут урезать денежную выгоду."
		},
		{
			"name": "Закон о коллективных договорах", "slot": "economy", "minister_id": "sorec", "weeks": 3, "cost": 1,
			"hint": "Потребует 6 млн на отраслевые фонды и усилит профсоюзы. Забастовки сохранятся, но будут заметно слабее сокращать налоги, доход госпредприятий и экспорт."
		},
		{
			"name": "Ограничение СМИ", "slot": "interior", "minister_id": "volsky", "weeks": 2, "cost": 1,
			"hint": "Будущие потери поддержки от непопулярных решений уменьшатся примерно на треть, но закон сразу вызовет политический кризис и протест."
		},
		{
			"name": "Закон об общественном посредничестве", "slot": "interior", "minister_id": "kovach", "weeks": 3, "cost": 1,
			"hint": "Новые гражданские, региональные и антивоенные протесты будут начинаться на один уровень слабее. Забастовки закон не смягчит; открытая либерализация временно ударит по порядку и настроит армию против президента, пока обороной руководит брат."
		},
		{
			"name": "Закон о региональных комиссиях", "slot": "interior", "minister_id": "sava", "weeks": 2, "cost": 1,
			"hint": "Гражданские протесты будут снимать на 1 меньше стабильности в неделю, а передача переговоров губернаторам больше не отнимет очко решений. Регионы усилятся, профсоюзы и центральная власть будут недовольны."
		}
	]


func minister_law_data(law_name: String) -> Dictionary:
	for law_data in minister_law_catalog():
		if str(law_data.get("name", "")) == law_name:
			return law_data
	return {}


func minister_law_is_active(law_name: String) -> bool:
	match law_name:
		"Приватизация сырьевого сектора":
			return bool(state.get("raw_sector_privatized", false))
		"Национализация стратегической промышленности":
			return bool(state.get("strategic_industry_nationalized", false))
		"Закон о коллективных договорах":
			return bool(state.get("collective_bargaining_law", false))
		"Ограничение СМИ":
			return bool(state.get("media_restricted", false))
		"Закон об общественном посредничестве":
			return bool(state.get("civic_mediation_law", false))
		"Закон о региональных комиссиях":
			return bool(state.get("regional_commissions_law", false))
	return law_enacted(law_name)


func minister_law_lock_reason(law_data: Dictionary) -> String:
	var law_name := str(law_data.get("name", ""))
	if minister_law_is_active(law_name):
		return "Закон уже принят и действует."
	var slot := str(law_data.get("slot", ""))
	var required_id := str(law_data.get("minister_id", ""))
	if str(selected_ministers.get(slot, "")) == required_id:
		return ""
	var required_name := str(minister_data(slot, required_id).get("name", "нужный кандидат"))
	return "Для подготовки требуется %s — %s. Сейчас эту должность занимает %s." % [MINISTER_OFFICES.get(slot, "МИНИСТР").to_lower(), required_name, current_minister_name(slot)]


func current_interior_law_data() -> Dictionary:
	var current_id := str(selected_ministers.get("interior", "volsky"))
	for law_data in minister_law_catalog():
		if str(law_data.get("slot", "")) == "interior" and str(law_data.get("minister_id", "")) == current_id:
			return law_data
	return {}


func interior_law_is_active(law_name: String) -> bool:
	return minister_law_is_active(law_name)


func show_law_selection() -> void:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(820, 620)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	scroll.add_child(content)
	content.add_child(label("ПОДГОТОВКА ЗАКОНА", 27, INK, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label("Можно вести только один законопроект. Первый этап оплачивается сразу, остальные автоматически — в начале новых недель. При нехватке очков работа приостанавливается, но не отменяется. Все министерские проекты остаются видимыми: заблокированная карточка показывает, какой министр требуется.", 17, Color("#4c4941"), HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label("БАЗОВЫЕ ЗАКОНЫ", 17, Color("#6f3e37")))
	if not law_enacted("Антикоррупционное бюро"):
		add_law_option(content, "Антикоррупционное бюро", 3, 2, "Снизит коррупцию на одну категорию, но встревожит элиты.")
	if not law_enacted("Чрезвычайные полномочия"):
		add_law_option(content, "Чрезвычайные полномочия", 2, 1, "Только при войне и стабильности ≤60%. Укрепит порядок и армию, но снизит поддержку и отношения со всеми гражданскими группами.", emergency_powers_lock_reason())
	if not bool(state.get("secular_education", false)):
		add_law_option(content, "Светское образование", 2, 1, "Ослабит вдвое и бонусы, и штрафы общественного влияния Церкви, но вызовет конфликт с её иерархами.")
	for slot in ["economy", "interior"]:
		content.add_child(label("ПРОЕКТЫ: %s" % str(MINISTER_OFFICES.get(slot, "МИНИСТЕРСТВО")), 17, Color("#6f3e37")))
		for law_data in minister_law_catalog():
			if str(law_data.get("slot", "")) != slot:
				continue
			add_law_option(
				content,
				str(law_data.get("name", "")),
				int(law_data.get("weeks", 2)),
				int(law_data.get("cost", 1)),
				str(law_data.get("hint", "")),
				minister_law_lock_reason(law_data)
			)
	var cancel := menu_button("ЗАКРЫТЬ")
	cancel.pressed.connect(close_overlay)
	content.add_child(cancel)
	show_overlay(scroll, PAPER, true, 880)


func add_law_option(parent: VBoxContainer, law_name: String, weeks: int, weekly_cost: int, hint: String, locked_reason := "") -> void:
	var availability_reason: String = str(locked_reason)
	if availability_reason == "" and int(state.get("influence", 0)) < weekly_cost:
		availability_reason = "Для первого этапа требуется %d очк. решений; сейчас доступно %d." % [weekly_cost, int(state.get("influence", 0))]
	var button := Button.new()
	if language_code == "en":
		button.text = "%s • %d weeks • %d points per stage\n%s%s" % [game_localization.text(law_name), weeks, weekly_cost, game_localization.text(hint), "\nUNAVAILABLE: " + game_localization.text(availability_reason) if availability_reason != "" else ""]
	else:
		button.text = "%s • %d нед. • %d очк. за этап\n%s%s" % [law_name, weeks, weekly_cost, hint, "\nНЕДОСТУПНО: " + availability_reason if availability_reason != "" else ""]
	button.custom_minimum_size = Vector2(0, 82)
	button.add_theme_font_size_override("font_size", 16)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.add_theme_stylebox_override("normal", style(Color("#d8cdb5"), 12, Color("#887b64"), 1))
	button.add_theme_color_override("font_color", INK)
	button.disabled = availability_reason != ""
	var money_preview := law_weekly_money_preview(law_name)
	button.tooltip_text = (game_localization.text(availability_reason) + "\n\n" if availability_reason != "" else "") + game_localization.text(hint) + ("\n\n" + game_localization.text(money_preview) if money_preview != "" else "")
	button.pressed.connect(begin_law.bind(law_name, weeks, weekly_cost))
	parent.add_child(button)


func law_weekly_money_preview(law_name: String) -> String:
	if not law_name in ["Антикоррупционное бюро", "Национализация стратегической промышленности", "Закон о коллективных договорах"]:
		return ""
	var original_state: Dictionary = state.duplicate(true)
	var old_flow := weekly_actual_income() - weekly_actual_expenses()
	var old_oligarchs := int(state.get("clan_oligarchs", 0))
	state = original_state.duplicate(true)
	match law_name:
		"Антикоррупционное бюро":
			state.corruption_tier = maxi(0, int(state.get("corruption_tier", 0)) - 1)
			state.clan_oligarchs = maxi(0, old_oligarchs - 12)
		"Национализация стратегической промышленности":
			state.clan_oligarchs = maxi(0, old_oligarchs - 18)
			state.strategic_industry_nationalized = true
		"Закон о коллективных договорах":
			state.clan_oligarchs = maxi(0, old_oligarchs - 12)
			state.collective_bargaining_law = true
	var new_oligarchs := int(state.get("clan_oligarchs", 0))
	var new_flow := weekly_actual_income() - weekly_actual_expenses()
	state = original_state
	var delta := snappedf(new_flow - old_flow, 0.01)
	return "Если бы закон вступил в силу сейчас: недельный баланс %+.2f млн; поддержка олигархов %d%% → %d%%, их денежный эффект %+.2f → %+.2f млн/нед. Это прогноз по нынешней экономике: за время подготовки закона показатели и забастовки могут измениться." % [delta, old_oligarchs, new_oligarchs, weekly_clan_money_flow(old_oligarchs), weekly_clan_money_flow(new_oligarchs)]


func begin_law(law_name: String, weeks: int, weekly_cost: int) -> void:
	if active_law != "":
		show_notice("Сначала завершите уже выбранный законопроект.")
		return
	var minister_project := minister_law_data(law_name)
	if not minister_project.is_empty():
		var minister_lock := minister_law_lock_reason(minister_project)
		if minister_lock != "":
			show_notice(minister_lock)
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
		law_effects = {"corruption_tier": -1, "support": 3, "clan_oligarchs": -6}
	elif completed == "Ограничение СМИ":
		law_effects = {"support": -6, "stability": 5, "army": 3, "west_pressure": 3, "authoritarian": 1, "clan_oligarchs": 7}
		state.media_restricted = true
	elif completed == "Закон об общественном посредничестве":
		law_effects = {"support": 4, "stability": -3, "clan_workers": 5}
		if brother_is_defense_minister():
			law_effects["army"] = -3
		state.civic_mediation_law = true
	elif completed == "Закон о региональных комиссиях":
		law_effects = {"support": -2, "stability": 3, "clan_regions": 8, "clan_workers": -3}
		state.regional_commissions_law = true
	elif completed == "Чрезвычайные полномочия":
		law_effects = emergency_powers_effects()
		state.authoritarian = int(state.authoritarian) + 1
	elif completed == "Приватизация сырьевого сектора":
		law_effects = {"money": 35, "corruption_tier": 1, "clan_oligarchs": 15, "clan_workers": -8, "support": -2}
		state.raw_sector_privatized = true
		state.oil_to_army = mini(int(state.get("oil_to_army", 0)), current_oil_output())
		state.metal_to_equipment = mini(int(state.get("metal_to_equipment", 0)), current_metal_output())
	elif completed == "Национализация стратегической промышленности":
		law_effects = {"money": -NATIONALIZATION_COMPENSATION_COST, "clan_oligarchs": -18, "clan_workers": 10, "army": 3, "stability": 2}
		state.strategic_industry_nationalized = true
	elif completed == "Закон о коллективных договорах":
		law_effects = {"money": -6, "support": 3, "stability": -2, "clan_workers": 9, "clan_oligarchs": -6}
		state.collective_bargaining_law = true
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
	elif completed == "Национализация стратегической промышленности":
		exact_effects += " • валовой доход госпредприятий +%.2f млн/нед. до конца кампании • выпуск наземной техники +%d%%" % [NATIONALIZED_STATE_ENTERPRISE_INCOME_BONUS, roundi((NATIONALIZED_EQUIPMENT_OUTPUT_MULTIPLIER - 1.0) * 100.0)]
	elif completed == "Закон о коллективных договорах":
		exact_effects += " • экономический ущерб забастовок снижен до конца кампании; сами забастовки и их политические последствия сохраняются"
	elif completed == "Закон об общественном посредничестве":
		exact_effects += " • новые гражданские, региональные и антивоенные протесты начинаются на 1 категорию слабее • забастовки не меняются"
	elif completed == "Закон о региональных комиссиях":
		exact_effects += " • гражданские протесты снимают на 1 меньше стабильности в неделю • план Савы больше не отнимает очко решений"
	var law_tooltip := transaction_tooltip("Денежный эффект закона", float(law_effects.get("money", 0.0)), previous_corruption_tier, "Категория коррупции урезает только положительное поступление от закона; стоимость закона не повышается.") if law_effects.has("money") else ""
	if show_completion_notice:
		if check_terminal_state():
			return "Закон «%s» принят: %s" % [completed, exact_effects]
		show_notice("Закон «%s» принят.\n\nТочные видимые последствия: %s%s" % [completed, exact_effects, "  ⓘ" if law_tooltip != "" else ""], law_tooltip)
	return "Закон «%s» принят автоматически: %s" % [completed, exact_effects]


func foreign_action_used_this_week() -> bool:
	return int(state.get("foreign_action_week", 0)) == int(state.get("week", 1))


func foreign_minister_initiative_data() -> Dictionary:
	return {
		"title": "КРИЗИСНЫЙ КАНАЛ",
		"summary": "Один раз откладывает на две недели вторжение соседа, с которым отношения стали враждебными. Канал не улучшает отношения: обе недели нужно использовать для дипломатического выхода.",
		"button": "ОТКРЫТЬ КАНАЛ • −3 МЛН • 1 ОЧК."
	}


func foreign_minister_initiative_lock_reason() -> String:
	if str(selected_ministers.get("foreign", "narin")) != "narin":
		return "Отдельная инициатива доступна только Лее Нарин. Варек и Крес открывают специальные соглашения в карточках соседей."
	if foreign_action_used_this_week():
		return "Внешнеполитическое действие этой недели уже использовано."
	if int(state.get("influence", 0)) < 1:
		return "Нужно 1 очко решений."
	if bool(state.get("narin_crisis_channel_armed", false)):
		return "Кризисный канал уже открыт и ждёт первого враждебного кризиса."
	if bool(state.get("narin_crisis_channel_used", false)):
		return "Кризисный канал уже был использован в текущей кампании."
	if bool(state.get("at_war", false)):
		return "Кризисный канал нужно открыть до начала войны."
	return ""


func add_foreign_minister_initiative_panel(parent: Container) -> void:
	var data := foreign_minister_initiative_data()
	var lock_reason := foreign_minister_initiative_lock_reason()
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", style(Color("#d8cdb5"), 14, BLUE, 2))
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	panel.add_child(box)
	box.add_child(label("ИНИЦИАТИВА МИНИСТРА • %s" % current_minister_name("foreign").to_upper(), 17, Color("#6f3e37")))
	box.add_child(label(str(data.get("title", "")), 20, INK))
	box.add_child(label(str(data.get("summary", "")), 14, Color("#5f594d")))
	var initiative := foreign_policy_button(str(data.get("button", "ИСПОЛЬЗОВАТЬ")))
	initiative.disabled = lock_reason != ""
	initiative.tooltip_text = lock_reason if lock_reason != "" else str(data.get("summary", "")) + "\n\nИнициатива занимает единственное внешнеполитическое действие недели. Все последствия применятся при переходе к следующей неделе."
	initiative.pressed.connect(perform_foreign_minister_initiative)
	box.add_child(initiative)
	if lock_reason != "":
		box.add_child(label(lock_reason, 13, RED if not bool(state.get("narin_crisis_channel_armed", false)) else GREEN))


func perform_foreign_minister_initiative() -> void:
	if str(selected_ministers.get("foreign", "narin")) != "narin":
		show_notice("У действующего министра нет отдельной инициативы. Его специальное соглашение находится в карточке соответствующего соседа.")
		return
	var lock_reason := foreign_minister_initiative_lock_reason()
	if lock_reason != "":
		show_notice(lock_reason)
		return
	var effects: Dictionary = {"money": -3}
	var flags: Dictionary = {"narin_crisis_channel_armed": true, "narin_crisis_delay_weeks": 0}
	var description := "Лея Нарин открыла кризисный канал. Он один раз даст две полные недели между враждебным кризисом и вторжением."
	effects = apply_media_support_filter(effects)
	state.influence = int(state.get("influence", 0)) - 1
	state.foreign_action_week = int(state.get("week", 1))
	queue_week_change("Инициатива министра иностранных дел", effects, flags)
	state.last_foreign_action = description
	update_interface()
	autosave_if_iron()
	show_foreign_policy()


func armistice_readiness() -> Dictionary:
	var quality := army_quality_effectiveness()
	var required := frontline_required_personnel(quality)
	var personnel := int(state.get("army_personnel", 0))
	var equipment_coverage := clampi(roundi(float(state.get("army_equipment", 0)) / float(army_required_equipment()) * 100.0), 0, 100)
	var supply := army_supply()
	var effectiveness := army_effectiveness()
	var war_support := int(state.get("war_support", 0))
	var minimum_future_effectiveness := 100
	var minimum_future_personnel_margin := 2147483647
	var minimum_future_war_support := 100
	if bool(state.get("at_war", false)):
		# Проверяем именно способность удержать фронт, а не один удачный снимок
		# показателей. Набор и выпуск техники продолжаются по текущим приказам;
		# новые решения и случайные события в прогноз не входят.
		var original_state := state
		state = original_state.duplicate(true)
		for projected_week in range(ARMISTICE_HOLD_WEEKS):
			process_army_recruitment()
			process_military_production()
			var battle := process_war_week(true)
			apply_effects(battle.get("political_effects", {}))
			state.week = int(state.get("week", 1)) + 1
			minimum_future_effectiveness = mini(minimum_future_effectiveness, army_effectiveness())
			minimum_future_personnel_margin = mini(minimum_future_personnel_margin, int(state.get("army_personnel", 0)) - frontline_required_personnel())
			minimum_future_war_support = mini(minimum_future_war_support, int(state.get("war_support", 0)))
		state = original_state
	var conditions: Array[String] = []
	if int(state.get("war_weeks", 0)) < ARMISTICE_MIN_WAR_WEEKS:
		conditions.append("Война: %d/%d недель" % [int(state.get("war_weeks", 0)), ARMISTICE_MIN_WAR_WEEKS])
	if two_front_war_active():
		conditions.append("Перемирие с одним соседом не завершит войну на втором фронте")
	if effectiveness < ARMISTICE_MIN_EFFECTIVENESS:
		conditions.append("Боеспособность: %d/%d%%" % [effectiveness, ARMISTICE_MIN_EFFECTIVENESS])
	if personnel < required + ARMISTICE_PERSONNEL_RESERVE:
		conditions.append("Личный состав: %s, нужно %s с резервом" % [format_people(personnel), format_people(required + ARMISTICE_PERSONNEL_RESERVE)])
	if equipment_coverage < ARMISTICE_MIN_EQUIPMENT_COVERAGE:
		conditions.append("Оснащение техникой: %d/%d%%" % [equipment_coverage, ARMISTICE_MIN_EQUIPMENT_COVERAGE])
	if supply < ARMISTICE_MIN_SUPPLY:
		conditions.append("Снабжение нефтью: %d/%d%%" % [supply, ARMISTICE_MIN_SUPPLY])
	if war_support < ARMISTICE_MIN_WAR_SUPPORT:
		conditions.append("Поддержка войны: %d/%d%%" % [war_support, ARMISTICE_MIN_WAR_SUPPORT])
	if minimum_future_effectiveness < ARMISTICE_MIN_FUTURE_EFFECTIVENESS or minimum_future_personnel_margin < 0 or minimum_future_war_support <= 0:
		conditions.append("Запас прочности: текущая армия не удержит фронт ещё %d недель (минимум боеспособности %d%%, людей сверх потребности %+d)" % [ARMISTICE_HOLD_WEEKS, minimum_future_effectiveness, minimum_future_personnel_margin])
	return {
		"ready": bool(state.get("at_war", false)) and not bool(state.get("war_armistice_signed", false)) and conditions.is_empty(),
		"missing": conditions,
		"future_effectiveness": minimum_future_effectiveness,
		"future_personnel_margin": minimum_future_personnel_margin
	}


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
		var war_heading := "WAR: %s" % ("%s AND %s" % [neighbor_title_en(str(state.get("war_enemy", "east"))), neighbor_title_en(str(state.get("war_second_enemy", "west")))] if two_front_war_active() else neighbor_title_en(str(state.get("war_enemy", "east")))) if language_code == "en" else "ВОЙНА: %s" % war_opponents_text().to_upper()
		war_box.add_child(label(war_heading, 20, RED))
		war_box.add_child(label("Неделя войны: %d • боеспособность фронта: %d%% • качество армии: %d%%" % [int(state.get("war_weeks", 0)), army_effectiveness(), quality], 16, INK))
		war_box.add_child(label("Для удержания фронта нужно не меньше %s военнослужащих; сейчас %s. Чем выше подготовка, техника, авиация и снабжение, тем меньше людей требуется." % [format_people(required), format_people(personnel)], 15, RED if personnel < required else GREEN))
		if two_front_war_active():
			war_box.add_child(label("Два фронта: потребность в людях и еженедельные потери людей и техники ×1,45; поддержка войны и стабильность дополнительно −1 за неделю.", 14, RED))
		var pressure_cost := float(int(state.get("war_frontline_pressure", 0))) * 0.45
		war_box.add_child(label("Разорение прифронтовых районов: %.2f млн/нед. Боеспособность ниже 25%% усиливает ущерб; от 40%% он постепенно спадает." % pressure_cost, 14, RED if pressure_cost > 0.0 else Color("#5f594d")))
		war_box.add_child(label("Общие военные потери: %s. Последний доклад: %s" % [format_people(int(state.get("war_casualties", 0))), str(state.get("last_war_report", ""))], 14, Color("#5f594d")))
		var armistice_status := armistice_readiness()
		var armistice := foreign_policy_button("ПРЕДЛОЖИТЬ ПЕРЕМИРИЕ • −5 МЛН • 1 ОЧК.")
		armistice.disabled = foreign_action_used_this_week() or int(state.get("influence", 0)) < 1 or not bool(armistice_status.get("ready", false))
		var armistice_requirements := "Требуется: минимум 6 недель войны, боеспособность 65%, 5 тысяч человек сверх потребности фронта, оснащение техникой 70%, снабжение 90%, поддержка войны 35%. При текущих приказах фронт должен выдержать ещё 5 недель: боеспособность всё время не ниже 55%, людей хватает, поддержка войны не обнуляется."
		var armistice_missing: Array[String] = armistice_status.get("missing", [])
		armistice.tooltip_text = armistice_requirements + ("\n\nПока не выполнено:\n" + "\n".join(armistice_missing) if not armistice_missing.is_empty() else "\n\nУсловия выполнены.") + ("\n\nПеремирие с одним соседом не остановит войну на втором фронте." if two_front_war_active() else "\n\nПосле конца недели: война прекратится, отношения с противником станут натянутыми; казна −5 млн, поддержка −8, стабильность −4, лояльность армии −4. Компенсации и международный контроль будут стоить 0,60 млн в неделю до конца кампании. Договор удержит прежнего противника от нового вторжения на шесть недель; затем враждебные отношения снова приведут к войне.")
		if not armistice_missing.is_empty():
			war_box.add_child(label("Для переговоров пока не хватает: %s" % "; ".join(armistice_missing), 13, Color("#6f3e37")))
		war_box.add_child(armistice)
		armistice.pressed.connect(perform_foreign_action.bind(str(state.get("war_enemy", "east")), "armistice"))
	else:
		war_box.add_child(label("МИРНОЕ ВРЕМЯ", 20, GREEN))
		war_box.add_child(label("При переходе отношений с любым соседом во враждебное состояние начнётся вторжение. До конца недели дипломатическая миссия ещё может улучшить отношения на одну категорию.", 15, Color("#5f594d")))
		if int(state.get("week", 1)) <= int(state.get("war_ceasefire_until_week", 0)):
			war_box.add_child(label("Перемирие с государством «%s» защищает границу до конца %d-й недели. При враждебных отношениях после этого срока война возобновится." % [neighbor_title(str(state.get("war_ceasefire_enemy", "east"))), int(state.get("war_ceasefire_until_week", 0))], 14, GOLD))
	var action_status := "Внешнеполитическое действие этой недели уже использовано." if foreign_action_used_this_week() else "Доступно одно внешнеполитическое действие на этой неделе."
	content.add_child(label(action_status, 14, RED if foreign_action_used_this_week() else Color("#6f3e37"), HORIZONTAL_ALIGNMENT_CENTER))
	if str(selected_ministers.get("foreign", "narin")) == "narin":
		add_foreign_minister_initiative_panel(content)
	if int(state.get("week", 1)) >= 20:
		var course_panel := PanelContainer.new()
		course_panel.add_theme_stylebox_override("panel", style(Color("#d8cdb5"), 14, GOLD, 2))
		content.add_child(course_panel)
		var course_box := VBoxContainer.new()
		course_box.add_theme_constant_override("separation", 7)
		course_panel.add_child(course_box)
		course_box.add_child(label("КУРС ПОСЛЕ ВЫБОРОВ", 18, INK))
		course_box.add_child(label("До конца временного срока можно один раз закрепить международный курс. Это изменит итог правления и создаст обязательства уже сейчас.", 14, Color("#5f594d")))
		for course in ["east", "west", "neutral"]:
			var course_button := foreign_policy_button(final_course_button_text(course))
			course_button.disabled = not final_course_available(course)
			course_button.tooltip_text = final_course_explanation(course)
			course_button.pressed.connect(perform_final_course_action.bind(course))
			course_box.add_child(course_button)
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
			var dependency_title := game_localization.text(str(dependency.get("title", "Соглашение")))
			var dependency_effect := game_localization.text(str(dependency.get("effect", "")))
			var dependency_label := label("• %s — %s  ⓘ" % [dependency_title, dependency_effect], 14, dependency.get("color", INK))
			dependency_label.tooltip_text = game_localization.text(str(dependency.get("detail", "")))
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
	if int(state.get("week", 1)) < 5:
		offer_tutorial("foreign")


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
	var enemy_at_war := at_war_with(side)
	if enemy_at_war:
		box.add_child(label("С этим государством идёт война. Обычные дипломатические действия недоступны.", 14, RED))
	var narin_in_office := str(selected_ministers.get("foreign", "narin")) == "narin"
	var mission := foreign_policy_button("МИССИЯ • −2 МЛН • 1 ОЧК.")
	mission.disabled = not narin_in_office or foreign_action_used_this_week() or int(state.get("influence", 0)) < 1 or enemy_at_war or projected_pending_value(side + "_relation") >= 3
	mission.tooltip_text = "Миссии по улучшению отношений доступны только при министре иностранных дел Лее Нарин." if not narin_in_office else "Отношения с государством-противником нельзя улучшать, пока продолжается война." if enemy_at_war else "%s Расход составит ровно 2 млн; коррупция его не увеличивает." % relation_improvement_summary(side)
	mission.pressed.connect(perform_foreign_action.bind(side, "mission"))
	box.add_child(mission)
	var concession_income := adjusted_money_transaction(10.0, projected_corruption_tier())
	var concession_data := foreign_concession_data(side)
	var concession_caption := "%s • +%.2f M • 1 POINT" % [game_localization.text(str(concession_data["button"])), concession_income] if language_code == "en" else "%s • +%.2f МЛН • 1 ОЧК." % [str(concession_data["button"]), concession_income]
	var concession := foreign_policy_button(concession_caption)
	var concession_minister_available := foreign_concession_available(side)
	concession.disabled = foreign_action_used_this_week() or int(state.get("influence", 0)) < 1 or enemy_at_war or bool(state.get(side + "_concession_signed", false)) or not concession_minister_available
	var permanent_cost := "Доступная добыча нефти: −4 ед. в неделю до конца кампании" if side == "east" else "Недельные расходы: −0.60 млн до конца кампании"
	concession.tooltip_text = "%s\n\nПОСЛЕДСТВИЯ ПРИ ЗАВЕРШЕНИИ НЕДЕЛИ\nКазна: +%.2f млн\nПоддержка власти: −2\n%s\n%s\nЦена действия: 1 очко решений\n\n%s" % [str(concession_data["detail"]), concession_income, permanent_cost, relation_improvement_summary(side), transaction_tooltip("Доход от соглашения", 10.0, projected_corruption_tier(), "Разовый платёж 10 млн до потерь от коррупции")]
	if language_code == "en":
		var cost_en := "Oil output: −4 units weekly for the rest of the campaign" if side == "east" else "Weekly expense: +0.60 M for the rest of the campaign"
		concession.tooltip_text = "%s\n\nEFFECTS AT WEEK'S END\nTreasury: +%.2f M\nGovernment support: −2\n%s\n%s\nAction cost: 1 decision point\n\n%s" % [game_localization.text(str(concession_data["detail"])), concession_income, cost_en, game_localization.text(relation_improvement_summary(side)), transaction_tooltip("Доход от соглашения", 10.0, projected_corruption_tier(), "Разовый платёж 10 млн до потерь от коррупции")]
	if not concession_minister_available:
		concession.tooltip_text = "Это соглашение может подготовить только %s. Смените министра иностранных дел, чтобы получить доступ к кнопке." % foreign_concession_minister_name(side)
	elif enemy_at_war:
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
	var enemy_at_war := at_war_with(side)
	var effects: Dictionary = {}
	var flags: Dictionary = {}
	var description := ""
	if action == "mission":
		if str(selected_ministers.get("foreign", "")) != "narin":
			show_notice("Дипломатические миссии доступны только при министре иностранных дел Лее Нарин.")
			return
		if enemy_at_war or projected_pending_value(side + "_relation") >= 3:
			show_notice("Дипломатическая миссия сейчас не сможет изменить положение.")
			return
		effects = {"money": -2}
		merge_numeric_effects(effects, relation_shift_effect(side, 1))
		description = relation_improvement_summary(side)
	elif action == "concession":
		if not foreign_concession_available(side):
			show_notice("Это соглашение может подготовить только %s." % foreign_concession_minister_name(side))
			return
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
	elif action == "armistice":
		var armistice_status := armistice_readiness()
		if not enemy_at_war or not bool(armistice_status.get("ready", false)):
			var missing: Array[String] = armistice_status.get("missing", [])
			show_notice("Для переговоров нужно укрепить оборону: %s." % "; ".join(missing) if not missing.is_empty() else "Перемирие сейчас недоступно.")
			return
		effects = {"money": -5, "support": -8, "stability": -4, "army": -4}
		flags = {"at_war": false, "war_armistice_signed": true, "war_ceasefire_until_week": int(state.get("week", 1)) + 6, "war_ceasefire_enemy": side, side + "_relation": 1, "war_frontline_pressure": 0}
		description = "Перемирие с государством «%s» вступит в силу после конца недели. Контроль границы и компенсации станут постоянным расходом." % neighbor_title(side)
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


func final_course_button_text(course: String) -> String:
	match course:
		"east": return "ЗАКРЕПИТЬ ВОСТОЧНЫЙ КУРС • 1 ОЧК."
		"west": return "ЗАКРЕПИТЬ ЗАПАДНЫЙ КУРС • −5 МЛН • 1 ОЧК."
		"neutral": return "ГАРАНТИРОВАТЬ НЕЙТРАЛИТЕТ • −6 МЛН • 1 ОЧК."
		"legacy": return "ОБЪЯВИТЬ НАСЛЕДСТВЕННЫЙ КУРС • 1 ОЧК."
		"unresolved": return "ОТКАЗАТЬСЯ ПРИЗНАВАТЬ ПОРЯДОК ПЕРЕДАЧИ ВЛАСТИ • 1 ОЧК."
	return ""


func final_course_explanation(course: String) -> String:
	match course:
		"east": return "Требуются отношения не хуже средних с Восточным Союзом, не враждебные с Западом и отсутствие войны. Восток получит право добывать 4 единицы приграничной нефти каждую неделю до конца кампании; поддержка власти −6. Для этой концовки нужно сохранить отношения с Востоком и мир до финала."
		"west": return "Требуются отношения не хуже средних с Западной Федерацией, не враждебные с Востоком и отсутствие войны. Протокол арбитража стоит 0,60 млн каждую неделю, разовая подготовка — 5 млн; поддержка власти −4. Для этой концовки нужно сохранить отношения с Западом и мир до финала."
		"neutral": return "Требуются отношения не хуже средних с обоими соседями и отсутствие войны. Независимые гарантии обойдутся в 6 млн, стабильность −2. Для нейтральной концовки нужно сохранить отношения не хуже средних с обоими соседями до финала."
		"legacy": return "Требуются авторитарный курс от 1 и лояльность армии от 40%. Поддержка власти −8, профсоюзы −10, стабильность +5, армия +5. Для этой концовки армия должна остаться лояльной до финала."
		"unresolved": return "Президент заранее отвергает признанный порядок передачи власти. Поддержка −10, стабильность −8, армия −5. В конце 26-й недели это приведёт к концовке о несостоявшейся передаче власти, если правительство доживёт до неё."
	return ""


func final_course_available(course: String) -> bool:
	if int(state.get("week", 1)) < 20 or bool(state.get("final_course_reserved", false)) or str(state.get("final_alignment", "")) != "" or int(state.get("influence", 0)) < 1:
		return false
	if course in ["east", "west", "neutral"] and (bool(state.get("at_war", false)) or foreign_action_used_this_week()):
		return false
	match course:
		"east": return projected_pending_value("east_relation") >= 2 and projected_pending_value("west_relation") >= 1
		"west": return projected_pending_value("west_relation") >= 2 and projected_pending_value("east_relation") >= 1
		"neutral": return projected_pending_value("east_relation") >= 2 and projected_pending_value("west_relation") >= 2
		"legacy": return int(state.get("authoritarian", 0)) >= 1 and int(state.get("army", 0)) >= 40
		"unresolved": return true
	return false


func perform_final_course_action(course: String) -> void:
	if not final_course_available(course):
		show_notice("Этот курс сейчас недоступен. Наведите курсор на кнопку, чтобы увидеть условия.")
		return
	var effects: Dictionary = {}
	var flags: Dictionary = {"final_alignment": course}
	match course:
		"east":
			effects = {"support": -6}
			flags["east_border_oil_concession"] = true
		"west":
			effects = {"money": -5, "support": -4}
			flags["west_investment_arbitration"] = true
		"neutral": effects = {"money": -6, "stability": -2}
		"legacy": effects = {"support": -8, "stability": 5, "army": 5, "clan_workers": -10}
		"unresolved": effects = {"support": -10, "stability": -8, "army": -5}
	state.influence = int(state.get("influence", 0)) - 1
	state.final_course_reserved = true
	if course in ["east", "west", "neutral"]:
		state.foreign_action_week = int(state.get("week", 1))
	queue_week_change("Заявление о будущем курсе республики", effects, flags)
	state.last_foreign_action = "Объявленный курс вступит в силу после завершения недели."
	update_interface()
	autosave_if_iron()
	if course in ["east", "west", "neutral"]:
		show_foreign_policy()
	else:
		show_ministers()


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
	var debt_rate_info := label("СТАВКА ПО ДОЛГУ: %.3f%% В НЕДЕЛЮ  ⓘ" % debt_weekly_interest_percent(), 16, Color("#5f594d"))
	debt_rate_info.tooltip_text = "Базовый недельный платёж равен долгу × ставку, но не меньше 0,5 млн. Сокращённое обслуживание оплачивает 70%% расчётной суммы, затем повышает ставку на %.3f п.п. Приоритетное оплачивает 140%%; часть сверх процентов погашает основной долг, а ставка снижается на %.3f п.п. до минимума %.2f%%." % [DEBT_UNDERPAY_RATE_INCREASE * 100.0, DEBT_PRIORITY_RATE_DECREASE * 100.0, DEBT_MIN_WEEKLY_RATE * 100.0]
	summary_box.add_child(debt_rate_info)
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
	corruption_info.mouse_filter = Control.MOUSE_FILTER_STOP
	add_hover_detail(corruption_info, corruption_levels_tooltip(tier))
	summary_box.add_child(corruption_info)
	var creditor_level := int(state.get("creditor_obligations", 0))
	var creditor_info := label("Международные кредиторы: %s ⓘ" % creditor_obligation_level(creditor_level), 16, Color("#5f594d"))
	var creditor_detail := "Текущие комиссии и надзор: %.2f млн в неделю. Сокращённое обслуживание долга еженедельно повышает ставку и ужесточает действующие условия на одну категорию. Приоритетные выплаты снижают ставку; четыре недели подряд также смягчают условия на одну категорию." % creditor_oversight_cost()
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
	add_economy_population_panel(content, tier)
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
	if int(state.get("week", 1)) < 2:
		offer_tutorial("budget")


func add_economy_population_panel(parent: VBoxContainer, corruption_tier: int) -> void:
	var current_total := total_population()
	var current_workable := workable_population()
	var current_dependents := dependent_population()
	var current_army := int(state.get("army_personnel", 0))
	var future_total := projected_total_population()
	var future_workable := projected_workable_population()
	var future_dependents := projected_dependent_population()
	var future_army := projected_pending_value("army_personnel")
	var pending := current_total != future_total or current_workable != future_workable or current_army != future_army
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", style(Color("#d8cdb5"), 14, Color("#92846c"), 1))
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 5)
	panel.add_child(box)
	box.add_child(label("НАСЕЛЕНИЕ И РАБОЧАЯ СИЛА", 16, Color("#6f3e37")))
	box.add_child(label("НАСЕЛЕНИЕ: %s • РАБОТОСПОСОБНЫЕ: %s" % [format_people(current_total), format_people(current_workable)], 19, INK))
	box.add_child(label("НЕРАБОТОСПОСОБНЫЕ: %s • ВОЕННОСЛУЖАЩИЕ: %s" % [format_people(current_dependents), format_people(current_army)], 15, Color("#5f594d")))
	if pending:
		var future_line := label("ПОСЛЕ РЕШЕНИЙ: население %s • работоспособные %s • неработоспособные %s • армия %s  ⓘ" % [format_people(future_total), format_people(future_workable), format_people(future_dependents), format_people(future_army)], 14, PENDING_BLUE)
		future_line.tooltip_text = "Голубые значения уже определены решениями этой недели, но применятся при переходе к следующей."
		box.add_child(future_line)
	var tax_item: Dictionary = weekly_income_breakdown()[0]
	var tax_gross := float(tax_item.get("amount", 0.0))
	var tax_final := adjusted_money_transaction(tax_gross, corruption_tier)
	var social_final := budget_final_for_level("budget_social", budget_level("budget_social"), corruption_tier)
	var finance_line := label("НАЛОГИ РАБОТОСПОСОБНЫХ: +%.2f млн/нед. • СОЦИАЛЬНЫЕ РАСХОДЫ: −%.2f млн/нед.  ⓘ" % [tax_final, social_final], 14, Color("#5f594d"))
	finance_line.tooltip_text = "%s\n\n%s\n\nНеработоспособные — все жители вне рабочей силы и действующей армии: дети, пенсионеры, люди с инвалидностью и другие получатели поддержки. Социальная статья рассчитывается от их общего числа." % [
		transaction_tooltip("Налоги работоспособных", tax_gross, corruption_tier, str(tax_item.get("calculation", ""))),
		budget_breakdown_tooltip(budget_item_by_key("budget_social"), corruption_tier)
	]
	if language_code == "en":
		finance_line.tooltip_text = "%s\n\n%s\n\nDependents are residents outside the workforce and active army: children, pensioners, people with disabilities and other benefit recipients. Social spending depends on their total number." % [transaction_tooltip("Налоги работоспособных", tax_gross, corruption_tier, str(tax_item.get("calculation", ""))), budget_breakdown_tooltip(budget_item_by_key("budget_social"), corruption_tier)]
	box.add_child(finance_line)
	var report_line := label(str(state.get("last_population_report", "Месячного демографического отчёта ещё не было.")) + "  ⓘ", 14, BLUE)
	var weeks_to_report := 4 - posmod(int(state.get("week", 1)) - 1, 4)
	var accrued_health_change := int(state.get("health_funding_balance", 0)) * HEALTH_POPULATION_WEEK_DELTA
	var projected_health_change := accrued_health_change + weeks_to_report * (budget_level("budget_health") - 1) * HEALTH_POPULATION_WEEK_DELTA
	report_line.tooltip_text = "Следующий пересчёт через %d нед.\nОбразование и медицина: уже накоплено %+d жителей; при сохранении текущего уровня итог будет %+d. Каждая неделя приоритета даёт +3 тыс., сокращения — −3 тыс.\n90%% изменения приходится на работоспособных. Церковь добавляет население отдельно; светское образование вдвое ослабляет её эффект." % [weeks_to_report, accrued_health_change, projected_health_change]
	box.add_child(report_line)
	var recruitment_line := label("Призыв доступен только из работоспособного населения.  ⓘ", 14, Color("#5f594d"))
	recruitment_line.tooltip_text = "Призыв переводит людей из работоспособного населения в армию, не меняя общее население. Демобилизация и дезертирство возвращают выживших в работоспособное население. Боевые потери уменьшают армию и общее население."
	box.add_child(recruitment_line)


func add_income_card(parent: Container, item: Dictionary, corruption_tier: int) -> void:
	var gross := float(item.get("amount", 0.0))
	var actual := adjusted_money_transaction(gross, corruption_tier)
	var detail := transaction_tooltip(str(item.get("title", "Доход")), gross, corruption_tier, str(item.get("calculation", "")))
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", style(Color("#ded4bf"), 10, Color("#9a8c73"), 1))
	add_hover_detail(panel, detail)
	parent.add_child(panel)
	var operation_text := "%s: %.2f M %s  ⓘ" % [game_localization.text(str(item.get("title", "Операция"))), absf(actual), "expense" if actual < 0.0 else "income"] if language_code == "en" else "%s: %.2f млн%s ⓘ" % [str(item.get("title", "Операция")), absf(actual), " расход" if actual < 0.0 else " доход"]
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
	button.tooltip_text = budget_breakdown_tooltip(item, corruption_tier) + ("\n\nClick to compare the three funding levels and choose one." if language_code == "en" else "\n\nНажмите, чтобы сравнить все три уровня и выбрать новый.")
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
	icon.name = "BudgetArtwork_" + key
	icon.custom_minimum_size = Vector2(64, 64)
	var custom_icon_path := str(CUSTOM_BUDGET_ICON_PATHS.get(key, ""))
	var custom_icon := load(custom_icon_path) as Texture2D if custom_icon_path != "" else null
	icon.setup(key, accent, custom_icon)
	icon.set_meta("uses_custom_art", custom_icon != null)
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
	if language_code == "en":
		submit.tooltip_text = ("The president will approve the entire draft without a parliamentary vote.\n\n" if override_active else "Parliament votes on the entire draft at once. If it rejects the draft, funding, group relations and decision points remain unchanged.\n\n") + str(forecast.get("detail", ""))
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
	var value_caption := "%d of %d • %s%s" % [value, maximum, game_localization.text(explanation), " ⓘ" if tooltip_detail != "" else ""] if language_code == "en" else "%d из %d • %s%s" % [value, maximum, explanation, " ⓘ" if tooltip_detail != "" else ""]
	var value_text := label(value_caption, 14, INK)
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
		add_effect_delta(reaction, "support", steps * (1 if delta > 0 else -2))
		add_effect_delta(reaction, "clan_workers", steps * (4 if delta > 0 else -4))
	elif key == "budget_health":
		add_effect_delta(reaction, "support", steps * (1 if delta > 0 else -1))
		add_effect_delta(reaction, "stability", steps * (1 if delta > 0 else -1))
	elif key == "budget_defense":
		add_effect_delta(reaction, "army", steps * (3 if delta > 0 else -3))
		add_effect_delta(reaction, "war_support", steps * (1 if delta > 0 else -1))
	elif key == "budget_infrastructure":
		add_effect_delta(reaction, "clan_regions", steps * (4 if delta > 0 else -4))
		add_effect_delta(reaction, "stability", steps if delta > 0 else -steps)
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
	army_hint.tooltip_text = "Новобранцы переходят только из работоспособного населения. Демобилизованные и дезертиры возвращаются в эту же группу. Поддержка войны 30% и ниже замедляет набор, 65% и выше ускоряет его. Боеспособность складывается из подготовки, наземной техники, авиации, снабжения и морали."
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
	var imported_fuel := imported_army_fuel_bonus()
	var supply_caption := "%d%s of %d units" % [int(state.get("oil_to_army", 0)), " + %d imported" % imported_fuel if imported_fuel > 0 else "", int(projected_army["oil_need"])] if language_code == "en" else "%d%s из %d ед." % [int(state.get("oil_to_army", 0)), " + %d имп." % imported_fuel if imported_fuel > 0 else "", int(projected_army["oil_need"])]
	add_army_metric(grid, "НЕФТЯНОЕ СНАБЖЕНИЕ", supply_caption, "Ожидаемое покрытие потребности: %d%%. Дефицит режет боеспособность.%s" % [expected_supply, " Импортные %d ед. по соглашению Дарьи Крес не расходуют собственную нефть и не уменьшают экспорт." % imported_fuel if imported_fuel > 0 else ""], BLUE, expected_supply != current_supply, "%d%%" % current_supply)
	content.add_child(label("ПРОИЗВОДСТВО И СНАБЖЕНИЕ", 15, Color("#6f3e37")))
	var production_hint := label("Внутри страны производится только наземная техника. Остаток ресурсов продаётся автоматически. ⓘ", 14, Color("#5f594d"))
	production_hint.tooltip_text = "Металл и нефть нельзя запасать. Авиационного производства в республике нет; авиация меняется только через закупки, помощь, потери и события."
	content.add_child(production_hint)
	var tier := int(state.get("corruption_tier", 0))
	add_resource_row(content, "metal_to_equipment", "МЕТАЛЛ → НАЗЕМНАЯ ТЕХНИКА", int(state.get("metal_to_equipment", 0)), current_metal_output(), "Выпуск +%d ед. • нагрузка на баланс %.2f млн" % [equipment_production_per_week(), equipment_balance_load(tier)], equipment_production_tooltip(tier), "army")
	var oil_export_gross := float(exported_oil()) * current_oil_price()
	var oil_export_final := adjusted_money_transaction(oil_export_gross, tier)
	add_resource_row(content, "oil_to_army", "НЕФТЬ → СНАБЖЕНИЕ", int(state.get("oil_to_army", 0)), current_oil_output(), "Снабжение %d%% • экспорт %.2f млн" % [army_supply(), oil_export_final], "Потребность армии: %d ед. нефти\nДоступная собственная добыча: %d ед. (%s)\nВыделено собственной нефти: %d ед.\nИмпортировано по соглашениям: %d ед.\nПокрытие: %d%%\nОстаток собственной нефти на экспорт: %d ед.\n%s" % [army_oil_need(), current_oil_output(), oil_output_reduction_note(), int(state.get("oil_to_army", 0)), imported_fuel, army_supply(), exported_oil(), transaction_tooltip("Экспорт нефти", oil_export_gross, tier, "%d ед. × %.2f млн" % [exported_oil(), current_oil_price()])], "army")
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
	if bool(state.get("at_war", false)) and int(state.get("week", 1)) < 7:
		offer_tutorial("war")


func add_recruitment_option(parent: Container, model_id: String) -> void:
	var data: Dictionary = RECRUITMENT_MODELS[model_id]
	var current := str(state.get("recruitment_model", "mixed")) == model_id
	var locked := model_id == "mobilization" and not bool(state.get("at_war", false)) and not bool(state.get("military_threat", false))
	var button := Button.new()
	var adjusted_speed := roundi(float(data.get("speed", 6000)) * recruitment_speed_multiplier(projected_pending_value("war_support")))
	button.text = "%s%s\nTarget: %s • intake: %s/week • training: %d%% ⓘ" % [game_localization.text(str(data["title"]).to_upper()), " • SELECTED" if current else "", format_people(recruitment_target_for(model_id)), format_people(adjusted_speed), int(data["training"])] if language_code == "en" else "%s%s\nЦель: %s • темп: %s/нед. • подготовка %d%% ⓘ" % [str(data["title"]).to_upper(), " • ВЫБРАНО" if current else "", format_people(recruitment_target_for(model_id)), format_people(adjusted_speed), int(data["training"])]
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
	if language_code == "en":
		var speed_note_en := "War support changes weekly recruitment: currently ×%.2f." % recruitment_speed_multiplier(projected_pending_value("war_support"))
		var description_en := game_localization.text(str(data["description"]))
		button.tooltip_text = "Mobilization requires war or a declared military threat.\n%s\n%s" % [description_en, speed_note_en] if locked else "%s\n%s\nChanging the recruitment model costs 1 decision point. Expanding conscription with war support at 30%% or below triggers protests." % [description_en, speed_note_en]
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
	if int(state.get("week", 1)) >= 20:
		add_final_mandate_panel(content)
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


func add_final_mandate_panel(parent: VBoxContainer) -> void:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", style(Color("#d9ceb7"), 14, RED, 1))
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	panel.add_child(box)
	box.add_child(label("БУДУЩИЙ МАНДАТ", 17, INK))
	box.add_child(label("Можно один раз объявить, на каком основании вы намерены править после временного срока. Обещание вступит в силу в конце недели и повлияет на концовку.", 14, Color("#5f594d")))
	for course in ["legacy", "unresolved"]:
		var button := foreign_policy_button(final_course_button_text(course))
		button.disabled = not final_course_available(course)
		button.tooltip_text = final_course_explanation(course)
		button.pressed.connect(perform_final_course_action.bind(course))
		box.add_child(button)


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
		var faction_caption := "%s • %d seats" % [game_localization.text(str(faction["title"])), int(faction["seats"])] if language_code == "en" else "%s • %d мест" % [str(faction["title"]), int(faction["seats"])]
		var name_text := label(faction_caption, 15, INK)
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
			texts.add_child(label("НЕДОСТУПЕН: " + minister_lock_reason(slot, candidate), 13, RED))
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
	if slot == "foreign":
		schedule_foreign_minister_resignation_if_needed()
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


func show_notice(message: String, tooltip_detail := "", play_warning_sound := true) -> void:
	if play_warning_sound:
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


func build_tutorial_focus_layer() -> void:
	tutorial_focus_layer = Control.new()
	tutorial_focus_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tutorial_focus_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_root.add_child(tutorial_focus_layer)
	tutorial_left_mask = PanelContainer.new()
	tutorial_left_mask.anchor_left = 0.0
	tutorial_left_mask.anchor_right = 0.0
	tutorial_left_mask.anchor_top = 0.0
	tutorial_left_mask.anchor_bottom = 1.0
	tutorial_left_mask.offset_left = 22.0
	tutorial_left_mask.offset_right = 322.0
	tutorial_left_mask.offset_top = 54.0
	tutorial_left_mask.offset_bottom = -12.0
	tutorial_left_mask.mouse_filter = Control.MOUSE_FILTER_STOP
	tutorial_left_mask.add_theme_stylebox_override("panel", style(Color("#101418", 0.97), 18, Color("#343b43"), 1))
	tutorial_focus_layer.add_child(tutorial_left_mask)
	var left_message := label("ПОКАЗАТЕЛИ ОТКРОЮТСЯ\nПОСЛЕ ПЕРВОГО РЕШЕНИЯ", 17, GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	left_message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	left_message.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_left_mask.add_child(left_message)
	tutorial_right_mask = PanelContainer.new()
	tutorial_right_mask.anchor_left = 1.0
	tutorial_right_mask.anchor_right = 1.0
	tutorial_right_mask.anchor_top = 0.0
	tutorial_right_mask.anchor_bottom = 1.0
	tutorial_right_mask.offset_left = -385.0
	tutorial_right_mask.offset_right = -22.0
	tutorial_right_mask.offset_top = 54.0
	tutorial_right_mask.offset_bottom = -12.0
	tutorial_right_mask.mouse_filter = Control.MOUSE_FILTER_STOP
	tutorial_right_mask.add_theme_stylebox_override("panel", style(Color("#101418", 0.97), 18, Color("#343b43"), 1))
	tutorial_focus_layer.add_child(tutorial_right_mask)
	var right_message := label("УПРАВЛЕНИЕ ОТКРОЕТСЯ\nПОСТЕПЕННО", 17, GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	right_message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	right_message.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_right_mask.add_child(right_message)


func refresh_tutorial_focus() -> void:
	if not is_instance_valid(tutorial_focus_layer) or not is_instance_valid(tutorial_left_panel) or not is_instance_valid(tutorial_right_panel):
		return
	var week := int(state.get("week", 1))
	var guided := tutorial_enabled and not state.is_empty()
	var first_choice_made := week > 1 or events_resolved_this_week > 0 or "chapter_1" in tutorial_seen
	var emergency_money := guided and (bool(state.get("financial_crisis_shown", false)) or weekly_balance_forecast() <= FINANCIAL_CRISIS_RESERVE or str(current_event.get("title", "")) == "Счета к оплате")
	var emergency_war := guided and (bool(state.get("at_war", false)) or bool(state.get("military_threat", false)))
	var emergency_foreign := emergency_war or int(state.get("east_relation", 2)) == 0 or int(state.get("west_relation", 2)) == 0
	var foreign_unlocked := "foreign_event" in tutorial_seen or emergency_foreign
	if is_instance_valid(tutorial_left_status_extra):
		tutorial_left_status_extra.visible = not guided or week >= 3 or emergency_money or emergency_war
	if is_instance_valid(tutorial_left_clans_section):
		tutorial_left_clans_section.visible = not guided or week >= 2
	if is_instance_valid(tutorial_left_foreign_section):
		tutorial_left_foreign_section.visible = not guided or foreign_unlocked
	if is_instance_valid(tutorial_left_army_section):
		tutorial_left_army_section.visible = not guided or week >= 6 or emergency_war
	if is_instance_valid(tutorial_minister_section):
		tutorial_minister_section.visible = not guided or week >= 4
	if is_instance_valid(influence_label):
		influence_label.visible = not guided or week >= 3 or foreign_unlocked
	if is_instance_valid(tutorial_sections_header):
		tutorial_sections_header.visible = not guided or week >= 2 or emergency_money or emergency_war or foreign_unlocked
	if is_instance_valid(tutorial_section_grid):
		tutorial_section_grid.visible = not guided or week >= 2 or emergency_money or emergency_war or foreign_unlocked
	var unlock_weeks := {"economy": 3, "report": 2, "government": 4, "clans": 2, "army": 6}
	for section_key in tutorial_section_buttons.keys():
		var section_button: Button = tutorial_section_buttons[section_key]
		var early_unlock: bool = (section_key == "economy" and emergency_money) or (section_key == "army" and emergency_war)
		section_button.visible = not guided or (foreign_unlocked if section_key == "foreign" else week >= int(unlock_weeks.get(section_key, 1)) or early_unlock)
	if is_instance_valid(law_button):
		law_button.visible = not guided or week >= 5
	tutorial_left_mask.visible = guided and week == 1 and not first_choice_made
	tutorial_right_mask.visible = guided and week == 1 and not week_ready_for_new_week() and not emergency_money and not emergency_war and not foreign_unlocked


func clear_tutorial_dialog() -> void:
	if is_instance_valid(tutorial_dialog):
		tutorial_dialog.queue_free()
	tutorial_dialog = null


func finish_tutorial_dialog() -> void:
	clear_tutorial_dialog()
	refresh_tutorial_focus()
	maybe_show_foreign_event_tutorial()
	autosave_if_iron()


func show_tutorial_briefing(chapter_id: String, chapter_title: String, chapter_body: String) -> void:
	if not tutorial_enabled or chapter_id in tutorial_seen or not is_instance_valid(screen_layer):
		return
	tutorial_seen.append(chapter_id)
	clear_tutorial_card()
	clear_tutorial_dialog()
	refresh_tutorial_focus()
	tutorial_dialog = Control.new()
	tutorial_dialog.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tutorial_dialog.mouse_filter = Control.MOUSE_FILTER_STOP
	screen_layer.add_child(tutorial_dialog)
	var shade := ColorRect.new()
	shade.color = Color(0.0, 0.0, 0.0, 0.15)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	tutorial_dialog.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_dialog.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(780, 0)
	panel.add_theme_stylebox_override("panel", style(PAPER, 22, GOLD, 3))
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	panel.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 22)
	margin.add_child(content)
	content.add_child(label("ПАМЯТКА ПРЕЗИДЕНТСКОГО АППАРАТА", 17, Color("#6f3e37"), HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label(chapter_title, 30, INK, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label(chapter_body, 19, INK, HORIZONTAL_ALIGNMENT_LEFT if chapter_id in ["chapter_2", "chapter_3"] else HORIZONTAL_ALIGNMENT_CENTER))
	var continue_button := menu_button("ПОНЯТНО  •  ПРОДОЛЖИТЬ")
	continue_button.pressed.connect(finish_tutorial_dialog)
	content.add_child(continue_button)


func show_tutorial_week_briefing() -> void:
	var week := int(state.get("week", 1))
	if not TUTORIAL_WEEK_BRIEFINGS.has(week):
		return
	var data: Dictionary = TUTORIAL_WEEK_BRIEFINGS[week]
	show_tutorial_briefing("chapter_%d" % week, str(data["title"]), str(data["body"]))


func clear_tutorial_card() -> void:
	if is_instance_valid(tutorial_card):
		tutorial_card.queue_free()
	tutorial_card = null


func offer_tutorial(tutorial_id: String) -> void:
	if not tutorial_enabled or tutorial_id in tutorial_seen or not TUTORIAL_CARDS.has(tutorial_id) or not is_instance_valid(screen_layer):
		return
	tutorial_seen.append(tutorial_id)
	clear_tutorial_card()
	var tutorial_data: Dictionary = TUTORIAL_CARDS[tutorial_id]
	tutorial_card = PanelContainer.new()
	tutorial_card.mouse_filter = Control.MOUSE_FILTER_STOP
	tutorial_card.add_theme_stylebox_override("panel", style(Color("#222a31"), 14, GOLD, 2))
	var inline_parent: VBoxContainer = null
	if is_instance_valid(active_overlay_scroll) and active_overlay_scroll.get_child_count() > 0:
		inline_parent = active_overlay_scroll.get_child(0) as VBoxContainer
	if is_instance_valid(inline_parent):
		inline_parent.add_child(tutorial_card)
		inline_parent.move_child(tutorial_card, 0)
		active_overlay_scroll.scroll_vertical = 0
	else:
		tutorial_card.anchor_left = 0.5
		tutorial_card.anchor_right = 0.5
		tutorial_card.anchor_top = 1.0
		tutorial_card.anchor_bottom = 1.0
		tutorial_card.offset_left = -350.0
		tutorial_card.offset_right = 350.0
		tutorial_card.offset_top = -110.0
		tutorial_card.offset_bottom = -10.0
		screen_layer.add_child(tutorial_card)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	tutorial_card.add_child(margin)
	var content := HBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	margin.add_child(content)
	var text_column := VBoxContainer.new()
	text_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_column.add_theme_constant_override("separation", 3)
	content.add_child(text_column)
	text_column.add_child(label("ЗАПИСКА АППАРАТА  •  " + str(tutorial_data["title"]), 17, GOLD))
	text_column.add_child(label(str(tutorial_data["body"]), 19, CREAM))
	var buttons := VBoxContainer.new()
	buttons.custom_minimum_size = Vector2(128, 0)
	buttons.add_theme_constant_override("separation", 4)
	content.add_child(buttons)
	var dismiss := menu_button("ПОНЯТНО")
	dismiss.custom_minimum_size = Vector2(120, 46)
	dismiss.add_theme_font_size_override("font_size", 15)
	dismiss.pressed.connect(clear_tutorial_card)
	buttons.add_child(dismiss)


func show_guide() -> void:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(840, 650)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	scroll.add_child(content)
	content.add_child(label("КАК ИГРАТЬ", 30, INK, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label("Памятка президентского аппарата. Её можно открыть снова в любой момент.", 16, Color("#5f594d"), HORIZONTAL_ALIGNMENT_CENTER))
	for section in [
		["ЦЕЛЬ КАМПАНИИ", "У вас 26 недель до досрочных выборов. Итог зависит от решений, состояния страны и того, удастся ли удержаться у власти. Единственного «правильного» курса нет."],
		["ДОКЛАДЫ И НЕДЕЛЯ", "Каждую неделю нужно рассмотреть не меньше трёх докладов. Выбирайте по ситуации: результат решения показывается сразу, но численные изменения применяются при переходе к новой неделе. Голубые числа слева — ожидаемый итог уже выбранных действий."],
		["ЭКОНОМИКА", "Во вкладке «Экономика» видны недельные доходы, расходы и прогноз казны. Наведите курсор на сумму или категорию коррупции, чтобы увидеть расчёт и уровни. Если денег не хватит на обязательные выплаты, кампания завершится дефолтом. Коррупция уменьшает поступления, но не повышает цены."],
		["ПРАВИТЕЛЬСТВО И ЗАКОНЫ", "Парламент голосует за бюджетные поправки и смену министров. Министров выбираете вы; они меняют события и доступные возможности. Законопроект можно вести только один: после запуска он продвигается сам при наличии очков решений, а до завершения его можно отменить."],
		["СОСЕДИ", "У каждого соседа виден один из четырёх уровней отношений. При министре иностранных дел Лее Нарин доступны дипломатические миссии: сближение с одной стороной отдаляет другую. При враждебных отношениях завершение недели приводит к вторжению; во время войны улучшать отношения с противником нельзя."],
		["АРМИЯ И НАСЕЛЕНИЕ", "Во вкладке «Армия» выбирается способ комплектования и распределяются ресурсы. Призыв берёт людей только из работоспособного населения. На войне важны численность, боеспособность, техника, авиация и снабжение. Каждую военную неделю стабильность падает на 4, 2 или 1 пункт при низкой, средней или высокой поддержке войны; нехватка людей на фронте добавляет ущерб."],
		["ГРУППЫ И ОБЩЕСТВО", "Поддержка кланов и общественных групп меняет их бонусы и противодействие. Непопулярные решения могут вызвать протест или забастовку. При стабильности 70% и выше новые протесты слабее на одну ступень, при 30% и ниже сильнее. Откройте «Кланы» и недельную «Сводку», чтобы понять, кто и почему отреагировал."],
		["УПРАВЛЕНИЕ", "Мышь — основные действия. A / D — левый и правый ответ; S / ↓ — третий. Esc закрывает вкладку. F4 / F11 переключают полный экран. Обучение выбирается при начале новой игры, подсказки последствий — в настройках."]
	]:
		content.add_child(weekly_report_panel(str(section[0]), [str(section[1])], Color("#6f3e37")))
	var close := menu_button("ЗАКРЫТЬ СПРАВКУ")
	close.pressed.connect(close_overlay)
	content.add_child(close)
	show_overlay(scroll, PAPER, true, 900)


func show_overlay(content: Control, panel_color: Color, can_cancel: bool, panel_width := 610.0) -> void:
	clear_tutorial_card()
	stop_sidebar_number_animation()
	# Замена одного окна другим не означает возвращение к управлению и не
	# должна запускать обновление/анимацию боковых показателей.
	close_overlay(false)
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
	localize_visible_tree()


func show_debug_cheats() -> void:
	if not OS.is_debug_build() or state.is_empty() or not is_instance_valid(game_root):
		return
	stop_sidebar_number_animation()
	debug_cheat_fields.clear()
	debug_cheat_panel = Control.new()
	debug_cheat_panel.name = "DebugCheatPanel"
	debug_cheat_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	debug_cheat_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(debug_cheat_panel)
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.025, 0.03, 0.90)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	debug_cheat_panel.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	debug_cheat_panel.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(810, 0)
	panel.add_theme_stylebox_override("panel", style(PAPER, 20, GOLD, 2))
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side_name in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side_name, 20)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)
	column.add_child(label("ОТЛАДКА · ЧИТЫ", 25, INK, HORIZONTAL_ALIGNMENT_CENTER))
	column.add_child(label("F2 или Esc — закрыть. Значения применяются сразу и сохраняются обычным способом.", 14, Color("#625b50"), HORIZONTAL_ALIGNMENT_CENTER))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(760, 510)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	var sections := VBoxContainer.new()
	sections.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sections.add_theme_constant_override("separation", 13)
	scroll.add_child(sections)
	add_debug_cheat_section(sections, "ФИНАНСЫ И УПРАВЛЕНИЕ", [
		["money", "Казна, млн", 10000, 0.1], ["debt", "Долг, млн", 10000, 0.1],
		["influence", "Очки решений", 30, 1], ["corruption_tier", "Коррупция: 0 минимум · 4 паралич", 4, 1]
	])
	add_debug_cheat_section(sections, "ОБЩЕСТВО И ГРУППЫ", [
		["support", "Поддержка власти", 100, 1], ["stability", "Стабильность", 100, 1],
		["war_support", "Поддержка войны", 100, 1], ["clan_oligarchs", "Олигархи", 100, 1],
		["clan_church", "Церковь", 100, 1], ["clan_workers", "Профсоюзы", 100, 1],
		["clan_regions", "Регионы", 100, 1]
	])
	add_debug_cheat_section(sections, "НАСЕЛЕНИЕ И АРМИЯ", [
		["population_total", "Население", 10000000, 1000], ["population_workable", "Работоспособные", 10000000, 1000],
		["army", "Лояльность армии", 100, 1], ["army_personnel", "Военнослужащие", 1000000, 1000],
		["army_equipment", "Наземная техника", 10000, 10], ["army_aircraft", "Авиация", 1000, 1]
	])
	add_debug_cheat_section(sections, "СОСЕДИ", [
		["east_relation", "Восток: 0 вражда · 3 партнёрство", 3, 1],
		["west_relation", "Запад: 0 вражда · 3 партнёрство", 3, 1]
	])
	sections.add_child(label("Отношение 0 может запустить вторжение. Во время войны отношение с противником не меняется.", 14, Color("#625b50")))
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	column.add_child(actions)
	var ending_preview_button := menu_button("ПОСМОТРЕТЬ КОНЦОВКУ")
	ending_preview_button.name = "EndingPreviewButton"
	ending_preview_button.custom_minimum_size.x = 260
	ending_preview_button.pressed.connect(show_debug_ending_preview)
	actions.add_child(ending_preview_button)
	var apply_button := menu_button("ПРИМЕНИТЬ")
	apply_button.pressed.connect(apply_debug_cheats)
	actions.add_child(apply_button)
	var close_button := menu_button("ЗАКРЫТЬ")
	close_button.pressed.connect(close_debug_cheats)
	actions.add_child(close_button)


func add_debug_cheat_section(parent: VBoxContainer, title_text: String, fields: Array) -> void:
	parent.add_child(label(title_text, 17, Color("#8b6c4b")))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 7)
	parent.add_child(grid)
	for field_data in fields:
		var key := str(field_data[0])
		var field_box := HBoxContainer.new()
		field_box.custom_minimum_size = Vector2(355, 38)
		grid.add_child(field_box)
		var field_label := label(str(field_data[1]), 14, INK)
		field_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		field_box.add_child(field_label)
		var spin := SpinBox.new()
		spin.custom_minimum_size = Vector2(120, 36)
		spin.min_value = 0
		spin.max_value = float(field_data[2])
		spin.step = float(field_data[3])
		spin.value = float(state.get(key, 0))
		var edit := spin.get_line_edit()
		edit.add_theme_color_override("font_color", INK)
		edit.add_theme_color_override("font_selected_color", INK)
		edit.add_theme_stylebox_override("normal", style(Color("#f4eddd"), 6, Color("#98876b"), 1))
		edit.add_theme_stylebox_override("focus", style(Color("#fff8e8"), 6, GOLD, 2))
		if key in ["east_relation", "west_relation"] and at_war_with(key.trim_suffix("_relation")):
			spin.editable = false
			spin.tooltip_text = "Во время войны отношения с противником нельзя улучшить."
		field_box.add_child(spin)
		debug_cheat_fields[key] = spin


func apply_debug_cheats() -> void:
	if not OS.is_debug_build() or not is_instance_valid(debug_cheat_panel) or state.is_empty():
		return
	for key in debug_cheat_fields:
		if key in ["east_relation", "west_relation"] and at_war_with(key.trim_suffix("_relation")):
			continue
		var spin := debug_cheat_fields[key] as SpinBox
		state[key] = snappedf(spin.value, 0.01) if key in ["money", "debt"] else roundi(spin.value)
	state.population_total = maxi(0, int(state.get("population_total", 0)))
	state.army_personnel = clampi(int(state.get("army_personnel", 0)), 0, int(state.population_total))
	state.population_workable = clampi(int(state.get("population_workable", 0)), 0, int(state.population_total) - int(state.army_personnel))
	start_invasion_if_needed()
	update_interface()
	autosave_if_iron()
	close_debug_cheats()


func close_debug_cheats() -> void:
	if is_instance_valid(debug_cheat_panel):
		debug_cheat_panel.queue_free()
	debug_cheat_panel = null
	debug_cheat_fields.clear()
	request_sidebar_refresh()


func show_debug_ending_preview() -> void:
	if not OS.is_debug_build() or not is_instance_valid(debug_cheat_panel) or state.is_empty():
		return
	close_debug_cheats()
	ending_preview_active = true
	show_ending("ПРОСМОТР КОНЦОВКИ", "Так выглядит эпилог при нынешнем состоянии республики. Это только просмотр: после возвращения игра продолжится с того же места.")


func close_debug_ending_preview() -> void:
	if not ending_preview_active or not is_instance_valid(ending_preview_game_layer):
		return
	if is_instance_valid(ending_transition):
		ending_transition.kill()
	var preview_layer := screen_layer
	screen_layer = ending_preview_game_layer
	screen_layer.show()
	ending_preview_active = false
	ending_preview_game_layer = null
	ending_track = null
	ending_back_button = null
	ending_next_button = null
	ending_progress_label = null
	ending_transition = null
	ending_chapter_index = 0
	preview_layer.queue_free()
	play_game_sound("page")
	request_sidebar_refresh()
	localize_visible_tree()


func run_debug_cheat_smoke_test() -> void:
	var failures: Array[String] = []
	if not OS.is_debug_build():
		failures.append("Тестовая сборка не определена как отладочная.")
	else:
		start_game("Сид: 1991", 1991)
		show_overlay(VBoxContainer.new(), PAPER, false)
		var f2 := InputEventKey.new()
		f2.keycode = KEY_F2
		f2.pressed = true
		_input(f2)
		if not is_instance_valid(debug_cheat_panel):
			failures.append("F2 не открывает панель читов в отладочной сборке.")
		else:
			(debug_cheat_fields["money"] as SpinBox).value = 100.0
			(debug_cheat_fields["support"] as SpinBox).value = 75.0
			(debug_cheat_fields["population_workable"] as SpinBox).value = 10000000.0
			apply_debug_cheats()
			if not is_equal_approx(float(state.money), 100.0) or int(state.support) != 75:
				failures.append("Изменения читов не применились сразу.")
			if int(state.population_workable) > int(state.population_total) - int(state.army_personnel):
				failures.append("Чит нарушил ограничение работоспособного населения.")
			if is_instance_valid(debug_cheat_panel) or not is_instance_valid(overlay):
				failures.append("Закрытие читов не вернуло предыдущую вкладку.")
			_input(f2)
			_input(f2)
			if is_instance_valid(debug_cheat_panel):
				failures.append("Повторный F2 не закрывает панель читов.")
		close_overlay()
		var game_layer_before_preview := screen_layer
		var state_before_preview := state.duplicate(true)
		var event_before_preview := current_event.duplicate(true)
		var achievements_before_preview := unlocked_achievement_count()
		show_debug_cheats()
		var preview_button := debug_cheat_panel.find_child("EndingPreviewButton", true, false) as Button
		if not is_instance_valid(preview_button):
			failures.append("В меню F2 нет кнопки просмотра концовки.")
		else:
			preview_button.pressed.emit()
			if not ending_preview_active or not is_instance_valid(ending_track) or ending_track.get_child_count() != 5:
				failures.append("Кнопка F2 не открыла пять глав эпилога.")
			else:
				show_ending_chapter(4)
				close_debug_ending_preview()
				if screen_layer != game_layer_before_preview or not game_layer_before_preview.visible or ending_preview_active:
					failures.append("После просмотра не восстановился прежний игровой экран.")
				if state != state_before_preview or current_event != event_before_preview or unlocked_achievement_count() != achievements_before_preview:
					failures.append("Просмотр изменил кампанию или открыл достижение.")
	if failures.is_empty():
		print("DEBUG_CHEAT_SMOKE_TEST: OK")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error(failure)
		get_tree().quit(1)


func current_overlay_scroll_position() -> int:
	return active_overlay_scroll.scroll_vertical if is_instance_valid(active_overlay_scroll) else 0


func restore_overlay_scroll_position(scroll: ScrollContainer, position: int) -> void:
	if position > 0:
		scroll.set_deferred("scroll_vertical", position)


func close_overlay(refresh_sidebar := true) -> void:
	if is_instance_valid(overlay):
		overlay.queue_free()
	overlay = null
	overlay_can_cancel = false
	active_overlay_scroll = null
	if not refresh_sidebar:
		return
	if sidebar_refresh_pending:
		call_deferred("flush_sidebar_refresh")
	else:
		request_sidebar_refresh()


func check_terminal_state() -> bool:
	if bool(state.get("at_war", false)) and int(state.get("war_support", 0)) <= 0:
		show_ending("КАПИТУЛЯЦИЯ", "Поддержка войны упала до нуля. Забастовали военные заводы, семьи перекрыли дороги к частям, резервисты отказались являться, а парламент потребовал капитуляции. Противники: %s. Правительство подписало капитуляцию не после разгрома армии, а после исчезновения общественной воли продолжать войну." % war_opponents_text())
		return true
	if bool(state.get("at_war", false)) and army_effectiveness() <= 0:
		show_ending("КАПИТУЛЯЦИЯ", "Фронт рухнул после полного распада боеспособных частей. Противники: %s. Правительство подписало капитуляцию, армия разоружена, а внешняя политика и ключевые государственные решения перешли под контроль победителей." % war_opponents_text())
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
		return "Голосование прошло на фоне войны. Противники: %s. Новый политический мандат не отменяет фронтовых потерь и зависимости от снабжения." % war_opponents_text()
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


func recognized_final_alignment() -> String:
	var declared := str(state.get("final_alignment", ""))
	if declared == "east" and (bool(state.get("at_war", false)) or int(state.get("east_relation", 0)) < 2):
		return ""
	if declared == "west" and (bool(state.get("at_war", false)) or int(state.get("west_relation", 0)) < 2):
		return ""
	if declared == "neutral" and (bool(state.get("at_war", false)) or int(state.get("east_relation", 0)) < 2 or int(state.get("west_relation", 0)) < 2):
		return ""
	if declared == "legacy" and int(state.get("army", 0)) < 40:
		return ""
	return declared


func show_ending(forced_title := "", forced_text := "") -> void:
	var ending_title := forced_title
	var ending_text := forced_text
	var final_alignment := recognized_final_alignment()
	if ending_title == "" and str(state.get("election_method", "")) != "" and final_alignment == "":
		var election_result := election_ending_data()
		ending_title = str(election_result.get("title", "ДОСРОЧНЫЕ ВЫБОРЫ"))
		ending_text = str(election_result.get("text", ""))
		if str(state.get("final_alignment", "")) != "":
			ending_text += "\n\nРанее объявленный курс не удалось удержать до конца временного срока."
	if ending_title == "":
		if final_alignment == "east":
			ending_title = "ВОСТОЧНЫЙ КУРС"
			ending_text = "Восточный Союз гарантировал безопасность режима и доступ к топливу. Республика сохранила флаг и президента, но ключевые решения теперь начинаются с консультации в восточном посольстве."
		elif final_alignment == "west":
			ending_title = "ЗАПАДНЫЙ КУРС"
			ending_text = "Республика вошла в западную систему договоров. Инвестиции вернулись, парламент стал громче, а старые связи с Восточным Союзом оборвались."
		elif final_alignment == "neutral":
			ending_title = "ХРУПКИЙ НЕЙТРАЛИТЕТ"
			ending_text = "Республика не вступила ни в один блок. Оба соседа недовольны, однако ни один не решился разрушить буфер. Страна сохранила свободу манёвра вместе с долгами и противоречиями."
		elif final_alignment == "legacy":
			ending_title = "НАСЛЕДСТВО ОТЦА"
			ending_text = "Президент сохранил семейную систему власти и сделал её прочнее. Армия и аппарат исполняют новый мандат, а оппозиция оспаривает само право семьи определять устройство республики."
		elif final_alignment == "unresolved":
			ending_title = "ДОСРОЧНЫЕ ВЫБОРЫ"
			ending_text = "Временный срок закончился. Отказ президента заранее признать порядок передачи власти сорвал согласование результатов: парламент, комиссия и правительство объявили разные версии законного исхода."
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
	if forced_title == "" and final_alignment in ["east", "west", "neutral", "legacy"] and str(state.get("election_method", "")) != "":
		ending_text += "\n\nИзбирательный итог: " + str(election_ending_data().get("text", ""))
	if not ending_preview_active:
		state.last_ending_title = ending_title
	var survived_weeks: int = maxi(0, int(state.get("week", 1)) - 1)
	var president_title := ending_title
	var president_text := forced_text if forced_title != "" else ending_text
	if forced_title == "" and final_alignment != "unresolved" and str(state.get("election_method", "")) != "":
		var election_result := election_ending_data()
		president_title = str(election_result.get("title", ending_title))
		president_text = str(election_result.get("text", "")).split("\n\n")[0]
	var earned_achievement_id := ending_achievement_id(president_title, survived_weeks) if forced_title == "" else ""
	var ending_achievement := achievement_definition(earned_achievement_id)
	var achievement_unlocked_now := false if ending_preview_active else unlock_ending_achievement(earned_achievement_id)
	var peaceful_achievement_unlocked_now := false
	if not ending_preview_active and peaceful_campaign_achievement_eligible(survived_weeks, forced_title):
		peaceful_achievement_unlocked_now = unlock_special_achievement("peaceful_campaign")
	if survived_weeks < DEMO_WEEKS:
		president_text += "\n\nПравительство продержалось %s из 26." % week_count_text(survived_weeks)
	var chapters: Array[Dictionary] = [
		{"eyebrow": "ГЛАВА I  •  СУДЬБА ПРЕЗИДЕНТА", "title": president_title, "body": president_text, "accent": GOLD},
		{"eyebrow": "ГЛАВА II  •  СУДЬБА РЕСПУБЛИКИ", "title": "СТРАНА ПОСЛЕ ВАС", "body": ending_country_summary(ending_title, final_alignment), "accent": BLUE},
		{"eyebrow": "ГЛАВА III  •  ЦЕНА РЕШЕНИЙ", "title": "ЧТО ОСТАЛОСЬ", "body": ending_decision_legacy(), "accent": RED},
		{"eyebrow": "ГЛАВА IV  •  ИТОГИ", "title": "РЕСПУБЛИКА В ЦИФРАХ", "body": "", "accent": GREEN},
		{"eyebrow": "ГЛАВА V  •  ЦЕНА ПРАВЛЕНИЯ", "title": "26 НЕДЕЛЬ В ЦИФРАХ", "body": "", "accent": GOLD}
	]
	if forced_title == "" and survived_weeks >= DEMO_WEEKS and not ending_preview_active:
		chapters.append({
			"kind": "thanks",
			"eyebrow": "A NOTE FROM THE CREATOR" if language_code == "en" else "ПОСЛЕСЛОВИЕ ОТ АВТОРА",
			"title": "THANK YOU FOR PLAYING" if language_code == "en" else "СПАСИБО ЗА ИГРУ",
			"body": "Thank you so much for playing my game to the end. I hope you found it interesting and engaging.\n\nIf you have impressions, ideas, questions or ran into a problem, please share them with me and other players on my Discord server." if language_code == "en" else "Большое спасибо тебе, игрок, за то, что прошёл мою игру до конца. Надеюсь, это был интересный и хотя бы немного увлекательный опыт для тебя.\n\nЕсли у тебя есть впечатления об игре, идеи, вопросы или ты столкнулся с проблемой, поделись ими, пожалуйста, со мной и другими игроками на моём Discord-сервере.",
			"accent": GOLD
		})
	play_game_sound("ending")
	if ending_preview_active:
		ending_preview_game_layer = screen_layer
		ending_preview_game_layer.hide()
		screen_layer = Control.new()
		screen_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(screen_layer)
		var preview_backdrop := Backdrop.new()
		preview_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		screen_layer.add_child(preview_backdrop)
	else:
		clear_screen()
	var viewport_size := get_viewport_rect().size
	var theater := Control.new()
	theater.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theater.clip_contents = true
	screen_layer.add_child(theater)
	ending_track = Control.new()
	ending_track.size = Vector2(viewport_size.x * chapters.size(), viewport_size.y)
	theater.add_child(ending_track)
	for chapter_index in range(chapters.size()):
		build_ending_chapter(ending_track, chapters[chapter_index], chapter_index, viewport_size)
	var header := HBoxContainer.new()
	header.position = Vector2(64, 32)
	header.size = Vector2(viewport_size.x - 128, 40)
	var header_title := label("HEIR TO THE REPUBLIC  /  ENDING PREVIEW" if ending_preview_active and language_code == "en" else "НАСЛЕДНИК РЕСПУБЛИКИ  /  ПРОСМОТР" if ending_preview_active else "HEIR TO THE REPUBLIC  /  EPILOGUE" if language_code == "en" else "НАСЛЕДНИК РЕСПУБЛИКИ  /  ЭПИЛОГ", 17, GOLD)
	header_title.custom_minimum_size.x = 560
	header_title.autowrap_mode = TextServer.AUTOWRAP_OFF
	header.add_child(header_title)
	var header_spacer := Control.new()
	header_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(header_spacer)
	var header_weeks := label(("%d / %d WEEKS" if language_code == "en" else "%d / %d НЕДЕЛЬ") % [survived_weeks, DEMO_WEEKS], 16, CREAM, HORIZONTAL_ALIGNMENT_RIGHT)
	header_weeks.custom_minimum_size.x = 240
	header_weeks.autowrap_mode = TextServer.AUTOWRAP_OFF
	header.add_child(header_weeks)
	screen_layer.add_child(header)
	var footer := HBoxContainer.new()
	footer.position = Vector2((viewport_size.x - 1080.0) * 0.5, viewport_size.y - 96.0)
	footer.size = Vector2(1080, 62)
	footer.add_theme_constant_override("separation", 18)
	screen_layer.add_child(footer)
	ending_back_button = menu_button("ВЕРНУТЬСЯ К ИГРЕ" if ending_preview_active else "НАЗАД")
	ending_back_button.custom_minimum_size.x = 210
	ending_back_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	ending_back_button.pressed.connect(func() -> void:
		if ending_preview_active and ending_chapter_index == 0:
			close_debug_ending_preview()
		else:
			show_ending_chapter(ending_chapter_index - 1)
	)
	footer.add_child(ending_back_button)
	ending_progress_label = label("01 / %02d" % chapters.size(), 18, GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	ending_progress_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ending_progress_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	footer.add_child(ending_progress_label)
	ending_next_button = menu_button("ДАЛЬШЕ")
	ending_next_button.custom_minimum_size.x = 300
	ending_next_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	ending_next_button.pressed.connect(func() -> void:
		if ending_chapter_index == ending_track.get_child_count() - 1:
			if ending_preview_active:
				close_debug_ending_preview()
			else:
				show_start_screen()
		else:
			show_ending_chapter(ending_chapter_index + 1)
	)
	footer.add_child(ending_next_button)
	ending_back_button.disabled = not ending_preview_active
	if achievement_unlocked_now and not ending_achievement.is_empty():
		var achievement_notice := label("ДОСТИЖЕНИЕ ОТКРЫТО: %s" % str(ending_achievement.get("title", "Новая концовка")).to_upper(), 15, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
		achievement_notice.position = Vector2(240, viewport_size.y - 128)
		achievement_notice.size = Vector2(viewport_size.x - 480, 24)
		screen_layer.add_child(achievement_notice)
	if peaceful_achievement_unlocked_now:
		var peace_notice := label("ДОСТИЖЕНИЕ ОТКРЫТО: ДВАДЦАТЬ ШЕСТЬ НЕДЕЛЬ МИРА", 15, GREEN, HORIZONTAL_ALIGNMENT_CENTER)
		peace_notice.position = Vector2(240, viewport_size.y - (105 if achievement_unlocked_now else 128))
		peace_notice.size = Vector2(viewport_size.x - 480, 24)
		screen_layer.add_child(peace_notice)
	localize_visible_tree()


func ending_country_summary(ending_title: String, final_alignment: String) -> String:
	var paragraphs: Array[String] = []
	if ending_title == "КАПИТУЛЯЦИЯ":
		paragraphs.append("После капитуляции победитель контролирует безопасность и важнейшие решения республики. Государственные учреждения продолжают работать, но уже в условиях чужого военного присутствия.")
	elif ending_title == "ДЕФОЛТ":
		paragraphs.append("Остановка обязательных выплат разрушила правительственную коалицию. Новый кабинет получает пустую казну и те же счета, которые прежняя власть не смогла оплатить.")
	elif ending_title == "РАСКОЛ":
		paragraphs.append("Приказы из столицы перестали исполняться в областях. Региональные власти и вооружённые группы решают, кому подчиняться, а соседи следят за приграничными районами.")
	elif ending_title == "ВОЕННЫЙ ПЕРЕВОРОТ":
		paragraphs.append("Армия взяла под контроль столицу. Формально ведомства уцелели, но теперь их решения требуют согласия военного руководства.")
	elif ending_title == "СВЕРЖЕНИЕ":
		paragraphs.append("После падения президента парламент и улица спорят о временной власти. Государство сохранилось, однако новый порядок ещё предстоит согласовать.")
	elif final_alignment == "east":
		paragraphs.append("Восточный Союз стал главным внешним партнёром республики. Переданное ему право добычи приграничной нефти сокращает собственные возможности страны и остаётся предметом спора внутри неё.")
	elif final_alignment == "west":
		paragraphs.append("Республика закрепила западный курс через договоры и арбитражный протокол. Это открывает путь к сотрудничеству, но протокол требует еженедельной оплаты и ограничивает свободу менять правила для инвесторов.")
	elif final_alignment == "neutral":
		paragraphs.append("Республика сохранила отношения с обоими соседями и не вступила ни в один блок. За эту свободу пришлось заплатить собственными гарантиями и постоянной готовностью выдерживать новое давление.")
	elif final_alignment == "legacy":
		paragraphs.append("Семейная система власти пережила первые выборы после смерти её основателя. Теперь новым поколениям предстоит решать, кому принадлежат государственные институты: стране или фамилии президента.")
	else:
		paragraphs.append("Восточный Союз: %s. Западная Федерация: %s. Это положение досталось следующему правительству вместе с заключёнными договорами и неразрешёнными спорами." % [neighbor_relation_band("east"), neighbor_relation_band("west")])
	if bool(state.get("at_war", false)) and ending_title != "КАПИТУЛЯЦИЯ":
		paragraphs.append("Война не закончилась вместе с правлением президента. Противники: %s. Фронту по-прежнему нужны люди, техника и общественная поддержка." % war_opponents_text())
	elif ending_title != "КАПИТУЛЯЦИЯ":
		paragraphs.append("Сейчас республика не ведёт войну. Сохранится ли мир, зависит от будущих решений и отношений с соседями.")
	return "\n\n".join(paragraphs)


func run_ending_smoke_test() -> void:
	var failures: Array[String] = []
	start_game("Сид: 1991", 1991)
	state.week = DEMO_WEEKS + 1
	state.election_method = "fair"
	state.final_alignment = "west"
	state.west_relation = 3
	state.east_relation = 1
	state.west_investment_arbitration = true
	if not peaceful_campaign_achievement_eligible(DEMO_WEEKS, "") or peaceful_campaign_achievement_eligible(DEMO_WEEKS - 1, "") or peaceful_campaign_achievement_eligible(DEMO_WEEKS, "ДЕФОЛТ"):
		failures.append("Мирное достижение должно требовать всех 26 недель и обычного завершения кампании.")
	state.war_ever_started = true
	state.at_war = false
	if peaceful_campaign_achievement_eligible(DEMO_WEEKS, ""):
		failures.append("Перемирие не должно считаться прохождением без войн.")
	state.war_ever_started = false
	var election_title := str(election_ending_data().get("title", ""))
	show_ending()
	if not is_instance_valid(ending_track) or ending_track.get_child_count() != 6:
		failures.append("Полное прохождение должно показывать пять глав эпилога и благодарность.")
	else:
		var first_page_text := ""
		for node in ending_track.get_child(0).find_children("*", "Label", true, false):
			first_page_text += str((node as Label).text)
		if not first_page_text.contains(election_title) or first_page_text.contains("Избирательный итог:"):
			failures.append("Первая глава должна показывать судьбу президента отдельно от внешнего курса.")
		var country_page_text := ""
		for node in ending_track.get_child(1).find_children("*", "Label", true, false):
			country_page_text += str((node as Label).text)
		if not country_page_text.contains("арбитражный протокол") or country_page_text.contains("Инвестиции вернулись"):
			failures.append("Вторая глава должна говорить о фактических договорах, а не обещать нерассчитанный результат.")
		show_ending_chapter(4)
		if ending_chapter_index != 4 or ending_next_button.text != "ДАЛЬШЕ":
			failures.append("После статистики полного прохождения должна открываться благодарность.")
		show_ending_chapter(5)
		var thanks_button := ending_track.get_child(5).find_child("EndingDiscordLinkButton", true, false) as Button
		if ending_next_button.text != "В ГЛАВНОЕ МЕНЮ" or not is_instance_valid(thanks_button) or thanks_button.text != DISCORD_INVITE_URL:
			failures.append("На экране благодарности нет нажимаемой ссылки на сервер разработки.")
		var metrics_page := ending_track.get_child(3)
		if metrics_page.find_children("*", "PanelContainer", true, false).size() < 9:
			failures.append("Показатели финала не разделены на карточки.")
		if ending_track.get_child(4).find_children("*", "Control", true, false).size() < 3:
			failures.append("Статистика кампании не содержит графики.")
	for early_title in ["КАПИТУЛЯЦИЯ", "ДЕФОЛТ", "СВЕРЖЕНИЕ", "ВОЕННЫЙ ПЕРЕВОРОТ", "РАСКОЛ"]:
		show_ending(early_title, "Правление завершилось досрочно.")
		if not is_instance_valid(ending_track) or ending_track.get_child_count() != 5 or ending_chapter_index != 0:
			failures.append("Досрочный финал «%s» не открыл пять глав." % early_title)
			break
	if failures.is_empty():
		print("ENDING_SMOKE_TEST: OK | completed_chapters=6 | early_chapters=5 | discord_thanks=yes | fate_before_alignment=yes | metric_cards=8 | history_charts=2")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("ENDING_SMOKE_TEST: " + failure)
		get_tree().quit(1)


func ending_decision_legacy() -> String:
	var memories: Array[String] = []
	if int(state.get("war_casualties", 0)) > 0:
		memories.append("Война унесла %s военнослужащих. Для семей погибших смена власти не завершает историю фронта." % format_people(int(state.get("war_casualties", 0))))
	var arc_memory: String = preload("res://scripts/campaign_arcs.gd").ending_memory(str(state.get("campaign_arc_legacy", "")))
	if arc_memory != "":
		memories.append(arc_memory)
	if bool(state.get("east_border_oil_concession", false)):
		memories.append("Восточный Союз получил право добывать приграничную нефть. Подпись под соглашением продолжит действовать и после ухода президента.")
	if bool(state.get("west_investment_arbitration", false)):
		memories.append("Западный арбитражный протокол остаётся в силе. Следующий кабинет унаследует защиту договоров и постоянный платёж за неё.")
	if bool(state.get("media_restricted", false)):
		memories.append("Ограничения для СМИ всё ещё действуют. Редакции ждут, станет ли контроль временной мерой или правилом для следующей власти.")
	if bool(state.get("printed_money", false)):
		memories.append("Напечатанные в кризис деньги закрыли срочные выплаты. Их инфляционная цена останется в счетах государства и семей.")
	if bool(state.get("fund_debt", false)) or int(state.get("creditor_obligations", 0)) > 0:
		memories.append("Кредиторы международного фонда ждут исполнения условий. Долг и переговоры перейдут к тому, кто будет управлять страной дальше.")
	if emergency_powers_override_active():
		memories.append("Чрезвычайные полномочия позволили обходить парламент. Следующая власть получит этот же инструмент — и спор о том, когда его следует отменить.")
	if int(state.get("active_unrest_level", 0)) > 0:
		memories.append("Протесты продолжаются. Люди на улицах ждут ответа на требования, с которыми прежнее правительство так и не справилось.")
	if int(state.get("brother_trust", 2)) <= 0:
		memories.append("Старший брат отдалился от президента. Его связи с офицерами сохранят значение и после семейного разрыва.")
	if memories.is_empty():
		memories.append("Парламент, министры и общественные группы запомнили проведённые за эти недели границы допустимого. Новому правительству придётся работать с созданными правилами.")
	if memories.size() == 1:
		memories.append("В казне осталось %.2f млн, государственный долг составляет %.2f млн. Именно с этого начнётся следующий политический период." % [float(state.get("money", 0.0)), float(state.get("debt", 0.0))])
	return "\n\n".join(memories.slice(0, 3))


func build_ending_chapter(track: Control, chapter: Dictionary, chapter_index: int, viewport_size: Vector2) -> void:
	var page := Control.new()
	page.position = Vector2(viewport_size.x * chapter_index, 0)
	page.size = viewport_size
	track.add_child(page)
	var moving_backdrop := Backdrop.new()
	moving_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page.add_child(moving_backdrop)
	var accent: Color = chapter["accent"]
	var tint := ColorRect.new()
	tint.color = accent.darkened(0.60)
	tint.color.a = 0.27
	tint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page.add_child(tint)
	var chapter_number := label("0%d" % (chapter_index + 1), 260, accent)
	chapter_number.modulate.a = 0.16
	chapter_number.position = Vector2(viewport_size.x - 490, 90)
	chapter_number.size = Vector2(420, 330)
	page.add_child(chapter_number)
	var holder := CenterContainer.new()
	holder.position = Vector2(60, 112)
	holder.size = Vector2(viewport_size.x - 120, viewport_size.y - 246)
	page.add_child(holder)
	var paper := PanelContainer.new()
	paper.custom_minimum_size = Vector2(minf(1080, viewport_size.x - 160), 530 if str(chapter.get("kind", "")) == "thanks" else 570)
	paper.add_theme_stylebox_override("panel", style(PAPER, 22, accent, 2))
	holder.add_child(paper)
	var margins := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margins.add_theme_constant_override("margin_" + side, 28 if chapter_index == 4 and side in ["top", "bottom"] else 38 if side in ["top", "bottom"] else 48)
	paper.add_child(margins)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10 if chapter_index == 4 else 21)
	margins.add_child(content)
	content.add_child(label(str(chapter["eyebrow"]), 17, accent, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(label(str(chapter["title"]), 42, INK, HORIZONTAL_ALIGNMENT_CENTER))
	var divider := ColorRect.new()
	divider.color = accent
	divider.custom_minimum_size = Vector2(0, 2)
	content.add_child(divider)
	if str(chapter.get("kind", "")) == "thanks":
		var prose := label(str(chapter["body"]), 23, Color("#35332f"), HORIZONTAL_ALIGNMENT_CENTER)
		prose.size_flags_vertical = Control.SIZE_EXPAND_FILL
		prose.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		content.add_child(prose)
		var discord_button := discord_link_button(DISCORD_INVITE_URL)
		discord_button.name = "EndingDiscordLinkButton"
		discord_button.custom_minimum_size = Vector2(0, 64)
		content.add_child(discord_button)
	elif chapter_index == 3:
		build_ending_metric_grid(content)
	elif chapter_index == 4:
		build_ending_campaign_statistics(content)
	else:
		var prose := label(str(chapter["body"]), 25, Color("#35332f"), HORIZONTAL_ALIGNMENT_CENTER)
		prose.size_flags_vertical = Control.SIZE_EXPAND_FILL
		prose.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		content.add_child(prose)


func build_ending_metric_grid(parent: VBoxContainer) -> void:
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 12)
	parent.add_child(grid)
	var cards: Array[Dictionary] = [
		{"title": "КАЗНА И ДОЛГ", "value": "%.2f млн в казне  •  %.2f млн долга" % [float(state.get("money", 0.0)), float(state.get("debt", 0.0))]},
		{"title": "ОБЩЕСТВО", "value": "Поддержка %d%%  •  стабильность %d%%" % [int(state.get("support", 0)), int(state.get("stability", 0))]},
		{"title": "НАСЕЛЕНИЕ", "value": "%s всего  •  %s работают" % [format_people(total_population()), format_people(workable_population())]},
		{"title": "АРМИЯ", "value": "%s служат  •  %d техники  •  %d самолётов" % [format_people(int(state.get("army_personnel", 0))), int(state.get("army_equipment", 0)), int(state.get("army_aircraft", 0))]},
		{"title": "ВОЙНА", "value": "Поддержка %d%%  •  потери %s" % [int(state.get("war_support", 0)), format_people(int(state.get("war_casualties", 0)))] if int(state.get("war_casualties", 0)) > 0 or bool(state.get("at_war", false)) else "Мир  •  боевых потерь нет"},
		{"title": "СОСЕДИ", "value": "Восток: %s  •  Запад: %s" % [neighbor_relation_band("east"), neighbor_relation_band("west")]},
		{"title": "КРЕДИТОРЫ", "value": creditor_obligation_level(int(state.get("creditor_obligations", 0)))},
		{"title": "КОРРУПЦИЯ", "value": "%s  •  доходы −%d%%" % [corruption_level(int(state.get("corruption_tier", 0))), corruption_transaction_rate(int(state.get("corruption_tier", 0)))]}
	]
	if language_code == "en":
		cards = [
			{"title": "TREASURY & DEBT", "value": "%.2fM treasury  •  %.2fM debt" % [float(state.get("money", 0.0)), float(state.get("debt", 0.0))]},
			{"title": "SOCIETY", "value": "Support %d%%  •  Stability %d%%" % [int(state.get("support", 0)), int(state.get("stability", 0))]},
			{"title": "POPULATION", "value": "%s total  •  %s working" % [format_people(total_population()), format_people(workable_population())]},
			{"title": "ARMY", "value": "%s serving  •  %d vehicles  •  %d aircraft" % [format_people(int(state.get("army_personnel", 0))), int(state.get("army_equipment", 0)), int(state.get("army_aircraft", 0))]},
			{"title": "WAR", "value": "Support %d%%  •  Losses %s" % [int(state.get("war_support", 0)), format_people(int(state.get("war_casualties", 0)))] if int(state.get("war_casualties", 0)) > 0 or bool(state.get("at_war", false)) else "Peace  •  no combat losses"},
			{"title": "NEIGHBOURS", "value": "East: %s  •  West: %s" % [game_localization.text(neighbor_relation_band("east")), game_localization.text(neighbor_relation_band("west"))]},
			{"title": "CREDITORS", "value": game_localization.text(creditor_obligation_level(int(state.get("creditor_obligations", 0))))},
			{"title": "CORRUPTION", "value": "%s  •  income −%d%%" % [game_localization.text(corruption_level(int(state.get("corruption_tier", 0)))), corruption_transaction_rate(int(state.get("corruption_tier", 0)))]}
		]
	for card_data in cards:
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(468, 86)
		card.add_theme_stylebox_override("panel", style(Color("#f2ecdf"), 10, Color("#c6bba6"), 1))
		grid.add_child(card)
		var card_content := VBoxContainer.new()
		card_content.add_theme_constant_override("separation", 5)
		card.add_child(card_content)
		card_content.add_child(label(str(card_data["title"]), 14, Color("#7c6249")))
		card_content.add_child(label(str(card_data["value"]), 17, INK))


func build_ending_campaign_statistics(parent: VBoxContainer) -> void:
	ensure_campaign_history()
	var history: Array = state.campaign_history
	var first: Dictionary = history[0]
	var last: Dictionary = history[history.size() - 1]
	var population_gained := 0
	var population_lost := 0
	var equipment_gained := 0
	var equipment_lost := 0
	for index in range(1, history.size()):
		var previous: Dictionary = history[index - 1]
		var current: Dictionary = history[index]
		var people_delta := int(current.get("population", 0)) - int(previous.get("population", 0))
		population_gained += maxi(0, people_delta)
		population_lost += maxi(0, -people_delta)
		var equipment_delta := int(current.get("equipment", 0)) - int(previous.get("equipment", 0))
		equipment_gained += maxi(0, equipment_delta)
		equipment_lost += maxi(0, -equipment_delta)
	var debt_delta := float(last.get("debt", 0.0)) - float(first.get("debt", 0.0))
	var cards: Array[Dictionary] = [
		{"title": "ДЕНЬГИ ЗА КАМПАНИЮ", "value": "+%.1f млн поступило  •  −%.1f млн потрачено" % [float(state.get("campaign_income", 0.0)), float(state.get("campaign_expenses", 0.0))]},
		{"title": "НАСЕЛЕНИЕ ПО НЕДЕЛЯМ", "value": "+%s выросло  •  −%s сократилось" % [format_campaign_count(population_gained), format_campaign_count(population_lost)]},
		{"title": "АРМИЯ И ВОЙНА", "value": "+%d / −%d техники  •  %s погибли" % [equipment_gained, equipment_lost, format_campaign_count(int(state.get("war_casualties", 0)))]},
		{"title": "ДОЛГ", "value": "%.1f → %.1f млн  •  изменение %+.1f млн" % [float(first.get("debt", 0.0)), float(last.get("debt", 0.0)), debt_delta]}
	]
	if language_code == "en":
		cards = [
			{"title": "CAMPAIGN CASH FLOW", "value": "+%.1fM received  •  −%.1fM spent" % [float(state.get("campaign_income", 0.0)), float(state.get("campaign_expenses", 0.0))]},
			{"title": "WEEKLY POPULATION CHANGES", "value": "+%s growth  •  −%s decline" % [format_campaign_count(population_gained), format_campaign_count(population_lost)]},
			{"title": "ARMY AND WAR", "value": "+%d / −%d equipment  •  %s killed" % [equipment_gained, equipment_lost, format_campaign_count(int(state.get("war_casualties", 0)))]},
			{"title": "DEBT", "value": "%.1f → %.1fM  •  change %+.1fM" % [float(first.get("debt", 0.0)), float(last.get("debt", 0.0)), debt_delta]}
		]
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 8)
	parent.add_child(grid)
	for card_data in cards:
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(474, 66)
		card.add_theme_stylebox_override("panel", style(Color("#f2ecdf"), 10, Color("#c6bba6"), 1))
		grid.add_child(card)
		var card_column := VBoxContainer.new()
		card_column.add_theme_constant_override("separation", 2)
		card.add_child(card_column)
		card_column.add_child(label(str(card_data["title"]), 13, Color("#7c6249")))
		card_column.add_child(label(str(card_data["value"]), 16, INK))
	var chart_row := HBoxContainer.new()
	chart_row.add_theme_constant_override("separation", 14)
	parent.add_child(chart_row)
	for chart_data in [
		{"key": "money", "title": "КАЗНА" if language_code == "ru" else "TREASURY", "unit": "M", "scale": 1.0, "color": BLUE},
		{"key": "population", "title": "НАСЕЛЕНИЕ" if language_code == "ru" else "POPULATION", "unit": "M", "scale": 1000000.0, "color": GREEN}
	]:
		var chart_panel := PanelContainer.new()
		chart_panel.custom_minimum_size = Vector2(474, 174)
		chart_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		chart_panel.add_theme_stylebox_override("panel", style(Color("#f2ecdf"), 10, Color("#c6bba6"), 1))
		chart_row.add_child(chart_panel)
		var chart_column := VBoxContainer.new()
		chart_column.add_theme_constant_override("separation", 0)
		chart_panel.add_child(chart_column)
		chart_column.add_child(label(str(chart_data["title"]), 14, chart_data["color"]))
		var chart := ENDING_LINE_CHART_SCRIPT.new() as Control
		chart.custom_minimum_size = Vector2(0, 145)
		chart.size_flags_vertical = Control.SIZE_EXPAND_FILL
		chart_column.add_child(chart)
		var points: Array = []
		for snapshot in history:
			points.append(float((snapshot as Dictionary).get(str(chart_data["key"]), 0.0)) / float(chart_data["scale"]))
		chart.call("configure", points, chart_data["color"], str(chart_data["unit"]), int(first.get("week", 0)), int(last.get("week", 0)))
	if history.size() < 2:
		parent.add_child(label("История прошлых недель недоступна для этого сохранения." if language_code == "ru" else "Weekly history is unavailable for this save.", 14, MUTED, HORIZONTAL_ALIGNMENT_CENTER))


func format_campaign_count(value: int) -> String:
	var digits := str(absi(value))
	var result := ""
	for index in range(digits.length()):
		if index > 0 and (digits.length() - index) % 3 == 0:
			result += " "
		result += digits[index]
	return ("−" if value < 0 else "") + result


func show_ending_chapter(new_index: int) -> void:
	if not is_instance_valid(ending_track):
		return
	var last_chapter := ending_track.get_child_count() - 1
	ending_chapter_index = clampi(new_index, 0, last_chapter)
	ending_back_button.disabled = ending_chapter_index == 0 and not ending_preview_active
	ending_back_button.text = "ВЕРНУТЬСЯ К ИГРЕ" if ending_preview_active and ending_chapter_index == 0 else "НАЗАД"
	localize_property(ending_back_button, "text", "localized_text")
	ending_next_button.text = ("ВЕРНУТЬСЯ К ИГРЕ" if ending_preview_active else "В ГЛАВНОЕ МЕНЮ") if ending_chapter_index == last_chapter else "ДАЛЬШЕ"
	localize_property(ending_next_button, "text", "localized_text")
	ending_progress_label.text = "%02d / %02d" % [ending_chapter_index + 1, ending_track.get_child_count()]
	if is_instance_valid(ending_transition):
		ending_transition.kill()
	play_game_sound("page")
	ending_transition = create_tween()
	ending_transition.set_trans(Tween.TRANS_CUBIC)
	ending_transition.set_ease(Tween.EASE_IN_OUT)
	ending_transition.tween_property(ending_track, "position:x", -get_viewport_rect().size.x * ending_chapter_index, 0.72)


func _unhandled_input(event: InputEvent) -> void:
	if is_fullscreen_shortcut(event):
		toggle_fullscreen()
		get_viewport().set_input_as_handled()
		return
	if is_instance_valid(ending_track):
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode in [KEY_RIGHT, KEY_D, KEY_ENTER, KEY_SPACE] and ending_chapter_index < ending_track.get_child_count() - 1:
				show_ending_chapter(ending_chapter_index + 1)
				get_viewport().set_input_as_handled()
			elif event.keycode in [KEY_LEFT, KEY_A] and ending_chapter_index > 0:
				show_ending_chapter(ending_chapter_index - 1)
				get_viewport().set_input_as_handled()
		return
	if is_instance_valid(debug_cheat_panel):
		return
	var cancel_pressed: bool = event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE)
	if cancel_pressed:
		if is_instance_valid(tutorial_dialog):
			finish_tutorial_dialog()
			get_viewport().set_input_as_handled()
			return
		if is_instance_valid(overlay) and overlay_can_cancel:
			close_overlay()
			get_viewport().set_input_as_handled()
		elif not is_instance_valid(overlay) and tutorial_enabled and not state.is_empty() and int(state.get("week", 1)) == 1:
			show_settings()
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
		"После сокращения пенсий и пособий колонны пенсионеров, семей с детьми и бюджетников перекрыли центр столицы. При низкой поддержке власти обещания переждать кризис никого не убедили: протестующие требуют вернуть выплаты, а профсоюзы готовят общую забастовку.",
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
		event("Старший брат", "military", "#a9473f", "День после похорон", "Служба безопасности не исключает нового нападения. Старший брат предлагает на две недели передать армии охрану парламента, телевидения, центрального банка и президентской резиденции. Полиция предупреждает: после покушения военные у ключевых учреждений могут выглядеть не только как защита.",
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
			option("Оформить документы", "Расходы • официальная рабочая сила и налоговая база вырастут", {"money": -4, "population_workable": 30000, "support": 2, "clan_workers": 4, "clan_regions": -3}, "Тридцать тысяч человек получили постоянные документы и вошли в официальный рынок труда. Муниципалитеты потребовали дополнительное финансирование."),
			option("Оставить временный статус", "Казна получит немного денег • положение людей останется нестабильным", {"money": 3, "support": -2, "stability": -3, "clan_oligarchs": 6}, "Крупные подрядчики сохранили дешёвую рабочую силу и перечислили налоговый аванс. Правозащитники опубликовали фотографии бараков.", {"migrant_gray_status": true}),
			option("Дать регистрацию через муниципалитеты", "Центр потратит меньше • часть людей войдёт в рабочую силу • регионы и местные различия усилятся", {"money": -2, "population_workable": 18000, "support": 1, "stability": -1, "clan_regions": 8}, "Губернаторы получили квоты и собственные критерии. В одном городе документы выдавали по трудовому договору, в соседнем — только семьям с детьми; люди начали переезжать между очередями.", {"municipal_migrant_quotas": true})),
		event("Пограничная служба", "official", "#536f82", "Автобусы у перевала", "На восточной границе остановилась колонна с сорока тысячами людей, бегущих от подавленных беспорядков в Восточном Союзе. Союз называет их преступниками и требует закрыть пропускные пункты.",
			option("Открыть границу", "Население и рабочая сила заметно вырастут • большие расходы • церковь поможет • Восток ответит резко", {"money": -9, "population_total": 40000, "population_workable": 20000, "support": 1, "stability": -2, "clan_church": 8, "east_pressure": 3, "west_commitment": 1}, "Людей разместили в школах и церковных приютах. Восточный посол потребовал выдать организаторов исхода."),
			option("Развернуть колонну", "Порядок сохранится • церковь и часть общества будут возмущены", {"stability": 2, "support": -3, "clan_church": -10, "east_commitment": 1, "war_support": 2}, "Шлагбаумы остались закрыты. Восточный Союз поблагодарил правительство, а ночью церковные колокола звонили в память о погибших у перевала.", {"refugees_turned_back": true}),
			option("Открыть временный лагерь у границы", "Население и рабочая сила немного вырастут • расходы будут умеренными • регионы и оба соседа начнут давить на лагерь", {"money": -5, "population_total": 15000, "population_workable": 7500, "support": -1, "stability": -3, "clan_regions": -4, "neutrality": 2, "east_pressure": 2}, "Пятнадцать тысяч человек впустили в палаточный лагерь под международным наблюдением, остальные остались у перевала. Восток требует списки, Запад — свободный проход, губернатор — дату закрытия.", {"border_refugee_camp": true})),
		event("Министерство экономики", "official", "#c7a96b", "Пустующие цеха", "Три оборонных завода стоят без заказов, оборудование ветшает, а рабочие смены распущены. Можно запустить государственный заказ или передать цеха частному объединению за налоговые льготы.",
			option("Дать госзаказ", "Крупные расходы • выпуск техники и профсоюзы укрепятся", {"money": -10, "army_equipment": 12, "clan_workers": 10, "clan_oligarchs": -6}, "Заводы вновь включили ночные смены. Первые машины переданы армии, но казначейство требует объяснить источник следующих выплат.", {"state_factory_order": true}),
			option("Отдать частникам", "Меньше расходов • производство оживёт • коррупция усилится", {"money": -5, "corruption_tier": 1, "clan_oligarchs": 10, "clan_workers": 4}, "Промышленное объединение быстро восстановило смены. В приложении к договору обнаружились льготы, которых депутаты не помнят на голосовании.", {"private_factory_concession": true})),
		event("Бюджетный комитет", "official", "#8b6c4b", "Квартальная поправка", "Наступил срок квартальной корректировки. Денег хватит либо на досрочную выплату кредиторам, либо на обещанную прибавку пенсионерам. Провести оба решения без нового займа невозможно.",
			option("Снизить долг", "Очень большие расходы • долг и финансовый риск заметно снизятся • поддержка пострадает", {"money": -14, "debt": -35, "support": -4, "stability": 4}, "Казначейство досрочно погасило крупную часть обязательств. Кредиторы смягчили условия, а союзы пенсионеров объявили, что правительство оплатило доверие банков их обещанной прибавкой.", {"quarter_debt_paid": true}),
			option("Доплатить пенсионерам", "Большие расходы • поддержка вырастет • долг и бюджетный риск усилятся", {"money": -9, "debt": 14, "support": 6, "stability": -2}, "Пенсионеры получили разовую доплату. Правительство перенесло квартальный платёж и взяло краткосрочный заём, поэтому следующая бюджетная поправка станет тяжелее.", {"pension_supplement_paid": true})),
		event("Министерство обороны", "military", "#a9473f", "Некомплект гарнизонов", "Штаб сообщает, что приграничным гарнизонам не хватает восьми тысяч человек. Министр обороны предлагает провести срочный шестимесячный набор либо ограничиться дорогими выплатами контрактникам.",
			option("Провести срочный набор", "Армия быстро вырастет • работоспособное население и поддержка войны сократятся • при низкой поддержке войны начнутся протесты", {"population_workable": -8000, "army_personnel": 8000, "army": 4, "support": -4, "war_support": -6, "stability": -2}, "Повестки закрыли нехватку людей. Заводы пожаловались на уход специалистов, а в университетах появились группы помощи уклонистам.", {"emergency_six_month_draft": true, "unrest": {"cause": "срочный шестимесячный призыв", "kind": "antiwar", "base_level": 1, "reversible": false, "condition": "low_war_support"}}),
			option("Поднять выплаты", "Большие расходы • прирост будет меньше, но армия поддержит решение", {"money": -9, "population_workable": -2000, "army_personnel": 2000, "army": 7, "support": 1, "war_support": 2}, "Контракт продлили опытные сержанты, и набор пошёл без облав. Штаб признаёт, что часть вакансий всё равно осталась открытой.", {"military_retention_bonus": true})),
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
			option("Нанять замену", "Казна сэкономит • нарушение трудовых прав вызовет более широкую забастовку", {"money": 3, "stability": -6, "corruption_tier": 1, "clan_workers": -15, "clan_oligarchs": 8}, "Полиция освободила проходную, а подрядчик привёз сменных рабочих. Пять тысяч участников забастовки уволены, оборудование несколько раз останавливалось из-за саботажа.", {"miners_strike_broken": true, "unrest": {"cause": "увольнение бастующих шахтёров и найм штрейкбрехеров", "kind": "labor", "labor": true, "base_level": 2, "reversible": false}})),
		event("Военная разведка", "military", "#536f82", "Добровольцы без шевронов", "Правительство далёкой страны просит не мешать набору добровольцев для её гражданской войны. Западная Федерация поддерживает эту сторону, Восточный Союз вооружает её противников.",
			option("Помочь тайному набору", "Часть работоспособных покинет страну • армия получит опыт • Восток обвинит республику", {"money": -6, "population_total": -4000, "population_workable": -4000, "war_support": 6, "army": 3, "west_commitment": 1, "east_pressure": 3}, "Четыре тысячи добровольцев выехали через туристические фирмы. Официально государство не участвовало, но фотографии инструкторов уже появились в сети.", {"covert_volunteers_sent": true}),
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
		option("Открыть свободный выезд", "Население и рабочая сила заметно сократятся • поддержка и переводы вырастут • Запад станет ближе, Восток — дальше", {"money": 5, "support": 4, "population_total": -30000, "population_workable": -30000, "west_commitment": 1, "east_pressure": 2, "clan_workers": 3}, "Очереди выстроились у визовых центров. Семьи получили первые переводы, а предприятия начали предлагать более высокие зарплаты оставшимся специалистам.", {"west_labor_mobility": true}),
		option("Согласовать отраслевые квоты", "Расходы на управление • население и рабочая сила немного сократятся • отток специалистов будет ограничен", {"money": -3, "support": 2, "population_total": -8000, "population_workable": -8000, "west_commitment": 1, "neutrality": 1, "clan_oligarchs": -3}, "Правительство выдало ограниченные разрешения сезонным рабочим. Запад согласился на квоты, а работодатели потребовали ещё больше исключений.", {"limited_west_mobility": true}),
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
		option("Принять в армию после проверки", "Армия получит людей и опыт • работоспособное население сократится • Восток назовёт подразделение западным легионом", {"money": -6, "population_workable": -3000, "army_personnel": 3000, "army": 5, "war_support": 5, "stability": -4, "west_commitment": 1, "east_pressure": 3}, "После краткой проверки ветераны вошли в отдельный батальон. Штаб доволен их опытом, но полиция уже расследует драку между новобранцами и пограничниками."),
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
	var church_scandal_event := event("Генеральная прокуратура", "official", "#a9473f", "Скандал с церковью", "В нескольких епархиях десятки людей публично обвинили священников в сексуальном насилии над несовершеннолетними. Часть заявлений относится к событиям многолетней давности, но журналисты нашли внутренние церковные письма о переводах подозреваемых между приходами. Прокуратура требует доступ к архивам и независимые допросы. Иерархи Церкви Веры просят назвать публикации неподтверждёнными слухами и провести закрытую внутреннюю проверку: публичное расследование может разрушить доверие ко всей церкви ещё до суда.",
		option("Начать государственную проверку", "Поддержка власти заметно вырастет • отношение Церкви Веры −15", {"support": 4, "clan_church": -11}, "Прокуратура открыла дела, изъяла архивы епархий и пригласила заявителей дать показания с защитой личности. Общество увидело, что духовный сан не даёт неприкосновенности, а церковное руководство обвинило президента в коллективном наказании всех верующих.", {"church_abuse_investigation": true}),
		option("Объявить обвинения слухами", "Поддержка власти заметно снизится • отношение Церкви Веры +15", {"support": -4, "clan_church": 11}, "Правительство назвало публикации кампанией слухов и оставило проверку церковной комиссии. Иерархи публично поддержали президента, но заявители и журналисты опубликовали новые свидетельства и обвинили власть в сокрытии возможных преступлений.", {"church_scandal_buried": true}))
	var memorial_event := event("Комиссия по памяти", "official", "#8b6c4b", "Кресты у братской могилы", "На месте массовых казней времён оккупации семьи погибших и приходы поставили деревянные кресты. Мэрия считает установку самовольной: здесь уже утверждён проект государственного мемориала. Техника ждёт у ворот, рядом собираются верующие, историки и сторонники оппозиции. Решение о сносе попадёт в утренние новости.",
		option("Признать кресты мемориалом", "Церковь и семьи поддержат власть • охрана памятника потребует денег • площадь станет местом митингов", {"money": -4, "clan_church": 9, "support": 2, "stability": -2}, "Технику отвели, кресты внесли в охранный реестр. Родственники впервые провели поминовение без полицейского кордона, но к вечеру у мемориала уже выступали противники правительства."),
		option("Убрать кресты ночью", "Порядок сейчас укрепится • церковь и общество резко ответят • при слабой власти возможен протест", {"money": -1, "clan_church": -10, "support": -4, "stability": 4, "authoritarian": 1}, "Полиция закрыла дорогу до рассвета, рабочие вывезли кресты. К утру участок был пуст, зато фотографии грузовиков и задержанных родственников разошлись по всей стране.", {"unrest": {"cause": "ночной снос крестов у братской могилы", "kind": "civic", "base_level": 1, "condition": "low_support", "reversible": false}}),
		option("Приостановить снос и сверить проект", "Дорогое согласование • церковь останется за столом • окончательное решение отложат", {"money": -6, "clan_church": 2, "support": 1, "stability": 1}, "Комиссия занесла каждый крест на план и пригласила семьи на слушания. Ни техника, ни активисты не ушли далеко: все ждут, какие знаки останутся после утверждения нового проекта."))
	var pulpit_event := event("Избирательная комиссия", "official", "#c7a96b", "Письмо к воскресной службе", "Перед досрочными выборами руководство Церкви Веры разослало настоятелям письмо о «долге сохранить дело основателя республики». Имя президента в нём не названо, но его штаб уже печатает цитаты на листовках. Оппозиция требует запретить агитацию в храмах, а приходы говорят, что государство не вправе править их проповеди.",
		option("Принять поддержку кафедр", "Президент получит сторонников • церковь укрепится • профсоюзы и часть общества увидят давление", {"support": 4, "stability": -3, "clan_church": 9, "clan_workers": -5}, "Штаб процитировал письмо на каждом митинге. В воскресенье прихожане услышали знакомые слова с кафедр, а профсоюзы объявили, что выборы превращают в продолжение службы."),
		option("Потребовать равной дистанции", "Избирательный порядок укрепится • понадобится контроль • церковь сочтёт это цензурой", {"money": -2, "support": 2, "stability": 2, "clan_church": -8}, "Комиссия направила наблюдателей на встречи всех кандидатов, а письмо перестало появляться в правительственных материалах. Иерархи обвинили президента в том, что он пользуется их доверием и одновременно запрещает им говорить."),
		option("Открыть приходы для всех кандидатов", "Потребуются расходы и согласования • спор о проповедях продолжится • церковь сохранит влияние", {"money": -3, "support": 1, "stability": -2, "clan_church": 2, "clan_workers": 2}, "Приходские залы стали площадками для встреч с разными кандидатами. Часть настоятелей соблюла расписание, другие отвели президенту лучшие часы, и комиссия получила новые жалобы."))
	var monastery_event := event("Министерство внутренних дел", "official", "#a9473f", "Ночь за монастырскими воротами", "После разгона местного митинга несколько десятков человек, в том числе раненые, укрылись в монастыре. Настоятель впустил врачей, но не вооружённую полицию. МВД утверждает, что среди укрывшихся есть организаторы нападения на патруль; приходы считают, что после штурма монастыря люди перестанут верить любым обещаниям безопасности.",
		option("Гарантировать убежище до суда", "Церковь и часть общества поддержат власть • полиция утратит контроль над задержанием • напряжение вырастет", {"clan_church": 8, "support": 4, "stability": -5}, "Полицейский кордон отступил от ворот, раненых вывезли врачи. Организаторы митинга остались внутри до судебных повесток, а МВД обвинило правительство в срыве задержаний."),
		option("Войти с полицией", "Порядок быстро восстановится • церковь и общество отвернутся • при слабой власти возможен новый протест", {"clan_church": -10, "support": -5, "stability": 5, "authoritarian": 1}, "Полиция вошла через боковые ворота и вывела подозреваемых. Министерство доложило об успешной операции, но фотографии монахов между щитами и ранеными стали новым символом протеста.", {"unrest": {"cause": "вход полиции в монастырь после разгона митинга", "kind": "civic", "base_level": 1, "condition": "low_support", "reversible": false}}),
		option("Допустить адвокатов и переговорщиков", "Стороны сохранят лицо • потребуются деньги и время • никто не получит полного контроля", {"money": -4, "clan_church": 2, "support": 2, "stability": -2}, "Адвокаты составили список укрывшихся, врачи вывезли раненых, а суд выдал повестки без немедленного штурма. Полиция и настоятель договорились лишь до утра; спор о виновных остался открытым."))
	var battalion_event := event("Пограничный губернатор", "military", "#536f82", "Батальон у заставы", "После серии диверсий губернатор собрал три тысячи добровольцев. У них свои командиры, пожертвованная олигархами техника и высокий авторитет в приграничье. Штаб предлагает включить батальон в армию, МВД — разоружить, губернаторы — узаконить такие отряды в каждом регионе.",
		option("Включить батальон в армию", "Часть работоспособных перейдёт в армию • единое командование возникнет не сразу • позже придётся решить конфликт приказов", {"money": -5, "population_workable": -3000, "army_personnel": 3000, "army": 4, "war_support": 5, "stability": -3}, "Добровольцам выдали армейские номера, но оставили прежнего командира на переходный период. В штабе уже лежат два несовместимых плана их применения.", {"volunteers_integrated": true}),
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
	var unified_broadcast_event := event("Национальный совет вещания", "official", "#536f82", "Один эфир на всех", "После недели тревожных сообщений четыре крупнейших канала предлагают объединить вечерние новости. Государство будет выдавать общий сигнал, владельцы каналов — по очереди формировать редакцию. Журналисты опасаются единой повестки, штаб говорит о панике из-за противоречивых сообщений, а олигархи не хотят оплачивать чужой эфир.",
		option("Создать единый государственный эфир", "Порядок и военные настроения укрепятся • поддержка и владельцы каналов пострадают • власть получит рычаг над новостями", {"money": -3, "support": -5, "stability": 6, "war_support": 5, "clan_oligarchs": -7, "authoritarian": 1}, "Все каналы показали одну студию и одну карту страны. Противоречивых сообщений стало меньше, но независимые редакции начали вести ночные выпуски в сети.", {"unified_state_broadcast": true, "unrest": {"cause": "создание единого государственного новостного эфира", "kind": "civic", "base_level": 1, "condition": "low_support", "reversible": false}}),
		option("Оставить каналы независимыми", "Свободный эфир укрепит поддержку • разноголосица ударит по стабильности • владельцы каналов усилятся", {"support": 4, "stability": -5, "war_support": -3, "clan_oligarchs": 6}, "Каналы сохранили собственные выпуски. Уже вечером один сообщил о закрытой границе, другой — о свободном проезде; правительство потратило ночь на опровержения.", {"independent_crisis_broadcasts": true}),
		option("Учредить общественную редакцию", "Потребуются деньги и спорное соглашение • влияние государства и владельцев ограничат • порядок улучшится умеренно", {"money": -7, "support": 2, "stability": 2, "clan_oligarchs": -3, "clan_workers": 3}, "Редакционный совет разделили между каналами, университетами и общественными организациями. Выпуски выходят медленнее, зато к каждому спорному сообщению теперь прикладывают источник.", {"public_broadcast_consortium": true}))
	var governor_vertical_event := event("Счётная палата", "official", "#8b6c4b", "Губернатор на ковре", "Губернатор Южного края отказался перечислять в центр доходы нового терминала, заявив, что столица годами не ремонтировала областные дороги. Проверка нашла закупки у фирмы его зятя, но региональный совет утверждает: расследование началось только после отказа делиться деньгами.",
		option("Снять губернатора указом", "Центр вернёт контроль и часть доходов • регионы резко отвернутся • поддержка снизится", {"money": 6, "support": -4, "stability": 5, "clan_regions": -12, "authoritarian": 1}, "Губернатора вывели из администрации, а временного управляющего прислали из столицы. Деньги терминала вернулись в бюджет, но четыре областных совета потребовали проверить законность указа.", {"governor_removed_by_decree": true}),
		option("Открыть публичный аудит", "Проверка обойдётся дорого и раскачает аппарат • поддержка и контроль над олигархами укрепятся", {"money": -5, "support": 5, "stability": -4, "clan_regions": 4, "clan_oligarchs": -6}, "Заседания аудиторов показали в прямом эфире. Фирма зятя потеряла контракт, однако проверяющие нашли похожие схемы уже у столичных ведомств.", {"governor_public_audit": true}),
		option("Оставить доходы региону", "Конфликт утихнет и регионы укрепятся • казна потеряет поступления • губернатор сохранит свою сеть", {"money": -7, "support": -2, "stability": 3, "clan_regions": 11, "clan_oligarchs": 4}, "Южный край получил право оставить сборы на два года. Дороги начали ремонтировать, а остальные губернаторы прислали собственные списки доходов, которые тоже хотели бы не перечислять центру.", {"regional_terminal_revenue": true}))
	var digital_draft_event := event("Мобилизационное управление", "military", "#536f82", "Повестка в телефоне", "Военное ведомство подготовило единый электронный реестр военнообязанных. Система найдёт резервистов быстрее бумажных списков, но в тестовой базе обнаружились умершие, эмигранты и сотрудники критических предприятий. Штаб хочет признать сообщение в приложении вручённой повесткой уже на этой неделе.",
		option("Запустить обязательные повестки", "Армия получит быстрый резерв • расходы, протестные настроения и недоверие регионов вырастут", {"money": -6, "army": 6, "war_support": -7, "stability": -3, "clan_regions": -6}, "Приложение разослало первые уведомления ночью. У военкоматов появились очереди исправлять ошибки, а штаб впервые получил общую карту доступного резерва.", {"digital_draft_registry": true, "unrest": {"cause": "обязательные электронные повестки", "kind": "civic", "base_level": 1, "condition": "low_war_support", "reversible": false}}),
		option("Открыть добровольную сверку", "Реестр станет точнее и власть сохранит доверие • армия получит меньше людей и не сразу", {"money": -4, "support": 3, "army": 2, "war_support": -2, "clan_regions": 3}, "Гражданам предложили проверить данные без автоматического призыва. За неделю исправили тысячи записей, но командиры получили лишь небольшой список добровольцев.", {"voluntary_draft_registry": true}),
		option("Вернуться к бумажным спискам", "Расходов почти не будет • поддержка войны сохранится • штаб и боеспособность пострадают", {"support": 2, "stability": -2, "army": -6, "clan_regions": 2}, "Реестр отправили на доработку, а военкоматы снова открыли картотеки. Ошибок стало привычно меньше видно, но розыск каждого резервиста снова занял дни.", {"digital_draft_postponed": true}))
	var opposition_plane_event := event("Пограничная служба", "official", "#a9473f", "Самолёт из эмиграции", "Регулярным рейсом возвращается бывший руководитель крупнейшего оппозиционного движения. Прокуратура заранее выписала ордер по делу о зарубежном финансировании, адвокаты называют обвинение политическим, а несколько тысяч сторонников едут в аэропорт. Самолёт уже вошёл в воздушное пространство республики.",
		liberal_option("Пропустить без задержания", "Поддержка открытой политики вырастет • улица и аппарат станут менее предсказуемыми • брат сочтёт это слабостью", {"support": 6, "stability": -6, "clan_workers": 4, "army": -3}, "Политик прошёл паспортный контроль и сразу поднялся на крышу автомобиля перед толпой. Он поблагодарил президента за соблюдение закона и назначил марш через две недели.", "Поддержка открытой политики вырастет • улица и аппарат станут менее предсказуемыми", "Политик прошёл паспортный контроль и сразу поднялся на крышу автомобиля перед толпой. Он поблагодарил президента за соблюдение закона и назначил марш через две недели.", {"opposition_returned_free": true}),
		option("Задержать в аэропорту", "Порядок укрепится немедленно • поддержка и отношения с Западом пострадают • история продолжится в суде", {"support": -6, "stability": 5, "west_pressure": 5, "authoritarian": 1}, "Пограничники задержали пассажира у трапа и вывезли через грузовой терминал. Толпа осталась у закрытого выхода, а суд получил ночь на решение о новом сроке ареста.", {"opposition_returned_detained": true}),
		option("Предложить публичные дебаты", "Казна оплатит эфир и охрану • обе стороны рискуют рейтингом • немедленное столкновение будет отложено", {"money": -5, "support": 2, "stability": -2, "clan_oligarchs": -3}, "Ордер приостановили до прямого эфира. Политик принял вызов, но потребовал три часа без монтажа и право принести собственные документы.", {"opposition_returned_debate": true}))
	var parliamentary_cash_event := event("Антикоррупционная служба", "official", "#c7a96b", "Пакеты на пленарном заседании", "Перед голосованием по государственным закупкам депутат правящей коалиции уронил в зале пакет с крупной суммой наличных. Он называет деньги пожертвованием на региональную больницу, маркировка банка ведёт к холдингу, участвующему в тендере, а без его фракции бюджетное большинство может распасться.",
		option("Разрешить обыск фракции", "Расследование ударит по большинству и стабильности • поддержка вырастет • олигархи потеряют влияние", {"support": 6, "stability": -6, "clan_oligarchs": -11}, "Следователи вынесли из кабинетов ещё три пакета и списки голосований. Коалиция потеряла несколько депутатов, зато дело невозможно закрыть одной запиской президента.", {"parliament_cash_raid": true}),
		option("Ограничиться партийным взысканием", "Большинство и порядок сохранятся • поддержка упадёт • олигархи укрепят договорённости", {"support": -6, "stability": 5, "clan_oligarchs": 9, "authoritarian": 1}, "Депутат вышел из комитета и сохранил мандат. Пакет объявили частным нарушением, а закон о закупках прошёл теми же голосами через два дня.", {"parliament_cash_disciplined": true}),
		option("Провести открытое переголосование", "Решение потребует времени и денег • общество увидит голоса • регионы получат больше самостоятельности", {"money": -3, "support": 3, "stability": -2, "clan_regions": 5, "clan_oligarchs": -4}, "Каждый депутат голосовал с трибуны, объясняя позицию. Спорную поправку отклонили, но региональные фракции потребовали такого же порядка для всего бюджета.", {"parliament_open_revote": true}))

	insert_story_event_after("Слишком большой портрет", dinner_event)
	insert_story_event_after("Ужин остывает", wine_event)
	insert_story_event_after("Бутылка из погреба", father_room_event)
	insert_story_event_after("Комната отца", motorcade_event)
	insert_story_event_after("Слишком большой портрет", health_event)
	insert_story_event_after("Слишком большой портрет", tape_event)
	insert_story_event_after("Квартальная поправка", tariff_event)
	insert_story_event_after("Учебник Веры", faith_event)
	insert_story_event_after("Учебник Веры", church_scandal_event)
	insert_story_event_after("Автобусы у перевала", memorial_event)
	insert_story_event_after("Весна в столице", monastery_event)
	insert_story_event_after("Некомплект гарнизонов", battalion_event)
	insert_story_event_after("Весна в столице", archive_event)
	insert_story_event_after("Весна в столице", committee_event)
	insert_story_event_after("Комитет двенадцати", protocols_event)
	insert_story_event_after("Протокол с мокрой печатью", pulpit_event)
	insert_story_event_after("Комитет двенадцати", court_event)
	insert_story_event_after("Два паспорта", language_event)
	insert_story_event_after("Три языка в одном классе", radio_event)
	insert_story_event_after("Частота 91,3", media_sale_event)
	insert_story_event_after("Автобусы у перевала", border_event)
	insert_story_event_after("Столб номер 217", mobility_event)
	insert_story_event_after("Пустующие цеха", heating_event)
	insert_story_event_after("Самолёты с чужими кодами", turbine_event)
	insert_story_event_after("Пропавший свидетель", returnees_event)
	insert_story_event_after("Канал на продажу", unified_broadcast_event)
	insert_story_event_after("Машина у школы", governor_vertical_event)
	insert_story_event_after("Батальон у заставы", digital_draft_event)
	insert_story_event_after("Плёнка из приёмной", opposition_plane_event)
	insert_story_event_after("Квартальная поправка", parliamentary_cash_event)

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
		"Ужин остывает": "society", "Бутылка из погреба": "society", "Комната отца": "society", "Машина у школы": "society", "Скандал с церковью": "society",
		"Кресты у братской могилы": "society", "Письмо к воскресной службе": "society", "Ночь за монастырскими воротами": "society",
		"Один эфир на всех": "society", "Губернатор на ковре": "society", "Самолёт из эмиграции": "society",
		"Пакеты на пленарном заседании": "economy", "Повестка в телефоне": "army",
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
		{"id": "ceremony", "source": "Министерство культуры", "role": "family", "accent": "#c7a96b", "title": "День первого флага", "body": "В городе {city} готовят годовщину первого поднятия республиканского флага. Совет просит выбрать между гражданской церемонией и службой Церкви Веры.", "left": {"label": "Провести городской праздник", "hint": "Расходы • широкая поддержка вырастет • Церковь Веры окажется в стороне", "effects": {"money": -2, "support": 3, "clan_church": -2}, "result": "На площади города {city} выступили школьные оркестры и ветераны независимости. Светская церемония собрала много людей, но духовенство отказалось участвовать."}, "right": {"label": "Поддержать службу Веры", "hint": "Церковь заметно укрепится • светская часть общества отнесётся прохладнее", "effects": {"support": 1, "clan_church": 3}, "result": "Колокола региона «{region}» звонили одновременно. Церковь Веры назвала независимость общим обетом страны, а светские организации провели отдельную встречу."}},
		{"id": "parish_kitchen", "source": "Совет общин Веры", "role": "family", "accent": "#8b6c4b", "title": "Приходская столовая", "body": "В городе {city} церковные волонтёры кормят семьи работников закрывшегося цеха. Приход готов взять муниципальную столовую на себя, если сможет назначать персонал и распоряжаться помещением. Профсоюз требует сохранить городские рабочие места и общие правила выдачи еды.", "left": {"label": "Передать столовую приходу", "hint": "Церковь укрепится • казна избежит расходов • профсоюзы и часть жителей будут недовольны", "effects": {"clan_church": 5, "clan_workers": -4, "support": -1}, "result": "Приход открыл двери столовой города {city} уже утром. Очередь прошла быстро, но прежние муниципальные работники узнали о новой смене из объявления на воротах."}, "right": {"label": "Сохранить городскую столовую", "hint": "Казна оплатит работу • профсоюзы и жители поддержат решение • церковь отстранится", "effects": {"money": -4, "clan_church": -4, "clan_workers": 3, "support": 2}, "result": "Город сохранил штат и открыл отдельную линию для семей без документов. Церковные волонтёры продолжают приносить продукты, но настоятель отказался от совместного управления."}},
		{"id": "chaplains", "source": "Военно-медицинское управление", "role": "military", "accent": "#77947d", "title": "Помощь гарнизону", "body": "В гарнизоне возле города {city} после череды пограничных выездов выросло число обращений к военным врачам. Церковь Веры предлагает направить капелланов для добровольных бесед, а врачи просят нанять штат гражданских психологов: они смогут работать и с теми солдатами, кто не принадлежит к Вере.", "left": {"label": "Допустить капелланов", "hint": "Церковь и поддержка войны укрепятся • армия получит недорогую помощь", "effects": {"money": -1, "clan_church": 4, "war_support": 2, "army": 1}, "result": "Капелланы приехали в гарнизон возле города {city} без сопровождения чиновников. Часть солдат пришла на беседы, остальные попросили военных врачей оставить им прежний порядок помощи."}, "right": {"label": "Нанять военных психологов", "hint": "Дороже • армия и общая устойчивость укрепятся • церковь потеряет доступ к части", "effects": {"money": -5, "clan_church": -4, "army": 4, "support": 2, "stability": 2}, "result": "Психологи начали приём без религиозных вопросов и подготовили командиров к новым ротациям. Церковь обвинила штаб в том, что её добровольцев не пустили даже к попросившим о встрече солдатам."}}
	]
	templates.append_array(preload("res://scripts/political_dispatches.gd").templates())
	var templates_by_family := {}
	var all_families: Array[String] = []
	for template in templates:
		var family := str(template["id"])
		templates_by_family[family] = template
		all_families.append(family)

	var used_variants := {}
	var family_schedule: Array[String] = all_families.duplicate()
	for shuffle_index in range(family_schedule.size() - 1, 0, -1):
		var swap_index := routine_rng.randi_range(0, shuffle_index)
		var chosen_family := family_schedule[shuffle_index]
		family_schedule[shuffle_index] = family_schedule[swap_index]
		family_schedule[swap_index] = chosen_family
	if family_schedule.size() < DEMO_WEEKS * (EVENTS_PER_WEEK - 1):
		push_error("Не хватает разных малых событий для кампании без повторов.")
	for family_index in range(mini(family_schedule.size(), DEMO_WEEKS * (EVENTS_PER_WEEK - 1))):
		var family := family_schedule[family_index]

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
		var contextual_body := format_routine_text(body_template, location)
		var context_note := format_routine_text(recurring_event_context(family, int(location["region_index"])), location)
		if context_note != "":
			contextual_body += " " + context_note
		var routine_title := str(template["title"])
		if body_template.contains("{city}") or body_template.contains("{region}") or body_template.contains("{office}"):
			routine_title += " — " + str(location["city"])
		var routine := event(
			str(template["source"]),
			str(template["role"]),
			str(template["accent"]),
			routine_title,
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
		],
		"parish_kitchen": [
			"Приход уже развернул временные столы в бывшем школьном спортзале, который город обещал отремонтировать.",
			"Часть семей добирается на лодке с другого берега озера, и волонтёры просят помещение рядом с пристанью.",
			"После остановки элеватора число людей в очереди удвоилось, а городской запас продуктов рассчитан только на неделю.",
			"Бывшая столовая комбината стоит пустой; её оборудование принадлежит городу, а здание — частному владельцу."
		],
		"chaplains": [
			"Командование опасается, что бойцы перестанут обращаться за помощью, если беседы станут частью обязательной проверки.",
			"Солдаты разных общин служат в одной роте, поэтому командир просит заранее установить правило добровольности.",
			"После учений на полигоне несколько контрактников попросили перевода ближе к семьям.",
			"Один из офицеров уже пригласил знакомого священника без приказа штаба, и теперь врачи требуют единых правил."
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
	for side in event_peace_requirements(event_data):
		if at_war_with(side):
			return true
	return false


func build_wartime_replacement_event(blocked_event: Dictionary) -> Dictionary:
	var blocked_enemy := str(state.get("war_enemy", "east"))
	for side in event_peace_requirements(blocked_event):
		if at_war_with(side):
			blocked_enemy = side
			break
	var enemy := neighbor_title(blocked_enemy)
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
	return {"label": option_label, "hint": hint, "effects": convert_legacy_population_effects(effects), "result": result, "set": flags}


func liberal_option(option_label: String, hint: String, effects: Dictionary, result: String, hint_without_brother: String, result_without_brother: String, flags: Dictionary = {}) -> Dictionary:
	var option_data := option(option_label, hint, effects, result, flags)
	option_data["liberal_army_reaction"] = true
	option_data["liberal_army_effect"] = int(effects.get("army", 0))
	option_data["hint_with_brother"] = hint
	option_data["result_with_brother"] = result
	option_data["hint_without_brother"] = hint_without_brother
	option_data["result_without_brother"] = result_without_brother
	return option_data
