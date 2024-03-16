extends Node2D

var velocity
var rotvel
var age = 0
var maxage = 20

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector2(rand_range(-0.5,0.5), rand_range(-1.0,-0.4))
	rotvel = rand_range(-0.1,0.1)
	rotation += rotvel * randf() * 5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	velocity.y += 0.05
	position += velocity
	rotation += rotvel
	age += 1
	if age > maxage: queue_free()
