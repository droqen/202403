extends NavdiMovingGuy

enum { WALK=101, CHATTER=102, ZAPPED }
enum { ZAPBUF=48888 }

onready var mvst = TinyState.new(IDLE,self,"_on_mvst_change")
onready var ccur = $"../../curious_cursor"
onready var talk = $"../../talk"
onready var talk_mtc = $"../../talk/Control/VBoxContainer/MarchingTextContainer"

var target = null

var chatterindex = 0

func _ready():
	talk.hide()
	bufs.defon(ZAPBUF, 30)

func _on_mvst_change(then,now):
	match then:
		CHATTER:
			$tdone2.play()
			talk_mtc.set_position_start()
			talk_mtc.pause()
			talk.hide()
	match now:
		IDLE:
			spr.setup([5,5,5,5,6,7,8,9], 9)
		WALK:
			spr.setup([15,5,16,5], 8)
		CHATTER:
			spr.setup([5,5,5,5,6,7,8,9], 9)
			talk.position = position
			talk_mtc.setup("(test)")
			talk.show()
			chatterindex = 0
		ZAPPED:
			$hurt.play()
			spr.setup([39,49], 13)
			bufs.on(ZAPBUF)

func _physics_process(_delta):
	pin.process_pins()
	bufs.process_bufs()
	if mvst.id == ZAPPED:
		position += velocity * -0.5
		if not bufs.has(ZAPBUF) or pin.a.pressed:
			position.x = floor(position.x / 200.0) * 200.0 + 5.0
			velocity.x = 0.0
			mvst.goto(IDLE)
	elif mvst.id == CHATTER:
		velocity = Vector2.ZERO
		if pin.a.pressed:
			if talk_mtc.is_done():
				if chatterindex == 0 and target.monologue2:
					chatterindex = 1
					talk_mtc.setup(target.monologue2)
				else:
					mvst.goto(IDLE)
			else:
				talk_mtc.set_position_end()
	else:
		velocity += (pin.stick.limit_length(1.0) * 1.0 - velocity).limit_length(0.1)
		process_slidey_move()
		if pin.stick:
			mvst.goto(WALK)
		else:
			mvst.goto(IDLE)
	
		var possible_targets = $curious_zone.get_overlapping_areas()
		if target == null:
			if len(possible_targets):
				target = possible_targets[0]
				$curious.play()
				ccur.global_position = target.global_position
				if global_position.x > target.global_position.x:
					ccur.global_position.x = target.global_position.x + 1
				else:
					ccur.global_position.x = target.global_position.x
				ccur.show()
		else:
			if not target in possible_targets:
				target = null
				ccur.hide()
			elif pin.a.pressed:
				mvst.goto(CHATTER)
				talk_mtc.setup(target.monologue)
			
#		if pin.b.pressed: # debug button
#			mvst.goto(ZAPPED)
				
