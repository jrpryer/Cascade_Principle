# Faction State Manager
class_name Faction
extends Resource

# Enums for cleaner state management
enum Leadership { CENTRALIZED, FRACTURED, COMPETING, INFILTRATED }
enum Doctrine { DIPLOMACY, SURVEILLANCE, MOBILIZATION, OCCUPATION }
enum Stability { HIGH, MEDIUM, LOW, COLLAPSED }
enum Morale { CONFIDENT, PARANOID, RALLIED, INFIGHTING }

@export var faction_name: String
@export var leadership_state: Leadership = Leadership.CENTRALIZED
@export var primary_doctrine: Doctrine = Doctrine.DIPLOMACY
@export var stability_level: Stability = Stability.HIGH
@export var morale_state: Morale = Morale.CONFIDENT

# Doctrine intensities (0-10 scale)
@export var doctrine_intensities = {
	Doctrine.DIPLOMACY: 5,
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

var subfactions: Array[Subfaction] = []

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
	doctrine_intensities[doctrine] = mini(10, doctrine_intensities[doctrine] + intensity)
	
	# Check if this becomes the new primary doctrine
	var highest_intensity = 0
	var dominant_doctrine = primary_doctrine
	
	for doc in doctrine_intensities:
		if doctrine_intensities[doc] > highest_intensity:
			highest_intensity = doctrine_intensities[doc]
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
			if doctrine_intensities[Doctrine.MOBILIZATION] > 7:
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
	desc += "Primary Doctrine: %s (Intensity: %d)\n" % [Doctrine.keys()[primary_doctrine], doctrine_intensities[primary_doctrine]]
	desc += "Stability: %s\n" % Stability.keys()[stability_level]
	desc += "Morale: %s\n" % Morale.keys()[morale_state]
	
	if subfactions.size() > 0:
		desc += "\nActive Subfactions:\n"
		for subfaction in subfactions:
			desc += "- %s (Influence: %.1f, Focus: %s)\n" % [subfaction.name, subfaction.influence, Doctrine.keys()[subfaction.methodology]]
	
	return desc
