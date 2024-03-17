tool
extends Node2D
class_name PreviewGrid

export var cell_width : int = 100
export var cell_height : int = 100
export var grid_width : int = 2
export var grid_height : int = 2
export var grid_colour : Color = Color(1, 0, 1, 0.10)
export var visible_in_play_mode : bool = false

func _ready():
	if not visible_in_play_mode and not Engine.editor_hint:
		hide()

func _draw():
	for y in range(grid_height):
		for x in range(grid_width):
			draw_rect(Rect2(x * cell_width, y * cell_height, cell_width, cell_height), grid_colour, false, 2.0)
