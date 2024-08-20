extends Node2D



func _on_area_2d_body_entered(body: Node2D) -> void:
	LevelManager.load_next_level()
