extends CharacterBody2D


@export_group("Basic Properties")
@export var SPEED: float = 300.0 #
@export var JUMP_VELOCITY: float = -400.0 #
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


@export_group("Wing Properties")
@export var GLIDE_VELOCITY: float = 40.0
var is_space_held: bool = false


@export_group("Brain_Properties")
var _brain_platform: PackedScene = preload("res://characters/Player/brain_platform/BrainPlatform.tscn")
var _bplatform_pixels_below: int = 20
var _can_make_brain_platform: bool = true


@export_group("Claw_Properties")
@export var wall_slide_speed: float = 40
@export var wall_jump_vector: Vector2 = Vector2.from_angle(PI/4)
@export var wall_jump_velocity: float = 300
@export var climbing_speed: float
var _is_wall_jumping: bool = false


## State values
var _can_double_jump: bool = false
var _can_dash: bool = false


## State Events
const GROUNDED: String = "grounded"
const AIRBORNE: String = "airborne"
const JUMP: String = "jump"
const JUMP_FINISHED: String = "jump_finished"
const DASH: String = "dash"
const WALL_COLLISION: String = "wall_collision"
const MAKE_PLATFORM: String = "make_platform"


@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _state_record: StateRecord = $StateRecord
@onready var _state_chart: StateChart = $StateChart


func _ready() -> void:
	Evolutions.evolution_updated.connect(_on_evolution_updated)


func _process(delta):
	#changing animation sprites works:
	#if Input.is_action_pressed("ui_right"):
	#	_animated_sprite.play("test")
	#else:
	#	_animated_sprite.stop()
	pass


#region main physics processing
func _physics_process_grounded(delta: float) -> void:
	_can_double_jump = Evolutions.has_double_jump # reset double jump on ground if djump is evolved
	_can_dash = Evolutions.has_dash # reset dash on ground if dash is evolved
	_update_state_values()
	
	if Input.is_action_just_pressed("ui_accept"):
		_state_chart.send_event(JUMP)
	
	if Input.is_action_just_pressed("slow_mo_or_dash"):
		_state_chart.send_event(DASH)
	
	if not is_on_floor():
		_state_chart.send_event(AIRBORNE)
	
	_do_movement()


func _physics_process_airborne(delta: float) -> void:
	_update_state_values()
	
	if Input.is_action_just_pressed("ui_accept"):
		_state_chart.send_event(JUMP)
	
	if Input.is_action_just_pressed("slow_mo_or_dash"):
		_state_chart.send_event(DASH)
	
	if is_on_floor():
		_state_chart.send_event(GROUNDED)
	
	if is_on_wall():
		_state_chart.send_event(WALL_COLLISION)
	
	_add_gravity(delta)
	_do_movement()


func _physics_process_wall(delta: float) -> void:
	_update_state_values()
	
	if Input.is_action_just_pressed("ui_accept"):
		_state_chart.send_event(JUMP)
	
	if is_on_floor():
		_state_chart.send_event(GROUNDED)
	elif not is_on_wall(): # not on floor and not on wall = airborne
		_state_chart.send_event(AIRBORNE)


func _update_state_values() -> void:
	_state_chart.set_expression_property("has_double_jump", _can_double_jump)
	_state_chart.set_expression_property("has_dash", _can_dash)
	_state_chart.set_expression_property("has_claws", Evolutions.has_claws)
#endregion


#region state signal handlers and subprocesses
func _on_jumping_physics_process(delta: float) -> void:
	if velocity.y > 0: # when we start falling, the jump is finished
		_state_chart.send_event(JUMP_FINISHED)


func _on_falling_physics_process(delta: float) -> void:
	_glide()


func _on_dashing_physics_process(delta: float) -> void:
	print("dashing")


func _on_wall_sliding_physics_process(delta: float) -> void:
	velocity.y = wall_slide_speed


func _on_wall_jump() -> void:
	print("wall jumped")


func _on_jump() -> void:
	velocity.y = JUMP_VELOCITY


func _on_dash() -> void:
	print("dash initiatied")


func _on_double_jump() -> void:
	_can_double_jump = false


func _on_air_dash() -> void:
	_can_dash = false
#endregion


#region basic movement
func _do_movement() -> void:
	_find_horizontal_movement()
	move_and_slide()
	_state_record.store_record(get_time_record()) # for rewind


func _find_horizontal_movement() -> void:
	if not _is_wall_jumping:
		var direction = Input.get_axis("ui_left","ui_right")
		velocity.x = SPEED * direction


func _add_gravity(delta: float) -> void:
	if not is_on_floor() and not (Evolutions.has_wall_jump and is_on_wall()):
		velocity.y += gravity * delta #add gravity
#endregion


#region wing abilities
func _glide() -> void:
	if Evolutions.has_glide:
		if Input.is_action_pressed("ui_accept"):
			velocity.y = GLIDE_VELOCITY
#endregion


#region brain abilities
func _build_brain_platform() -> void:
	if Evolutions.has_brain_platform and not is_on_floor() and _can_make_brain_platform:
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


func get_time_record() -> Dictionary:
	return {"position" : position, "velocity" : velocity}


func set_from_time_record(record: Dictionary) -> void:
	position = record["position"]
	velocity = record["velocity"]
#endregion


#region claw abilities
func _wall_jump() -> void:
	if Evolutions.has_wall_jump and is_on_wall():
		_is_wall_jumping = true
		velocity = get_wall_normal() * wall_jump_velocity
		print(velocity)
		pass
#endregion


func _on_evolution_updated() -> void:
	pass



