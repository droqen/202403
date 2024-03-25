extends Camera2D

onready var player = $"../YSort/orange"
onready var world = get_parent()

signal gridpos_change(cx,cy)

var cx = 0
var cy = 0
var loading = false

func _physics_process(_delta):
	var cx2 = floor(player.position.x / 200.0)
	var cy2 = floor(player.position.y / 200.0)
	if cx2 != cx or cy2 != cy:
		player.velocity.x = cx2-cx
		player.velocity.y = cy2-cy
		cx = cx2
		cy = cy2
		position = Vector2(cx,cy)*200.0
		emit_signal("gridpos_change", cx, cy)
		load_next_screen()

func load_next_screen():
	if not loading:
		loading = true
		get_tree().paused = true
		world.hide()
		if cx > 7:
			return # never unpause.
		yield(get_tree().create_timer(1.0),"timeout")
		get_tree().paused = false
		yield(get_tree().create_timer(rand_range(0.0,0.15)),"timeout")
		world.show()
		loading = false
		
