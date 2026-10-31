extends RefCounted

# One authored four-report storyline occupies an ordinary report slot in weeks
# 6, 7, 9 and 11. Its earlier choices change later reports and the election.


static func choice(caption: String, hint: String, effects: Dictionary, result: String, flags: Dictionary = {}) -> Dictionary:
	return {"label": caption, "hint": hint, "effects": effects, "result": result, "set": flags}


static func report(source: String, role: String, title: String, body: String, left: Dictionary, right: Dictionary, third: Dictionary = {}) -> Dictionary:
	var item := {"source": source, "role": role, "accent": "#a07b56", "title": title, "body": body, "left": left, "right": right}
	if not third.is_empty():
		item["third"] = third
	return item


static func build(arc: String, stage: int, state: Dictionary) -> Dictionary:
	if arc == "factory":
		return factory_report(stage, state)
	if arc == "broadcast":
		return broadcast_report(stage, state)
	return {}


static func factory_report(stage: int, state: Dictionary) -> Dictionary:
	match stage:
		1:
			return report("Министерство экономики", "official", "Ведомость за закрытой дверью",
				"Металлургический завод в Рудне получил государственный заказ на броневые листы, но рабочие третий месяц ждут зарплату. Директор Павел Рог просит аванс из казны: без него он остановит печи. Представительница смены Лада Серин приносит фотографию вашего отца на открытии цеха. Под ней его обещание: «Государство не бросит завод». До выплаты осталось три дня.",
				choice("Выдать аванс на зарплаты", "Казна заплатит за частный завод • смены продолжатся • собственник избежит немедленной ответственности", {"money": -6, "support": 2, "clan_workers": 3, "clan_oligarchs": 2}, "Казначейство перечислило деньги напрямую на зарплатные счета. Директор обещал вернуть аванс после поставки, а Лада попросила показать ей платёжные ведомости через неделю.", {"campaign_arc_started": true, "factory_advance": true}),
				choice("Потребовать денег от собственника", "Казна сохранится • рабочие получат публичную поддержку • владелец может сократить смены", {"stability": -2, "support": 1, "clan_workers": 2, "clan_oligarchs": -4}, "Павел Рог подписал обязательство выплатить долг из собственных счетов. В тот же вечер завод отменил две смены, а профсоюз попросил проверить, было ли это неизбежно.", {"campaign_arc_started": true, "factory_advance": false}))
		2:
			var body := "Неделю назад вы выдали заводу аванс. Зарплаты пришли, но Лада Серин нашла второй платёж: часть денег прошла через фирму, принадлежащую семье директора. Павел Рог говорит, что это поставщик руды и без него печи остановятся. Проверить документы можно только открыв и государственный контракт." if bool(state.get("factory_advance", false)) else "Неделю назад вы обязали Павла Рога выплатить долг самостоятельно. Деньги пришли не всем: директор закрыл две смены и назвал это пересмотром заказа. Лада Серин приносит список работников, которых сняли с графика после её жалобы. Завод утверждает, что государство не оплатило дополнительные броневые листы."
			return report("Счётная палата", "official", "Вторая платёжка", body,
				choice("Открыть счета и контракт", "Проверка потребует денег • вскроет и ошибки государства • директор потеряет защиту", {"money": -3, "support": 2, "stability": -2, "clan_oligarchs": -3, "clan_workers": 2}, "Ревизоры опубликовали оба платежа и сроки поставки. Они нашли спорные счета директора, но также подтвердили, что ведомство меняло заказ уже после подписания договора.", {"factory_public_audit": true}),
				choice("Согласовать закрытый график", "Печи заработают без публичного спора • директор сохранит контроль • рабочие не увидят условий", {"money": -1, "stability": 2, "clan_oligarchs": 3, "clan_workers": -3}, "Правительство и директор подписали новый график выплат без участия смен. Печи запустили, однако на проходной появилась копия соглашения с закрашенными суммами.", {"factory_public_audit": false}))
		3:
			var body := "После открытой проверки директор уволил трёх работников, передавших ревизорам документы. Лада Серин требует признать выборный совет смен, иначе в понедельник люди не выйдут к печам. Павел Рог считает это захватом управления заводом." if bool(state.get("factory_public_audit", false)) else "Закрытое соглашение не удержало завод. Рабочие нашли в нём пункт об отмене части надбавок, а Павел Рог уже заказал охрану для проходной. Лада Серин предлагает избрать совет смен до начала следующего заказа."
			var third := {}
			if bool(state.get("factory_public_audit", false)):
				third = choice("Передать увольнения парламенту", "Расследование затянется • рабочие получат защиту • парламент начнёт проверять государственный заказ", {"money": -2, "support": 2, "stability": -2, "clan_workers": 3, "clan_oligarchs": -3}, "Парламентская комиссия потребовала вернуть уволенных до окончания проверки. Директор согласился, но предупредил, что следующий контракт будет обсуждать уже с депутатами, а не только с президентом.", {"factory_worker_committee": true, "factory_parliament_hearing": true})
			return report("Трудовая инспекция", "official", "Пустая проходная", body,
				choice("Признать совет смен", "Понадобятся расходы и переговоры • рабочие вернутся • собственник потеряет часть контроля", {"money": -3, "support": 1, "stability": -2, "clan_workers": 4, "clan_oligarchs": -3}, "Лада Серин собрала представителей цехов в столовой. Смена вернулась к печам после обещания обсуждать следующий контракт с выборным советом.", {"factory_worker_committee": true}),
				choice("Вернуть смены приказом", "Поставки возобновятся быстрее • армия одобрит жёсткость • возможна забастовка", {"stability": 2, "support": -3, "army": 2, "clan_workers": -4, "clan_oligarchs": 2}, "Ворота открыли под охраной. Часть смен вышла, часть оставила каски у проходной и объявила, что не признаёт новый график.", {"factory_worker_committee": false, "unrest": {"cause": "возвращение заводских смен приказом без соглашения", "kind": "labor", "labor": true, "base_level": 1, "condition": "workers_low", "reversible": false}}), third)
		4:
			if bool(state.get("factory_worker_committee", false)):
				var hearing := " Парламентская комиссия тоже ждёт вашей подписи: её расследование нашло ошибки и директора, и министерства." if bool(state.get("factory_parliament_hearing", false)) else ""
				var director_offer := "быстрый возврат выданного аванса" if bool(state.get("factory_advance", false)) else "снижение цены государственного заказа"
				var final_report := report("Министерство экономики", "official", "Контракт до выборов", "Лада Серин и Павел Рог принесли два варианта следующего государственного заказа. В одном совет смен получает право проверять зарплатные платежи. В другом директор обещает казне " + director_offer + ", если больше не придётся согласовывать график с рабочими." + hearing,
					choice("Закрепить совет смен", "Новый контроль потребует денег • рабочие поддержат власть • собственник потеряет свободу распоряжаться заказом", {"money": -4, "support": 2, "clan_workers": 4, "clan_oligarchs": -3}, "Совет смен подписал контракт вместе с директором. Зарплаты теперь видны работникам до закрытия ведомости; Рог обещал спорить о каждом новом заказе.", {"campaign_arc_legacy": "factory_council"}),
					choice("Вернуть контроль директору", "Казна получит платёж • владелец сохранит завод • доверие рабочих резко упадёт", {"money": 5, "stability": 1, "clan_oligarchs": 4, "clan_workers": -4}, "Директор перечислил оговорённый платёж и получил контракт без выборного совета. Лада Серин осталась на заводе, но сказала, что подпись президента рабочие запомнят к выборам.", {"campaign_arc_legacy": "factory_director"}))
				var director_offer_en := "repay the advance" if bool(state.get("factory_advance", false)) else "cut the cost of the state order"
				final_report["body_en"] = "Lada Serin and Pavel Rog have brought you two versions of the next state contract. One gives the shift council the right to inspect wage payments. In the other, Rog offers to " + director_offer_en + " if he no longer has to negotiate the work schedule with employees."
				if bool(state.get("factory_parliament_hearing", false)):
					final_report["body_en"] += " The parliamentary committee also awaits your signature: its inquiry found mistakes by both the director and the ministry."
				return final_report
			return report("Министерство экономики", "official", "Контракт до выборов", "Охрана всё ещё стоит у ворот. Павел Рог предлагает продлить прямой государственный заказ, Лада Серин просит хотя бы вернуть уволенных и снять посты. Новый контракт решит, станет ли временный приказ обычным способом управлять заводом.",
				choice("Снять охрану и договориться", "Потребуются деньги и уступки • рабочие вернутся • штаб сочтёт отступление слабостью", {"money": -4, "support": 2, "army": -2, "clan_workers": 3, "clan_oligarchs": -2}, "Охрану вывели, смены составили новый график вместе с инспекцией. Поставки возобновились позже обещанного, но спор перестал быть вопросом силы.", {"campaign_arc_legacy": "factory_settlement"}),
				choice("Продлить особый порядок", "Заказ пойдёт без переговоров • штаб и директор поддержат власть • рабочий конфликт останется", {"stability": 2, "support": -3, "army": 2, "clan_oligarchs": 3, "clan_workers": -4}, "Посты охраны стали постоянными, график теперь утверждает дирекция. На заводе работают, но увольнения и списки недовольных стали частью нового контракта.", {"campaign_arc_legacy": "factory_security", "unrest": {"cause": "продление особого порядка на металлургическом заводе", "kind": "labor", "labor": true, "base_level": 1, "condition": "workers_low", "reversible": false}}))
	return {}


