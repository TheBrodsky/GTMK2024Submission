extends PathFollow2D
class_name PlatformOnTrack


@export var speed: float = 200 ## in pixels/second
@export var platform: StaticBody2D

var _prev_position: Vector2 = global_position
var _velocity: Vector2


func _process(delta: float) -> void:
	progress += speed * delta
	_velocity = global_position - _prev_position
	_prev_position = global_position
	platform.constant_linear_velocity = _velocity


func get_time_record() -> Dictionary:
	return {"progress_ratio" : progress_ratio, "velocity" : _velocity}


func set_from_time_record(record: Dictionary) -> void:
	progress_ratio = record["progress_ratio"]
	_velocity = record["velocity"]
