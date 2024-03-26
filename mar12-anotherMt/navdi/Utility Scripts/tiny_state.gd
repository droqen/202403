# by Pancelor!

class_name TinyState
extends Reference

signal state_changed(old, new)

#signal state_changed(old: int, new: int)

var id: int

func goto(newid: int, force_signal: bool = false) -> void:
	var oldid := id
	if newid != oldid or force_signal:
		id = newid
		emit_signal("state_changed", oldid, newid)
#		state_changed.emit(oldid,newid)

## you can do this manually with .new() etc
## this just makes the common use-case convenient
func _init(newid: int, on_change_owner: Node, on_change_method: String, skip_first_signal: bool = false):
	connect("state_changed", on_change_owner, on_change_method)
	if skip_first_signal:
		id = newid
	else:
		goto(newid,true)
