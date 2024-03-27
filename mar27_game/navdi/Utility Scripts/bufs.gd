class_name Bufs
extends Reference

var _bufs : Dictionary = Dictionary()
var _bufdefs : Dictionary = Dictionary()

func _init(_starting_bufdefs : Array = []):
	if _starting_bufdefs:
		defons(_starting_bufdefs)

func _setbuf(bufid : int, value : int):
	if value <= 0: _bufs.erase(bufid)
	else: _bufs[bufid] = value
func defon(bufid : int, default_value : int):
	_bufdefs[bufid] = default_value
func defons(buf_def_pairs : Array):
	for bufdef in buf_def_pairs:
		defon(bufdef[0], bufdef[1])
func on(bufid : int):
	setmin(bufid, _bufdefs[bufid])
func addto(bufid : int, value : int):
	_setbuf(bufid,max(0, read(bufid) + value))
func setmin(bufid : int, value : int):
	_setbuf(bufid,max(read(bufid), value))
func clr(bufid : int):
	_setbuf(bufid, 0)
func has(bufid : int) -> bool:
	return _bufs.has(bufid)
func read(bufid : int) -> int:
	return _bufs.get(bufid, 0)
func try_consume(bufids:Array) -> bool:
	for bufid in bufids:
		if read(bufid) <= 0:
			return false
	for bufid in bufids:
		clr(bufid)
	return true
func process_bufs():
	for bufid in _bufs:
		addto(bufid, -1)
	
