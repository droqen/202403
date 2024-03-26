tool

extends Sprite
class_name SheetSprite

export (Resource) var sprite_sheet
export (Array, int) var _frames = [0]
export (int) var _frame_period : int = 8

var _ss_ani : int = 0
var _ss_index : int = 0

func setup(__frames : Array, __frame_period : int = 0):
	if _frames != __frames:
		_frames = __frames
		_ss_ani = 0
		_ss_index = 0#_ss_index % len(_frames)
		frame = _frames[_ss_index]
	if _frame_period != __frame_period:
		_frame_period = __frame_period

func set_frames(__frames : Array):
	if _frames != __frames:
		_frames = __frames
		_ss_ani = 0
		_ss_index = _ss_index % len(_frames)
		frame = _frames[_ss_index]

func set_frame_period(__frame_period : int):
	if _frame_period != __frame_period: # dont reset
		_frame_period = __frame_period

func _ready():
	_ss_ani = 0
	_ss_index = 0
	frame = _frames[_ss_index]

func _process(_delta):
	if sprite_sheet:
		if texture != sprite_sheet.texture:
			texture = sprite_sheet.texture
		if hframes != sprite_sheet.hframes:
			hframes = sprite_sheet.hframes
		if vframes != sprite_sheet.vframes:
			vframes = sprite_sheet.vframes

func _physics_process(_delta):
	if _frame_period != 0 and len(_frames):
		_ss_ani += 1
		if _ss_ani > _frame_period:
			_ss_ani = 0
			set_frame_index(_ss_index+1)
func set_frame_index(index):
	_ss_ani = 0
	_ss_index = (index) % len(_frames)
	frame = _frames[_ss_index]
