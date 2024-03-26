extends Node2D

var age : int = 0

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	age += 1
	for child in get_children():
		child.position += child.position.normalized() * 0.25
	if age > 25:
		queue_free()
