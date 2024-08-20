extends Node2D
class_name TransitionScreen


@export var transition_time: float = 2 ## in seconds
@export var has_upgrade: bool = false

var timer: Timer
var is_in_menu: bool = false


func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = transition_time
	timer.timeout.connect(check_upgrade)
	timer.start()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_in_menu:
			check_upgrade()


func check_upgrade() -> void:
	if has_upgrade:
		timer.queue_free()
		is_in_menu = true
		var evo_menu = get_tree().get_nodes_in_group("EvoMenu")[0]
		evo_menu.transition_scene = self
		evo_menu.show()
	else:
		load_next_level()


func load_next_level() -> void:
	get_tree().change_scene_to_packed(LevelManager.advance_level())
