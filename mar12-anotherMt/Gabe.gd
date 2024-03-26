extends NavdiMovingGuy

enum { IDLE, RUN, SKID, JUMP, FALL, WALL_CLING, WALL_SCAMPER, DEAD }

onready var maze : NavdiFlagMazeMaster = $"../NavdiFlagMazeMaster"

onready var mst = TinyState.new(FALL,self,"_on_mst_change")
#onready var fst = TinyState.new(1,self,"_on_fst_change")

enum { WALLBUF = 1218, JUSTFELLCOYOTEBUF, JETBUF, HEADBONKBUF }
var wallbuf_dir : int = 0

signal changed

var fuel : int = 0
var maxfuel : int = 0
var timerframes : int = 0
var timerstarted : bool = false
var timerfinished : bool = false

var can_airjump : bool = false
var in_waitingroom : bool = false
var at_summit: bool = false

var deadtimer: int = 0

onready var bank = $"../bank"
onready var flag = $"../flag"
#onready var generateMountain = $"../generateMountain"

func _ready():
	bufs.defon(JETBUF, 20)
	bufs.defon(JUMPBUF, 6)
	bufs.defon(WALLBUF, 4)
	bufs.defon(JUSTFELLCOYOTEBUF, 6)
	bufs.defon(HEADBONKBUF, 15)

func _on_mst_change(_then,now):
	match now:
		IDLE: spr.setup([0])
		RUN: spr.setup([5,2,6,0],8)
		SKID: spr.setup([3])
		JUMP: spr.setup([2])
		FALL:
			spr.setup([3])
			bufs.setmin(JUSTFELLCOYOTEBUF, 6)
		WALL_CLING: spr.setup([30])
		WALL_SCAMPER: spr.setup([31,32,33,30],5)
		DEAD: spr.setup([4])

func _physics_process(_delta):
	if mst.id == DEAD:
		deadtimer += 1
		if deadtimer > 100:
			if randf() < 0.05:
				mst.goto(JUMP)
				velocity.x = 0
				velocity.y = -0.40
				$reup.play()
			else:
				position = Vector2(0, 187)
				mst.goto(IDLE)
				velocity *= 0
				fuel = maxfuel
				emit_signal("changed")
		return
	else:
		deadtimer = 0
	
	if timerstarted and not timerfinished:
		timerframes += 1
	if not timerstarted: timerstarted = not in_waitingroom
	if not timerfinished: timerfinished = at_summit
	if in_waitingroom:
		timerstarted = false
		timerfinished = false
		timerframes = 0
	
	if position.x < -5: position.x = -5
	pin.process_pins()
	if position.x < 10 and pin.stick.x == 0: pin.stick.x = 1
	if position.x >= 502 and pin.stick.x > 0: pin.stick.x = 0
	if pin.a.pressed: bufs.on(JUMPBUF)
	bufs.process_bufs()
	var xaccel = 0.02
	
	match mst.id:
		WALL_CLING, WALL_SCAMPER:
			velocity.y *= 0.95
			accel_velocity(wallbuf_dir * 0.5, pin.stick.y * 0.20, 0.05, 0.03)
		FALL:
			velocity.x = 0
			accel_velocity(0, 0 if bufs.has(JUSTFELLCOYOTEBUF) else 4.0, xaccel, 0.04)
		_:
			if mst.id == SKID: xaccel = 0.02
			if not bufs.has(FLORBUF): xaccel = 0.01 if pin.stick.x else 0.00
			accel_velocity(pin.stick.x * 0.55, 4.0, xaccel, 0.04)
			
	if position.x + velocity.x > 502:
		position.x = 502
		velocity.x = 0
		if not flag.visible:
			flag.show()
			$"../wind/win".play()
	
	process_slidey_move()
	
	
	if bufs.try_consume([FLORBUF,JUMPBUF]):
		velocity.y = -0.6
		mst.goto(JUMP)
	
	if bufs.has(FLORBUF) and bufs.has(WALLBUF) and pin.stick.y < 0:
		bufs.clr(FLORBUF)
		bufs.clr(JUMPBUF)
	
	if bufs.has(FLORBUF):
		if velocity.x != 0: spr.flip_h = velocity.x < 0 # turn.
		if pin.stick.x * velocity.x < 0 or pin.stick.x == 0 and velocity.x != 0: mst.goto(SKID)
		elif pin.stick.x != 0 or velocity.x != 0:
			mst.goto(RUN)
			spr.set_frame_period(int(8 - abs(velocity.x * 5 / 0.5)))
		else: mst.goto(IDLE)
	elif bufs.has(WALLBUF):
		spr.flip_h = wallbuf_dir < 0
		if bufs.try_consume([WALLBUF, JUMPBUF]):
			velocity.y = -0.6
			mst.goto(JUMP)
			if pin.stick.x * wallbuf_dir > 0:
				velocity.x = wallbuf_dir * -0.05 # very slight push out
			elif pin.stick.x == 0:
				velocity.x = wallbuf_dir * -0.15 # slight walljump
				spr.flip_h = velocity.x < 0
			else:
				velocity.x = wallbuf_dir * -0.5 # walljump
				spr.flip_h = velocity.x < 0
		elif pin.stick.y:
			mst.goto(WALL_SCAMPER)
		else:
			mst.goto(WALL_CLING)
	else:
		match mst.id:
			JUMP, FALL:
				if velocity.y >= 0 and pin.a.held and not bufs.has(HEADBONKBUF) and can_airjump and not bufs.has(JETBUF):
					if fuel > 0:
						velocity.y = -0.3
						for i in range(3):
							if fuel > 0:
								fuel -= 1
								bank.spawn("smoke").setup(self)
								velocity.y -= 0.1
						bufs.on(JETBUF)
						mst.goto(JUMP)
						emit_signal("changed")
					else:
