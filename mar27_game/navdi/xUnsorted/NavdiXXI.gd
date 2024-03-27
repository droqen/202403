extends Node
class_name NavdiXXI

var bank:Node

var currentStateName = null
var currentState = self
var states = null
	
func spawn(node_name, group_name=null, position=null):
	if not bank:
		print("cannot spawn "+node_name+" (init_bank has not been called)")
	if bank.has_node(node_name):
		if group_name==null: group_name=node_name+"s"
		var group = get_group(group_name)
		var n = bank.get_node(node_name).duplicate()
		group.add_child(n)
		if position!=null: n.position = position
		return n
	else:
		print("cannot spawn "+node_name+" (it is not in the bank)")
	
func get_group(group_name) -> Node:
	if not currentState.has_node(group_name):
		var node = Node.new()
		node.set_name(group_name)
		currentState.add_child(node)
	return currentState.get_node(group_name)
	
func queue_free_group(group_name):
	var group = get_group(group_name)
	for i in range(group.get_child_count()):
		group.get_child(i).queue_free()

func init_bank(bank_name = "bank"):
	bank = get_node("bank")
	remove_child(bank)
	
func init_states(stateNames):
	states = Dictionary()
	for stateName in stateNames:
		states[stateName] = get_node(stateName)
	set_state(stateNames[0])
		
func set_state(targetStateName):
	if currentStateName != targetStateName:
		if states.has(targetStateName):
			for stateName in states.keys():
				var state = states[stateName]
				if stateName == targetStateName:
					add_child(state)
					currentStateName = stateName
					currentState = state
				else:
					remove_child(state)
		else:
			print("set_state(", targetStateName, ") failed - no such state exists.")
	else:
		pass # already that state
	
func is_state(stateName):
	return currentStateName != stateName
