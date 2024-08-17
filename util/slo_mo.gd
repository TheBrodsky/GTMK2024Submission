extends Node


var is_slo_mo: bool = false
var slo_mo_rate: float = 0.5


func _process(delta: float) -> void:
	if Input.is_action_pressed("slow_mo"):
		if Evolutions.has_slo_mo:
			is_slo_mo = true
			Engine.time_scale = slo_mo_rate
	else:
		is_slo_mo = false
		Engine.time_scale = 1
