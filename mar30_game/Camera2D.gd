extends Camera2D

onready var player = $"../stumbler"
var tracking : bool = false
var yvelocity : float = 0.0

func _physics_process(_delta):
	if position.x < 100 and player.position.x > 100:
		position.x = 100
		$"../musmgr".die()
	if player.movst.id == player.STUMBLE:
		tracking = false
	if player.position.y > position.y + 90:		
		tracking = true
	if tracking:
		if player.position.y < position.y + 50:
			yvelocity = move_toward(yvelocity * 0.95, 0.0, 0.06)
		else:
			yvelocity = move_toward(yvelocity * 0.95, (player.position.y - 50) - (position.y + yvelocity * 5), 0.06)
	else:
		yvelocity *= 0.99
	position.y += yvelocity
