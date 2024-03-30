extends Node2D


var velocity = Vector2(0,0)

var hovered = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var pin = $Pin
	pin.process_pins()
	var goal_velocity = pin.stick * 2.0
	var accel = 0.15
	velocity += (goal_velocity - velocity).clamped(accel)
#	velocity *= 0.95
	position += velocity
	rotation = lerp(rotation, velocity.x * 0.10, 0.1)
	var cards_here = $pointzone.get_overlapping_bodies()	
	if hovered:
		if not hovered in cards_here:
			hovered.hide_hover()
			hovered = null
	else:
		if cards_here:
			hovered = cards_here[0]
			hovered.show_hover()
