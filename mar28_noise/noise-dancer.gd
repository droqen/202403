extends NavdiMovingGuy

onready var maze = $"../maze"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pin.process_pins()
	bufs.process_bufs() # unused?
	var gravity : float = 2.0
	var buoyancy : float = 0.0
	var cell = maze.world_to_map(position)
	match maze.get_cellv(cell):
		10: buoyancy = 4.0
		20: buoyancy = 3.0
		30: buoyancy = 2.0
		40: buoyancy = 1.0
	if position.y > 140: buoyancy += 0.15 * (position.y - 140)
	accel_velocity(pin.stick.x, gravity-buoyancy, 0.05, 0.025 * abs(buoyancy-gravity))
	if pin.stick.x: spr.flip_h = pin.stick.x < 0
	process_slidey_move()
	position.x = fposmod(position.x, 170)

	if position.y <= -5:
		get_tree().paused = true
		$"../win".play()
		position.y = 175
		yield($"../win", "finished")
		for x in range(17):
			for y in range(17):
				match maze.get_cell(x,y):
					10: maze.set_cell(x, y, 20)
					20: maze.set_cell(x, y, 30)
					30: maze.set_cell(x, y, 40)
					40: maze.set_cell(x, y, 50)
		get_tree().paused = false
