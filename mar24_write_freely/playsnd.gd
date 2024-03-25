extends Node

var pawstil : float = 0.0

func _on_MarchingTextContainer_char_marched(c):
	var t = Time.get_unix_time_from_system()
	if t > pawstil:
		$tup.pitch_scale = rand_range(1.8,2.2)
		$tup.play()
		pawstil = t + rand_range(0.1,0.4)
	$tprnt.play()


func _on_MarchingTextContainer_finished():
#	$tup.pitch_scale = rand_range(1.2,1.6)
#	$tup.play()
	$tup.stop()
	$tprnt.stop()
	$tdone.play()
