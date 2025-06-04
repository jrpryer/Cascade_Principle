# Faction State Manager
class_name FactionClass
extends Resource

# Enums for cleaner state management"
enum KnownFactions { IMPERIAL, REBEL, CIVILIAN, GUILD, MANDOLORIAN }
enum Leadership { CENTRALIZED, FRACTURED, INFILTRATED, COMPETING }
enum Doctrine { DIPLOMACY, SURVEILLANCE, MOBILIZATION, OCCUPATION }
enum Stability { HIGH, MEDIUM, LOW, COLLAPSED }
enum Morale { CONFIDENT, PARANOID, RALLIED, INFIGHTING }

@export var faction_name: String
@export var leadership_state: Leadership = Leadership.CENTRALIZED
@export var primary_doctrine: Doctrine = Doctrine.DIPLOMACY
@export var stability_level: Stability = Stability.HIGH
@export var morale_state: Morale = Morale.CONFIDENT
var last_events: Array[logEvent]

# Doctrine intensities (0-10 scale)
@export var doctrine_strength = {
	Doctrine.DIPLOMACY: 3,
	Doctrine.SURVEILLANCE: 2,
	Doctrine.MOBILIZATION: 1,
	Doctrine.OCCUPATION: 0
}

# Regional occupation data
@export var occupied_regions = {}  # {region_name: occupation_strength}

# Subfaction system for fracture states
class Subfaction:
	var name: String
	var influence: float  # 0.0 to 1.0
	var methodology: Doctrine
	var rivalry_targets: Array[Person] = []
	
	func _init(subfaction_name: String, subfaction_influence: float, subfaction_method: Doctrine):
		name = subfaction_name
		influence = subfaction_influence
		methodology = subfaction_method
		
	func describe() -> String:
		return "    Subfaction: %s, Influence: %.2f, Methodology: %s\n" % [
			name, influence, FactionClass.Doctrine.keys()[methodology]]
	
	func generate_summary_text() -> String:
		return "    ▸ [b]%s[/b] (Influence: %.2f, Methodology: %s)\n" % [
			name, influence, FactionClass.Doctrine.keys()[methodology]
	]

var subfactions: Array[Subfaction] = []

func update_primary_doctrine_from_strengths() -> void:
	var max_strength := -1
	var dominant := Doctrine.DIPLOMACY  # fallback

	for doctrine in doctrine_strength:
		var strength = doctrine_strength[doctrine]
		if strength > max_strength:
			max_strength = strength
			dominant = doctrine

	primary_doctrine = dominant



func describe() -> String:
	var desc = "Faction: %s\n Leadership: %s\n Doctrine: %s\n Stability: %s\n Morale: %s\n" % [
		faction_name, Leadership.keys()[leadership_state], Doctrine.keys()[primary_doctrine],
		Stability.keys()[stability_level], Morale.keys()[morale_state]]
	desc += "  Doctrine Strengths:\n"
	
	for doctrine_enum in doctrine_strength:
		var name = Doctrine.keys()[doctrine_enum]
		var strength = doctrine_strength[doctrine_enum]
		desc += "    - %s: %d\n" % [name, strength]
	
	desc += "  Occupied Regions:\n"
	for region in occupied_regions:
		desc += "    - %s: %d\n" % [region, occupied_regions[region]]

	for sub in subfactions:
		desc += sub.describe()

	return desc




# State transition methods
func fracture_leadership():
	"""Transition from centralized to fractured leadership"""
	if leadership_state == Leadership.CENTRALIZED:
		leadership_state = Leadership.FRACTURED
		_create_competing_subfactions()

func _create_competing_subfactions():
	"""Generate subfactions when leadership fractures"""
	subfactions.clear()
	
	# Create Intelligence subfaction
	var intelligence = Subfaction.new(faction_name + " Intelligence", 0.4, Doctrine.SURVEILLANCE)
	intelligence.rivalry_targets = [faction_name + " Navy"]
	
	# Create Military subfaction  
	var military = Subfaction.new(faction_name + " Navy", 0.6, Doctrine.MOBILIZATION)
	military.rivalry_targets = [faction_name + " Intelligence"]
	
	subfactions.append(intelligence)
	subfactions.append(military)

