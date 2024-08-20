extends FlyingEnemy


@export var sprite: Sprite2D
@export var rotation_rate: float = PI/2 ## in rads/second


func _process(delta: float) -> void:
	super(delta)
	if sprite != null:
		sprite.rotate(rotation_rate * delta)
