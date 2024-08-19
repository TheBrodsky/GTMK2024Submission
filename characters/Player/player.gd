extends CharacterBody2D
class_name Player
signal died


@export_group("Basic Properties")
@export_subgroup("Ground Speed")
@export var TOP_SPEED_GROUND: float = 250
@export var ACCELERATION_GROUND: float = 2500 # top_speed / acceleration = time to reach top speed
@export var DECELERATION_GROUND: float = 5000 # top speed / deceleration = time to reach stationary from top speed
@export_subgroup("Air Speed")
@export var TOP_SPEED_AIR: float = 175
@export var ACCELERATION_AIR: float = 1500
@export var DECELERATION_AIR: float = 1500
@export_subgroup("Jump Velocity")
@export var JUMP_VELOCITY: float = -400.0
@export var WALL_JUMP_VELOCITY: float = 300
@export var MAX_JUMP_BUFFER_TIME: float = 0.1
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_direction: float = 1 ##1 == right, -1 == left
var jump_buffer: float = 0 #if above zero, jump in grounded. Then set to zero. Decays with each process tick

@export_group("Ability Properties")
@export_subgroup("Wings")
@export var GLIDE_VELOCITY: float = 40.0
@export var DASH_SCALAR: float = 2.0
@export var DASH_TIME: float = 2.0
var dash_timer: float = 0 #set in on_dash
var dash_velocity: float = 0
var is_dashing: bool = false
@export_subgroup("Brain")
var _brain_platform: PackedScene = preload("res://characters/Player/brain_platform/BrainPlatform.tscn")
var _bplatform_pixels_below: int = 20
var _can_make_brain_platform: bool = true
@export_subgroup("Claw")
@export var WALL_SLIDE_SPEED: float = 100
@export var CLIMBING_SPEED: float = 60
@export var CLIMBING_DURATION: float = 1.5
var is_wall_jumping: bool = false
var is_climbing: bool = false
var _remaining_climb_duration: float = CLIMBING_DURATION


@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _wings_sprite: AnimatedSprite2D = $WingAnimations
@onready var _claws_sprite: AnimatedSprite2D = $ClawAnimations
@onready var _state_record: StateRecord = $StateRecord
@onready var _state_chart: StateChart = $StateChart
@onready var _kill_box: Area2D = $KillBox

## State values
var _can_double_jump: bool = false
var _can_dash: bool = false
var _can_climb: bool = false

## State Events
const GROUNDED: String = "grounded"
const AIRBORNE: String = "airborne"
const JUMP: String = "jump"
const JUMP_FINISHED: String = "jump_finished"
const DASH: String = "dash"
const DASH_FINISHED: String = "dash_finished"
const WALL_COLLISION: String = "wall_collision"
const WALL_CLIMB: String = "climb"
const WALL_CLIMB_FINISHED: String = "climb_released"
const MAKE_PLATFORM: String = "make_platform"


## Animation Names
const IDLE_ANIM: String = "idle"
const JUMP_ANIM: String = "jump"
const CLIMB_TURN_ANIM: String = "turn_to_wall"
const CLIMB_ANIM: String = "climb"
const WALL_JUMP_ANIM: String = "wall_jump"
const BRAIN_IDLE_ANIM: String = "brain_idle"
const DEATH_ANIM: String = "die"
const DESTROY_ANIM: String = "destroy"
var cur_animation: String = IDLE_ANIM


func _process(delta):
	if last_direction == 1: # right
		_animated_sprite.flip_h = false
		_wings_sprite.flip_h = false
	else:
		_animated_sprite.flip_h = true
		_wings_sprite.flip_h = true


#region main physics processing
func _physics_process(delta: float) -> void:
	_check_hazard_collision()
	_state_record.store_record(get_time_record()) # for rewind


