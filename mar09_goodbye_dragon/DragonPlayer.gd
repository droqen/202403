extends NavdiMovingGuy


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var head : Node2D = $head
onready var headspr : SheetSprite = $head/SheetSprite
var head_velocity : Vector2

enum { HEAD_TURN_BUF, SQUASH_BUF, DUCK_BUF }
enum { HEAD, HEAD_TURN, HEAD_SQUASHED, HEAD_DUCKING }
enum { LEFT = -1, RIGHT = 1}
var hst : TinyState = TinyState.new(HEAD, self, "_on_hst_change", true)
var hfst : TinyState = TinyState.new(RIGHT, self, "_on_hfst_change", true)
func _on_hst_change(_then,now):
	headspr.position.y = 0
	match now:
		HEAD:
			headspr.setup([21,33],31)
		HEAD_TURN:
			headspr.setup([23])
		HEAD_SQUASHED:
			headspr.setup([25])
			headspr.position.y = -1
		HEAD_DUCKING:
			headspr.setup([24])
#	match then:
#		HEAD_SQUASHED:
#			velocity.x = hfst.id * -1
func _on_hfst_change(_then,now):
	match now:
		LEFT:
			headspr.flip_h = true
		RIGHT:
			headspr.flip_h = false
	if hst.id == HEAD:
		hst.goto(HEAD_TURN)
		bufs.on(HEAD_TURN_BUF)
enum { IDLE, WALK, AIR }
var bst : TinyState = TinyState.new(IDLE, self, "_on_bst_change", true)
func _on_bst_change(_then,now):
	match now:
		IDLE: spr.setup([20])
		WALK: spr.setup([30,20,32,20],8)
		AIR: spr.setup([32])

func _ready():
	bufs.defon(FLORBUF, 5)
	bufs.defon(JUMPBUF, 5)
	bufs.defon(HEAD_TURN_BUF, 10)
	bufs.defon(SQUASH_BUF, 5)
	bufs.defon(DUCK_BUF, 5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var pin = $Pin
	pin.process_pins()
	bufs.process_bufs()
	head_velocity.x += pin.stick.x * 0.1
	head_velocity.y += pin.stick.y * 0.05
	head.position += head_velocity
	head.position -= velocity * 0.1
	
	head.position.y = clamp(head.position.y, -8, 2)
	var hy_from_center = inverse_lerp(-3, 2, head.position.y)
	
	if hy_from_center > 0.5:
		bufs.on(DUCK_BUF)
	
	var xmaxreach = 8 - abs(hy_from_center) * 2
	head.position.x = clamp(head.position.x, -xmaxreach, xmaxreach)
	
	$headray.cast_to = head.position + Vector2(sign(head.position.x)*4, -3)
#	$headray.cast_to += $headray.cast_to.normalized() * 3.0 # push through!
	$headray.force_raycast_update()
	if $headray.get_collider(): # bonk.
		head.position.x *= 0.8
		head_velocity.x *= 0.4
		bufs.on(SQUASH_BUF)
	
	var hx_from_center_raw = inverse_lerp(0, 8, head.position.x)
	var hx_from_center = hx_from_center_raw
	if abs(hx_from_center) < 0.8:
		hx_from_center = 0.0
	elif hx_from_center > 0.8:
		hx_from_center = (hx_from_center - 0.8) * 5
	else:
		hx_from_center = (hx_from_center + 0.8) * 5
	
	var velx_speed = 0.20
	if bufs.has(DUCK_BUF): velx_speed = 0.10
	head_velocity.x *= 0.5
	head_velocity.x = lerp(head_velocity.x + pin.stick.x * velx_speed, -hx_from_center, 0.1)
	if hy_from_center < 0:
		head_velocity.y = lerp(head_velocity.y + pin.stick.y * 0.10, -hy_from_center * 1.0, 0.1)
	else:
		head_velocity.y = lerp(head_velocity.y + pin.stick.y * 0.10, -hy_from_center * 2.0, 0.1)
	
	if pin.stick.x != 0:
		hfst.goto(LEFT if pin.stick.x < 0 else RIGHT)
	
	if pin.a.pressed:
		bufs.on(JUMPBUF)
	
	if bufs.try_consume([JUMPBUF,FLORBUF]):
		bst.goto(AIR)
		velocity.y = -1.6
	
	if hst.id == HEAD_TURN:
		if not bufs.has(HEAD_TURN_BUF):
			hst.goto(HEAD)
	else:
		if bufs.has(SQUASH_BUF): hst.goto(HEAD_SQUASHED)
		elif bufs.has(DUCK_BUF): hst.goto(HEAD_DUCKING)
		else: hst.goto(HEAD)

	if abs(hx_from_center_raw) < 0.25:
		hx_from_center_raw = 0

	accel_velocity(hx_from_center_raw * abs(pin.stick.x) * 0.75, 2.00, 0.1, 0.1)
	
	if head.position.x != 0:
		spr.flip_h = head.position.x < 0
	
	process_slidey_move()
	
	if bufs.has(FLORBUF):
		if pin.stick.x:
			bst.goto(WALK)
		else:
			bst.goto(IDLE)
	else:
		bst.goto(AIR)
