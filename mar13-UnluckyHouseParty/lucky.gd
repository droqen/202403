extends NavdiMovingGuy

onready var headspr : SheetSprite = $headspr
enum { NOGRAVBUF = 610, HOVBUF, }
enum { IDLE, WALK, JUMP, }
onready var mst : TinyState = TinyState.new(IDLE,self,"_on_mst_change")
onready var facest : TinyState = TinyState.new(1,self,"_on_facest_change")

var jump_height : int = 20
var hov_length : int = 8
#var jump_height : int = 30
#var hov_length : int = 32

func get_j_remaining() -> int:
	if bufs.has(NOGRAVBUF):
		return bufs.read(NOGRAVBUF)
	elif mst.id == JUMP:
		return 0
	else:
		return jump_height
func get_h_remaining() -> int:
	if get_j_remaining() > 0:
		return hov_length
	else:
		return bufs.read(HOVBUF)

func _on_mst_change(_then,now):
	match now:
		IDLE: spr.setup([10])
		WALK: spr.setup([11,12,13,14],8)
		JUMP: spr.setup([13])
		
func _on_facest_change(_then,now):
	spr.flip_h = now < 0
	headspr.flip_h = now < 0

func _physics_process(_delta):
	pin.process_pins()
	bufs.process_bufs()
	if pin.down.pressed:
		bufs.clr(NOGRAVBUF)
	if pin.down.held and not bufs.has(NOGRAVBUF):
		bufs.clr(HOVBUF)
	accel_velocity(
		pin.stick.x * (1.2 if (bufs.has(HOVBUF) and velocity.y == 0) else 0.6),
		0.0 if bufs.has(HOVBUF) else 0.6,
		(0.03 if (bufs.has(HOVBUF) and velocity.y == 0) else 0.3),
		0.0 if bufs.has(NOGRAVBUF) else 0.3)
	if pin.a.pressed: bufs.setmin(JUMPBUF,4)
	if bufs.try_consume([JUMPBUF,FLORBUF]):
		velocity.y = -1.0
		bufs.setmin(NOGRAVBUF, jump_height)
		bufs.setmin(HOVBUF, jump_height + hov_length)
	if pin.stick.x: facest.goto(sign(pin.stick.x))
	if not bufs.has(FLORBUF): mst.goto(JUMP)
	elif pin.stick.x: mst.goto(WALK)
	else: mst.goto(IDLE)
		
	process_slidey_move()
