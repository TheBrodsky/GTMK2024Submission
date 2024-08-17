extends Node
signal evolution_updated


enum EvolutionPaths {WINGS, BRAIN, CLAWS}
@export var path: EvolutionPaths = EvolutionPaths.WINGS

# Wings
var has_double_jump: bool = true:
	get:
		return has_double_jump and path == EvolutionPaths.WINGS
var has_dash: bool = false:
	get:
		return has_dash and path == EvolutionPaths.WINGS

# Brain
var has_slo_mo: bool = false:
	get:
		return has_slo_mo and path == EvolutionPaths.BRAIN
var has_rewind: bool = false:
	get:
		return has_rewind and path == EvolutionPaths.BRAIN

# Claws
var has_climb: bool = false:
	get:
		return has_climb and path == EvolutionPaths.CLAWS
var has_destroy_obstacles: bool = false:
	get:
		return has_destroy_obstacles and path == EvolutionPaths.CLAWS


func update_evolution(path: EvolutionPaths, has_first_skill: bool, has_second_skill: bool) -> void:
	self.path = path
	match path:
		EvolutionPaths.WINGS:
			has_double_jump = has_first_skill
			has_dash = has_second_skill
		EvolutionPaths.BRAIN:
			has_slo_mo = has_first_skill
			has_rewind = has_second_skill
		EvolutionPaths.CLAWS:
			has_climb = has_first_skill
			has_destroy_obstacles = has_second_skill
	evolution_updated.emit()
