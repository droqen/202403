extends Camera2D

onready var target = $"../player"

func _physics_process(_delta):
	var tpx = round(target.position.x/100.0)*100.0
	var tpy = round(target.position.y/100.0)*100.0
	position.x = move_toward(position.x, tpx, 5)
	position.y = move_toward(position.y, tpy, 5)
