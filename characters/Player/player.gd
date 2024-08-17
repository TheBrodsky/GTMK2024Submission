extends CharacterBody2D

@export_group("Player Properties")
@export var SPEED: float = 300.0 #
@export var JUMP_VELOCITY: float = -400.0 #
@export var extra_jumps: int = 0
#climb velocity
#double jump velocity, etc.

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _state_record: StateRecord = $StateRecord

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _remaining_jumps: int = extra_jumps


func _process(delta):
	#changing animation sprites works:
	#if Input.is_action_pressed("ui_right"):
	#	_animated_sprite.play("test")
	#else:
	#	_animated_sprite.stop()
	pass

func _physics_process(delta):
	if is_on_floor():
		_remaining_jumps = extra_jumps # reset extra jumps
	else:
		velocity.y += gravity * delta #add gravity
	
	#jump (spacebar == "ui_select")
	if Input.is_action_just_pressed("ui_select"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif has_remaining_jumps():
			velocity.y = JUMP_VELOCITY
			_remaining_jumps -= 1 
		
	
	var direction = Input.get_axis("ui_left","ui_right")
	velocity.x = SPEED * direction
	
	_state_record.store_record(get_time_record())
	move_and_slide()
	

func get_time_record() -> Dictionary:
	return {"position" : position, "velocity" : velocity, "remaining_jumps" : _remaining_jumps}


func set_from_time_record(record: Dictionary) -> void:
	position = record["position"]
	velocity = record["velocity"]
	_remaining_jumps = record["remaining_jumps"]


func has_remaining_jumps() -> bool:
	return _remaining_jumps > 0
