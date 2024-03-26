extends Node

onready var camera = $"../Camera2D"
onready var player = $"../player_buggy"
onready var maze = $"../NavdiFlagMazeMaster"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var camy : float = 0
var lowest_generated_ycell : int = 21

var current_chunk_height : int = 0
var current_chunk_through : int = 0

var current_chunk_block_density : float = 0.65
var current_chunk_block_deck : Array = [11]
var current_chunk_coin_density : float = 0.5
var current_chunk_coin_deck : Array = [23]

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

func regen_chunk():
	current_chunk_height = 4 + randi() % 8 # chunk height is random
	current_chunk_through = 0
	clrdeck()
	current_chunk_block_density = 0.55
	current_chunk_coin_density = 0.27
	var difficulty : int = 1 + randi() % 2
	if lowest_generated_ycell > 10 + randi() % 40: difficulty += 1
	if lowest_generated_ycell > 60 + randi() % 80: difficulty += 1
	if lowest_generated_ycell > randi() % 500: difficulty += 1
	match difficulty:
		0, 1:
			current_chunk_height = 2 + randi() % 5 # easy small chunks
			current_chunk_block_density = 0.1 * rand_range(0.35,0.50) # significantly reduced block density
			current_chunk_coin_density = 0.02
			addblock(Block.Plain, 5)
			addblock(Block.Kill, 2)
			addblock(Block.Jump, 3)
			if randf()<0.1: addblock(Block.Danger, 1)
			addcoin(Coin.Point, 5)
			addcoin(Coin.Curse3, 1)
			addcoin(Coin.Curse4, 1)
		2:
			current_chunk_block_density = rand_range(0.52,0.65) # slightly reduced block density
			current_chunk_coin_density = 0.12
			addblock(Block.Plain, 3)
			addblock(Block.Kill, 3)
			addblock(Block.Jump, 3)
			if randf()<0.1: addblock(Block.Danger, 1)
			if randf()<0.5: addblock(Block.Scramble, 1)
			if randf()<0.1: addblock(Block.Grey2 + randi() % 3, 2)
			addcoin(Coin.Point, 2)
			addcoin(Coin.Curse2 + randi() % 3, 1)
			addcoin(Coin.Curse2 + randi() % 3, 1)
		3:
			addblock(Block.Plain, 2)
			addblock(Block.Kill, 4)
			addblock(Block.Jump, 3)
			if randf()<0.35: addblock(Block.Danger, 2)
			if randf()<0.75: addblock(Block.Scramble, 1)
			addblock(Block.Grey2 + randi() % 3, 1 + randi() % 2)
			addcoin(Coin.Point, 3)
			addcoin(Coin.Curse2, 1)
			addcoin(Coin.Curse2 + randi() % 3, 1)
			addcoin(Coin.Curse4, 2)
		4, _: # hyper rare
			current_chunk_height = 2 + randi() % 20 # could be extremely large or very tiny
			current_chunk_coin_density = 0.45 # many more coins
			addblock(Block.Plain, 1)
			if randf()<0.15: addblock(Block.Plain, 5)
			if randf()<0.35: addblock(Block.Kill, 5)
			if randf()<0.65: addblock(Block.Scramble, 2)
			if randf()<0.85: addblock(Block.Danger, 2)
			addblock(Block.Grey2, 1)
			addblock(Block.Green3, 1)
			addblock(Block.Yellow4, 1)
			if randf()<0.05: addblock(Block.Grey2, 2)
			if randf()<0.05: addblock(Block.Green3, 2)
			if randf()<0.05: addblock(Block.Yellow4, 2)
			addcoin(Coin.Point, 1)
			addcoin(Coin.Curse2, 1)
			addcoin(Coin.Curse3, 1)
			addcoin(Coin.Curse4, 1)

func gen_next_ycell_row():
	if current_chunk_through >= current_chunk_height:
		regen_chunk()
	current_chunk_through += 1
	
	var y : int = lowest_generated_ycell + 1
	maze.set_cell(-1, y, 20)
	for x in range(10):
		maze.set_cell(x, y, draw_random_cell_value(y))
	for x in range(10):
		maze.set_cell(x, y-30, -1) # clear 30 rows up
	maze.set_cell(10, y, 20, true)
	lowest_generated_ycell = y

enum Block {
	Plain = 11,
	Kill = 21, Jump = 22, 
	Scramble = 31, Danger = 32, HealBug = 33,
	Grey2 = 41, Green3 = 42, Yellow4 = 43,
}

enum Coin {
	Point = 23,
	Curse2 = 2, Curse3 = 3, Curse4 = 4,
}

func clrdeck():
	current_chunk_block_deck = [11]
	current_chunk_coin_deck = [23]
func addblock(block_int:int, count:int):
	for i in range(count): current_chunk_block_deck.append(block_int)
func addcoin(coin_int:int, count:int):
	for i in range(count): current_chunk_coin_deck.append(coin_int)

func draw_random_cell_value(y) -> int:
	if randf() < current_chunk_block_density * (0.54 if y%2==0 else 1.0):
		if randf() < 0.01:
			return Block.HealBug
		else:
			return current_chunk_block_deck[randi()%len(current_chunk_block_deck)]
	elif randf() < current_chunk_coin_density:
		return current_chunk_coin_deck[randi()%len(current_chunk_coin_deck)]
	else:
		return -1
	