func escalate_doctrine(doctrine: Doctrine, intensity: int):
	"""Increase doctrine intensity, potentially shifting primary focus"""
	doctrine_strength[doctrine] = mini(10, doctrine_strength[doctrine] + intensity)
	
	# Check if this becomes the new primary doctrine
	var highest_intensity = 0
	var dominant_doctrine = primary_doctrine
	
	for doc in doctrine_strength:
		if doctrine_strength[doc] > highest_intensity:
			highest_intensity = doctrine_strength[doc]
			dominant_doctrine = doc
	
	if dominant_doctrine != primary_doctrine:
		primary_doctrine = dominant_doctrine
		_trigger_doctrine_shift_consequences()

func _trigger_doctrine_shift_consequences():
	"""Handle cascading effects when primary doctrine changes"""
	match primary_doctrine:
		Doctrine.SURVEILLANCE:
			if stability_level < Stability.LOW:  # Can still decrease
				stability_level += 1  # Move toward COLLAPSED
			morale_state = Morale.PARANOID
		
		Doctrine.MOBILIZATION:
			morale_state = Morale.RALLIED
			# Mobilization might fracture leadership if pushed too hard
			if doctrine_strength[Doctrine.MOBILIZATION] > 7:
				fracture_leadership()

func apply_player_action(action_type: String, severity: int):
	"Main interface for player actions affecting " + faction_name + " state"
	match action_type:
		"sabotage_communications":
			escalate_doctrine(Doctrine.SURVEILLANCE, severity)
			if severity > 5:
				fracture_leadership()
		
		"destroy_supply_depot":
			escalate_doctrine(Doctrine.MOBILIZATION, severity)
			if stability_level < Stability.COLLAPSED:
				stability_level += 1  # Move toward instability
		
		"rescue_prisoners":
			escalate_doctrine(Doctrine.OCCUPATION, severity)
			if morale_state == Morale.CONFIDENT:
				morale_state = Morale.PARANOID

func get_current_state_description() -> String:
	"Generate text description of current " + faction_name + " state for UI"
	var desc = faction_name + " Leadership: %s\n" % Leadership.keys()[leadership_state]
	desc += "Primary Doctrine: %s (Intensity: %d)\n" % [Doctrine.keys()[primary_doctrine], doctrine_strength[primary_doctrine]]
	desc += "Stability: %s\n" % Stability.keys()[stability_level]
	desc += "Morale: %s\n" % Morale.keys()[morale_state] 
	
	if subfactions.size() > 0:
		desc += "\nActive Subfactions:\n"
		for subfaction in subfactions:
			desc += "- %s (Influence: %.1f, Focus: %s)\n" % [subfaction.name, subfaction.influence, Doctrine.keys()[subfaction.methodology]]
	
	return desc

func generate_summary_text() -> String:
	var text := "[b]Faction:[/b] %s\n [i]Leadership:[/i] %s\n [i]Primary Doctrine:[/i] %s\n [i]Stability:[/i] %s\n [i]Morale:[/i] %s\n" % [
		faction_name, Leadership.keys()[leadership_state], Doctrine.keys()[primary_doctrine],
		Stability.keys()[stability_level], Morale.keys()[morale_state]]

	text += "  [u]Doctrine Strengths:[/u]\n"
	for doctrine_enum in doctrine_strength:
		var name = Doctrine.keys()[doctrine_enum]
		var strength = doctrine_strength[doctrine_enum]
		text += "    • %s: %d\n" % [name, strength]

	text += "  [u]Occupied Regions:[/u]\n"
	for region in occupied_regions:
		text += "    • %s: %d\n" % [region, occupied_regions[region]]

	text += "\n  [u]Subfactions:[/u]\n"
	for sub in subfactions:
		text += sub.generate_summary_text()

	return text
