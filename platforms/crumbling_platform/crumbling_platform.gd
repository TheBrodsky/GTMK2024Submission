extends StaticBody2D
class_name CrumblingPlatform


@export var lifetime: float = 2 ## in seconds
@export var respawns: bool = false
@export var respawn_time: float = 5 ## in seconds

@onready var _life_left: float = lifetime
var _time_until_respawn: float = respawn_time
var _is_crumbled: bool = false


func _process(delta: float) -> void:
	if not _is_crumbled:
		_life_left -= delta
		if _life_left <= 0:
			crumble()
	else:
		_time_until_respawn -= delta
		if _time_until_respawn <= 0:
			respawn()


func crumble() -> void:
	if respawns:
		_is_crumbled = true
		hide()
	else:
		queue_free()


func respawn() -> void:
	_life_left = lifetime
	_is_crumbled = false
	show()
