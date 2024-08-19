extends StaticBody2D


@export var rotation_speed: float = PI/2 ## in radians per second


func _physics_process(delta: float) -> void:
	rotate(rotation_speed * delta)
