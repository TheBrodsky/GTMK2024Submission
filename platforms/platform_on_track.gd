extends PathFollow2D
class_name PlatformOnTrack


@export var speed: float = 200 ## in pixels/second


func _process(delta: float) -> void:
	progress += speed * delta


func get_time_record() -> Dictionary:
	return {"progress_ratio" : progress_ratio}


func set_from_time_record(record: Dictionary) -> void:
	progress_ratio = record["progress_ratio"]