func _physics_process_grounded(delta: float) -> void:
	_can_double_jump = Evolutions.has_double_jump # reset double jump on ground if djump is evolved
	_can_dash = Evolutions.has_dash # reset dash on ground if dash is evolved
	_remaining_climb_duration = CLIMBING_DURATION
	is_climbing = false
	_reset_brain_platform()
	_update_state_values()
	_reset_killbox()
	
	_play_animation(IDLE_ANIM)
	
	if Input.is_action_just_pressed("ui_accept") or jump_buffer > 0:
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
		#since we're airborne we also want to use the input buffer for jump here
		jump_buffer = MAX_JUMP_BUFFER_TIME
	
	if Input.is_action_just_pressed("slow_mo_dash_climb"):
		_state_chart.send_event(DASH)
	
	if is_on_floor():
		_state_chart.send_event(GROUNDED)
	
	if is_on_wall():
		_state_chart.send_event(WALL_COLLISION)
	
	_decrement_jump_buffer_time(delta)
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
	_state_chart.set_expression_property("has_climb", Evolutions.has_climb)
	_state_chart.set_expression_property("has_destroy", Evolutions.has_destroy_obstacles)
#endregion


#region state signal handlers and subprocesses
func _on_jumping_physics_process(delta: float) -> void:
	if velocity.y > 0: # when we start falling, the jump is finished
		_state_chart.send_event(JUMP_FINISHED)
	
	if Input.is_action_just_pressed("ui_accept"):
		_build_brain_platform()


func _on_falling_physics_process(delta: float) -> void:
	_play_animation(IDLE_ANIM)
	is_wall_jumping = false
	if Evolutions.has_glide:
		if Input.is_action_pressed("ui_accept"):
			velocity.y = GLIDE_VELOCITY
	
	if Input.is_action_just_pressed("ui_accept"):
		_build_brain_platform()


func _on_dashing_physics_process(delta: float) -> void:
	velocity.x = dash_velocity
	velocity.y = 0
	dash_timer -= delta
	if (dash_timer <= 0):
		_state_chart.send_event(DASH_FINISHED)
		is_dashing = false

func _on_wall_sliding_physics_process(delta: float) -> void:
	velocity.y = WALL_SLIDE_SPEED
	if Input.is_action_pressed("slow_mo_dash_climb") and _remaining_climb_duration >= 0:
		_state_chart.send_event(WALL_CLIMB)


func _on_wall_climbing_physics_process(delta: float) -> void:
	if not is_on_wall():
		_state_chart.send_event(WALL_CLIMB_FINISHED)
	
	if Input.is_action_pressed("slow_mo_dash_climb"):
		_do_wall_movement(delta)
		if _remaining_climb_duration <= 0:
			_end_wall_movement()
	else:
		_end_wall_movement()


func _on_destroy_obstacle_physics_process(delta: float) -> void:
	collision_mask = collision_mask & ~(1 << 2) # remove layer 2 collision during this
	_kill_box.show()


func _on_wall_jump() -> void:
	_play_animation(WALL_JUMP_ANIM)
	is_wall_jumping = true
	is_climbing = false
	velocity = (get_wall_normal() + Vector2.UP).normalized() * WALL_JUMP_VELOCITY


func _on_jump() -> void:
	_play_animation(JUMP)
	velocity.y = JUMP_VELOCITY
	is_dashing = false


func _on_dash() -> void:
	dash_velocity = TOP_SPEED_AIR * last_direction * DASH_SCALAR
	dash_timer = DASH_TIME
	is_dashing = true


func _on_double_jump() -> void:
	_can_double_jump = false
	is_dashing = false


func _on_air_dash() -> void:
	_can_dash = false


func _on_wall_transition() -> void:
	_reset_killbox()
	_play_animation(CLIMB_TURN_ANIM)


func _on_destroy_obstacles() -> void:
	_play_animation(DESTROY_ANIM)


func _on_destroy_obstacles_expire() -> void:
	collision_mask = collision_mask | (1 << 2) # restore layer 2 collision
	_kill_box.hide()
#endregion


#region basic movement
func _do_movement(delta: float, is_aerial: bool) -> void:
	if is_aerial:
		_do_air_acceleration(delta)
	else:
		_do_ground_acceleration(delta)
	move_and_slide()


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
		last_direction = direction


func _add_gravity(delta: float) -> void:
	if not is_dashing:
		velocity.y = move_toward(velocity.y, gravity, delta * gravity)


