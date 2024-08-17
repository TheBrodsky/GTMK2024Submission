extends Node

enum EvolutionPaths {WINGS, BRAIN, CLAWS}
@export var path: EvolutionPaths

# Wings
var has_double_jump: bool
var has_dash: bool

# Brain
var has_slo_mo: bool
var has_rewind: bool

# Claws
var has_climb: bool
var has_destroy_obstacles: bool