static func broadcast_report(stage: int, state: Dictionary) -> Dictionary:
	match stage:
		1:
			return report("Национальный телеканал", "official", "Вопросы до эфира", "Журналистка Нина Белецкая получила перечень вопросов для вечернего интервью о первых неделях вашего правления. Список составлен в президентской канцелярии, хотя канал получает государственные деньги по договору о независимом вещании. Редактор просит решить, можно ли показать зрителям сам договор. Канцелярия предупреждает: в нём есть расходы на безопасность эфира.",
				choice("Опубликовать договор", "Зрители увидят условия и государственные расходы • редакция сохранит самостоятельность • возникнут неудобные вопросы", {"money": -2, "support": 2, "stability": -2, "clan_oligarchs": -2}, "Договор вышел вместе со списком вопросов. Белецкая провела интервью в прямом эфире, а зрители начали сверять обещания президента с текстом на сайте канала.", {"campaign_arc_started": true, "broadcast_contract_open": true}),
				choice("Оставить договор служебным", "Канцелярия сохранит контроль над эфиром • часть редакции и зрителей потеряет доверие", {"stability": 2, "support": -2, "clan_oligarchs": 2}, "Интервью прошло по согласованному списку. Нина Белецкая задала один незапланированный вопрос и получила уведомление о проверке своего доступа к студии.", {"campaign_arc_started": true, "broadcast_contract_open": false}))
		2:
			var body := "После публикации договора редакция обнаружила ещё одну страницу — таблицу тем, которые советовали не обсуждать до выборов. Нина Белецкая просит гарантию, что государственный рекламодатель не сможет снимать журналистов с эфира. Канцелярия считает список обычным планированием." if bool(state.get("broadcast_contract_open", false)) else "После закрытого интервью Нину Белецкую сняли с ближайшего эфира. Коллеги опубликовали служебное письмо с рекомендацией не приглашать оппозицию. Канцелярия отрицает цензуру и напоминает, что канал работает на государственные деньги."
			return report("Совет по вещанию", "official", "Пустое кресло в студии", body,
				choice("Защитить редакцию", "Редактор вернётся • расследование обойдётся денег • аппарат и владельцы канала будут недовольны", {"money": -3, "support": 2, "stability": -2, "clan_oligarchs": -3}, "Белецкая вернулась в студию, а совет по вещанию потребовал объяснить каждую попытку снять передачу с эфира. Теперь любой новый запрет станет публичным.", {"broadcast_editor_protected": true}),
				choice("Дать канцелярии право согласования", "Эфир станет предсказуемее • аппарат укрепится • редакция начнёт искать другие площадки", {"stability": 2, "support": -2, "clan_oligarchs": 2}, "Редактор получил новый порядок согласования. Белецкая продолжила работать, но первые два материала отправила независимому районному каналу.", {"broadcast_editor_protected": false}))
		3:
			var body := "Нина Белецкая открыла независимый вечерний выпуск, и зрители присылают туда вопросы, не попавшие на главный канал. Владельцы региональных передатчиков требуют государственную гарантию: они боятся лишиться частот за одну неугодную передачу." if bool(state.get("broadcast_editor_protected", false)) else "Запрещённые сюжеты появились сразу на трёх районных частотах. Канцелярия просит проверить лицензии, а владельцы передатчиков говорят, что ни один закон не запрещает обсуждать государственный контракт и будущие выборы."
			return report("Региональные вещатели", "official", "Три районные частоты", body,
				choice("Гарантировать открытый эфир", "Понадобятся деньги на наблюдение • разные взгляды будут слышны • власть потеряет удобный контроль", {"money": -3, "support": 2, "stability": -2, "clan_regions": 2}, "Региональные каналы получили одинаковые правила доступа к передатчикам. Правительству пришлось отвечать и на вопросы, которые оно не выбирало.", {"broadcast_open_air": true}),
				choice("Оставить частоты под надзором", "Канцелярия сохранит контроль • часть регионов и зрителей отвернётся • при слабой поддержке возможен протест", {"stability": 2, "support": -3, "clan_regions": -3}, "Частоты сохранили, но каждую политическую передачу стали проверять до выхода. Белецкая продолжила выпуск в сети, где государственный надзор оказался гораздо менее убедительным.", {"broadcast_open_air": false, "unrest": {"cause": "предварительная проверка региональных политических передач", "kind": "civic", "base_level": 1, "condition": "low_support", "reversible": false}}))
		4:
			var body := "После гарантии открытого эфира канал готов провести общенациональные дебаты. Нина Белецкая предупреждает: вопросы зададут и министрам, и оппозиции, без права согласовать их заранее. Канцелярия предлагает вместо этого собственную итоговую программу." if bool(state.get("broadcast_open_air", false)) else "Перед выборами Нина Белецкая предложила провести общие дебаты на региональных частотах. Канцелярия опасается, что любой спор попадёт в эфир без контекста, и готовит единую государственную программу о результатах правления."
			var third := {}
			if bool(state.get("broadcast_editor_protected", false)) and bool(state.get("broadcast_open_air", false)):
				third = choice("Передать эфир комиссии", "Независимая сетка обойдётся дороже • штаб потеряет влияние на дебаты • итогу выборов поверят охотнее", {"money": -5, "support": 1, "stability": -3, "clan_regions": 3, "clan_oligarchs": -3}, "Канал передал предвыборную сетку межпартийной комиссии. Белецкая ведёт дебаты, но редакция не вправе менять список участников в пользу президента или его соперников.", {"campaign_arc_legacy": "broadcast_independent"})
			return report("Национальный телеканал", "official", "Эфир до голосования", body,
				choice("Провести открытые дебаты", "Кандидаты получат равное время • подсчёту поверят охотнее • президенту придётся отвечать без подготовки", {"money": -3, "support": 2, "stability": -2, "clan_regions": 2}, "В прямом эфире прозвучали вопросы о бюджете, долге и соседях. Президент ответил не на все, но после эфира меньше людей сомневаются, что они услышат и другую сторону.", {"campaign_arc_legacy": "broadcast_open"}),
				choice("Показать государственный итог", "Официальная кампания получит удобный эфир • порядок на время укрепится • признание результатов станет труднее", {"stability": 2, "support": -2, "clan_oligarchs": 3}, "Канал показал подготовленный фильм о правлении. Рейтинги оказались высокими, но независимые редакции выпустили запись вопросов, которые до эфира не допустили.", {"campaign_arc_legacy": "broadcast_managed"}), third)
	return {}


