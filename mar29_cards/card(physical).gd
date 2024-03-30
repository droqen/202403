extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if abs(angular_velocity) < 10:
		angular_velocity *= 0.95 # damping
		angular_velocity -= rotation * lerp(1, 0, abs(angular_velocity) / 10)
	
	if position.y > 200:
		linear_velocity.y -= 10
	for body in $repelzone.get_overlapping_bodies():
		var away_from_body = position - body.position
		linear_velocity += away_from_body.normalized() * 500.0 / max(away_from_body.length_squared(), 100.0)


func rename(text:String):
	$Label.text = text

func show_hover():
	$hover.show()
	get_parent().move_child(self, get_parent().get_child_count()-1)
func hide_hover():
	$hover.hide()
