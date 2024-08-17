extends CharacterBody2D

@export_group("Player Properties")
@export var SPEED: float = 300.0 #
@export var JUMP_VELOCITY: float = -400.0 #
@export var extra_jumps: int = 1
@export var GLIDE_VELOCITY: float = 40.0
@export var dash_duration: float = 0.25
@export var dash_cooldown_duration: float = 1.0
@export var DASH_SCALAR: float = 1.4

var dash_cooldown_timer: float = 0.0
var is_space_held: bool = false
var dash_timer: float = 0.0
var dash_direction: float = 0 #need dash direction so player's dash direction is fixed throughout the dash
var direction: float = 0
#climb velocity
#double jump velocity, etc.

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _state_record: StateRecord = $StateRecord

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _remaining_jumps: int = extra_jumps
var player_sm: LimboHSM

var _brain_platform: PackedScene = preload("res://characters/Player/brain_platform/BrainPlatform.tscn")
var _bplatform_pixels_below: int = 20
var _can_make_brain_platform: bool = true


func _ready() -> void:
	Evolutions.evolution_updated.connect(_on_evolution_updated)
	initiate_state_machine() 
	#technically only need this if we have dash rn, but we might use it for animations later


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
	
	if (player_sm.get_active_state().name == &"dash"):
		velocity.x = dash_direction * SPEED * DASH_SCALAR
		velocity.y = 0
	
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
	if Evolutions.has_double_jump and _has_remaining_jumps():
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
	pass


#region state machine
func initiate_state_machine() -> void:
	player_sm = LimboHSM.new()
	add_child(player_sm)
	
	#not dashing, not cooldown, can dash
	var idle_state = LimboState.new().named("idle").call_on_enter(idle_start).call_on_update(idle_update)
	var dash_state = LimboState.new().named("dash").call_on_enter(dash_start).call_on_update(dash_update)
	var cooldown_state = LimboState.new().named("cooldown").call_on_enter(cooldown_start).call_on_update(cooldown_update)
	
	player_sm.add_child(idle_state)
	player_sm.add_child(dash_state)
	player_sm.add_child(cooldown_state)
	
	player_sm.initial_state = idle_state
	
	player_sm.add_transition(idle_state, dash_state, &"to_dash")
	player_sm.add_transition(dash_state, cooldown_state, &"to_cooldown")
	player_sm.add_transition(cooldown_state, idle_state, &"to_idle")
	
	player_sm.initialize(self)
	player_sm.set_active(true)
	
	

func idle_start():
	print("idle_start")
func idle_update(delta: float):
	print("idle_update")
	#dash pressed with directional input
	if (Input.is_action_just_pressed("dash") and not is_equal_approx(direction, 0)): 
		dash_direction = direction
		player_sm.dispatch(&"to_dash")

func dash_start():
	print("dash_start")
	dash_timer = dash_duration
func dash_update(delta: float):
	print("dash_update")
	dash_timer -= delta
	if (dash_timer <= 0):
		player_sm.dispatch(&"to_cooldown")

func cooldown_start():
	print("cooldown_start")
	dash_cooldown_timer = dash_cooldown_duration
func cooldown_update(delta: float):
	print("cooldown_update")
	dash_cooldown_timer -= delta
	if (dash_cooldown_timer <= 0):
		player_sm.dispatch(&"to_idle")
#endregion
