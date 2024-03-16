tool
extends NavdiMazeMaster
class_name NavdiFlagEditor

var _s2f = null
var _f2ss: LumpyDictionary = null

const FlagEditorSpritesheet = preload("res://navdi/Node Scripts/Maze/FlagEditor/flags_sprites.png")

func _ready():
	_s2f = null
	rebuild_tileset()

export(Texture)var master_tileset_image = null
export(Vector2)var master_cell_size = Vector2(8,8)
export(bool)var click_to_cleanup_strays = false
export(bool)var click_both_to_clear_all_flags
export(bool)var click_both_to_clear_all_flags_2

func _process(_delta):
	if Engine.editor_hint:
		if click_to_cleanup_strays:
			cleanup_strays()
			click_to_cleanup_strays = false
		if click_both_to_clear_all_flags and click_both_to_clear_all_flags_2:
			clear()
			click_both_to_clear_all_flags = false
			click_both_to_clear_all_flags_2 = false

func cleanup_strays():
	var zone = TileZone.new(Vector2($Tiles.get_hframes(), $Tiles.get_vframes()))
	for cell in get_used_cells():
		if not zone.has_point(cell):
			set_cellv(cell, -1)

func apply():
	if $Tiles.tileset_image != master_tileset_image:
		self.tileset_image = FlagEditorSpritesheet
		rebuild_tileset()
		clear()
	else:
		rebuild_tileset()

func load_tileset_image(image):
	print("load tileset image")
	self.master_tileset_image = image
	apply()

func rebuild_tileset():
	self.tileset_image = FlagEditorSpritesheet
	self.cell_size = Vector2(16, 16)
	
	.rebuild_tileset()
	
	$Tiles.clear()
	$Tiles.tileset_image = master_tileset_image
	$Tiles.cell_size = master_cell_size
	$Tiles.rebuild_tileset()
	var i = 0
	for y in range(0, $Tiles.get_vframes()):
		for x in range(0, $Tiles.get_hframes()):
			$Tiles.set_cell(x, y, i)
			i += 1
	self.scale = master_cell_size / self.cell_size
	$Tiles.scale = Vector2.ONE / self.scale # invert scale
func _init_s2f2ss():
	if _s2f == null or _f2ss == null:
		rebuild_tileset()
		_s2f = Dictionary()
		_f2ss = LumpyDictionary.new()
		var sid = 0
		
		for y in range(0, $Tiles.get_vframes()):
			for x in range(0, $Tiles.get_hframes()):
				var flag = self.get_cell(x, y)
				_s2f[sid] = flag
				_f2ss.lump_add(flag, sid)
				sid += 1
func get_sids_to_flags():
	_init_s2f2ss()
	return _s2f
func get_flags_to_sids():
	_init_s2f2ss()
	return _f2ss
