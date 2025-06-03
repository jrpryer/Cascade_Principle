class_name Person
extends Resource

enum Threat { HIGH, MEDIUM, LOW }
enum Action { FIGHT, SABOTAGE, NEGOTIATE, STEAL, FLEE }

@export var name: String
@export var faction: Resource
@export var loyalty: float # 0.0 to 1.0
@export var threat: Threat = Threat.LOW
@export var approach: Action = Action.NEGOTIATE

func _init():
	randomize() # Optional: ensure fresh seed
	name = Global.NAME_POOL[randi() % Global.NAME_POOL.size()]
