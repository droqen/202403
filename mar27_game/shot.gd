extends Area2D

var velocity
var invinc : int = 10

func shoot_to(b):
	velocity = (b-position).normalized()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	position += velocity
	if invinc > 0:
		invinc -= 1
	else:
		var hit_solid = false
		var hit_player = null
		for a in get_overlapping_areas():
			if a.name == "body_area": hit_player = a.get_parent()
			else: hit_solid = true
		for b in get_overlapping_bodies():
			hit_solid = true
		if hit_solid or hit_player:
			queue_free() # pop!
			if hit_player: hit_player.takedamage()
