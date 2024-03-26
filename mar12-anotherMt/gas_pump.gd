extends Area2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var overlapping_gabe = false
	for body in get_overlapping_bodies():
		if body.name == "gabe":
			overlapping_gabe = true
			$Pin.process_pins()
			if $Pin.down.pressed:
				if body.maxfuel > 100:
					body.maxfuel = 100 * round(body.maxfuel/100.0 - 1)
				else:
					body.maxfuel = 10 * round(body.maxfuel/10.0 - 1)
				if body.maxfuel < 0: body.maxfuel = 0
			if $Pin.up.pressed:
				if body.maxfuel >= 100:
					body.maxfuel = 100 * round(body.maxfuel/100.0 + 1)
				else:
					body.maxfuel = 10 * round(body.maxfuel/10.0 + 1)
				if body.maxfuel > 999: body.maxfuel = 999
			$Label.text = "up/down to adjust fuel\n\n%03d" % body.maxfuel
			if body.fuel != body.maxfuel:
				body.fuel = body.maxfuel
				body.emit_signal("changed")
				
	if overlapping_gabe:
		$Label.show()
	else:
		$Label.hide()
