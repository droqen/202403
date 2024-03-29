extends Node2D

var _levelid : int = 0

const LEVELPATHS = [
	"res://level0.tscn",
	"res://level1.tscn",
	"res://level2.tscn",
	"res://level3.tscn",
	"res://level4.tscn",
]

onready var player = $"../ship"

func _ready():
	goto_level(0)

func goto_level(levelid : int) :
	_levelid = levelid
	$startcamera.position.y = -130
	$startcamera.start()
	for child in get_children():
		if child is Camera2D: pass
		else:
			child.queue_free()
			remove_child(child)
	var maze = load(LEVELPATHS[_levelid]).instance()
#	maze.owner = owner if owner else self
	add_child(maze)
func goto_next_level():
	goto_level(_levelid+1)
	player.start() # resets player
func goto_restart():
	goto_level(0)
	player.start() # resets player
