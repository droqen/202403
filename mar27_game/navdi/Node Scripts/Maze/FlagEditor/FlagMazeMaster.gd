tool
extends NavdiMazeMaster
class_name NavdiFlagMazeMaster

var _s2f = null
var _f2ss: LumpyDictionary = null
var _sid_floor = 0
var _sids_object = []

enum Flag {
	Floor = 0,
	SpawnObject = 2,
	DefaultFloor = 20,
}

const FlagEditorScene = preload("res://navdi/Node Scripts/Maze/FlagEditor/FlagEditorScene.tscn")

export var solid_flag_ids = [1, 10]

var flag_editors_parent = null
export(NodePath)var flag_editors_parent_path = "."
export(String) var flag_editor_name = ""

func get_cellvalue_flag(cellvalue):
	if _s2f and _s2f.has(cellvalue):
		return _s2f[cellvalue]
	else:
		return -1
		
func get_used_cells_by_flag(flagvalue):
	var used_cells = []
	for cellid in _s2f.keys():
		if _s2f[cellid] == flagvalue:
			used_cells += get_used_cells_by_id(cellid)
	return used_cells

func _ready():
	if not Engine.editor_hint:
		if not flag_editors_parent: flag_editors_parent = get_node(flag_editors_parent_path)
		if flag_editors_parent.has_node(flag_editor_name):
			flagmaze_setup(flag_editors_parent.get_node(flag_editor_name))
		for child in flag_editors_parent.get_children():
			if child.name == flag_editor_name:
				child.call_deferred("hide") # hide all flag editors

func flagmaze_setup(flag_editor: NavdiFlagEditor):
	self.flag_editor_name = flag_editor.name
	self._s2f = flag_editor.get_sids_to_flags()
	self._f2ss = flag_editor.get_flags_to_sids()
	var floorSids = _f2ss.lump_get_all(Flag.DefaultFloor)
	if floorSids and len(floorSids): _sid_floor = floorSids[0]
	var objectSids = _f2ss.lump_get_all(Flag.SpawnObject)
	if objectSids and len(objectSids): _sids_object = objectSids
	rebuild_tileset()
	return self
	
func flagmaze_clear():
	self.tileset_image = null
	
func load_objects_from_leveldata(leveldata):
	var x = 0
	var y = 0
	var w = leveldata.get_width()
	for i in range(leveldata.get_area()):
		if leveldata._tiles[i] - 1 in _sids_object:
			leveldata.objects.append(MazeObjectData.new(
				leveldata._tiles[i] - 1, map_to_center(Vector2(x, y))))
			leveldata._tiles[i] = _sid_floor + 1
		x += 1
		if x >= w:
			x -= w
			y += 1
	.load_objects_from_leveldata(leveldata)
	
func load_tileset_image(image): # override
	self.tileset_image = image
	var raw_png_name = tileset_image.resource_path.rsplit("/", false, 1)[1].rsplit(".", false, 1)[0]
	var flag_editor
	if not flag_editors_parent: flag_editors_parent = get_node(flag_editors_parent_path)
	if not flag_editors_parent.has_node(raw_png_name):
		flag_editor = FlagEditorScene.instance()
		flag_editor.name = raw_png_name
		flag_editors_parent.add_child(flag_editor)
		flag_editor.set_owner(flag_editors_parent.owner)
		flag_editor.load_tileset_image(image)
	else:
		flag_editor = flag_editors_parent.get_node(raw_png_name)
	flagmaze_setup(flag_editor)

# override
func _is_cellvalue_collision(cellvalue):
	return get_cellvalue_flag(cellvalue) in solid_flag_ids

func _astar_is_cellvalue_obstacle(cellvalue):
	return _is_cellvalue_collision(cellvalue)

func apply():
	.apply()
	if not flag_editors_parent: flag_editors_parent = get_node(flag_editors_parent_path)
	if flag_editors_parent and flag_editors_parent.has_node(flag_editor_name):
		var flag_editor : NavdiFlagEditor = flag_editors_parent.get_node(flag_editor_name)
		if flag_editor.master_tileset_image != self.tileset_image:
			flag_editor.master_tileset_image = self.tileset_image
			flag_editor.apply()
	else:
		push_warning("FlagMazeMaster "+name+" can't find flag editor")
