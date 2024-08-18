extends TabContainer
class_name EvolutionsMenu


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("open_evo_menu"):
		visible = not visible # toggle visibility


func _submit_changes() -> void:
	if current_tab != 0:
		var evo_tab: EvoPathTab = get_current_tab_control()
		var skill_toggles: Array[bool] = evo_tab.get_skill_toggles()
		Evolutions.update_evolution(current_tab, skill_toggles[0], skill_toggles[1])


func _on_visibility_changed() -> void:
	if visible:
		get_tree().paused = true
	else:
		get_tree().paused = false
		_submit_changes()
