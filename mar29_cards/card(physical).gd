extends RigidBody2D

var id : int = 0
var number : int = 0
var discarded : bool = false
var discarded_nicely : bool = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const ANIMALS = ["cat", "worm", "egg", "crow", "ant", "eye", "horse", "otter", "husky", "orc", "squid", "kid", "gull", "death"]
const ANIMALS_PLURAL = ["cats", "worms", "eggs", "crows", "ants", "eyes", "horses", "otters", "huskies", "orcs", "squids", "kids", "gulls", "deaths"]
const NUMBERS = ["none", "one", "two", "three", "four", "five", "hex", "seven", "eight", "nine", "ten", "leven", "dozen", "13"]
const NUMBERS_PLURAL = ["nones", "ones", "twos", "threes", "fours", "fives", "hexes", "sevens", "eights", "nines", "tens", "levens", "dozens", "13s"]

func setup(force_id = -1, force_number = -1):
	id = randi() % (6+1)
	number = randi() % (13+1)
	if force_id >= 0: id = force_id
	if force_number >= 0: number = force_number
	match id:
		0: say(ANIMALS[number]+" "+NUMBERS[number])
		1: say(NUMBERS[number]+" of draws")
		2: say(NUMBERS[number]+" of trash")
		3: say("dance with "+NUMBERS[number])
		4: say("raise em by "+NUMBERS_PLURAL[number])
		5: say("mix above "+NUMBERS_PLURAL[number])
		6: say("only under "+ANIMALS_PLURAL[number])
	$NumberLabel.text = str(number)
	$NumberLabel2.text = str(number)
	return self

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if discarded:
		if visible and (not discarded_nicely or randf()<0.25): hide()
		elif not visible and (discarded_nicely or randf()<0.25): show()
		if position.y > 220:
			queue_free()
	else:
		if abs(angular_velocity) < 10:
			angular_velocity *= 0.95 # damping
			angular_velocity -= rotation * lerp(1, 0, abs(angular_velocity) / 10)
		
		if position.y > 200:
			linear_velocity.y -= 10
		for body in $repelzone.get_overlapping_bodies():
			var away_from_body = position - body.position
			linear_velocity += away_from_body.normalized() * 500.0 / max(away_from_body.length_squared(), 100.0)


func say(text:String):
	$Label.text = text

func show_hover():
	$hover.show()
	get_parent().move_child(self, get_parent().get_child_count()-1)
func hide_hover():
	$hover.hide()

func dance():
	angular_velocity = rand_range(5, 8) * sign(randf()-.5)
	linear_velocity = Vector2.UP.rotated( rand_range(.3,.4) * sign(randf()-.5) ) * rand_range(130, 150)

func discard(nicely:bool):
	hide_hover()
	discarded = true
	angular_damp = 0
	linear_damp = 0
	$CollisionShape2D.disabled = true
	$repelzone/CollisionShape2D.disabled = true
	angular_velocity = rand_range(5, 8) * sign(randf()-.5)
	linear_velocity = Vector2.UP.rotated( rand_range(.3,.4) * sign(randf()-.5) ) * rand_range(130, 150)
	gravity_scale = 3.0
	if nicely:
		discarded_nicely = true
		gravity_scale = 2.0
		angular_velocity *= 0.1	
	z_index = 3
	
