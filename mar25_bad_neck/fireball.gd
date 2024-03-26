extends Area2D

var dead = false
var timespawned : int = 0
var timedead : int = 0
var faceleft : bool = true

func _ready():
	$SheetSprite.position.x = 5 if faceleft else -5
	$SheetSprite.setup([13])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if timespawned < 10:
		timespawned += 1
		$SheetSprite.position.x += -0.4 if faceleft else 0.4
		if timespawned >= 10:
			$SheetSprite.position.x = 0
			$SheetSprite.setup([14,15,16],7)
	elif dead:
		timedead += 1
		if timedead > 23:
			queue_free()
	else:
		position.x += -1.0 if faceleft else 1.0
		if get_overlapping_bodies():
			dead = true
			$SheetSprite.setup([17,18,19],8)
			for body in get_overlapping_bodies():
				if body.has_method("toast"): body.toast()

func flip():
	faceleft = not faceleft
	$SheetSprite.flip_h = not $SheetSprite.flip_h
	$SheetSprite.position.x = 5 if faceleft else -5
