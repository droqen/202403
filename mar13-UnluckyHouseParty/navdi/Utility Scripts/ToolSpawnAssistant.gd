class_name ToolSpawnAssistant

var packed_scene
var parent

func _init(packed_scene, parent):
	self.packed_scene = packed_scene
	self.parent = parent
	
func clear_all():
	for child in parent.get_children():
		child.call_deferred("free")
	
func spawn():
	var scene = self.packed_scene.instance()
	self.parent.add_child(scene)
	scene.set_owner(self.parent.owner)
	return scene
