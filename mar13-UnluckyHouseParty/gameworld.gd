extends Node2D

onready var cam = $Camera2D
onready var stats_label = $Camera2D/stats
onready var lucky = $lucky
onready var camfoc = lucky
func setcamfoc(target):
	if target != camfoc:
		camfoc = target
func unsetcamfoc(target):
	if target == camfoc:
		camfoc = lucky
func _physics_process(_delta):
	var targetpos = camfoc.position + Vector2(0, -5)
	var targetvel = camfoc.get('velocity')
	if targetvel: targetpos += targetvel
	if targetpos.y > 135:
		targetpos.y = 135 # cap
	cam.position.x = move_toward(cam.position.x, targetpos.x, 1)
	cam.position.y = move_toward(cam.position.y, targetpos.y, 1)

	stats_label.text = "%02d jump\n%02d hover" % [lucky.get_j_remaining(), lucky.get_h_remaining()]

onready var talkas = [$talka, $talkb, $talkc]

func playvoice(pitch):
	for t in talkas:
		if t.playing:
			return
	var t = talkas[randi()%3]
	t.pitch_scale = randf() * 0.2 - 0.1 + pitch
	t.play()
