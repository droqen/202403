extends Node2D

onready var bank = $"../bank"
onready var maze = $"../maze"
var wait : int = 100

func _physics_process(_delta):
	if wait > 0:
		wait -= 1
	else:
		wait = 100
		for cell in maze.get_used_cells_by_id(20):
			bank.spawn("fireball", "fireballs", maze.map_to_center(cell) + Vector2(-10, 4))
		for cell in maze.get_used_cells_by_id(21):
			bank.spawn("fireball", "fireballs", maze.map_to_center(cell) + Vector2(10, 4)).flip()
