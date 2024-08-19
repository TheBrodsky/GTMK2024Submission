extends Node2D
class_name KillableHazard


func kill() -> void:
	queue_free()
