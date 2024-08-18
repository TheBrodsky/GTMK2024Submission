@tool
extends VBoxContainer
class_name EvoTree
signal tree_updated(button_states: Array[bool])


@export var path_name: String:
	set(value):
		path_name = value
		label.text = path_name
@export var label: Label


@export var label_one: String:
	set(value):
		label_one = value
		button_one.label_text = label_one
@export var label_two: String:
	set(value):
		label_two = value
		button_two.label_text = label_two
@export var label_three: String:
	set(value):
		label_three = value
		button_three.label_text = label_three


@export var icon_one: Texture2D:
	set(value):
		icon_one = value
		button_one.icon = icon_one
@export var icon_two: Texture2D:
	set(value):
		icon_two = value
		button_two.icon = icon_two
@export var icon_three: Texture2D:
	set(value):
		icon_three = value
		button_three.icon = icon_three

@export var button_one: EvoButton
@export var button_two: EvoButton
@export var button_three: EvoButton


func _ready() -> void:
	button_two.disable()
	button_three.disable()


func disable() -> void:
	button_one.disable()


func _on_evo_button_pressed(button: TextureButton) -> void:
	tree_updated.emit([button_two.is_pressed(), button_three.is_pressed()])
	button_two.enable()
	button_three.enable()
