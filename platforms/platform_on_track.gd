@tool
extends Path2D
class_name PlatformOnTrack


@export var speed: float = 200 ## in pixels/second
@export var platform_scale: Vector2 = Vector2(.1, .1):
	set(value):
		platform_scale = value
		platform.scale = value
@export_group("DO NO TOUCH")
@export var platform: AnimatableBody2D

@onready var _follower: PathFollow2D = $PathFollow2D
@onready var _state_record: StateRecord = $StateRecord




func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		_follower.progress += speed * delta
		_state_record.store_record(get_time_record())


func get_time_record() -> Dictionary:
	return {"progress_ratio" : _follower.progress_ratio}


func set_from_time_record(record: Dictionary) -> void:
	_follower.progress_ratio = record["progress_ratio"]
