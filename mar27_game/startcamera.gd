extends Camera2D

var yvel : float = 0.0

func start():
	position.y = -130
	yvel = 0.0
func _physics_process(_delta):
	if position.y < 0:
		yvel += 0.02
		yvel *= 0.999
		position.y += yvel
		if position.y >= 0:
			position.y = 0
