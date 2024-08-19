extends KillableHazard
class_name FlyingEnemy

@export var speed: float = 200
@export_enum("Left", "Right") var facing: int
@onready var state_record: StateRecord = $StateRecord

var direction: int


func _ready() -> void:
	super()
	direction = -1 if facing == 0 else 1 # -1 is left, 1 is right
	if animation_sprite != null and direction == 1:
		animation_sprite.flip_h = true


func _process(delta: float) -> void:
	if state_record != null:
		state_record.store_record(get_time_record())


func _physics_process(delta: float) -> void:
	velocity.x = speed * direction
	super(delta)


func get_time_record() -> Dictionary:
	return {"position" : position, "velocity" : velocity}


func set_from_time_record(record: Dictionary) -> void:
	position = record["position"]
	velocity = record["velocity"]


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
