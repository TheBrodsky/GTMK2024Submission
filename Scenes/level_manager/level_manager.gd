extends Node
signal checkpoint_activate(checkpoint: Checkpoint)


@export var player_scene: PackedScene
@export var level_order: Array[PackedScene]


var current_level_index: int = 0
var current_checkpoint_id: int = 0


func advance_level() -> PackedScene:
	current_level_index += 1
	return level_order[current_level_index]


func get_current_packed_scene() -> PackedScene:
	return level_order[current_level_index] 


func _set_checkpoint(checkpoint: Checkpoint) -> void:
	current_checkpoint_id = checkpoint.id


func _on_checkpoint_activate(checkpoint: Checkpoint) -> void:
	_set_checkpoint(checkpoint)
