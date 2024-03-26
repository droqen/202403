extends Node

onready var cam = $"../gabecam"
onready var gabe = $"../gabe"

func _ready():
	$AudioStreamPlayer.play()

var sharpness : float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if gabe.position.y < -630:
		var upness = clamp(inverse_lerp(-630,-700,gabe.position.y),0,1)
		$AudioStreamPlayer.volume_db = lerp($AudioStreamPlayer.volume_db,lerp(-11.362, -70, upness),0.1)
	else:
		$AudioStreamPlayer.volume_db = lerp($AudioStreamPlayer.volume_db,-11.362,0.1)
	var t = OS.get_system_time_msecs() * 0.001
	
	if randf() < 0.01: sharpness = randf()
	if sharpness > 0.0: sharpness -= 0.0
	
	var lowpassfilter : AudioEffectLowPassFilter = AudioServer.get_bus_effect(1, 0)
	if cam.position.x < 200: # waitingroom
		lowpassfilter.cutoff_hz = lerp(lowpassfilter.cutoff_hz, 4000 + 1000 * sin(t), 0.1)
		lowpassfilter.resonance = lerp(lowpassfilter.resonance, 0.1 + sharpness, 0.1)
	elif cam.position.y < -600: # the summit
		lowpassfilter.cutoff_hz = lerp(lowpassfilter.cutoff_hz, 4000 + 1000 * sin(t), 0.1)
		lowpassfilter.resonance = lerp(lowpassfilter.resonance, 0.1 + sharpness, 0.1)
	else: # 
		lowpassfilter.cutoff_hz = lerp(lowpassfilter.cutoff_hz, 1000 + 500 * sin(t), 0.1)
		lowpassfilter.resonance = lerp(lowpassfilter.resonance, 0.1 + sharpness, 0.1)
