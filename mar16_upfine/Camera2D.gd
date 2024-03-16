extends Camera2D

onready var player = $"../NotMoth"
export var follow_enabled : bool = true

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if follow_enabled:
		position.y = min(0, player.position.y - 100)
