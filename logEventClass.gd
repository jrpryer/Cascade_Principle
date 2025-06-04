class_name logEvent
extends Resource

enum Faction { IMPERIAL, REBEL, CIVILIAN, GUILDS, MANDOLORIAN }
enum Action { FIGHT, SABATOGE, NEGOTIATE, STEAL, FLEE } 
enum Outcome { POSITIVE, NEGATIVE, NUETRAL }
enum Weight { LOW, MODERATE, EXTREME }

var eventFaction: Faction
var eventAction: Action
var eventOutcome: Outcome
var eventWeight: Weight
var eventTimestamp: float

func _init(_faction: Faction, _action: Action, _outcome: Outcome, _weight: Weight, _timestamp: float) -> void:
	eventFaction = _faction
	eventAction = _action
	eventOutcome = _outcome
	eventWeight = _weight
	eventTimestamp = _timestamp

#
#var deeds_log: Dictionary = {}
#
