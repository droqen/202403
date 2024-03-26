extends Node

var rolled : bool = false
var rollval : int = 0

var lucky

func roll(_lucky):
	rollval = randi() % 6 + 1
	lucky = _lucky
func get_outcome_message() -> String:
	if not lucky: return ""
	if lucky.jump_height < 5:
		rollval = 7
		return "oof, ya busted. here, just have some jump."
	if lucky.jump_height >= 40:
		rollval = 0
		return "too rich\nfor my blood\ncome back later\nwhen yer low"
	if rollval > 3:
		return "rollin' . . . %d.\nyou got some jump!" % rollval
	elif rollval == 3:
		return "rollin' . . . lucky 3!\nyer set to 30."
	else:
		if lucky.jump_height - (rollval*10) < 0:
			return "rollin' . . . %d.\nyou shoulda lost\nbut yer outta jump\nso whatever" % rollval
		else:
			return "rollin' . . . %d.\nok, you LOST some." % rollval
		
func apply_outcome():
	if lucky:
		if rollval == 7:
			lucky.jump_height = 20
		elif rollval > 3:
			lucky.jump_height += rollval
		elif rollval == 3:
			lucky.jump_height = 30
		elif rollval > 0:
			if lucky.jump_height - (rollval*10) < 0:
				pass
			else:
				lucky.jump_height -= rollval * 10
		lucky = null