#						velocity.x *= 0.5
#						velocity.y = -0.15
						for i in range(3):
							bank.spawn("deadsmoke").setup(self)
						bufs.on(JETBUF)
						mst.goto(JUMP)
						emit_signal("changed")
#					else:
				if mst.id == JUMP:
					if bufs.has(JETBUF):
						spr.setup([3])
					else:
						spr.setup([2])
			_:
				if pin.stick.y > 0 and mst.id in [IDLE,SKID,RUN]:
					mst.goto(WALL_CLING)
					bufs.on(WALLBUF)
					wallbuf_dir = -sign(velocity.x)
					velocity.x = wallbuf_dir * 1.0
				elif mst.id == WALL_CLING or mst.id == WALL_SCAMPER:
					mst.goto(JUMP) # always 'jump' off walls (backwards)
				else:
					mst.goto(JUMP if velocity.y < 0 else FALL)

func on_bonk_h(hit:KinematicCollision2D):
	if pin.stick.x * velocity.x > 0 or bufs.has(WALLBUF):
		bufs.on(WALLBUF)
		wallbuf_dir = sign(velocity.x)
	velocity.x = 0

func on_bonk_v(hit:KinematicCollision2D):
	if velocity.y < 0:
		bufs.on(HEADBONKBUF)
		mst.goto(JUMP)
	if velocity.y >= 0:
		bufs.on(FLORBUF)
	if velocity.y > 0.10:
#		prints("Terminal velocity",velocity.y)
		var falldeath : bool = false
		var cellleft : Vector2 = maze.world_to_map(position + Vector2.LEFT * 1.5)
		var cellright : Vector2 = maze.world_to_map(position + Vector2.RIGHT * 2.0)
		var leftfootinspikes : bool = (maze.get_cellv(cellleft) == 68)
		var rightfootinspikes : bool = (maze.get_cellv(cellright) == 68)
		var hasfootonair : bool = maze.get_cellvalue_flag(maze.get_cellv(cellleft + Vector2.DOWN)) != 1 or maze.get_cellvalue_flag(maze.get_cellv(cellright + Vector2.DOWN)) != 1
		if int(leftfootinspikes) + int(rightfootinspikes) + int(hasfootonair) >= 2 and velocity.y > 0.55:
			falldeath = true
		if velocity.y > 1.85:
			falldeath = true
		
		if falldeath:
			mst.call_deferred('goto',DEAD)
			$die.play()
	velocity.y = 0
