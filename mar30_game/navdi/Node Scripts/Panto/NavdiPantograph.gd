tool
extends BasePantograph
class_name NavdiPantograph

signal refreshed_all

export (NodePath) var ModelsNode

export (PackedScene) var ViewPrefabScene

export (bool) var cleanup_now = false
export (bool) var refresh_now = false
export (float) var refresh_period = 0

var _refresh_timer = 0

func get_models():
	return get_node(ModelsNode).get_children()

func _process(delta):
	if cleanup_now:
		cleanup_now = false
		cleanup_all()
	
	if refresh_now:
		refresh_now = false
		refresh_all()
	elif refresh_period > 0:
		_refresh_timer += delta
		if _refresh_timer >= refresh_period:
			_refresh_timer = 0
			refresh_all()

func cleanup_all():
	var expected_view_names = PoolStringArray()
	for model in get_models():
		expected_view_names.append(get_view_name(model))
	for view in get_children():
		if not view.name in expected_view_names:
			view.queue_free()

func refresh_all():
	for model in get_models():
		refresh_model(model)
	emit_signal("refreshed_all")

func refresh_model(model):
	var view = get_view(model)
	if view: view.call_deferred("refresh_model", model)

func get_view_name(model):
	return "v->" + str(model.name)

func get_view(model):
	var view_name = get_view_name(model)
	if not has_node(view_name):
		if not spawn_view(view_name):
			print("NavdiPantograph.gd - bad get_view call (use try_get_view if NULL return is desired)")
			return null # error
	return get_node(view_name)

func try_get_view(model):
	var view_name = get_view_name(model)
	if not has_node(view_name):
#		if not spawn_view(view_name):
			return null # not error
	return get_node(view_name)

func spawn_view(view_name):
	if ViewPrefabScene:
		var view = ViewPrefabScene.instance()
		view.name = view_name
		add_child(view)
		view.set_owner(owner)
		return view # not necessary?
	else:
		print("NavdiPantograph.gd - spawn_view failed (ViewPrefabScene export not set)")
		return null
