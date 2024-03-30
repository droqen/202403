extends Node2D

onready var cardmgr = $"../card_sssspawner"

enum { CLICKBUF }
onready var bufs = Bufs.new([[CLICKBUF,9]])

var velocity = Vector2(0,0)

var hovered = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var pin = $Pin
	pin.process_pins()
	bufs.process_bufs()
	if bufs.has(CLICKBUF):
		$SheetSprite.setup([88,79],5)
		velocity *= 0
	else:
		$SheetSprite.setup([77])
		var goal_velocity = pin.stick * 2.0
		var accel = 0.15
		velocity += (goal_velocity - velocity).clamped(accel)
#	velocity *= 0.95
	position += velocity
	rotation = lerp(rotation, (velocity.x-velocity.y) * 0.05, 0.1)
	var cards_here = $pointzone.get_overlapping_bodies()
	if hovered:
		if pin.a.pressed:
			bufs.on(CLICKBUF)
			cardmgr.click_card(hovered)
			hovered = null
#			hovered.discard()
			# do something
		else:
			if not hovered in cards_here:
				hovered.hide_hover()
				hovered = null
	else:
		if pin.a.pressed:
			bufs.on(CLICKBUF)
			$click.play()
		elif cards_here:
			hovered = cards_here[0]
			hovered.show_hover()
