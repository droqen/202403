class_name Bounds
extends Reference

var _has_points: bool = false
var _min: Vector2
var _max: Vector2

func _init(points):
	_has_points = false
	add_points(points)

func add_points(points):
	for point in points:
		add_point(point)

func add_point(point):
	if _has_points:
		_min.x = min(_min.x, point.x)
		_max.x = max(_max.x, point.x)
		_min.y = min(_min.y, point.y)
		_max.y = max(_max.y, point.y)
	else:
		_has_points = true
		_min = point
		_max = point

func get_center():
	if _has_points:
		return lerp(_min, _max, 0.5)
	else:
		push_error("Bounds has no points")

func get_rect2():
	if _has_points:
		return Rect2(_min, _max - _min)
	else:
		push_error("Bounds has no points")
