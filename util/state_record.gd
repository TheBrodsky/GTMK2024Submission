extends Node
class_name StateRecord


## Stores the past states of objects to allow things to "rewind"


## INTERFACE:
## Assumes the "recorded_entity" implements a method called "add_time_record"
## which takes 1 argument, a dictionary of information stored as a time record.and returns a dictionary of information to be stored
## at this time interval
##
## Assumes the "recorded_entity" implements a method called "set_from_time_record"
## which takes 1 argument, a dictionary of information stored as a time record,
## and which uses that information to set the state of the entity



static var global_rewind_key: StringName = "global_rewind"
static var record_length: float = 3 ## time in seconds to record
static var records_per_second: int = 60 ## don't make this more than the framerate

@export var recorded_entity: Node

var record_tape: Array[Dictionary]
var _prev_returned_state: Dictionary


func _ready() -> void:
	assert(recorded_entity.has_method("get_time_record"))
	assert(recorded_entity.has_method("set_from_time_record"))


func _process(delta: float) -> void:
	if Evolutions.has_rewind and Input.is_action_pressed(global_rewind_key):
		recorded_entity.set_process(false)
		recorded_entity.set_physics_process(false)
		rewind_one_record()
		
		if record_tape.size() == 0:
			recorded_entity.set_process(true)
			recorded_entity.set_physics_process(true)
	else:
		recorded_entity.set_process(true)
		recorded_entity.set_physics_process(true)


func store_record(record: Dictionary) -> void:
	if Evolutions.has_rewind:
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