static func election_memory(legacy: String) -> Dictionary:
	match legacy:
		"factory_council":
			return {"ru": "В Рудне Лада Серин сверяет новый контракт с советом смен. Рабочие обещают принести на участки свои ведомости: они хотят видеть, что подписанное вами соглашение переживёт выборы.", "en": "In Rudnya, Lada Serin checks the new contract with the shift council. Workers plan to bring their wage records to the polling stations: they want to know whether your agreement will survive the election."}
		"factory_director":
			return {"ru": "В Рудне Павел Рог снова подписывает контракт один. Лада Серин напоминает у заводских ворот, как президент отозвал право смен проверять зарплаты. Рабочие собираются судить о вашем сроке по этому решению.", "en": "In Rudnya, Pavel Rog signs the contract alone again. At the factory gate, Lada Serin reminds workers that you withdrew their right to inspect wages. They intend to judge your term by that decision."}
		"factory_settlement":
			return {"ru": "На заводе в Рудне сняли охрану и вернули рабочие смены. До сих пор спорят о цене уступок, но Лада Серин и Павел Рог хотя бы признают один и тот же договор.", "en": "The guards have left the Rudnya factory and the shifts are back. People still argue about the cost of the compromise, but Lada Serin and Pavel Rog at least recognize the same agreement."}
		"factory_security":
			return {"ru": "У проходной в Рудне остаётся охрана. Заказ выполняется, но списки уволенных продолжают ходить из рук в руки. Для части рабочих этот контракт стал главным ответом на вопрос о вашем правлении.", "en": "Guards remain at the Rudnya factory gate. Orders are being filled, but lists of dismissed workers still pass from hand to hand. For some of them, this contract defines your presidency."}
		"broadcast_open":
			return {"ru": "Нина Белецкая готовит открытые дебаты. Вопросы поступают от зрителей, включая те, на которые канцелярия предпочла бы не отвечать. Избиратели увидят и президента, и его соперников в одном эфире.", "en": "Nina Beletskaya is preparing open debates. Viewers are sending questions, including those your office would rather avoid. Voters will see you and your opponents in the same broadcast."}
		"broadcast_independent":
			return {"ru": "Предвыборную сетку теперь составляет межпартийная комиссия. Нина Белецкая ведёт эфир, а чиновники больше не могут решить в одиночку, кого пригласить. Даже ваши противники вынуждены признать правила доступа.", "en": "A cross-party commission now sets the election broadcast schedule. Nina Beletskaya hosts the debates, and officials can no longer decide alone whom to invite. Even your opponents have to acknowledge the access rules."}
		"broadcast_managed":
			return {"ru": "Государственный канал снова показывает фильм о достижениях президента. Нина Белецкая работает на районной частоте, где зрители сравнивают запись неудобных вопросов с официальным эфиром.", "en": "The state channel is screening its film about your achievements again. Nina Beletskaya is working on a regional station, where viewers compare the suppressed questions with the official broadcast."}
	return {}


static func ending_memory(legacy: String) -> String:
	match legacy:
		"factory_council": return "На заводе в Рудне совет смен сохранил право проверять зарплатные ведомости государственного заказа."
		"factory_director": return "В Рудне Павел Рог снова управляет заказом единолично. Рабочие потеряли право проверять зарплатные ведомости."
		"factory_settlement": return "Охрану с проходной в Рудне сняли. Рабочие и дирекция согласовали новый график без силового приказа."
		"factory_security": return "В Рудне государственный заказ выполняют под постоянной охраной. Список уволенных остаётся открытым спором."
		"broadcast_open": return "Нина Белецкая провела открытые дебаты на государственном канале. Запись неудобных вопросов осталась доступной."
		"broadcast_independent": return "Предвыборную сетку государственного канала партии согласовали совместно. Канцелярия больше не выбирает его гостей одна."
		"broadcast_managed": return "Государственный телеканал сохранил согласованный эфир. Незаданные вопросы Нины Белецкой обсуждают на районных частотах."
	return ""
