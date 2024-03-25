extends Node

onready var cam = $"../gridcam"

func _ready():
	cam.connect("gridpos_change", self, "_on_cam_gridpos_change")

func _on_cam_gridpos_change(cx : int, cy : int):
	match [cx,cy]:
		[0,_], [6,_], [7,_]:
			$bgm2.stop()
			if not $bgm.playing: $bgm.play(randf()*$bgm.stream.get_length())
		[4,_], [5,_]:
			$bgm.stop()
			if not $bgm2.playing: $bgm2.play(randf()*$bgm2.stream.get_length())
		_:
			$bgm.stop()
			$bgm2.stop()
