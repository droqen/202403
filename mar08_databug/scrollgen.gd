extends Node

onready var camera = $"../Camera2D"
onready var player = $"../player_buggy"
onready var maze = $"../NavdiFlagMazeMaster"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var camy : float = 0
var lowest_generated_ycell : int = 21

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
#	camy = lerp(camy, player.position.y - 45, 0.05)
	var target_camy = player.position.y - 55
	var to_target_camy = target_camy - camy
	camy += clamp(to_target_camy * 0.02, -0.5, 0.5)
	var camybot = camy + 210
	camera.position.y = floor(camy / 2) * 2
	var camycell = maze.world_to_map(Vector2(0, camybot)).y
	while camycell > lowest_generated_ycell:
		gen_next_ycell_row()

func gen_next_ycell_row():
	var y : int = lowest_generated_ycell + 1
	maze.set_cell(-1, y, 20)
	for x in range(10):
		maze.set_cell(x, y, draw_random_cell_value(y))
	maze.set_cell(10, y, 20, true)
	lowest_generated_ycell = y

const DECK = [
#	-1,-1, # empty
	11,11, # plain block
	22,22, # jump block - can kill you
	21, # pink block - unknown function
	31, # mysterizing block
]

const HARD_DECK = [
	11,11, # plain block
	22,22,22, # jump block - can kill you
	21,21,21, # pink block - unknown function
	31, # mysterizing block
]

const emptydeck = [
	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,23,23,23,2,3,4,
]

const empty_hard_deck = [
	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,23,23,23,23,23,2,3,4,2,3,4,
]

static func draw_random_cell_value(y:int) -> int:
	if y > randi() % 1000:
		if randf() < (0.65 if y%2==0 else 0.35):
			return empty_hard_deck[randi()%len(empty_hard_deck)]
		else:
			return HARD_DECK[randi()%len(HARD_DECK)]
	else:
		if randf() < (0.65 if y%2==0 else 0.35):
			return emptydeck[randi()%len(emptydeck)]
		else:
			return DECK[randi()%len(DECK)]
	
