extends Area2D
class_name NavdiAreaSweeper

signal areas_changed(new_current_areas)

var areas = []

func _ready():
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")
func _on_area_entered(area):
	if not area in areas:
		areas.append(area)
		emit_signal("areas_changed", areas)
func _on_area_exited(area):
	var count = areas.count(area)
	for _i in range(count):
		areas.erase(area)
	if count:
		emit_signal("areas_changed", areas)
