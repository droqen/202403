extends NavdiMovingGuy

enum { IDLE=100, WALK, AIR, FORCEWALKRIGHT, OUCH, OUCHBUF, RECENTLY_OUCHBUF }

onready var startpos = position
onready var sticky_particle = $"../../../sticky"
onready var maze = $"../maze"
onready var hpst = TinyState.new(3,self,"_on_movst_or_hp_chg",true)
onready var movst = TinyState.new(IDLE,self,"_on_movst_or_hp_chg",true)
onready var facest = TinyState.new(1,self,"_on_facest_chg",true)
func _on_movst_or_hp_chg(then,now):
	if then == OUCH and hpst.id <= 0:
		position = startpos
		hpst.goto(3)
	var h = hpst.id * 2
	match movst.id:
		IDLE: spr.setup([8+h])
		WALK: spr.setup([9+h, 8+h],8)
		AIR: spr.setup([9+h])
		FORCEWALKRIGHT: spr.setup([9+h, 8+h],8)
		OUCH:
			spr.setup([9+h])
			if then in [IDLE,WALK,AIR,FORCEWALKRIGHT]:
				prints("ouch@", velocity)
				if velocity.x: facest.goto(sign(velocity.x))
				velocity.x = facest.id * -1
				prints("ouch", facest.id, velocity)
				velocity.y = -0.5
				bufs.on(OUCHBUF)
				bufs.on(RECENTLY_OUCHBUF)
func _on_facest_chg(_then,now):
	spr.flip_h = now<0
func _ready():
	bufs.defons([
		[FLORBUF,13],
		[JUMPBUF,4],
		[OUCHBUF,30],
		[RECENTLY_OUCHBUF,20],
	])
	sticky_particle.one_shot = true
	sticky_particle.emitting = false
func _physics_process(_delta):
	
	var sticky_floor : bool = false
	var death_floor : bool = false
	if bufs.has(FLORBUF):
		var cells = [
			maze.world_to_map(position + Vector2(-2,6)),
			maze.world_to_map(position + Vector2( 2,6)),
		]
		for cell in cells:
			match maze.get_cellv(cell):
				1:
					death_floor = true
				3:
					sticky_floor = true
		if death_floor and movst.id != OUCH:
			movst.goto(OUCH)
			hpst.goto(hpst.id - 1)
	pin.process_pins()
	bufs.process_bufs()
	if movst.id == OUCH:
		if visible: hide()
		elif randf()<0.4: show()
		accel_velocity(facest.id * -0.5, 1.5, 0.1, 0.035)
#		if pin.a.pressed: bufs.on(JUMPBUF)
		process_slidey_move()
	else:
		show()
		if movst.id == FORCEWALKRIGHT:
			pin.stick.x = 1
			pin.a.pressed = false
		accel_velocity(pin.stick.x, 1.5, 0.1, 0.035)
		if pin.a.pressed: bufs.on(JUMPBUF)
		if bufs.try_consume([JUMPBUF,FLORBUF]):
			if death_floor: movst.goto(OUCH)
			elif sticky_floor:
				velocity.y = -0.5
				sticky_particle.position = position + Vector2(0,5)
				sticky_particle.restart()
			else:
				velocity.y = -1.3
		process_slidey_move()
	
	if movst.id == OUCH:
		if bufs.has(FLORBUF):
			velocity.y = -0.2 -0.2*randf() 
		if not bufs.has(OUCHBUF):
			movst.goto(AIR)
	elif movst.id == FORCEWALKRIGHT:
		facest.goto(1)
		if position.x > 5:
			movst.goto(IDLE)
	else:
		if not bufs.has(FLORBUF):
			movst.goto(AIR)
		elif position.x < 0:
			movst.goto(FORCEWALKRIGHT)
		elif pin.stick.x:
			movst.goto(WALK)
		else:
			movst.goto(IDLE)
		if pin.stick.x: facest.goto(sign(pin.stick.x))
	
	if pin.stick or pin.a.pressed or bufs.has(OUCHBUF) or not bufs.has(FLORBUF):
		bufs.setmin(RECENTLY_OUCHBUF, 20)
	elif movst.id == IDLE and hpst.id <3 and not pin.stick and not bufs.has(RECENTLY_OUCHBUF):
		hpst.goto(hpst.id + 1)
		bufs.setmin(RECENTLY_OUCHBUF, 20)
	
	if position.x > 120:
		var celly = maze.world_to_map(position).y
		print("Exited from cell "+str(celly))
		hpst.goto(4)
		for x in range(12,24):
			for y in range(celly,celly+1+1):
				maze.set_cell(x,y,-1)
		position = startpos
		movst.goto(FORCEWALKRIGHT)
