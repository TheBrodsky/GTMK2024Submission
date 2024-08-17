extends CharacterBody2D

@export_group("Player Properties")
@export var SPEED: float = 300.0 #
@export var JUMP_VELOCITY: float = -400.0 #
@export var extra_jumps: int = 0
@export var GLIDE_VELOCITY: float = 40.0
@export var has_glide: bool = false 
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

func _ready():
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
	
	#is_space_held logic 
	is_space_held = Input.is_action_just_pressed("ui_select") or (not (Input.is_action_just_released("ui_select")) and is_space_held )
	#glide
	if is_space_held and has_glide and not is_on_floor() and velocity.y > 0: 
		velocity.y = GLIDE_VELOCITY
	
	direction = Input.get_axis("ui_left","ui_right")
	velocity.x = SPEED * direction
	if (player_sm.get_active_state().name == &"dash"):
		velocity.x = dash_direction * SPEED * DASH_SCALAR
		velocity.y = 0
	
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
