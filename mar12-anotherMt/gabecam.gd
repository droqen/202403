extends Camera2D

onready var gabe = $"../gabe"
export (Color) var normal_colour
export (Color) var flash_colour
enum { FLASHBUF = 77 }
var bufs = Bufs.new([[FLASHBUF,4]])

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	gabe.connect("changed", self, '_on_changed')
	update_gabe_vars()

func _on_changed():
	bufs.on(FLASHBUF)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	bufs.process_bufs()
	if gabe.maxfuel:
		$Label.text = "%03d/%03d\n" % [gabe.fuel, gabe.maxfuel]
	else:
		$Label.text = ""
	if gabe.timerframes > 0:
		$Label.text += "%02d:%02d\n" % [
			gabe.timerframes / 60 / 60,
			(gabe.timerframes / 60) % 60
		]

	if bufs.has(FLASHBUF):
		$Label.modulate = flash_colour
	else:
		$Label.modulate = normal_colour
	var dx = 0
	var dy = 0
	if position.x > 100 and gabe.position.x < position.x - 2: dx = -200
	if gabe.position.y < position.y - 2: dy = -200
	if gabe.position.y > position.y + 200 + 2: dy = 200
	if gabe.position.x > position.x + 200 + 2: dx = 200
	if dx or dy:
		position.x += dx
		position.y += dy
		update_gabe_vars()

func update_gabe_vars():
	gabe.can_airjump = position.x < 300
	gabe.in_waitingroom = position.x < 100 and position.y > 0
	gabe.at_summit = position.x > 300
