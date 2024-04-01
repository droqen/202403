tool
extends Sprite
class_name NavdiBitsySprite
export(Array, int
) var frames = [0,1]
export var period : int = 8
var ani : int = 0
var anif : float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	ani += 1
	_update_frame()

func set_frames(_frames: Array):
	frames = _frames
	_update_frame()
	
func _update_frame():
	if period < 1: period = 1
	ani = fmod(ani, period * len(frames))
	anif = ani * 1.0 / period
	frame = frames[int(anif)] % (vframes * hframes)
