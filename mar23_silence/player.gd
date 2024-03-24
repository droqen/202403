extends NavdiMovingGuy


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pin.process_pins()
	bufs.process_bufs()
	velocity += (pin.stick.normalized()*0.5 - velocity).clamped(0.1)
	process_slidey_move()
