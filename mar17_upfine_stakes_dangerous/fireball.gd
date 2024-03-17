extends NavdiMovingGuy

enum {ROTBUF=3333}

enum {PATROL}

func _ready():
	movingst.goto(PATROL)
func _on_movingst_change(_then,now):
	pass

func _physics_process(_delta):
	# no pin
	bufs.process_bufs()
	accel_velocity( facingst.id * 1.5, 0.0, 0.1, 0.1 )
	process_slidey_move()
	if not bufs.has(ROTBUF):
		bufs.setmin(ROTBUF,10)
		spr.rotation_degrees += 90

func on_bonk_h(hit:KinematicCollision2D):
	if velocity.x:
		facingst.goto(-sign(velocity.x))
	velocity.x = 0
