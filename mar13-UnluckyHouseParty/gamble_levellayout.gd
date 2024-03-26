extends Node

onready var maze = $"../../NavdiFlagMazeMaster"

var lucky
var accepted : bool

func _ready():
	randomize()
	gen_pillars()
func roll(_lucky):
	lucky = _lucky
func get_outcome_message() -> String:
	if not lucky:
		return ""
	elif lucky.jump_height < 5:
		accepted = false
		return "not enouf 'j' im afraid"
	elif lucky.hov_length < 5:
		accepted = false
		return "not enouf 'h' im afraid"
	else:
		accepted = true
		return "job's done.\ngo take a look."
func apply_outcome():
	if lucky and accepted:
		lucky.jump_height -= 5
		lucky.hov_length -= 5
		gen_pillars()
		lucky = null

var _last_first_pillarx = -1
var _last_first_pillarheight = -1

func gen_pillars():
	
	var pillarchance = 0.33
	for x in range(64-3,83):
		if x >= 64 and randf() < pillarchance:
			pillarchance *= 0.33
			var pillarheight = max(randi() % 3, randi() % 7)
			if randf() < 0.1:
				pillarheight += randi() % 4
			for y in range(22):
				maze.set_cell(x,y,-1)
				if 19-y == pillarheight: maze.set_cell(x,y,20)
				if 19-y < pillarheight: maze.set_cell(x,y,21)
		else:
			pillarchance += 0.33
			for y in range(22):
				maze.set_cell(x,y,-1)
			maze.set_cell(x,19,(22)) # floor.
	
	var pillarx = _last_first_pillarx
	var pillarheight = _last_first_pillarheight
	while(pillarx == _last_first_pillarx and pillarheight == _last_first_pillarheight):
		pillarx = 61 + randi() % 2
		pillarheight = 1 + randi() % 3
	_last_first_pillarx = pillarx
	_last_first_pillarheight = pillarheight
	for y in range(22):
		maze.set_cell(pillarx,y,-1)
		if 19-y == pillarheight: maze.set_cell(pillarx,y,20)
		if 19-y < pillarheight: maze.set_cell(pillarx,y,21)
		
