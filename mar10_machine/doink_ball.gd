extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var pin = $Pin
onready var cam = $"../doink_cam"

var endgame : bool = false
var bounces : int = 1
enum {INVINCBUF, CAUGHTBUF, RECENTLYTHROWNBUF, NOCONTROLBUF}
var bufs : Bufs = Bufs.new([[INVINCBUF,5],[CAUGHTBUF,4],[RECENTLYTHROWNBUF,12],[NOCONTROLBUF,100]])
onready var curs = $throw_cursor

# Called when the node enters the scene tree for the first time.
func _ready():
	# debug
#	position = Vector2(815,100)
#	if cam.position.x == 0:
#		cam.position.x = 815 - 115
		
	inertia = 999
	angular_damp = 999
	curs.position = Vector2.ZERO
	curs.hide()
	bufs.on(NOCONTROLBUF)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pin.process_pins()
	bufs.process_bufs()
	var accel = pin.stick
	rotation = 0
	angular_velocity = 0
	if curs.visible:
		bufs.clr(NOCONTROLBUF)
		curs.position *= 0.95
		if pin.stick.x != 0 and pin.stick.y == 0:
			pin.stick.y = -0.1
		curs.position += (pin.stick*2).clamped(1.0) * 0.65
		var curslen : float = curs.position.length()
		var dots : int = curs.get_child_count()
		var visdots : int = min(dots,floor(curslen / 3))
		for i in range(visdots):
			curs.get_child(i).position = -curs.position * i / visdots
			curs.get_child(i).show()
		for i in range(visdots,dots):
			curs.get_child(i).hide()
		if pin.a.pressed and visdots > 0:
			throw()
		if visdots > 0:
			if not $charge.playing:
				$charge.play()
				$charge.pitch_scale = 1.0 + visdots * 0.4
	else:
		if bufs.has(NOCONTROLBUF):
			pin.clear()
#		if pin.stick.x * linear_velocity.x > 5:
#			pin.stick.x *= 0.5
		if pin.stick.y < 0: pin.stick.y *= 0.65
	linear_velocity += pin.stick

func _on_doink_ball_body_entered(body):
	if bufs.has(INVINCBUF): return
	bufs.on(INVINCBUF)
	bounces -= 1
	if bounces < 0:
		call_deferred('ball_explode')
	else:
		$bounce.play()
		match bounces:
			0:
				$SheetSprite.setup([21,20],4)
			1:
				$SheetSprite.setup([20])
		if linear_velocity.y < 0 and linear_velocity.y > -10:
			linear_velocity.y = -10

func is_catchable() -> bool:
	return not bufs.has(RECENTLYTHROWNBUF)
func caught():
	if not is_catchable(): return
	bounces = 1
	$SheetSprite.setup([20])
	bufs.on(CAUGHTBUF)
	if not curs.visible:
		curs.position = Vector2.ZERO
		curs.show()
		$catch.play()
func throw():
	linear_velocity = curs.position.normalized() * (40.0 + curs.position.length() * 5.0)
	curs.position = Vector2.ZERO
	curs.hide()
	var dots : int = curs.get_child_count()
	for i in range(dots):
		curs.get_child(i).hide()
	bufs.on(RECENTLYTHROWNBUF)
	$toss.pitch_scale = 1.0 + randf() * 0.2 + 0.8
	$toss.pitch_scale -= linear_velocity.y / 100.0
	$toss.play()

func ball_explode():
##	$break.play()
#	$break2.play()
#	$break3.play()
	
	if endgame:
		if visible:
			sad_break_plays()
			$"../bank".spawn("ballcorpse", -1, position)
			hide()
		return
	
	sad_break_plays()
	$"../bank".spawn("ballcorpse", -1, position)
	var parent = get_parent()
	
	parent.remove_child(self)
	bounces = 1
	$SheetSprite.setup([20])
	position = Vector2(15,-2)
	
	linear_velocity = Vector2(0,0)
	parent.add_child(self)
	bufs.on(NOCONTROLBUF)

func sad_break_plays():
	$break.pitch_scale = 1.0
	$break.play()
	$break2.pitch_scale = 1.1
	$break2.play()
	for i in range(3):
		yield(get_tree().create_timer(0.05 * randf()), "timeout")
		$break.pitch_scale -= 0.05 + 0.1 * randf()
		$break.play()
		yield(get_tree().create_timer(0.05 * randf()), "timeout")
		$break2.pitch_scale -= 0.05 + 0.1 * randf()
		$break2.play()
