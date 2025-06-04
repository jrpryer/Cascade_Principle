extends Control

var active: GlobalData.Active_Scenario

func _ready():
	randomize()
	
	var base_faction := FactionClass.new()
	# Randomize doctrine strength
	for doctrine in FactionClass.Doctrine.values():
		base_faction.doctrine_strength[doctrine] = randi() % 11 # 0–10
	#base_faction.faction_name = GlobalData._get_random_name()
	base_faction.faction_name = FactionClass.KnownFactions.keys()[GlobalData._get_random_enum_value(FactionClass.KnownFactions)]
	base_faction.update_primary_doctrine_from_strengths()
	base_faction.leadership_state = GlobalData._get_random_enum_value(FactionClass.Leadership)
	base_faction.stability_level = GlobalData._get_random_enum_value(FactionClass.Stability)
	base_faction.morale_state = GlobalData._get_random_enum_value(FactionClass.Morale)

	# Create a random subfaction
	var sub_name : String = GlobalData._get_random_name() + "'s Cell"
	var sub_influence := randf_range(0.2, 0.8)
	var sub_doctrine :FactionClass.Doctrine = GlobalData._get_random_enum_value(FactionClass.Doctrine)
	var subfaction := FactionClass.Subfaction.new(sub_name, sub_influence, sub_doctrine)
	base_faction.subfactions.append(subfaction)
	
	base_faction.occupied_regions = GlobalData.REGION_POOL.reduce(
	func(acc, region):
		var strength = randi() % 4  # 0–3
		if strength > 0:
			acc[region] = strength
		return acc,
	{}
	)
	

	# Create and store the scenario
	var region_names : Array = base_faction.occupied_regions.keys()
	var random_region : String = region_names[randi() % region_names.size()]
	
	active = GlobalData.Active_Scenario.new(
		base_faction,
		subfaction,
		base_faction.faction_name + " EVENT",
		"An emerging crisis is brewing within their %s-controlled %s!" % [base_faction.faction_name, random_region ]
	)
	
	$Background/MarginContainer/Rows/banner_background/BANNER.text = active.scenario_banner
	$Background/MarginContainer/Rows/desc/desc_text.text = active.scenario_desc
	#$Background/MarginContainer/Rows/desc/desc_text.text = active.scenario_faction.generate_summary_text()

	# Output for testing
	print(active.scenario_faction.describe())
	print(active.scenario_faction.get_current_state_description())

####### TRY MOVING THIS ALL ^^^ TO ITS OWN SCRIPT AND FUNCTION, THEN WORK ON SAVING ITS STATE AND 
####### LOADING BACK AND FORTH FROM THE DATA STREAMED TO THE EVENT LOG????
	
	
	
	## EXAMPLE LOGGING
	#var first_logEvent := logEvent.new(
		#logEvent.Faction.IMPERIAL,
		#logEvent.Action.FIGHT,
		#logEvent.Outcome.POSITIVE,
		#logEvent.Weight.EXTREME,
		#Time.get_ticks_msec()
	#)
	#
	#var second_logEvent := logEvent.new(
		#logEvent.Faction.REBEL,
		#logEvent.Action.NEGOTIATE,
		#logEvent.Outcome.NUETRAL,
		#logEvent.Weight.MODERATE,
		#Time.get_ticks_msec()
	#)
#
	#GlobalData.evemt_log["event1"] = first_logEvent
	#GlobalData.evemt_log["event2"] = second_logEvent
#
	## Display the log
	#for key in GlobalData.evemt_log:
		#var event: logEvent = GlobalData.evemt_log[key]
		#print("%s - Faction: %s | Action taken: %s | Event outcome: %s | Impact: %s | Occured at: %sms" % [
			#key,
			#logEvent.Faction.keys()[event.eventFaction],
			#logEvent.Action.keys()[event.eventAction],
			#logEvent.Outcome.keys()[event.eventOutcome],
			#logEvent.Weight.keys()[event.eventWeight],
			#event.eventTimestamp
		#])





# Need to write out here exactly WHAT happens on game init:
# load faction data, assign random values, and present player with encounter scenario

# Faction Response Calculators, calling signals to faction actions


func _on_fight_pressed() -> void:
	#pass # Replace with function body.
	var _event := logEvent.new(
		logEvent.Faction.IMPERIAL,
		logEvent.Action.FIGHT,
		logEvent.Outcome.POSITIVE,
		logEvent.Weight.EXTREME,
		Time.get_ticks_msec()
	)
	print(logEvent)
