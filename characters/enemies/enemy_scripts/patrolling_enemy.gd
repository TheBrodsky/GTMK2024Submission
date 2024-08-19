extends Path2D

@export var speed: float = 100 ## in pixels/second
@export var state_record: StateRecord

@onready var follower: PathFollow2D = $PathFollow2D


func _ready() -> void:
	assert(follower != null)


func _process(delta: float) -> void:
	follower.progress += speed * delta
	if state_record != null:
		state_record.store_record(get_time_record())


func get_time_record() -> Dictionary:
	return {"progress_ratio" : follower.progress_ratio}


func set_from_time_record(record: Dictionary) -> void:
	follower.progress_ratio = record["progress_ratio"]
