extends Area2D


func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	
func _on_body_entered(body):
	get_parent().activate(body)
func _on_body_exited(_body):
	get_parent().deactivate()
