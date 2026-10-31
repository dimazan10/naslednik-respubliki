extends RefCounted

# English copy for the location-dependent reports. Translating the already
# inflected Russian sentence cannot reliably recover its city and region.
const REPORTS := {
	"utilities": {"title": "Pipes Beneath the Square", "body": "A water main has burst beneath the central square in {city}. The local administration wants an immediate repair; utility crews offer a temporary bypass until spring."},
	"clinics": {"title": "The Clinic Queue", "body": "Clinics in {region} are short of doctors on duty. The governor asks for mobile medical teams or a redistribution of medicine between districts."},
	"schools": {"title": "The Leaking School Roof", "body": "Rain has damaged a school roof in {city}. Parents demand repairs; officials propose moving classes to two shifts for now."},
	"roads": {"title": "A Bridge Down to One Lane", "body": "Inspectors found cracks in a bridge near {city}. You can pay for a quick repair or restrict heavy trucks."},
	"customs": {"title": "Queue at the Border Gate", "body": "Perishable cargo is piling up at a crossing in {region}. The shift chief asks for paid night work or permission to move food ahead of the queue."},
	"police": {"title": "Night Patrols", "body": "After a string of thefts, residents of {city} want more patrols. Police request overtime pay; the municipality proposes joint civilian rounds."},
	"procurement": {"title": "Bread for the Canteens", "body": "Schools and hospitals in {region} need a new bread supplier. Local bakeries cost more, while a large private company's central plant promises cheap deliveries once a week."},
	"garrison": {"title": "The Barracks Roof", "body": "An old barracks is leaking at the garrison near {city}. Commanders ask for an urgent repair or a temporary cut to training while soldiers move into the teaching block."},
	"rumors": {"title": "An Unsigned Letter", "body": "A message claiming that the local hospital will close is spreading through {city}. The letter is forged, but it quotes real, unpublished budget pages: the hospital stays open, while other programs really are facing cuts."},
	"migrant_housing": {"title": "The Station Dormitory", "body": "Temporary housing for migrant workers in {city} is full. The state could open another dormitory or require employers to house the people they hired."},
	"power_grid": {"title": "An Overloaded Transformer", "body": "The substation in {city} overheats at peak hours. Engineers propose replacing its transformer now or introducing short rolling blackouts."},
	"wages": {"title": "A Night Shift Without Its Bonus", "body": "Workers at a municipal company in {city} refused a night shift after their promised bonus was withheld. Labor inspectors propose state mediation; management wants a court order forcing the workers back."},
	"ceremony": {"title": "First Flag Day", "body": "{city} is preparing to mark the first raising of the republic's flag. The council asks you to choose between a civic ceremony and a service led by the Church of the Faith."},
	"parish_kitchen": {"title": "The Parish Kitchen", "body": "Church volunteers in {city} are feeding families whose factory has closed. The parish will take over the municipal canteen if it can appoint staff and control the building. The union wants to keep city jobs and common rules for distributing meals."},
	"chaplains": {"title": "Help for the Garrison", "body": "After repeated border deployments, more soldiers at the garrison near {city} are seeking medical help. The Church of the Faith offers chaplains for voluntary talks. Army doctors want civilian psychologists who can also help soldiers outside the Faith."}
}

const CITY_NAMES := {
	"Радов": "Radov", "Белогор": "Belogor", "Черницы": "Chernitsy", "Острог": "Ostrog",
	"Милова": "Milova", "Бережск": "Berezhsk", "Приозёрье": "Priozerye", "Ладен": "Laden",
	"Леск": "Lesk", "Долин": "Dolin", "Вежа": "Vezha", "Сухов": "Sukhov",
	"Каменец": "Kamenets", "Рудня": "Rudnya", "Явор": "Yavor", "Новоград": "Novograd"
}

const CITY_FORMS := {
	"Радов": ["Радова", "Радове", "Радову"], "Белогор": ["Белогора", "Белогоре", "Белогору"],
	"Черницы": ["Черниц", "Черницах", "Черницам"], "Острог": ["Острога", "Остроге", "Острогу"],
	"Милова": ["Миловы", "Милове", "Милове"], "Бережск": ["Бережска", "Бережске", "Бережску"],
	"Приозёрье": ["Приозёрья", "Приозёрье", "Приозёрью"], "Ладен": ["Ладена", "Ладене", "Ладену"],
	"Леск": ["Леска", "Леске", "Леску"], "Долин": ["Долина", "Долине", "Долину"],
	"Вежа": ["Вежи", "Веже", "Веже"], "Сухов": ["Сухова", "Сухове", "Сухову"],
	"Каменец": ["Каменца", "Каменце", "Каменцу"], "Рудня": ["Рудни", "Рудне", "Рудне"],
	"Явор": ["Явора", "Яворе", "Явору"], "Новоград": ["Новограда", "Новограде", "Новограду"]
}

const REGION_NAMES := {
	"Северный край": "Northern Territory", "Озёрная область": "Lake District",
	"Степная область": "Steppe Region", "Южный округ": "Southern District"
}


static func location_values(location: Dictionary) -> Dictionary:
	return {
		"city": str(CITY_NAMES.get(str(location.get("city", "")), location.get("city", ""))),
		"region": str(REGION_NAMES.get(str(location.get("region", "")), location.get("region", "")))
	}


static func russian_location_from_key(generation_key: String) -> Dictionary:
	var parts := generation_key.split("|")
	if parts.size() != 3:
		return {}
	var city := str(parts[2])
	var forms: Array = CITY_FORMS.get(city, [])
	if forms.size() != 3:
		return {}
	return {"region": str(parts[1]), "city": city, "city_gen": forms[0], "city_loc": forms[1], "city_dat": forms[2], "office": ""}


static func title(family: String, location: Dictionary) -> String:
	var report: Dictionary = REPORTS.get(family, {})
	return str(report.get("title", family)) + " — " + str(location_values(location)["city"])


static func body(family: String, location: Dictionary, context: String) -> String:
	var report: Dictionary = REPORTS.get(family, {})
	var translated := str(report.get("body", "")).format(location_values(location))
	if context != "":
		translated += " " + context.format(location_values(location))
	return translated
