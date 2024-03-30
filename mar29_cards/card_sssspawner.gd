extends Node

onready var bank = $"../bank"

func _ready():
	call_deferred('spawn_cards')
func spawn_cards():
	for i in range(10):
		var card : RigidBody2D = bank.spawn("card(physical)", "cards", Vector2(rand_range(50,250),250))
#		var card : RigidBody2D = bank.spawn("card(physical)", "cards", Vector2(300,250))
		match i:
			0: card.rename("draw seven")
			1: card.rename("Hello World")
			2: card.rename("a card that does nothing")
			4: card.rename("ready for the next day")
			_: card.rename("-")
		card.rotation = rand_range(-.25,.25) * PI
		card.angular_velocity = -card.rotation * rand_range(30,50)
		card.linear_velocity = Vector2(rand_range(-50,50) + 2.0*(150-card.position.x), rand_range(-100,-50)-0.5*card.position.y)
		$deal.pitch_scale = 1.0 + 0.1 * i
		$deal.play()
		yield(get_tree().create_timer(0.25 - 0.002 * i * i),"timeout")
	
