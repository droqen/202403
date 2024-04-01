extends KinematicBody2D
class_name NavdiJumper

# copy these to the owner?
export(float) var X_MAX = 100.0
export(float) var X_ACCEL = 10.0
export(float) var Y_JUMP = 150.0
export(float) var Y_GRAV = 3.0
export(float) var Y_FASTGRAV = 6.0
export(float) var Y_MAXFALL = 150.0

export(Array) var X_ACTIONS = ["left", "right"]

export(String) var JUMP_ACTION = "jump"

export(Array) var JUST_PRESSED_ACTIONS = [JUMP_ACTION]

export(int) var DEFAULT_BUFFER_DUR = 4
export(Dictionary) var CUSTOM_BUFFER_DUR = {'floor': 6}

onready var spriter: NavdiBitsySprite = get_node("NavdiSheetSprite")

var _buffers = {}

var grounded = false

var velocity: Vector2 = Vector2()

func set_buf(buf):
	if CUSTOM_BUFFER_DUR.has(buf):
		_buffers[buf] = CUSTOM_BUFFER_DUR[buf]
	else:
		_buffers[buf] = DEFAULT_BUFFER_DUR
		
func clear_buf(buf):
	_buffers[buf] = 0
	
func is_buf(buf):
	return _buffers[buf] > 0
	
func check_bufs(bufs, clearOnTrue = true):
	for buf in bufs:
		if _buffers[buf] <= 0:
			return false
	if clearOnTrue:
		for buf in bufs:
			clear_buf(buf)
	return true

func _tow(a, b, rate):
	if a + rate < b:
		return a + rate
	if a - rate > b:
		return a - rate
	return b
	
func _ready():
	
	# clear all intended buffers
	
	clear_buf('floor')
	for action in JUST_PRESSED_ACTIONS:
		clear_buf(action)
	
func _process(_delta):
	for action in JUST_PRESSED_ACTIONS:
		if Input.is_action_just_pressed(action):
			set_buf(action)

func _physics_process(_delta):
	update_groundedness()
	check_buffer_actions() # e.g. jumping, shooting.
	reduce_buffers()
	apply_gravity()
	apply_x_control()
	update_flip_h(get_pinx())
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	# set buffers (if necessary)
	if is_on_floor():
		grounded = true
		set_buf('floor')
	else:
		grounded = false
		
########################################################################
		
func update_flip_h(dx, sensitivity = 0.5):
	if abs(dx) >= sensitivity:
		spriter.flip_h = dx < 0
		
func perform_jump_action(): # called in 'check_buffer_actions'
	grounded = false
	velocity.y = -Y_JUMP
	
func update_groundedness():
	if is_on_floor() and velocity.y >= 0:
		grounded = true
		velocity.y = 0
		set_buf('floor')
	
func get_pinx():
	var pinx = 0
	if Input.is_action_pressed(X_ACTIONS[0]):
		pinx -= 1
	if Input.is_action_pressed(X_ACTIONS[1]):
		pinx += 1
	return pinx
	
func apply_gravity():
	if not grounded:
		if velocity.y < 0 and not Input.is_action_pressed(JUMP_ACTION):
			velocity.y += Y_FASTGRAV
		else:
			velocity.y += Y_GRAV
			
func apply_x_control():
	var pinx = get_pinx()
	velocity.x = _tow(velocity.x, X_MAX * pinx, X_ACCEL)
	
func modify_accel(accel, pinx, passive_friction_mult = 1, active_friction_mult = 1, ungrounded_mult = 1):
	# apply accel modifiers? unused, but good template
	if pinx == 0 and passive_friction_mult != 1:
		accel *= passive_friction_mult # if player has no input, apply passive friction
	if pinx * velocity.x < 0 and active_friction_mult != 1:
		accel *= active_friction_mult # if player has opposite input, apply active friction
	if not grounded and ungrounded_mult != 1:
		accel *= ungrounded_mult # if player is in the air, apply ungrounded
		
	return accel

func check_buffer_actions():
#	print(_buffers['floor'], _buffers['jump'])
	if check_bufs(['floor', 'jump']):
		perform_jump_action()
		
func reduce_buffers():
	for action in _buffers.keys():
		if _buffers[action] > 0:
			_buffers[action] -= 1
