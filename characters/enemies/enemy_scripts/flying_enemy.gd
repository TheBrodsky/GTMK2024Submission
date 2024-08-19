extends KillableHazard


@export var speed: float = 200

var direction: int = -1 # -1 = left, 1 = right


func _ready() -> void:
	super()
	if animation_sprite != null and animation_sprite.flip_h:
		direction = 1


func _physics_process(delta: float) -> void:
	velocity.x = speed * direction
	super(delta)
