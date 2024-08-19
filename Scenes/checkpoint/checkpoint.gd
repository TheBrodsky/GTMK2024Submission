extends Node2D
class_name Checkpoint


## THIS MUST BE INCREMENTED FOR EACH CHECKPOINT IN THE LEVEL
@export var id: int = 0
@export_group("DO NOT TOUCH")
@export var flag_up: Sprite2D
@export var flag_down: Sprite2D


func _ready() -> void:
	LevelManager.checkpoint_activate.connect(_on_any_checkpoint_active)


func _on_area_2d_body_entered(body: Node2D) -> void:
	LevelManager.checkpoint_activate.emit(self)
	flag_down.hide()
	flag_up.show()


func _on_any_checkpoint_active(checkpoint: Checkpoint) -> void:
	if checkpoint != self:
		flag_down.show()
		flag_up.hide()
