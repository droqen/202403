extends KinematicBody2D
class_name NavdiMovingGuy

enum {FLORBUF=5939,JUMPBUF}
var bufs : Bufs = Bufs.new([[FLORBUF, 4]])

onready var spr : SheetSprite = _try_get_spr()
onready var pin : Pin = _try_get_pin()

func _try_get_spr() -> SheetSprite:
	if has_node("SheetSprite"): return $SheetSprite as SheetSprite
	else: return null
func _try_get_pin() -> Pin:
	if has_node("Pin"): return $Pin as Pin
	else: return null

var velocity : Vector2

#func _physics_process(_delta):
#	# please override this completely
#	bufs.process_bufs()
#	process_slidey_move()

func accel_velocity(dvx:float, dvy:float, avx:float, avy:float):
	velocity.x = move_toward(velocity.x, dvx, avx)
	velocity.y = move_toward(velocity.y, dvy, avy)

func process_slidey_move():
	var hit:KinematicCollision2D
	hit = move_and_collide(Vector2(velocity.x, 0))
	if hit: on_bonk_h(hit)
	hit = move_and_collide(Vector2(0, velocity.y))
	if hit: on_bonk_v(hit)
	
func on_bonk_h(hit:KinematicCollision2D):
	velocity.x = 0
func on_bonk_v(hit:KinematicCollision2D):
	if velocity.y >= 0:
		bufs.on(FLORBUF)
	velocity.y = 0
 
