extends Node2D


var age : int = 0
var maxage : int = 10

#func setup(pos):
#	position = pos
#	age = 0
#	maxage += randi() % 10
#	if randf() < 0.15:
#		maxage += 100 + randi() % 40

# Called when the node enters the scene tree for the first time.
func _ready():
	if randf() < 0.25:
		maxage += randi() % 20

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	position += Vector2(rand_range(-1,1),rand_range(0.5,1.0))
	age += 1
	if age >= maxage:
		queue_free()
