extends NavdiMovingGuy

onready var musmgr = $"../musmgr"

var stumbles : bool = true

enum { IDLE= 100, WALK = 200, AIR, STUMBLE, }
enum { STUMBLEBUF = 949 }

onready var movst = TinyState.new(IDLE,self,"_on_movst_chg",true)
onready var turnst = TinyState.new(1,self,"_on_turnst_chg",true)
func _on_movst_chg(then,now):
	match then:
		STUMBLE:
			musmgr.stumble_recover()
	match now:
		IDLE: spr.setup([0])
		WALK:
			if spr.frame == 2:
				spr.setup([0,1,0,2],8)
			else:
				spr.setup([1,0,2,0] if randf()<.5 else [2,0,1,0],8)
		AIR: spr.setup([2] if randf()<.5 else [3])
		STUMBLE:
			spr.setup([5])
			bufs.on(STUMBLEBUF)
#			$oof.pitch_scale = rand_range(1.0,2.0)
#			$oof.play()
			musmgr.stumble()
func _on_turnst_chg(_then,now):
	spr.flip_h = now < 0

func _ready():
	bufs.defons([[STUMBLEBUF, 50], [JUMPBUF, 4]])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pin.process_pins()
	bufs.process_bufs()
	if movst.id == STUMBLE:
#		if not bufs.has(FLORBUF):
#			bufs.on(STUMBLEBUF) # no air recovery
		if not bufs.has(STUMBLEBUF):
			movst.goto(AIR)
			velocity.y = -0.5 # lil hop up
		accel_velocity(0.0, 1.5, 0.02, 0.1)
		process_slidey_move()
	else:
		if pin.stick.x:
			turnst.goto(sign(pin.stick.x))
		if pin.a.pressed:
			bufs.on(JUMPBUF)
		if bufs.try_consume([FLORBUF,JUMPBUF]):
			velocity.y = -2.0 # jump
			if stumbles and randf () < 0.25: # 25% of jumps stumble
				bufs.on(STUMBLEBUF)
		accel_velocity(pin.stick.x, 1.5, 0.1, 0.1)
		process_slidey_move()
	if stumbles and bufs.has(FLORBUF) and spr.frame in [1,2] and randf () < 0.01: # occasionally you just stumble.
		bufs.on(STUMBLEBUF)
		
	if not bufs.has(FLORBUF):
		if movst.id != STUMBLE:
			movst.goto(AIR)
		if bufs.has(STUMBLEBUF):
			bufs.on(STUMBLEBUF)
	elif stumbles and bufs.has(STUMBLEBUF):
		movst.goto(STUMBLE)
	elif pin.stick.x:
		movst.goto(WALK)
	else:
		movst.goto(IDLE)
		
func on_bonk_h(hit:KinematicCollision2D):
	velocity.x = 0
	if movst.id == STUMBLE:
		velocity.x = hit.normal.x * 0.1
	
