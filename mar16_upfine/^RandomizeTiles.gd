extends Node

export var chunk_collection : Resource

onready var bank = $"../../bank"

func draw_rand_tile(_context = null) -> int:
	if randf() < 0.6:
		return 17
	return [13,14,15,15,16][randi()%5]

func _ready():
	randomize()
#	get_parent().clear()

#	for i in range(10):
#		load_chunk_to_roomy(-i)

	randomize_11s()
	replace_blanks_with_10s()
	pop_foes()

func pop_foes():
	var r : Rect2 = get_parent().get_used_rect()
	for x in range(r.position.x, r.position.x + r.size.x):
		var empty = false
		for y in range(r.position.y + 1, r.position.y + r.size.y):
			if empty:
				if get_parent().get_cell(x,y) > 10:
					empty = false
					# possible enemy spawn
					if randf() < 0.1:
						bank.call_deferred("spawn",
							"fireball", -1, get_parent().map_to_world(Vector2(x,y-1)) + Vector2(5,5) )
			else:
				if get_parent().get_cell(x,y) <= 10:
					empty = true
func hide(): pass

func build_tower():
	pass

func load_chunk_to_roomy(roomy : int):
	var chunk : TileMap = chunk_collection.chunks[randi()%len(chunk_collection.chunks)].instance()
	var dxy = Vector2(0, roomy * 20)
	for x in range(0,20):
		for y in range(0+roomy*20,20+roomy*20):
			get_parent().set_cell(x,y,10)
	
	# assign tiles
	for cell in chunk.get_used_cells_by_id(11):
		if randf() < 0.50:
			get_parent().set_cellv(cell + dxy, draw_rand_tile())
	for cell in chunk.get_used_cells_by_id(12):
		get_parent().set_cellv(cell + dxy, draw_rand_tile())
		
	# clear orphans.
	for cell in chunk.get_used_cells_by_id(11):
		var has_solid_neighbour = cell.x == 0 or cell.x == 19
		if not has_solid_neighbour:
			for dir in [Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]:
				if get_parent().get_cellv(cell + dxy + dir) >= 11:
					has_solid_neighbour = true
					break
		if not has_solid_neighbour:
			get_parent().set_cellv(cell + dxy, 10) # make nonsolid

func replace_blanks_with_10s():
	var r : Rect2 = get_parent().get_used_rect()
	for x in range(r.position.x, r.position.x + r.size.x):
		for y in range(r.position.y, r.position.y + r.size.y):
			if get_parent().get_cell(x,y) < 0:
				get_parent().set_cell(x,y,10)

func randomize_11s():
	for cell in get_parent().get_used_cells_by_id(11):
		if randf() < 0.50:
			get_parent().set_cellv(cell, draw_rand_tile())
	for cell in get_parent().get_used_cells_by_id(12):
		get_parent().set_cellv(cell, draw_rand_tile())
