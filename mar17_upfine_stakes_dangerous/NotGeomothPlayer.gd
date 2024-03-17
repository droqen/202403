extends NavdiMovingGuy

onready var maze = $"../maze"

enum {WALK=101,AIR,TURN,HURT}

enum {TURNBUF=12941284, JETPUFFBUF, HURTSTUNBUF, INVINCBUF}

func _ready():
	bufs = Bufs.new([ [JUMPBUF,4], [FLORBUF,4], [TURNBUF,4] ])

var fuelmax : int = 160
var fuel : int = fuelmax

var hunger : int = 5000

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	hunger -= 1
	$HungerLabel.text = "%02d" % (hunger/50)
	pin.process_pins()
	bufs.process_bufs()
	if bufs.has(HURTSTUNBUF):
		pin.clear()
	elif pin.a.held and fuel > 0:
		accel_velocity(pin.stick.x * 1.0, -0.7, 0.1, 0.01 if velocity.y < -0.7 else 0.07)
		fuel -= 1
	else:
		accel_velocity(pin.stick.x * 0.8, 2.5, 0.1, 0.07)
	if pin.stick.x: facingst.goto(sign(pin.stick.x))
	if pin.a.pressed: bufs.on(JUMPBUF)
	process_slidey_move()
	if bufs.has(FLORBUF): fuel = fuelmax
	if bufs.try_consume([JUMPBUF,FLORBUF]):
		velocity.y = -1.5
		bufs.setmin(JETPUFFBUF, 10)
	
	proc_jetting()
	proc_pickupdrop()
	
	if not bufs.has(INVINCBUF):
		if $HurtArea.get_overlapping_bodies():
			movingst.goto(HURT) # owch
	
	match bufs.read(INVINCBUF) % 6:
		0,1,2: spr.show()
		3,4,5: spr.hide()
	
	if bufs.has(HURTSTUNBUF): movingst.goto(HURT)
	elif bufs.has(TURNBUF): movingst.goto(TURN)
	elif not bufs.has(FLORBUF): movingst.goto(AIR)
	elif pin.stick.x: movingst.goto(WALK)
	else: movingst.goto(IDLE)

func _on_movingst_change(_then,now):
	match now:
		IDLE:
			spr.setup([20])
		WALK:
			spr.setup([21,20,22,20], 7)
		AIR:
			spr.setup([23])
		TURN:
			spr.setup([24])
		HURT:
			spr.setup([25])
			bufs.setmin(HURTSTUNBUF,20)
			bufs.setmin(INVINCBUF,40)
			velocity.x = -facingst.id
			velocity.y = -0.5
			if $carrying.visible:
				$"../bank".spawn("droppedcarry",-1,position + Vector2.UP * 4)
				$carrying.hide()
func _on_facingst_change(_then,now):
	spr.flip_h = now < 0
	bufs.on(TURNBUF)

func proc_jetting():
	if not bufs.has(FLORBUF) and pin.a.held and not bufs.has(JETPUFFBUF) and fuel > 0:
		if fuel > fuelmax * 0.80: bufs.setmin(JETPUFFBUF, 0)
		elif fuel > fuelmax * 0.6: bufs.setmin(JETPUFFBUF, 1)
		elif fuel > fuelmax * 0.5: bufs.setmin(JETPUFFBUF, 2)
		elif fuel > fuelmax * 0.4: bufs.setmin(JETPUFFBUF, 4)
		elif fuel > fuelmax * 0.3: bufs.setmin(JETPUFFBUF, 6)
		elif fuel > fuelmax * 0.2: bufs.setmin(JETPUFFBUF, 8)
		else: bufs.setmin(JETPUFFBUF, 10)
		var dx = 0
		var dy = 5
		if not bufs.has(TURNBUF):
			dx = -facingst.id * 1
			dy = 3
		dx += randi() % 3 - 1
		dy += randi() % 3
		$"../bank".spawn("smokepuff", -1, position + Vector2(dx,dy))

var _lastcell = null

func proc_pickupdrop():
	var curcell = maze.world_to_map(position)
	if curcell != _lastcell:
		_lastcell = curcell
		match maze.get_cellv(curcell):
			40:
				if not $carrying.visible:
					maze.set_cellv(curcell, 41)
					$carrying.show()
			41:
				if $carrying.visible:
					maze.set_cellv(curcell, 40)
					$carrying.hide()
