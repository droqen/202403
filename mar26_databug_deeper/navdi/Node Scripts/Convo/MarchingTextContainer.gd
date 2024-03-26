tool
extends MarginContainer
class_name MarchingTextContainer

signal char_marched(c)
signal finished()

export(bool)var set_to_zero_on_ready = true
export(bool)var start_playing_on_ready = true

export(String, MULTILINE)var bbcode_text setget _set_bbcode_text, _get_bbcode_text
func _set_bbcode_text(_bbcode_text):
	if has_node('RichTextLabel'):
		$RichTextLabel.bbcode_text = _bbcode_text
		_char_count = len($RichTextLabel.text)
	
func _get_bbcode_text():
	if has_node('RichTextLabel'):
		return $RichTextLabel.bbcode_text

export(float)var delay_per_char = 0.10

export(float)var extra_delay = 0.20

export(String)var extra_delay_chars = "..!!??,"

var _next_char_position: int = 0
onready var _char_delay: float = delay_per_char
var _char_count
var _paused
var _skip_first_process

func setup(_bbcode_text, start_playing = true):
	self.bbcode_text = _bbcode_text
	self.set_position_start()
	if start_playing: self.resume()
	else: self.pause()
	return self

func is_done():
	return _next_char_position >= _char_count
func pause():
	_paused = true
	_char_delay = delay_per_char
func resume():
	_paused = false
func resume_nodelay():
	_paused = false
	_char_delay = 0
func set_position_start():
	_next_char_position = 0
	_char_delay = delay_per_char
	$RichTextLabel.visible_characters = 0
func march(emit = true):
	var c = $RichTextLabel.text[_next_char_position]
	_next_char_position += 1
	if c != '\n':
		$RichTextLabel.visible_characters += 1
	if emit and is_char_visible(c):
		emit_signal("char_marched", c)
	return c
func set_position_end():
	for _i in range(_char_count - _next_char_position):
		march(false)
	pause()
#	if not is_done():
#		_next_char_position = _char_count
#		$RichTextLabel.visible_characters = -1
#		emit_signal("finished")
#		pause()

func get_char_delay(c):
	return delay_per_char + extra_delay * extra_delay_chars.count(c)
func is_char_visible(c):
	match c:
		' ', '\t', "\n":
			return false
		_:
			return true

func _ready():
	_skip_first_process = true
	if not Engine.editor_hint and set_to_zero_on_ready:
		_char_count = len($RichTextLabel.text) # just in case
		set_position_start()
		if start_playing_on_ready: resume()
		else: pause()
		
func _process(delta):
	if not Engine.editor_hint:
		if _skip_first_process:
			delta = 0
			_skip_first_process = false 
		if not _paused:
			_char_delay -= delta
			if is_done():
				pause()
			else: while _char_delay < 0 and not is_done():
				# "march" advances the container inexorably towards is_done()=true.
				_char_delay += get_char_delay(march())
				if is_done():
					emit_signal("finished")
					pause()
