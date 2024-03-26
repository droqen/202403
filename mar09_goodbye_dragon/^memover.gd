extends Node

export(NodePath)var follow_screen_x_of

var vx : float
var target_x : float
onready var mst = TinyState.new(-1, self, "_on_mst_change")
func _on_mst_change(_then,now):
	match now:
		-1:
			get_parent().flip_h = true
			target_x = 86 + randi()%(94-86+1)
		1:
			get_parent().flip_h = false
			target_x = 101 + randi()%(104-101+1)

func _physics_process(_delta):
	var stick = 0
	match get_node(follow_screen_x_of).screen_x:
		0: mst.goto(-1)
		1: mst.goto(1)
	if mst.id < 0:
		if get_parent().position.x - 1 > target_x:
			stick = -1
	if mst.id > 0:
		if get_parent().position.x + 1 < target_x:
			stick = 1
	vx = move_toward(vx, stick * 0.40, 0.10)
	if stick:
		get_parent().setup([37,34,38,34],5)
	else:
		get_parent().setup([34,35],13)
	get_parent().position.x += vx
