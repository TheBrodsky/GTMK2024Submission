extends Path2D
class_name PlatformOnTrack


@export var speed: float = 200 ## in pixels/second

@onready var _follower: PathFollow2D = $PathFollow2D
@onready var _state_record: StateRecord = $StateRecord


func _physics_process(delta: float) -> void:
	_follower.progress += speed * delta
	_state_record.store_record(get_time_record())


func get_time_record() -> Dictionary:
	return {"progress_ratio" : _follower.progress_ratio}


func set_from_time_record(record: Dictionary) -> void:
	_follower.progress_ratio = record["progress_ratio"]
