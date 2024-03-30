tool
extends Node

class_name NavdiSettings

export var apply_on_click = false
export var width: int = 100
export var height: int = 100
export var dev_zoom: int = 3
export var bg_color: Color = Color.black
export var project_year: String = "2024"
export var project_month: String = "March"
export var project_day: String = "6"
export var project_name: String = ""
export(String, MULTILINE) var project_desc: String = ""
export var project_icon: Texture = null

var pause_phase : float = 0.0

func _ready():
	if not Engine.editor_hint:
		var calculated_width = ProjectSettings.get("display/window/size/width")
		var calculated_height = ProjectSettings.get("display/window/size/height")
		JavaScript.eval('setGameBaseSize(' + str(calculated_width) + ',' + str(calculated_height) + ');')
		JavaScript.eval('setGameDesc(`' +
			project_desc.replacen("`","'")
#				.replacen("\n",'<br/>')
			+ '`);')
		queue_free()

func _process(_delta):
	if Engine.editor_hint:
		if apply_on_click:
			if project_name == "":
				project_name = generate_fun_project_name()
			apply_on_click = false
			ProjectSettings.set("dynamic_fonts/use_oversampling", false) # stop the errors!
			ProjectSettings.set("network/limits/debugger_stdout/max_errors_per_frame",100)
	#		print("Set max errors per frame to 100")
			ProjectSettings.set("display/window/stretch/mode","viewport")
	#		print("Set stretch mode to 'viewport'")
			ProjectSettings.set("rendering/quality/2d/use_pixel_snap",true)
	#		print("Set 2d/pixel snap to true")
			ProjectSettings.set("display/window/size/width", width)
			ProjectSettings.set("display/window/size/height", height)
			ProjectSettings.set("display/window/size/test_width", width * dev_zoom)
			ProjectSettings.set("display/window/size/test_height", height * dev_zoom)
	#		print("Set width x height to ", width, " x ", height)
			ProjectSettings.set("application/config/name", project_year + ", " + project_month + " " + project_day + ": " + project_name + ".")
			ProjectSettings.set("application/config/description", project_desc)
			
			ProjectSettings.set("application/run/main_scene", get_tree().edited_scene_root.filename)
			
			ProjectSettings.set("rendering/environment/default_clear_color", bg_color)
			ProjectSettings.set("application/boot_splash/bg_color", bg_color)
			
			if project_icon:
				ProjectSettings.set("application/config/icon", project_icon.resource_path)
				ProjectSettings.set("application/boot_splash/image", project_icon.resource_path)
				ProjectSettings.set("application/boot_splash/fullsize", false)
				ProjectSettings.set("application/boot_splash/filter", false)
			
			print("Applied Navdi 2d project settings for '", project_name, "' viewed @ ", width, "x", height)

const VS : Array = [ 'a','e','i','o','u', 'a','e','i','o','u', 'y' ]
const CS : Array = [ 'b','c','d','f','g','h','j','k','l','m','n','p','q','r','s','t','v','x','z', ]

func generate_fun_project_name() -> String:
	var vowel : bool = randf() < 0.15
	var fpn : String = ''
	var letters : int = 6
	if randf() < 0.20: letters -= 1
	if randf() < 0.10: letters += 1
	for _i in range(letters):
		fpn += gen_vowel() if vowel else gen_consonant()
		vowel = not vowel
	return fpn

func gen_vowel() -> String:
	return VS[randi()%len(VS)]
func gen_consonant() -> String:
	return CS[randi()%len(CS)]
