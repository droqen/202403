extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const MINX = 19
const MAXX = 38
const TOPY = -60
const BOTTOMY = 18
# Called when the node enters the scene tree for the first time.
func _ready():
	seed(1)
	# randomize() # no randomize
	makemountain()
	
func makemountain():
	var maze = $"../NavdiFlagMazeMaster"
	for y in range(BOTTOMY, TOPY-1, -1):
		var minx = MINX
		var maxx = MAXX+1
		if y >= 10:
			maxx -= (y-10)*2
		if y >= 0:
			minx += 2
		if y >= 10:
			minx += 2
		for x in range(minx,maxx):
			var wallchance = 0.10
			if int(x) % 2 == 0: wallchance *= 3
			if int(y) % 2 == (int(x)/4) % 2: wallchance *= 3
			
			if x < maxx - 5: wallchance *= 0.5
			if x < maxx - 10: wallchance *= 0.5
			if x < maxx - 15: wallchance *= 0.75
			if randf() < wallchance:
				maze.set_cell(x, y, 20)
			else:
				maze.set_cell(x, y, -1)
