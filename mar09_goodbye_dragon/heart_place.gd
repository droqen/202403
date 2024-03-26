extends Node2D

export(NodePath)var a
export(NodePath)var b
var t : float = 0.0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var v : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	t += 0.01
	var targetpos = (get_node(a).global_position + get_node(b).global_position) * 0.5 + Vector2.UP * (25 + 5 * sin(t))
	v += 0.05 * (targetpos - position)
	v *= 0.8
	position += v
