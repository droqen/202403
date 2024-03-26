extends Camera2D

var velocity_x : float = 0
var velocity_y : float = 0
onready var ball = get_node("../doink_ball")
export var screen_width : int = 230
export var screen_height : int = 130

func _ready():
	$end.hide()

func _physics_process(_delta):
	if is_instance_valid(ball) and ball.position.y < 800 and position.y < 521:
		var target_x = max(0, ball.position.x - screen_width/2)
		var target_y = 0
		if abs(ball.position.x-815)<5:
#			target_x = 815 - screen_width/2
			if ball.position.y > screen_height - 20:
				target_y = ball.position.y - screen_height/2
		elif position.y > 0:
			target_y = 0.0
			
		if position.x + velocity_x > target_x:
			velocity_x -= 0.1
		if position.x + velocity_x < target_x:
			velocity_x += 0.1
		if position.y + velocity_y * velocity_y * 0.1 > target_y:
			velocity_y -= 0.1
		if position.y + velocity_y * velocity_y * 0.1 < target_y:
			velocity_y += 0.1
		velocity_x = clamp(velocity_x,-1,1)
	#	velocity_y = clamp(velocity_y,-1,1) # unclamped
		position.x += velocity_x
		position.y += velocity_y
		if position.y < 0:
			position.y = 0
			velocity_y = 0
		if position.y > 0:
			ball.bounces = 2
		if abs(position.x - target_x) < 1:
			position.x = target_x
			velocity_x = 0
	else:
		position.x = 815 - screen_width/2
		if is_instance_valid(ball):
			var target_y = ball.position.y - screen_height/2
			if position.y + velocity_y * velocity_y * 0.1 > target_y:
				velocity_y -= 0.1
			if position.y + velocity_y * velocity_y * 0.1 < target_y:
				velocity_y += 0.1
		position.y += velocity_y
		ball.endgame = true
		play_an_end()
		if $thm.pitch_scale > 0.01:
			$thm.pitch_scale -= 0.01
		else:
			$thm.stop()

func play_an_end():
	if not $end.visible:
		$end.show()
		for x in [
			[ 0.66, 0.0, 0.15 ],
			[ 0.80, 0.0, 0.19 ],
			[ 0.59, 0.0, 1.00 ],
			
			[ 0.65, 0.0, 0.20 ],
			[ 0.75, 0.0, 0.16 ],
			[ 0.52, 0.0, 0.17 ],
			[ 0.51, 0.0, 1.00 ],
		]:
			$thm.pitch_scale = x[0]
			$thm.volume_db = x[1]
			$thm.play()
			yield(get_tree().create_timer(x[2]), "timeout")
		ball.call_deferred('ball_explode')
