extends Node

const NAME_POOL := [
	"Aelric", "Vashara", "Korrin", "Talon", "Lira",
	"Draven", "Sorrel", "Kaelin", "Mira", "Thorne",
	"Zevra", "Nyxar", "Orlin", "Tessik", "Shira",
	"Ravik", "Kelna", "Vorn", "Tavira", "Jaxen",
	"Serin", "Xelra", "Calo", "Nayla", "Brel",
	"Torvin", "Arix", "Yulana", "Keln", "Zerra",
	"Jora", "Daelin", "Sarek", "Rydan", "Vexa",
	"Thalos", "Nira", "Omrin", "Velar", "Kessa",
	"Dorin", "Yarik", "Selyn", "Trevik", "Rylos",
	"Zasha", "Malik", "Talonis", "Arven", "Sayla",
	"Brask", "Tyra", "Quorin", "Halek", "Niven",
	"Xara", "Rannic", "Delva", "Sovra", "Kael",
	"Tayven", "Lunara", "Varek", "Zynn", "Jorek"
]

const REGION_POOL := [
	"Corellian Run",
	"Outer Rim",
	"Mid Rim",
	"Deep Core",
	"Unknown Regions",
	"Expansion Region",
	"Corporate Sector",
	"Hydian Way",
	"Tion Cluster",
	"Wild Space"
]

var evemt_log: Dictionary = {}

class Active_Scenario:
	var scenario_faction: FactionClass
	var scenario_subfaction: FactionClass.Subfaction
	var scenario_banner: String
	var scenario_desc: String
	
	func _init(faction: FactionClass, sub: FactionClass.Subfaction, banner: String, desc: String) -> void:
		scenario_faction = faction
		scenario_subfaction = sub
		scenario_banner = banner
		scenario_desc = desc

func _get_random_enum_value(enum_dict: Dictionary) -> int:
	var values := enum_dict.values()
	return values[randi() % values.size()]

	
func _get_random_name() -> String:
	return GlobalData.NAME_POOL[randi() % GlobalData.NAME_POOL.size()]
