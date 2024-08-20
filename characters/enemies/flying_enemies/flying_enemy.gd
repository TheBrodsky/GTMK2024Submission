extends KillableHazard
class_name FlyingEnemy

@export var speed: float = 200
@onready var state_record: StateRecord = $StateRecord


func _ready() -> void:
	if animation_sprite != null:
		animation_sprite.rotation = -rotation


func _process(delta: float) -> void:
	if state_record != null:
		state_record.store_record(get_time_record())


func _physics_process(delta: float) -> void:
	velocity = speed * Vector2.from_angle(rotation)
	super(delta)


func get_time_record() -> Dictionary:
	return {"position" : position, "velocity" : velocity}


func set_from_time_record(record: Dictionary) -> void:
	position = record["position"]
	velocity = record["velocity"]


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
