extends Node

onready var maze = get_parent()

onready var mus1 = $"../../mus1"
onready var mus2 = $"../../mus2"

onready var beatlength1 = mus1.stream.get_length() / (6*4)
onready var beatlength2 = mus2.stream.get_length() / (6*4)

onready var beatid1 = 1
onready var beatid2 = 1

onready var nextbeat1 = beatlength1
onready var nextbeat2 = beatlength2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var muspos1 = mus1.get_playback_position()
	if muspos1 >= nextbeat1:
		nextbeat1 += beatlength1
		beatid1 += 1
		beat(1, beatid1)
	elif nextbeat1 > beatlength1 and muspos1 < beatlength1:
		nextbeat1 = beatlength1
		beatid1 = 0
		beat(1, beatid1)
		
	var muspos2 = mus2.get_playback_position()
	if muspos2 >= nextbeat2:
		nextbeat2 += beatlength2
		beatid2 += 1
		beat(2, beatid2)
	elif nextbeat2 > beatlength2 and muspos2 < beatlength1:
		nextbeat2 = beatlength2
		beatid2 = 0
		beat(2, beatid2)

func beat(trackid:int, beatid:int):
	var ox = randi() % 17
	var oy = randi() % 17
	for _repeat in range(2):
		for dx in range(-trackid,trackid+1):
			for dy in range(-trackid,trackid+1):
				if randf() < 0.85:
					var x = ox + dx
					var y = oy + dy
					var v = maze.get_cell(x, y)
					var v2 = v
					match [v, trackid]:
						[ 50, 1 ]: v2 = 40
						[ 40, 1 ]: v2 = 30
						[ 30, 1 ]: v2 = 20
						[ 20, 1 ]: v2 = 10
						[ 10, 1 ]: v2 = 40
						[ 40, 2 ]: v2 = 40
						[ 30, 2 ]: v2 = 40
						[ 20, 2 ]: v2 = 30
						[ 10, 2 ]: v2 = 20
					maze.set_cell(x, y, v2)
		yield(get_tree().create_timer(0.5 * (beatlength1 if trackid == 1 else beatlength2)), "timeout")
