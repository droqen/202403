extends NavdiMovingGuy

enum {WALK=101,AIR,DEAD}
enum {DEAD_PAUSE_BUF=1200}
onready var myst = TinyState.new(IDLE,self,"_on_myst_change")
onready var startpos = position
func _on_myst_change(_then,now):
	match now:
		IDLE:
			spr.setup([2])
		AIR:
			spr.setup([6])
		WALK:
			if pin.stick.x < 0:
				spr.setup([4,2,3,2],8)
			else:
				spr.setup([3,2,4,2],8)
		DEAD:
			spr.setup([24])
			bufs.setmin(DEAD_PAUSE_BUF, 40)

func _physics_process(_delta):
	pin.process_pins()
	bufs.process_bufs()
	if myst.id == DEAD:
		if bufs.has(DEAD_PAUSE_BUF):
			velocity = Vector2.ZERO
			pin.clear()
			bufs.clr(JUMPBUF)
			bufs.clr(FLORBUF)
		else:
			var dx = round(startpos.x - position.x)
			var dy = round(startpos.y - position.y)
			if abs(dx)>3 or abs(dy)>3:
				if abs(dx)<3: position.x = startpos.x
				else: position.x += sign(dx)*3
				if abs(dy)<3: position.y = startpos.y
				else: position.y += sign(dy)*3
			else:
				position = startpos
				myst.goto(IDLE)
	else:
		accel_velocity(pin.stick.x * 1, 1.2, 0.1, 0.048)
		if pin.a.pressed:bufs.setmin(JUMPBUF, 4)
		if bufs.try_consume([FLORBUF,JUMPBUF]):
			velocity.y = -1.2
		if not bufs.has(FLORBUF):
			myst.goto(AIR)
			if velocity.y < -0.5:
				spr.setup([6])
			else:
				spr.setup([7])
		elif pin.stick.x:
			myst.goto(WALK)
		else:
			myst.goto(IDLE)
		process_slidey_move()

func toast():
	myst.goto(DEAD)
