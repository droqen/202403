extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var target : Node2D
onready var starting_line : String = $MarchingTextContainer/RichTextLabel.text
export var pitch : float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$MarchingTextContainer.connect("finished", self, "doneprint")
	$MarchingTextContainer.connect("char_marched", self, "_on_mtc_char_marched")
func _on_mtc_char_marched(c):
	get_parent().playvoice(pitch)

func _physics_process(_delta):
	if target:
		if target.position.x != position.x:
			$head.flip_h = target.position.x < position.x
			$body.flip_h = $head.flip_h
		if $MarchingTextContainer.is_done():
			$Pin.process_pins()
			if $Pin.b.pressed:
				$gamble.roll(target)
				var outcome : String = $gamble.get_outcome_message()
				if outcome:
					$MarchingTextContainer.setup($gamble.get_outcome_message())
				else:
					$MarchingTextContainer.setup(starting_line)

func doneprint():
	$gamble.apply_outcome()

func activate(_target):
	target = _target
	get_parent().setcamfoc(self)
	var outcome : String = $gamble.get_outcome_message()
	if outcome:
		$MarchingTextContainer.setup($gamble.get_outcome_message())
	else:
		$MarchingTextContainer.setup(starting_line)

func deactivate():
	get_parent().unsetcamfoc(self)
	$MarchingTextContainer.set_position_start()
	$MarchingTextContainer.pause()
