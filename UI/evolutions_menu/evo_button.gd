@tool
extends VBoxContainer
class_name EvoButton
signal pressed(button: TextureButton)

@export var button: TextureButton

@export var icon: Texture2D:
	set(value):
		icon = value
		texture_rect.texture = icon

@export var texture_rect: TextureRect


@export var label_text: String:
	set(value):
		label_text = value
		label.text = label_text

@export var label: Label


func disable() -> void:
	button.disabled = true


func enable() -> void:
	button.disabled = false


func is_pressed() -> bool:
	return button.button_pressed


func _on_evo_button_pressed() -> void:
	pressed.emit(button)
