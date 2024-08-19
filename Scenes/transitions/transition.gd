extends Node2D


@export var transition_time: float = 2 ## in seconds


func _ready() -> void:
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.wait_time = transition_time
	timer.timeout.connect(load_next_level)
	timer.start()


func load_next_level() -> void:
	get_tree().change_scene_to_packed(LevelManager.advance_level())
