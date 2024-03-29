extends NavdiMovingGuy

enum { FLYING = 39999, FLYING_TURNING, WINCH_LOWERING, WINCH_RAISING, STARTING, KABOOMEY }
enum { CARNONE = 29999, CARBLOCK, }

enum { TURNBUF = 9, STARTBUF, KABOOMEYBUF, }

onready var maze : NavdiFlagMazeMaster = $"../levelmgr/maze"
onready var flyst = TinyState.new(FLYING,self,"_on_flyst_or_carst_change",true)
onready var carst = TinyState.new(CARNONE,self,"_on_flyst_or_carst_change",true)
onready var turnst = TinyState.new(1,self,"_on_turnst_change",true)
onready var levelmgr = $"../levelmgr"
var cell : Vector2
var winch_length : int = 0
var winch_sublength : int = 0
var carrying_block_id : int = 0
var damage : int = 0

func _on_flyst_or_carst_change(_then,now):
	match now:
		STARTING: bufs.on(STARTBUF)
		KABOOMEY: bufs.on(KABOOMEYBUF)
		FLYING_TURNING: bufs.on(TURNBUF)
		CARNONE:
			carrying_block_id = 0
		CARBLOCK:
			$BlockSprite.setup([carrying_block_id])
	match [flyst.id, carst.id]:
		[KABOOMEY, _]: spr.setup([8,9],4)
		[FLYING, CARNONE], [STARTING, CARNONE]: spr.setup([1])
		[FLYING, CARBLOCK], [STARTING, CARBLOCK]: spr.setup([2])
		[WINCH_LOWERING, _]:
			winch_length = 0
			winch_sublength = 0
#		[WINCH_LOWERING, _], [WINCH_RAISING, _]: spr.setup([3])
#		[WINCH_LOWERING, _], [WINCH_RAISING, _]: spr.setup([3])
		[FLYING_TURNING, _]: spr.setup([7])
	match [flyst.id, carst.id]:
		[FLYING, CARBLOCK], [FLYING_TURNING, CARBLOCK]:
			$BlockSprite.show()
			$shape_carrying_block.disabled = false
			$solid_area/shape_carrying_block2.disabled = false
		_:
			$BlockSprite.hide()
			$shape_carrying_block.disabled = true
			$solid_area/shape_carrying_block2.disabled = true
func _on_turnst_change(_then,now):
	flyst.goto(FLYING_TURNING)
	spr.flip_h = now < 0

func start():
	damage = 0
	flyst.goto(STARTING)
	position = Vector2(25,0)
	turnst.goto(1)
	maze = $"../levelmgr/maze"
#	carst.goto(CARNONE)

func _ready():
	bufs.defons([[TURNBUF,5], [STARTBUF,120], [KABOOMEYBUF,60]])
	start()

