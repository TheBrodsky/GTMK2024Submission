extends Node2D

@export var flying_enemy: PackedScene
@export var seconds_per_emission: float = 2
@export var emission_velocity: float = 200
@export_enum("Left: -1", "Right: 1") var emission_direction: int

var _time_to_emission: float = seconds_per_emission


func _process(delta: float) -> void:
	_time_to_emission -= delta
	if _time_to_emission <= 0:
		emit()
		_time_to_emission += seconds_per_emission


func emit() -> void:
	var emission: FlyingEnemy = flying_enemy.instantiate()
	emission.speed = emission_velocity
	emission.facing = emission_direction
