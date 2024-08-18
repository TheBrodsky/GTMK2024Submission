extends CharacterBody2D


@export_group("Basic Properties")
@export var SPEED: float = 300.0 #
@export var JUMP_VELOCITY: float = -400.0 #
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


@export_group("Wing Properties")
@export var extra_jumps: int = 0:
	set(value):
		extra_jumps = value
		_remaining_jumps = value
@export var GLIDE_VELOCITY: float = 40.0
var is_space_held: bool = false
var _remaining_jumps: int = extra_jumps


@export_group("Brain_Properties")
var _brain_platform: PackedScene = preload("res://characters/Player/brain_platform/BrainPlatform.tscn")
var _bplatform_pixels_below: int = 20
var _can_make_brain_platform: bool = true


@export_group("Claw_Properties")


@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _state_record: StateRecord = $StateRecord


func _ready() -> void:
	Evolutions.evolution_updated.connect(_on_evolution_updated)


func _process(delta):
	#changing animation sprites works:
	#if Input.is_action_pressed("ui_right"):
	#	_animated_sprite.play("test")
	#else:
	#	_animated_sprite.stop()
	pass


func _physics_process(delta):
	_reset_brain_platform()
	_reset_jumps()
	
	if Input.is_action_just_pressed("ui_accept"):
		_jump()
		_double_jump()
		_build_brain_platform()
	_glide()
	
	_add_gravity(delta)
	_find_horizontal_movement()
	move_and_slide()
	_state_record.store_record(get_time_record())


#region basic abilities
func _jump() -> void:
	if is_on_floor():
		velocity.y = JUMP_VELOCITY


func _find_horizontal_movement() -> void:
	var direction = Input.get_axis("ui_left","ui_right")
	velocity.x = SPEED * direction


func _add_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta #add gravity
#endregion


#region wing abilities
func _has_remaining_jumps() -> bool:
	return _remaining_jumps > 0


func _glide() -> void:
	if Evolutions.path == Evolutions.EvolutionPaths.WINGS:
		is_space_held = Input.is_action_just_pressed("ui_accept") or (not (Input.is_action_just_released("ui_accept")) and is_space_held )
		if is_space_held and not is_on_floor() and velocity.y > 0: 
			velocity.y = GLIDE_VELOCITY


func _double_jump() -> void:
	if Evolutions.has_double_jump and not is_on_floor() and _has_remaining_jumps():
		velocity.y = JUMP_VELOCITY
		_remaining_jumps -= 1


func _reset_jumps() -> void:
	if is_on_floor():
		_remaining_jumps = extra_jumps
#endregion


#region brain abilities
func _build_brain_platform() -> void:
	if Evolutions.path == Evolutions.EvolutionPaths.BRAIN and not is_on_floor() and _can_make_brain_platform:
		var platform = _brain_platform.instantiate()
		get_tree().get_root().add_child(platform)
		platform.position = position + Vector2(0, _bplatform_pixels_below)
		_can_make_brain_platform = false


func _reset_brain_platform() -> void:
	if is_on_floor() and _is_on_non_brain_platform():
		_can_make_brain_platform = true


func _is_on_non_brain_platform() -> bool:
	var return_bool: bool = false
	var collision = get_slide_collision(0)
	if collision:
		var collider = collision.get_collider()
		if collider != null and not collider.collision_layer & 2**7:
			return_bool = true
	return return_bool


func _is_on_brain_platform() -> bool:
	var collision = get_slide_collision(0)
	if collision:
		var collider = collision.get_collider()
		if collider == null:
			return true # the only way I've ever gotten this to be null is from a brain platform expiring
		elif collider.collision_layer & 2**7: # brain platform on layer 8
			return true
	return false


func get_time_record() -> Dictionary:
	return {"position" : position, "velocity" : velocity, "remaining_jumps" : _remaining_jumps}


func set_from_time_record(record: Dictionary) -> void:
	position = record["position"]
	velocity = record["velocity"]
	_remaining_jumps = record["remaining_jumps"]
#endregion


#region claw abilities
#endregion

func _on_evolution_updated() -> void:
	extra_jumps = 0
	match Evolutions.path:
		Evolutions.EvolutionPaths.WINGS:
			if Evolutions.has_double_jump:
				extra_jumps = 1
		Evolutions.EvolutionPaths.BRAIN:
			pass
		Evolutions.EvolutionPaths.CLAWS:
			pass
