extends Path2D

@export var speed: float = 100 ## in pixels/second

@onready var follower: PathFollow2D = $PathFollow2D


func _ready() -> void:
	assert(follower != null)


func _process(delta: float) -> void:
	follower.progress += speed * delta
