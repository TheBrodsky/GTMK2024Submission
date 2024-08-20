extends KillableHazard


@onready var state_record: StateRecord = $StateRecord

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


func _process(delta: float) -> void:
	if state_record != null:
		state_record.store_record(get_time_record())


func _physics_process(delta: float) -> void:
	velocity.y = move_toward(velocity.y, gravity, delta * gravity)
	super(delta)


func get_time_record() -> Dictionary:
	return {"position" : position, "velocity" : velocity}


func set_from_time_record(record: Dictionary) -> void:
	position = record["position"]
	velocity = record["velocity"]


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
