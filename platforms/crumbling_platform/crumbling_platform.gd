extends StaticBody2D
class_name CrumblingPlatform


@export var lifetime: float = 2 ## in seconds
@export var respawns: bool = false
@export var respawn_time: float = 5 ## in seconds
@export var bypass_step_on: bool = false

@onready var _life_left: float = lifetime
var _time_until_respawn: float = respawn_time
var _is_crumbled: bool = false
var _is_stepped_on: bool = false

var collider: CollisionShape2D

var tile_map: TileMap

func _ready() -> void:
	collider = $CollisionShape2D
	tile_map = $TileMap

func _process(delta: float) -> void:
	if _is_stepped_on or bypass_step_on:
		_life_left -= delta
		## animate the shader progress parameter
		if (tile_map):
			tile_map.material.set_shader_parameter('progress', _life_left/lifetime)
		if _life_left <= 0:
			crumble()
	elif _is_crumbled:
		_time_until_respawn -= delta
		if _time_until_respawn <= 0:
			respawn()


func crumble() -> void:
	if respawns:
		_is_stepped_on = false
		_is_crumbled = true
		hide()
		collider.disabled = true
	else:
		queue_free()


func respawn() -> void:
	_life_left = lifetime
	_time_until_respawn = respawn_time
	_is_crumbled = false
	_is_stepped_on = false
	collider.disabled = false
	show()


func _on_area_2d_body_entered(body):
	if (body.has_signal("died")):
		_is_stepped_on = true
