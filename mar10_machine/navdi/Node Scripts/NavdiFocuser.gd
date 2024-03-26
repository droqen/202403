extends Node
class_name NavdiFocuser

export(String)var focus_node_name = "focus"
export(String)var show_func = "show"
export(String)var hide_func = "hide"

var _focus = null
var focus setget set_focus, get_focus
func set_focus(f):
	if _focus != f:
		_focus_node_call(hide_func) # old unfocused
		_focus = f
		_focus_node_call(show_func) # new focused
func get_focus():
	return _focus

func _focus_node_call(callname):
	if _focus and _focus.has_node(focus_node_name):
		_focus.get_node(focus_node_name).call_deferred(callname)
