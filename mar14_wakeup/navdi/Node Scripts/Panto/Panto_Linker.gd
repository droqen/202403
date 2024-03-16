tool
extends NavdiPantograph
class_name Panto_Linker

export var models_to_link: String = ""
export var apply_model_links: bool = false

func apply_pending_links():
	if apply_model_links:
		apply_model_links = false
		var model_names = models_to_link.split(",")
		var models = []
		for mname in model_names:
			print(mname, "?")
			if get_node(ModelsNode).has_node(mname):
				print(mname, " found.")
				models.append(get_node(ModelsNode).get_node(mname))
		for i in range(len(models) - 1):
			for j in range(i + 1, len(models)):
				link_models(models[i], models[j])
#		models_to_link = ""

func link_models(m1, m2):
	var linkview = get_view(model_pair(m1, m2))
	print("linked models ", m1.name, " & ", m2.name, " - ", linkview.get_parent().name)

func model_pair(m1, m2):
	if m1.name < m2.name:
		return [m1.name, m2.name]
	else:
		return [m2.name, m1.name]

func get_model_link_view(m1, m2):
	return try_get_view(get_view_name(model_pair(m1, m2)))

func get_linked_views(m1):
	var linked_views = []
	for m2 in get_models():
		var possible_linked_view = try_get_view(get_view_name(model_pair(m1, m2)))
		if possible_linked_view:
			linked_views.append(possible_linked_view)
	return linked_views

func try_get_model(model_name):
	if get_node(ModelsNode).has_node(model_name):
		return get_node(ModelsNode).get_node(model_name)
	else:
		return null

# OVERRIDE from NavdiPantograph.gd
func cleanup_all():
	for linkview in get_children():
		var model_names = get_views_linked_model_names(linkview)
		var m1 = try_get_model(model_names[0])
		var m2 = try_get_model(model_names[1])
		if m1 and m2:
			pass # same as refresh_all except this.
		else:
			if m1: m1.links.erase(linkview)
			if m2: m2.links.erase(linkview)
			linkview.queue_free()

# OVERRIDE from NavdiPantograph.gd
func refresh_all():
	apply_pending_links()
	for linkview in get_children():
		var model_names = get_views_linked_model_names(linkview)
		var m1 = try_get_model(model_names[0])
		var m2 = try_get_model(model_names[1])
		if m1 and m2:
			linkview.call_deferred("refresh_models", m1, m2)
		else:
			linkview.queue_free() # one or both models are missing: the link is broken
	emit_signal("refreshed_all")

# OVERRIDE from NavdiPantograph.gd
func refresh_model(model):
	print("Panto_Linker.gd - refresh_model is not allowed")

# OVERRIDE from NavdiPantograph.gd
func get_view_name(modelpair):
	if "," in modelpair[0] or "," in modelpair[1]:
		print("***Panto_Linker.gd error 10*** - models can't have commas in their names")
		return "***Panto_Linker.gd error 10***"
	return str(modelpair[0]) + "," + str(modelpair[1])

func get_views_linked_model_names(view):
	var model_names = view.name.split(",")
	return model_names
