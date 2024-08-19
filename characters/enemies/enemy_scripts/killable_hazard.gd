extends CharacterBody2D
class_name KillableHazard


@export var animation_sprite: AnimatedSprite2D
@export var state_record: StateRecord


func _ready() -> void:
	collision_mask = collision_mask | 0


func _process(delta: float) -> void:
	if state_record != null:
		state_record.store_record(get_time_record())


func _physics_process(delta: float) -> void:
	move_and_slide()
	_detect_collision()


func kill() -> void:
	queue_free()


func get_time_record() -> Dictionary:
	return {"position" : position, "velocity" : velocity}


func set_from_time_record(record: Dictionary) -> void:
	position = record["position"]
	velocity = record["velocity"]


func _detect_collision() -> void:
	for i in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
		if collision:
			var collider = collision.get_collider()
			if collider is Player:
				_do_attack()


func _do_attack() -> void:
	if animation_sprite != null:
		animation_sprite.play("attack")
