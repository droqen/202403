extends Node2D

export var target_ball = "../doink_ball"
onready var ball = get_node(target_ball)
onready var spr = $SheetSprite
onready var mitt = $mitt

var _last_dir2ball : Vector2 = Vector2.ZERO
var _blp_memory : int = 0

func _physics_process(_delta):
	if not is_instance_valid(ball): return
	
	var dir2ball = ball.position - position
	var dist2ball = dir2ball.length()
	
	if dist2ball > 50:
		if _blp_memory > 0:
			_blp_memory -= 1
		else:
			_last_dir2ball = Vector2.ZERO
		dir2ball = _last_dir2ball
		dist2ball = dir2ball.length()
	else:
		_last_dir2ball = dir2ball
		_blp_memory = 100 + randi() % 400
	
	if dist2ball > 2.5:
		if dir2ball.x != 0:
			spr.flip_h = dir2ball.x < 0
		var vang2ball = dir2ball.angle_to(Vector2.UP)
		if abs(vang2ball) < 1:
			spr.setup([3])
		elif abs(vang2ball) < 1.5:
			spr.setup([2])
		elif abs(vang2ball) < 2.5:
			spr.setup([1])
		else:
			spr.setup([0]) # looking down
	else:
		spr.setup([4])

	for ball in mitt.get_overlapping_bodies():
		if ball.is_catchable():
			ball.linear_velocity *= 0.8
			if ball.linear_velocity.y > 10:
				ball.linear_velocity.y *= 0.8 # more strongly slow real fast falling so it dont hit da floor
			var ball_to_mitt = position + Vector2(0,0) - ball.position
			ball.linear_velocity += ball_to_mitt
			if ball.linear_velocity.length_squared() < 100:
				ball.caught()