func _physics_process(_delta):
	if position.y < 5:
		flyst.goto(STARTING)
		bufs.on(STARTBUF)
	pin.process_pins()
	bufs.process_bufs()
	velocity *= 0.95
	var xaccel = 0.08
	var yaccel = 0.10
	match flyst.id:
		STARTING:
			velocity *= 0
			position.y += 0.25
			if not bufs.has(STARTBUF): flyst.goto(FLYING)
			return # stop
		KABOOMEY:
			if not bufs.has(KABOOMEYBUF): levelmgr.goto_restart()
			return # stop
		FLYING, FLYING_TURNING:
			self.cell = maze.world_to_map(position)
			if pin.stick.x and (pin.stick.x < 0) != spr.flip_h: xaccel *= 0.5 # 'backing up' is slower.
		WINCH_LOWERING, WINCH_RAISING:
			pin.stick = Vector2(0,0)
			xaccel *= 5
			yaccel *= 5
	
	accel_velocity(pin.stick.x, pin.stick.y, xaccel, yaccel)
	
	# gravitate towards cell-center
	var cellpos = maze.map_to_center(cell)
	var to_cellpos = cellpos - (position + velocity)
	accel_velocity(to_cellpos.x, to_cellpos.y,
		xaccel * (1-sqrt(abs(pin.stick.x))),
		yaccel * (1-sqrt(abs(pin.stick.y)))
	)
	
	# winch input
	match flyst.id:
		FLYING, FLYING_TURNING:
			if pin.a.pressed:
				flyst.goto(WINCH_LOWERING)
		WINCH_LOWERING:
			if pin.a.pressed: # press to cancel
				flyst.goto(WINCH_RAISING)
			else:
				winch_sublength += 1
				if winch_sublength >= 1:
					var ready_to_drop = 0
					var ready_to_pick = 0
					var ready_to_unlock = 0
					
					match carst.id:
						CARNONE:
							ready_to_pick = maze.get_cellv(celld(winch_length+1))
							match ready_to_pick:
								10,21,24:
									pass
								_:
									ready_to_drop = maze.get_cellvalue_flag(ready_to_pick) == 1
									ready_to_pick = 0
						CARBLOCK:
							if maze.get_cellvalue_flag(maze.get_cellv(celld(winch_length+2))) == 1:
								if maze.get_cellv(celld(winch_length+2)) == 25 and carrying_block_id == 24:
									ready_to_unlock = true
								else:
									ready_to_drop = true
					
					if ready_to_unlock:
						$unlock.play()
						flyst.goto(WINCH_RAISING)
						maze.set_cellv(celld(winch_length+2), 11)
						maze.set_cellv(celld(winch_length+1), 0)
						carrying_block_id = 0
						carst.goto(CARNONE)
					elif ready_to_drop:
						if carrying_block_id > 0:
							$drop.play()
							flyst.goto(WINCH_RAISING)
							maze.set_cellv(celld(winch_length+1), carrying_block_id)
							carst.goto(CARNONE)
						else:
							flyst.goto(WINCH_RAISING)
					elif ready_to_pick:
						$grab.play()
						flyst.goto(WINCH_RAISING)
						carrying_block_id = ready_to_pick
						carst.goto(CARBLOCK)
					elif winch_length < 5:
						maze.set_cellv(celld(winch_length), 4)
						winch_length += 1
						$chain.pitch_scale = 1.0 - 0.1 * winch_length
						$chain.play()
						winch_sublength -= 10
						# change tiles.
						maze.set_cellv(celld(winch_length), hookf())
						if carrying_block_id:
							maze.set_cellv(celld(winch_length+1), carrying_block_id)
					else: # max winch length reached
						flyst.goto(WINCH_RAISING)
		WINCH_RAISING:
			# no input will change this, i.e. you are locked into this mode
			winch_sublength -= 1
			if winch_sublength <= -1:
				if winch_length > 0:
					if carrying_block_id:
						maze.set_cellv(celld(winch_length), carrying_block_id)
						maze.set_cellv(celld(winch_length+1), 0)
					else:
						maze.set_cellv(celld(winch_length), 0)
					winch_length -= 1
					$chain.pitch_scale = 1.0 - 0.1 * winch_length
					$chain.play()
					winch_sublength += 10
					# change tiles.
					maze.set_cellv(celld(winch_length), hookf())
				else:
					# change tiles
					maze.set_cellv(celld(0), 0)
					if carst.id == CARBLOCK:
						maze.set_cellv(celld(1), 0)
					
					flyst.call_deferred('goto',FLYING) # done! now we can fly around carrying our block.
	
	# rendering the winch
	match flyst.id:
		WINCH_LOWERING, WINCH_RAISING:
			if winch_length == 0:
				spr.setup([1 if carst.id == CARNONE else 2])
			else:
				spr.setup([3])
	
	if pin.stick.x != 0 and flyst.id in [FLYING, FLYING_TURNING]:
		turnst.goto(sign(pin.stick.x))
	if flyst.id == FLYING_TURNING and not bufs.has(TURNBUF):
		flyst.goto(FLYING)
	process_slidey_move()

	if position.y > 130:
		levelmgr.goto_next_level()

func celld(y:int) -> Vector2: return cell + Vector2(0,y)
func hookf() -> int: return 5 if carst.id == CARNONE else 6
func takedamage():
	if flyst.id != KABOOMEY:
		damage += 1
		if damage < 5:
			$hurt1.pitch_scale = 1.0 - damage * 0.1
			$hurt1.play()
		else:
			$hurt2.play()
			flyst.goto(KABOOMEY)
