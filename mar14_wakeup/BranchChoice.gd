extends Node2D

export var nice_colour : Color
export var item_colour : Color
export var fail_colour : Color

var _branch : StoryBranch

func setup(branch : StoryBranch):
	_branch = branch
	show_default()

func show_default():
	modulate = item_colour if _branch.action_string.begins_with("*") else nice_colour
	$Label.text = _branch.action_string

func show_fail():
	modulate = fail_colour
	$Label.text = _branch.fail_string
