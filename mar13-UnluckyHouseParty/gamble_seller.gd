extends Node

var lucky
var accepted : bool

func roll(_lucky):
	lucky = _lucky
func get_outcome_message() -> String:
	if not lucky:
		return ""
	elif lucky.hov_length >= 99:
		accepted = false
		return "yer full up\non hover already"
	elif lucky.jump_height - 5 > 0:
		accepted = true
		return "ok, exchangin' a bit,\nthankya"
	else:
		accepted = false
		return "you aint got\nenough jump to sell\neven me"
func apply_outcome():
	if lucky and accepted:
		lucky.jump_height -= 5
		lucky.hov_length += 12
		if lucky.hov_length > 99: lucky.hov_length = 99
		lucky = null
