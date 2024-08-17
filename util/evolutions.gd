extends Node
signal evolution_updated


enum EvolutionPaths {WINGS, BRAIN, CLAWS}
@export var path: EvolutionPaths = EvolutionPaths.WINGS

# Wings
var has_double_jump: bool = false
var has_dash: bool = false

# Brain
var has_slo_mo: bool = false
var has_rewind: bool = false

# Claws
var has_climb: bool = false
var has_destroy_obstacles: bool = false
