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
@export var wall_slide_speed: float = 40
@export var wall_jump_vector: Vector2 = Vector2.from_angle(PI/4)
@export var wall_jump_velocity: float = 300
@export var climbing_speed: float
var _is_wall_jumping: bool = false


## State Events
const ON_SPACE: String = "on_space"
const GROUNDED: String = "grounded"
const AIRBORNE: String = "airborne"
const DASH: String = "dash"
const WALL_COLLISION: String = "wall_collision"


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


func _physics_process(delta):
	if is_on_floor():
		_state_chart.send_event(GROUNDED)
	else:
		_state_chart.send_event(AIRBORNE)
			

	if Input.is_action_just_pressed("ui_accept"):
		_state_chart.send_event(ON_SPACE)
	
	if Input.is_action_just_pressed("slow_mo_or_dash"):
		_state_chart.send_event(DASH)
	
	_find_horizontal_movement()
	move_and_slide()
	_state_record.store_record(get_time_record()) # for rewind



#region basic abilities
func _jump() -> void:
	velocity.y = JUMP_VELOCITY


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
		is_space_held = Input.is_action_just_pressed("ui_accept") or (not (Input.is_action_just_released("ui_accept")) and is_space_held )
		if is_space_held and not is_on_floor() and velocity.y > 0: 
			velocity.y = GLIDE_VELOCITY


func _dash() -> void:
	print("dash")
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
func _wall_slide() -> void:
	if Evolutions.has_wall_jump and is_on_wall() and not _is_wall_jumping:
		velocity.y = wall_slide_speed


func _wall_jump() -> void:
	if Evolutions.has_wall_jump and is_on_wall():
		_is_wall_jumping = true
		velocity = get_wall_normal() * wall_jump_velocity
		print(velocity)
		pass


func _reset_wall_jump() -> void:
	if not is_on_wall():
		_is_wall_jumping = false
#endregion


func _on_evolution_updated() -> void:
	_state_chart.set_expression_property("has_none", Evolutions.has_none)
	_state_chart.set_expression_property("has_wings", Evolutions.has_wings)
	_state_chart.set_expression_property("has_brain", Evolutions.has_brain)
	_state_chart.set_expression_property("has_claws", Evolutions.has_claws)
	_state_chart.set_expression_property("has_dash", Evolutions.has_dash)
	_state_chart.set_expression_property("has_double_jump", Evolutions.has_double_jump)
	_state_chart.set_expression_property("has_wall_jump", Evolutions.has_wall_jump)


#region state physics processing
func _on_jump_enabled(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_jump()


func _on_glide_enabled(delta: float) -> void:
	_glide()


func _on_airborne(delta: float) -> void:
	_add_gravity(delta)


func _on_wall_slide(delta: float) -> void:
	velocity.y = wall_slide_speed
	if not is_on_wall() and not is_on_floor():
		_state_chart.send_event(AIRBORNE)
#endregion
