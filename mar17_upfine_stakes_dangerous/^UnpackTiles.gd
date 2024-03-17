extends Node

onready var maze = get_parent()
onready var bank = $"../../bank"
func _ready():
	replace_blanks_with_10s()
	call_deferred("unpack_foes")
func replace_blanks_with_10s():
	var r : Rect2 = get_parent().get_used_rect()
	for x in range(r.position.x, r.position.x + r.size.x):
		for y in range(r.position.y, r.position.y + r.size.y):
			if get_parent().get_cell(x,y) < 0:
				get_parent().set_cell(x,y,10)
func unpack_foes():
	var r : Rect2 = get_parent().get_used_rect()
	for x in range(r.position.x, r.position.x + r.size.x):
		for y in range(r.position.y, r.position.y + r.size.y):
			match get_parent().get_cell(x,y):
				32:
					get_parent().set_cell(x,y,10)
					bank.spawn("fireball", -1, get_parent().map_to_world(Vector2(x,y)) + Vector2(5,5) )
