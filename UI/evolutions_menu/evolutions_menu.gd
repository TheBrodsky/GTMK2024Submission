extends PanelContainer

@export var wing_tree: EvoTree
@export var brain_tree: EvoTree
@export var claw_tree: EvoTree

var transition_scene: TransitionScreen


func _ready() -> void:
	hide()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("open_evo_menu"):
		visible = not visible # toggle visibility


func _on_visibility_changed() -> void:
	if get_tree() != null:
		if visible:
			get_tree().paused = true
		else:
			get_tree().paused = false


# it wont signal idk
func notify_transition() -> void:
	if transition_scene != null:
		transition_scene.load_next_level()
		transition_scene = null


func _on_wing_tree_tree_updated(button_states) -> void:
	Evolutions.update_evolution(Evolutions.EvolutionPaths.WINGS, button_states[0], button_states[1])
	brain_tree.disable()
	claw_tree.disable()
	hide()
	notify_transition()


func _on_brain_tree_tree_updated(button_states) -> void:
	Evolutions.update_evolution(Evolutions.EvolutionPaths.BRAIN, button_states[0], button_states[1])
	wing_tree.disable()
	claw_tree.disable()
	hide()
	notify_transition()


func _on_claw_tree_tree_updated(button_states) -> void:
	Evolutions.update_evolution(Evolutions.EvolutionPaths.CLAWS, button_states[0], button_states[1])
	wing_tree.disable()
	brain_tree.disable()
	hide()
	notify_transition()
