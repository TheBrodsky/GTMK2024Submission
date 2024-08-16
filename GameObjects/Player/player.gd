extends CharacterBody2D

@export_group("Player Properties")
@export var SPEED: float = 300.0 #
@export var JUMP_VELOCITY: float = -400.0 #
@export var has_double_jump: bool = false
#climb velocity
#double jump velocity, etc.

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


func _process(delta):
	#changing animation sprites works:
	#if Input.is_action_pressed("ui_right"):
	#	_animated_sprite.play("test")
	#else:
	#	_animated_sprite.stop()
	pass

func _physics_process(delta):
	#add gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	#jump (spacebar == "ui_select")
	if Input.is_action_just_pressed("ui_select") and (is_on_floor() or has_double_jump):  
		#TODO: need to figure out a way to handle that if statement better when we have multiple jumps and stuff
		velocity.y = JUMP_VELOCITY
		#has_double_jump = false
	
	var direction = Input.get_axis("ui_left","ui_right")
	velocity.x = SPEED * direction
	move_and_slide()
	
