extends CharacterBody2D


@export_group("Basic Properties")
@export_subgroup("Ground Speed")
@export var TOP_SPEED_GROUND: float = 250
@export var ACCELERATION_GROUND: float = 2500 # top_speed / acceleration = time to reach top speed
@export var DECELERATION_GROUND: float = 5000 # top speed / deceleration = time to reach stationary from top speed
@export_subgroup("Air Speed")
@export var TOP_SPEED_AIR: float = 200
@export var ACCELERATION_AIR: float = 1500
@export var DECELERATION_AIR: float = 100
@export_subgroup("Jump Velocity")
@export var JUMP_VELOCITY: float = -400.0
@export var WALL_JUMP_VELOCITY: float = 300
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@export_group("Ability Properties")
@export_subgroup("Wings")
@export var GLIDE_VELOCITY: float = 40.0
@export_subgroup("Brain")
var _brain_platform: PackedScene = preload("res://characters/Player/brain_platform/BrainPlatform.tscn")
var _bplatform_pixels_below: int = 20
var _can_make_brain_platform: bool = true
@export_subgroup("Claw")
@export var WALL_SLIDE_SPEED: float = 100
@export var CLIMBING_SPEED: float = 60
@export var CLIMBING_DURATION: float = 3
var is_wall_jumping: bool = false
var is_climbing: bool = false
var _remaining_climb_duration: float = CLIMBING_DURATION


@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _state_record: StateRecord = $StateRecord
@onready var _state_chart: StateChart = $StateChart

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
const WALL_CLIMB: String = "climb"
const WALL_CLIMB_FINISHED: String = "climb_released"
const MAKE_PLATFORM: String = "make_platform"


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
	_remaining_climb_duration = CLIMBING_DURATION
	_update_state_values()
	
	if Input.is_action_just_pressed("ui_accept"):
		_state_chart.send_event(JUMP)
	
	if Input.is_action_just_pressed("slow_mo_dash_climb"):
		_state_chart.send_event(DASH)
	
	if not is_on_floor():
		_state_chart.send_event(AIRBORNE)
	
	_do_movement(delta, false)


func _physics_process_airborne(delta: float) -> void:
	_update_state_values()
	
	if Input.is_action_just_pressed("ui_accept"):
		_state_chart.send_event(JUMP)
	
	if Input.is_action_just_pressed("slow_mo_dash_climb"):
		_state_chart.send_event(DASH)
	
	if is_on_floor():
		_state_chart.send_event(GROUNDED)
	
	if is_on_wall():
		_state_chart.send_event(WALL_COLLISION)
	
	_add_gravity(delta)
	_do_movement(delta, true)


func _physics_process_wall(delta: float) -> void:
	_update_state_values()
	
	if Input.is_action_just_pressed("ui_accept"):
		_state_chart.send_event(JUMP)
	
	if is_on_floor():
		_state_chart.send_event(GROUNDED)
	elif not is_on_wall(): # not on floor and not on wall = airborne
		_state_chart.send_event(AIRBORNE)
	
	_do_movement(delta, true)


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
	is_wall_jumping = false
	if Evolutions.has_glide:
		if Input.is_action_pressed("ui_accept"):
			velocity.y = GLIDE_VELOCITY


func _on_dashing_physics_process(delta: float) -> void:
	print("dashing")


func _on_wall_sliding_physics_process(delta: float) -> void:
	velocity.y = WALL_SLIDE_SPEED
	if Input.is_action_pressed("slow_mo_dash_climb") and _remaining_climb_duration >= 0:
		_state_chart.send_event(WALL_CLIMB)


func _on_wall_climbing_physics_process(delta: float) -> void:
	if Input.is_action_pressed("slow_mo_dash_climb"):
		is_climbing = true
		velocity.y = 0
		var direction = Input.get_axis("ui_up", "ui_down")
		velocity.y = direction * CLIMBING_SPEED
		
		_remaining_climb_duration -= delta
		if _remaining_climb_duration <= 0:
			is_climbing = false
			_state_chart.send_event(WALL_CLIMB_FINISHED)
	else:
		is_climbing = false
		_state_chart.send_event(WALL_CLIMB_FINISHED)


func _on_wall_jump() -> void:
	is_wall_jumping = true
	is_climbing = false
	velocity = (get_wall_normal() + Vector2.UP).normalized() * WALL_JUMP_VELOCITY


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
func _do_movement(delta: float, is_aerial: bool) -> void:
	if is_aerial:
		_do_air_acceleration(delta)
	else:
		_do_ground_acceleration(delta)
	move_and_slide()
	_state_record.store_record(get_time_record()) # for rewind


func _do_ground_acceleration(delta: float) -> void:
	_do_acceleration(delta, TOP_SPEED_GROUND, ACCELERATION_GROUND, DECELERATION_GROUND)


func _do_air_acceleration(delta: float) -> void:
	if not (is_wall_jumping or is_climbing):
		_do_acceleration(delta, TOP_SPEED_AIR, ACCELERATION_AIR, DECELERATION_AIR)


func _do_acceleration(delta: float, top_speed: float, acceleration: float, deceleration: float) -> void:
	var direction = Input.get_axis("ui_left","ui_right")
	if abs(direction) <= 1e-2: # if no left/right input. Epsilon used here to account for controller input inaccuracy, just in case
		velocity.x = move_toward(velocity.x, 0, delta * deceleration)
	else:
		velocity.x = move_toward(velocity.x, direction * top_speed, delta * acceleration)


func _add_gravity(delta: float) -> void:
	velocity.y = move_toward(velocity.y, gravity, delta * gravity)
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


func _on_evolution_updated() -> void:
	pass



