extends Resource
class_name StoryBranch

export(String) var action_string : String = "Do Action"
#export(String) var action_description : String = "Details regarding the action"
#export(String) var action_ing : String = "Actioning"
export(String) var fail_string : String = "Failed"
export(float) var action_speed : float = 100.0
export var success_chance : float = 0.25
export(Array,Resource) var success_unlocks_branches = []
export(Array,String) var requires_endings = []

func _init(_action:String,_fail:String,_speed:float,_chance:float,_branches:Array,_requires:Array=[]):
	self.action_string = _action
	self.fail_string = _fail
	self.action_speed = _speed
	self.success_chance = _chance
	self.success_unlocks_branches = _branches
	self.requires_endings = _requires

func require(required_action : String):
	requires_endings.append(required_action)
	return self
