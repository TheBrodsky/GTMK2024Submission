extends VBoxContainer
class_name EvoPathTab


@export var skill_one_button: Button
@export var skill_two_button: Button


func _ready() -> void:
	assert(skill_one_button != null)
	assert(skill_two_button != null)


func get_skill_toggles() -> Array[bool]:
	return [skill_one_button.button_pressed, skill_two_button.button_pressed]
