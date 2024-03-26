extends Node2D

var velocity : Vector2 = Vector2.DOWN

func setup(player):
	position = player.position + Vector2(randi()%2,1)
	velocity = Vector2.DOWN.rotated(rand_range(-0.4,0.4)) * rand_range(0.9, 1.0)

func _physics_process(_delta):
	position += (velocity + Vector2(rand_range(-0.5,0.5), rand_range(-0.5,0.5))) * 0.4
	velocity *= 0.99
	if velocity.length_squared()<0.1:
		queue_free()
