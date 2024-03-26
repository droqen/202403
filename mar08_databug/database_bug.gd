extends NavdiMovingGuy

export (NodePath) var _maze
onready var maze : NavdiFlagMazeMaster = get_node(_maze)
export (NodePath) var _scorelabel
onready var scorelabel : Label = get_node(_scorelabel)
export (NodePath) var _guidelabel
onready var guidelabel : Label = get_node(_guidelabel)

enum { IDLE, WALK, AIR, AIR_HIJUMP, TURN, DIGGING, GLITCH }
enum { FACELEFT = -1, FACERIGHT = 1 }
onready var mst = TinyState.new(IDLE,self,"_on_mst_change")
onready var fst = TinyState.new(FACERIGHT,self,"_on_fst_change",true)

var damage : int = 0
var coins : int = 0
var laststepindex : int = 1

enum { TURNBUF=99, DIGBUF, GLITCHBUF, STEPBUF }

func _on_mst_change(_then,now):
	match now:
		TURN: spr.setup([16])
		IDLE: spr.setup([12,12,12,12,12,12,12,12,17],10)
		WALK:
			spr.setup([13,15,14,15],5)
			playstepsound()
		AIR: spr.setup([13])
		AIR_HIJUMP:
			spr.setup([18])
			bufs.clr(FLORBUF)
		DIGGING:
			spr.setup([26,27,28,29,28,29,29],5)
			bufs.on(DIGBUF)
		GLITCH:
			$hurt.pitch_scale = 1.00 - 0.33 * damage
			$hurt.play()
			spr.setup([34,35,36,37,38],2)
			bufs.setmin(GLITCHBUF, 20 + 10 * damage)
			damage += 1
func _on_fst_change(_then,now):
	spr.flip_h = now < 0
	bufs.on(TURNBUF)

func _ready():
	bufs.defon(JUMPBUF, 8)
	bufs.defon(FLORBUF, 5)
	bufs.defon(TURNBUF, 5)
	bufs.defon(DIGBUF, 30)
	bufs.defon(GLITCHBUF, 20)
	guidelabel.text = ""

func process_slidey_move():
	if position.x < -5 or position.x > 115:
		velocity.y = 0
	.process_slidey_move()

func _physics_process(_delta):
	bufs.process_bufs()
	pin.process_pins()
	check_collect_coin()
	
	if mst.id == GLITCH:
		accel_velocity(0,0,0, 0.14)
		process_slidey_move()
		if bufs.has(GLITCHBUF):
			return
		else:
			if damage < 3:
				mst.goto(IDLE)
			else:
				if visible:
					hide()
					guidelabel.text = 'esc to reset'
					$dig2.play()
				return
	if pin.down.pressed and bufs.has(FLORBUF) and (mst.id != DIGGING):
		var mycell = maze.world_to_map(position - maze.position)
		if maze.get_cell(mycell.x, mycell.y + 1) == -1:
			mycell = maze.world_to_map(position + Vector2(fst.id * 3, 0) - maze.position)
		position.x = (maze.map_to_world(mycell) + maze.position).x + 5
		velocity.x = 0
		mst.goto(DIGGING)
	if mst.id == DIGGING:
		if not $dig.playing:
			$dig.pitch_scale = 1.0
			$dig.play()
		if not bufs.has(FLORBUF):
			mst.goto(AIR)
		elif not bufs.has(DIGBUF):
			$dig.pitch_scale = 0.5
			$dig.play()
			mst.goto(AIR)
			velocity.y = -1.1
			dig()
		accel_velocity(0.0, 2.0, 0.1, 0.14)
		process_slidey_move()
	else:
		accel_velocity(pin.stick.x * 1.0, 2.0, 0.0 if mst.id==TURN else 0.1, 0.14)
		if pin.stick.x: fst.goto(sign(pin.stick.x))
		if pin.a.pressed: bufs.on(JUMPBUF)
		if bufs.try_consume([JUMPBUF,FLORBUF]):
			velocity.y = -1.8 # jump
			$hop.play()
		if bufs.has(TURNBUF):
			mst.goto(TURN)
		elif bufs.has(FLORBUF):
			if pin.stick.x: mst.goto(WALK)
			else: mst.goto(IDLE)
		else:
			if mst.id == AIR_HIJUMP:
				if velocity.y > 0:
					mst.goto(AIR)
			else:
				mst.goto(AIR)
		process_slidey_move()
	
	if mst.id == WALK:
		playstepsound()

const scrollgen = preload("res://scrollgen.gd")

func dig():
	var mycell = maze.world_to_map(position - maze.position)
	var x : int = mycell.x
	var y : int = mycell.y
	var dug_cell_id = maze.get_cell(x, y + 1)
	match dug_cell_id:
		11: # ordinary block, no power
			pass
		21: # magic pink block, unknown
			velocity.y = 0
			mst.goto(GLITCH)
		22: # up-arrow block, big jump
			velocity.y = -3.1
			mst.goto(AIR_HIJUMP)
			$jump.play()
		31:
			maze.set_cell(x, y + 1, -1)
			freeze_scramble(x, y + 1)
			$scramble.play()
	maze.set_cell(x, y + 1, -1)

func freeze_scramble(ox,oy):
	get_tree().paused = true
	for i in range(1,5+1):
		yield(get_tree().create_timer(0.05*i), "timeout")
		for x in range(ox-2,ox+2+1):
			for y in range(oy-2,oy+2+1):
				if maze.get_cell(x,y) != -1:
					var random_cell_value = scrollgen.draw_random_cell_value(y)
					if random_cell_value >= 0:
						maze.set_cell(x,y,random_cell_value)
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().paused = false

func glitch():
	velocity *= 0
	mst.goto(GLITCH)

func on_bonk_v(hit:KinematicCollision2D):
#	if velocity.y < 0 and mst.id == AIR_HIJUMP:
#		mst.goto(GLITCH)
	if velocity.y >= 0:
		bufs.on(FLORBUF)
	velocity.y = 0

func check_collect_coin():
	var mycell = maze.world_to_map(position - maze.position)
#	print(maze.get_cell(mycell.x, mycell.y))
	match maze.get_cell(mycell.x, mycell.y):
		23:
			coins += 1
			prints("coins:", coins)
			scorelabel.text = str(coins)
			$coin.play()
		2: glitch()
		3: glitch()
		4: glitch()
		_: return
	maze.set_cell(mycell.x, mycell.y, -1)

func playstepsound():
	if bufs.has(STEPBUF):
		pass # waiting
	else:
		if laststepindex == 1:
			$step2.play()
			laststepindex = 2
		else:
			$step.play()
			laststepindex = 1
		bufs.setmin(STEPBUF,12 + randi()%2)
