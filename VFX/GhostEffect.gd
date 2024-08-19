extends Sprite2D


func _ready():
	_ghosting()


func _setProperty(x_pos, x_scale):
	position = x_pos
	scale = x_scale
	
func _ghosting():
	var tween = get_tree().create_tween()
	
	tween.tween_property(self, "self_modulate", Color(1, 1, 1, 0), 0.75)
	await tween.finished
	
	queue_free()