func _do_wall_movement(delta: float) -> void:
	is_climbing = true
	velocity.y = 0
	var direction = Input.get_axis("ui_up", "ui_down")
	velocity.y = direction * CLIMBING_SPEED
	
	if abs(velocity.y) > 0: 
		if direction > 0:
			_play_animation(CLIMB_ANIM, true)
		else:
			_play_animation(CLIMB_ANIM)
		_remaining_climb_duration -= delta # only subtract climbing time if you're moving
	else:
		_animated_sprite.pause()


func _end_wall_movement() -> void:
	is_climbing = false
	_state_chart.send_event(WALL_CLIMB_FINISHED)


func _decrement_jump_buffer_time(delta: float) -> void: 
	if jump_buffer > 0:
		jump_buffer -= delta
#endregion


#region brain abilities
func _build_brain_platform() -> void:
	if Evolutions.has_brain_platform and _can_make_brain_platform:
		var platform = _brain_platform.instantiate()
		get_tree().get_root().add_child(platform)
		platform.position = position + Vector2(0, _bplatform_pixels_below)
		_can_make_brain_platform = false
		jump_buffer = -1


func _reset_brain_platform() -> void:
	if _is_on_non_brain_platform():
		_can_make_brain_platform = true


func _is_on_non_brain_platform() -> bool:
	var return_bool: bool = false
	var collision = get_slide_collision(0)
	if collision and not is_on_wall():
		var collider = collision.get_collider()
		if collider != null and "collision_layer" in collider:
			if not collider.collision_layer & 2**7:
				return_bool = true
	return return_bool
	


func get_time_record() -> Dictionary:
	print("write %s" % position)
	return {"position" : position, "velocity" : velocity}


func set_from_time_record(record: Dictionary) -> void:
	position = record["position"]
	print("read %s" % position)
	velocity = record["velocity"]
#endregion


#region animation
func _on_animated_sprite_2d_animation_finished() -> void:
	if cur_animation == DEATH_ANIM:
		died.emit()
		queue_free()
	
	if cur_animation == CLIMB_ANIM or cur_animation == WALL_JUMP_ANIM or cur_animation == DESTROY_ANIM:
		_claws_sprite.show()
		if cur_animation == WALL_JUMP_ANIM:
			_play_animation(IDLE_ANIM)


func _on_wing_animations_animation_finished() -> void:
	_wings_sprite.play(IDLE_ANIM)


func _play_animation(animation: String, backwards: bool = false) -> void:
	if cur_animation == DEATH_ANIM:
		return
	
	if animation == IDLE_ANIM and Evolutions.has_brain:
		animation = BRAIN_IDLE_ANIM
	
	if backwards:
		_animated_sprite.play_backwards(animation)
	else:
		_animated_sprite.play(animation)
	cur_animation = animation
	
	if animation == CLIMB_ANIM or animation == CLIMB_TURN_ANIM or animation == WALL_JUMP_ANIM or animation == DESTROY_ANIM:
		_claws_sprite.hide()
	
	if animation == JUMP and Evolutions.has_wings:
		_wings_sprite.play(JUMP_ANIM)
	
	if animation == IDLE_ANIM:
		if Evolutions.has_claws:
			_claws_sprite.show()
		else:
			_claws_sprite.hide()
		
		if Evolutions.has_wings:
			_wings_sprite.show()
		else:
			_wings_sprite.hide()
#endregion

#region death
func _check_hazard_collision() -> void:
	for i in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
		if collision:
			var collider = collision.get_collider()
			if collider != null:
				if "collision_layer" in collider:
					if collider.collision_layer & 2**1 or collider.collision_layer & 2**2:
						_die()
				elif collider is TileMap:
					var collider_rid = collision.get_collider_rid()
					var collider_collision_layer = PhysicsServer2D.body_get_collision_layer(collider_rid)
					if collider_collision_layer & 2**1 or collider_collision_layer & 2**2:
						_die()


func _die() -> void:
	_state_record.set_process(false)
	set_physics_process(false)
	_play_animation(DEATH_ANIM)
#endregion


func _reset_killbox() -> void:
	collision_mask = collision_mask | (1 << 2) # restore layer 2 collision
	_kill_box.hide()


func _on_kill_box_body_entered(body: Node2D) -> void:
	if _kill_box.visible and body is KillableHazard:
		(body as KillableHazard).kill()
