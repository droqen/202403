extends Node

export var chunk_collection : Resource

func _ready():
	randomize()
	get_parent().clear()
	for i in range(10):
		load_chunk_to_roomy(-i)
#	randomize_11s()

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
			get_parent().set_cellv(cell + dxy, [13,14][randi()%2])
	for cell in chunk.get_used_cells_by_id(12):
		get_parent().set_cellv(cell + dxy, [13,14][randi()%2])
		
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

func randomize_11s():
	for cell in get_parent().get_used_cells_by_id(11):
		if randf() < 0.50:
			get_parent().set_cellv(cell, [13,14][randi()%2])
	for cell in get_parent().get_used_cells_by_id(12):
		get_parent().set_cellv(cell, [13,14][randi()%2])
