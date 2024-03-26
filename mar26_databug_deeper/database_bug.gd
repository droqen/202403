extends NavdiMovingGuy

export (NodePath) var _maze
onready var maze : NavdiFlagMazeMaster = get_node(_maze)
export (NodePath) var _scorelabel
onready var scorelabel : Label = get_node(_scorelabel)
export (NodePath) var _guidelabel
onready var guidelabel : Label = get_node(_guidelabel)

enum { IDLE, WALK, AIR, AIR_HIJUMP, TURN, DIGGING, GLITCH, HEALED }
enum { FACELEFT = -1, FACERIGHT = 1 }
onready var mst = TinyState.new(IDLE,self,"_on_mst_change")
onready var fst = TinyState.new(FACERIGHT,self,"_on_fst_change",true)

var damage : int = 0
var coins : int = 0
var laststepindex : int = 1

enum { TURNBUF=99, DIGBUF, GLITCHBUF, STEPBUF, HEALEDBUF }

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
		HEALED:
			$heal.play()
			spr.setup([18,19],2)
			bufs.setmin(HEALEDBUF, 20)
			damage = 0
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
	
	if mst.id == HEALED:
		accel_velocity(0,-0.2,0, 0.005)
		process_slidey_move()
		if bufs.has(HEALEDBUF):
			return
		else:
			damage = 0
			mst.goto(IDLE)
	elif mst.id == GLITCH:
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

onready var scrollgen = $"../scrollgen"

enum Block {
	Plain = 11,
	Kill = 21, Jump = 22,
	Scramble = 31, Danger = 32, HealBug = 33,
	Grey2 = 41, Green3 = 42, Yellow4 = 43,
}

enum Coin {
	Point = 23,
	Curse2 = 2, Curse3 = 3, Curse4 = 4,
}

func dig():
	var mycell = maze.world_to_map(position - maze.position)
	var x : int = mycell.x
	var y : int = mycell.y
	var dug_cell_id = maze.get_cell(x, y + 1)
	match dug_cell_id:
#		11: # ordinary block, no power
#			pass
		Block.Kill: # magic pink block, unknown
			velocity.y = 0
			mst.goto(GLITCH)
		Block.Jump: # up-arrow block, big jump
			velocity.y = -3.1
			mst.goto(AIR_HIJUMP)
			$jump.play()
		Block.Scramble:
			maze.set_cell(x, y + 1, -1)
			freeze_scramble(x, y + 1)
			$scramble.play()
		Block.Danger:
			maze.set_cell(x, y + 1, -1)
			cor_danger(x, y + 1)
		Block.Grey2: altercurse2()
		Block.Green3: altercurse3()
		Block.Yellow4: altercurse4()
		Block.HealBug: healme()
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

func cor_danger(ox,y):
	$dangbang.pitch_scale = 1.0
	for dx in range(1,10+1):
		$dangbang.pitch_scale -= 0.05
		for x in [ox-dx,ox+dx]:
			if maze.get_cell(x,y) != -1:
				maze.set_cell(x,y,Coin.Curse2)
			$dangbang.play()
		yield(get_tree().create_timer(rand_range(0.10, 0.12)), "timeout")
		if randf() < 0.9:
			for x in [ox-dx,ox+dx]:
				if maze.get_cell(x,y) == Coin.Curse2:
					maze.set_cell(x,y,-1)

func altercurse2():
	var dirs = [ [-1,0], [1,0], [0,-1], [0,1] ]
	var curses = maze.get_used_cells_by_id(Coin.Curse2)
	for cell in curses:
		for dir in dirs:
			if maze.get_cell(cell.x+dir[0], cell.y+dir[1]) == -1:
				maze.set_cell(cell.x, cell.y, -1)
	curses.shuffle()
	var living_curses_count = min(len(curses),5)
	var dead_indices = []
	$curse.pitch_scale = 3.0
	var live_indice_count : int = living_curses_count
	for h in range(10):
		for i in range(living_curses_count):
			maze.set_cellv(curses[i],Coin.Curse2)
			if i in dead_indices: continue
			else: live_indice_count += 1
			dirs.shuffle()
			var live : bool = false
			for dir in dirs:
				var cell2 = curses[i] + Vector2(dir[0], dir[1])
				if cell2.x >= 0 and cell2.x <= 9:
					match maze.get_cellv(cell2):
						-1:
							maze.set_cellv(cell2,Coin.Curse2)
				live = true
				curses[i] = cell2
				if live: break
			if live:
				live_indice_count += 1
			elif not live:
				dead_indices.append(i)
		$curse.pitch_scale = ($curse.pitch_scale - 2) * 0.9 + 2
		$curse.play()
		yield(get_tree().create_timer(0.2 + 0.02 * h), "timeout")

func altercurse3():
	var curses = maze.get_used_cells_by_id(Coin.Curse3)
	var coins = maze.get_used_cells_by_id(Coin.Point)
	for i in range(10):
		if i > 0:
			$curse.play()
			for cell in coins: maze.set_cellv(cell, Coin.Point)
			for cell in curses: maze.set_cellv(cell, Coin.Curse3)
			yield(get_tree().create_timer(0.1 - i * 0.005), "timeout")
		$curse.pitch_scale = 2.0 + 0.02 * i
		$curse.play()
		for cell in curses: maze.set_cellv(cell, Coin.Point)
		for cell in coins: maze.set_cellv(cell, Coin.Curse3)
		yield(get_tree().create_timer(0.1 - i * 0.005), "timeout")

func altercurse4():
	var curses = maze.get_used_cells_by_id(Coin.Curse4)
	curses.shuffle()
	for cell in curses:
		var smearlength : int = 0
		while true:
			smearlength += 1
			$curse.pitch_scale = 3.0 - 0.02 * smearlength
			$curse.play()
			for i in range(5):
				if randf() < 0.65: maze.set_cellv(cell, -1)
				else: maze.set_cellv(cell, Coin.Curse4)
				yield(get_tree().create_timer(0.01), "timeout")
			cell.y += 1
			if randf() < 0.25:
				break
#		maze.set_cellv(cell, Coin.Curse4)
#		yield(get_tree().create_timer(0.025), "timeout")
#		if randf() < 0.65: maze.set_cellv(cell, -1)
#		yield(get_tree().create_timer(0.025), "timeout")

func glitch():
	velocity *= 0
	mst.goto(GLITCH)

func healme():
	velocity *= 0
	mst.goto(HEALED)

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
