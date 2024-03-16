extends NavdiMovingGuy

enum {WALK=101,AIR,TURN}

enum {TURNBUF=12941284, JETPUFFBUF}

func _ready():
	bufs = Bufs.new([ [JUMPBUF,4], [FLORBUF,4], [TURNBUF,4] ])

var fuelmax : int = 160
var fuel : int = fuelmax

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pin.process_pins()
	bufs.process_bufs()
	if pin.a.held and fuel > 0:
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
		
	if bufs.has(TURNBUF): movingst.goto(TURN)
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
func _on_facingst_change(_then,now):
	spr.flip_h = now < 0
	bufs.on(TURNBUF)

