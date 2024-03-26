extends Camera2D

export (NodePath) var follow
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var screen_x : int = -999

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var cur_screen_x = min(9,floor(get_node(follow).global_position.x / 100.0))
	if screen_x != cur_screen_x:
		screen_x = cur_screen_x
		position.x = screen_x * 100
		var lowPassFilter = AudioServer.get_bus_effect(1, 0)
		var panner = AudioServer.get_bus_effect(1, 1)
		(lowPassFilter as AudioEffectLowPassFilter).cutoff_hz = 1000 - abs(screen_x) * 90
		(panner as AudioEffectPanner).pan = -screen_x * 0.10
