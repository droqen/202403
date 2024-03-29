extends Node

onready var maze = $"../levelmgr/maze"
onready var bank = $"../bank"
onready var player = $"../ship"
onready var r = $RayCast2D

var to_next_shot : int = 0

func _physics_process(_delta):
	if not is_instance_valid(maze):
		maze = $"../levelmgr/maze"
	if to_next_shot > 0:
		to_next_shot -= 1
	else:
		to_next_shot = 40
		var shots_taken = 0
		for cell in maze.get_used_cells_by_id(21):
			if randf()<0.85:
				var a = maze.map_to_center(cell)
				var b = player.position
				r.position = a
				r.cast_to = b-a
				var castdir = r.cast_to.normalized()
				var castlength = r.cast_to.length()
				if castlength > 10:
					r.position += castdir * 10
					r.cast_to -= castdir * 10
					r.force_raycast_update()
					if r.get_collider():
						b = null
				if b:
					bank.spawn("shot",-1,a).shoot_to(b)
					shots_taken += 1
		
		if shots_taken >= 1:
			var pews = [$pew, $pew2]
#			pews.shuffle()
			for i in range(min(shots_taken,2)):
				pews[i].play()
				yield(get_tree().create_timer(rand_range(0.05,0.07)), "timeout")
				
