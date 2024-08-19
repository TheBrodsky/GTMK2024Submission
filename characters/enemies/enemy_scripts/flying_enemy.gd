extends KillableHazard


@export var speed: float = 200


func _physics_process(delta: float) -> void:
	velocity.x = speed
	super(delta)
