extends Node
class_name StateRecord


## Stores the past states of objects to allow things to "rewind"


## INTERFACE:
## Assumes the "recorded_entity" implements a method called "get_time_record"
## which takes no arguments and returns a dictionary of information to be stored
## at this time interval
##
## Assumes the "recorded_entity" implements a method called "set_from_time_record"
## which takes 1 argument, a dictionary of information stored as a time record,
## and which uses that information to set the state of the entity
##
## If the "recorded_entity" has a clickable area, "recorded_entity_area," then
## StateRecord assumes that clicking on the area should cause the recored_entity
## to rewind to the back of the tape. This is "selective rewind"



static var global_rewind_key: StringName = "global_rewind"
static var record_length: float = 3 ## time in seconds to record
static var records_per_second: int = 60 ## don't make this more than the framerate

@export var recorded_entity: Node
@export var recorded_entity_area: CollisionObject2D

var record_tape: Array[Dictionary]
var _prev_returned_state: Dictionary
var _is_doing_full_rewind: bool = false


func _ready() -> void:
	assert(recorded_entity.has_method("get_time_record"))
	assert(recorded_entity.has_method("set_from_time_record"))
	if recorded_entity_area != null:
		recorded_entity_area.input_event.connect(_on_entity_area_input)


func _process(delta: float) -> void:
	if not get_tree().paused:
		if _is_doing_full_rewind or Input.is_action_pressed(global_rewind_key):
			recorded_entity.set_process(false)
			rewind_one_record()
			
			# if global rewind overrides selective rewind or if selective rewind finishes
			if Input.is_action_pressed(global_rewind_key) or (_is_doing_full_rewind and record_tape.size() == 0):
				_is_doing_full_rewind = false
		else:
			recorded_entity.set_process(true)
			store_record(recorded_entity.get_time_record())


func store_record(record: Dictionary) -> void:
	record_tape.push_front(record)
	if record_tape.size() > get_num_records():
		record_tape.pop_back()


func rewind_one_record() -> void:
	var rewind_state: Dictionary
	if record_tape.size() == 0:
		rewind_state = _prev_returned_state
	else:
		rewind_state = record_tape.pop_front()
		_prev_returned_state = rewind_state
	recorded_entity.set_from_time_record(rewind_state)


func get_num_records() -> int:
	return record_length * records_per_second


func _on_entity_area_input(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_is_doing_full_rewind = true
