extends Node2D
class_name Level


@export var spawn_point: Checkpoint
@export_group("DO NOT TOUCH")
@export var player_scene: PackedScene = preload("res://characters/Player/Player.tscn")


func _ready() -> void:
	load_level()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("skip_level"):
		load_next_level()


func load_level() -> Checkpoint:
	var player: Player = player_scene.instantiate()
	player.died.connect(reload)
	add_child(player)
	var cur_checkpoint: Checkpoint = _find_checkpoint_by_id(LevelManager.current_checkpoint_id)
	player.global_position = cur_checkpoint.global_position
	return cur_checkpoint


func reload() -> void:
	LevelManager.reload()


func load_next_level() -> void:
	get_tree().change_scene_to_packed(LevelManager.advance_level())


func _find_checkpoint_by_id(id: int) -> Checkpoint:
	for checkpoint in get_tree().get_nodes_in_group("checkpoint"):
		if checkpoint.id == id:
			return checkpoint
	return spawn_point
