extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var headid : int = 0
var headid_movex : int = 0
onready var gameworld = $"../gameworld"

var requested_start : bool = false
var start_timer : int = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	headid = randi()%5
	get_parent().call_deferred('remove_child',gameworld)
	$press_x_label.hide()
	$headspot/spr.setup([headid])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	
	var pin = $Pin
	pin.process_pins()
	
	if requested_start:
		start_timer -= 1
		if start_timer < 0:
			get_parent().add_child(gameworld)
			gameworld.get_node("lucky/headspr").setup([headid])
			if $bod.flip_h:
				gameworld.get_node("lucky").facest.goto(-1)
			queue_free()
		pin.clear()
	
	if headid_movex != 0:
		$headspot/spr.position.x += headid_movex
		headid_movex = 0
	
	$headspot/spr.setup([headid])
	$headspot/spr.position *= 0.8
	
	var dir : int = 0
	
	if pin.left.pressed: dir = -1
	if pin.right.pressed: dir = 1
	
	if dir:
		if dir > 0:
			$right.play()
		else:
			$left.play()
		headid = posmod(headid + dir, 5)
		$headspot/spr.position.x = -4 * dir
		headid_movex = 8 * dir
		$bod.flip_h = dir < 0
		$headspot/spr.flip_h = dir < 0
		$press_x_label.show()
	elif pin.b.pressed:
		if $press_x_label.visible:
			$done.play()
			requested_start = true
			$you_are_label.hide()
			$press_x_label.hide()
			$headspot/spr/lucky_label.hide()
			$bod.set_frame_period(99999)
		else:
			$press_x_label.show()
