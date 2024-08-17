extends Path2D
class_name PlatformOnTrack


@export var speed: float = 200 ## in pixels/second

@export_group("Private")
@export var follower: PathFollow2D


func _process(delta: float) -> void:
	follower.progress += speed * delta


func get_time_record() -> Dictionary:
	return {"progress_ratio" : follower.progress_ratio}


func set_from_time_record(record: Dictionary) -> void:
	follower.progress_ratio = record["progress_ratio"]
