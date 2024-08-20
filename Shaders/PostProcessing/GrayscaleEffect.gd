extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("slow_mo_dash_climb") and Evolutions.has_slo_mo:
		show()
	else:
		hide()
