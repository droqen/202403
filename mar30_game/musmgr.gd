extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$mus1.play()
	yield($mus1, "finished")
	$"../stumbler".stumbles = false
	$mus2.play()

func die():
	dead = true
	$mus1.stop()
	$mus2.stop()
	for i in range(20):
		$mus2.play()
		$mus2.volume_db = -i * 2
		yield(get_tree().create_timer(1.0), "timeout")
	$mus2.stop()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var stumbled_time : float = 0.0

func stumble():
	stumbled_time = $mus1.get_playback_position()
#	if $mus1.playing: $mus1.pitch_scale = rand_range(0.9,0.95)
func stumble_recover():
	if $mus1.playing:
#		$mus1.pitch_scale = 1.0
		$mus1.play(stumbled_time)
	elif $mus2.playing:
		$mus2.play() # start over
