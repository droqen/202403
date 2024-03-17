extends Node2D

onready var bank = $"../bank"

export (Array, Resource) var branches : Array = []
var finished_branches : Array = []

var hand_index : int = 0
var progress : float = 0.0
var progspeed : float = 100.0
var failprog : float = 50.0

enum { CHOOSING, CHOICE_PROGRESS, OUTCOME }

onready var choosest = TinyState.new( CHOOSING, self, "_on_choosest_change" )

func _on_choosest_change(_then,now):
	match now:
		CHOOSING:
			$cursor/curspr.setup([3,3,3,4], 16)
		CHOICE_PROGRESS:
			$cursor/curspr.setup([6,7], 16)

const BRANCH_DEFINITIONS = preload("res://BranchDefScript.gd")

func _ready():
	
	branches = BRANCH_DEFINITIONS.GetStartingBranches()
	
	update_branches()

func update_branches():
	choosest.goto(CHOOSING)
	hand_index = 0
	progress = 0
	for child in $choices.get_children():$choices.remove_child(child)
	$cursor.position = Vector2(0,-10)
	for i in range(len(branches)): bank.spawn("BranchChoice",$choices,Vector2(0,-10)).setup(branches[i])
	for i in range(len(branches)):
		if branches[i].action_string.begins_with("*"):
			continue
		else:
			hand_index = i
			break

func refresh_branch_texts():
	for choice in $choices.get_children(): choice.show_default()

func _physics_process(delta):
	var choice_count = $choices.get_child_count()
	if choice_count > 0:
		$cursor.show()
		var pin = $Pin
		pin.process_pins()
		var dh : int = 0
		if pin.down.pressed: dh += 1
		if pin.up.pressed: dh -= 1
		if dh:
			choosest.goto(CHOOSING)
			progress = 0
			for i in range(100):
				hand_index = posmod(hand_index + dh, len(branches))
				if branches[hand_index].action_string.begins_with("*"): continue
				else: break
			$cursor.position = $choices.get_child(hand_index).position + Vector2.UP * dh * 5
			refresh_branch_texts()
		else:
			var curspos = $choices.get_child(hand_index).position
			if choosest.id == CHOICE_PROGRESS:
				curspos.x += 4
			if choosest.id == CHOOSING:
				curspos.x = max(10, curspos.x - 10)
			$cursor.position = lerp($cursor.position, curspos, 0.5)
		
		for i in range(choice_count):
			$choices.get_child(i).position = lerp($choices.get_child(i).position, get_index_pos(i), 0.25)
		
		if pin.a.pressed:
			choosest.goto(CHOICE_PROGRESS)
			refresh_branch_texts()
			progspeed = branches[hand_index].action_speed * rand_range(0.75, 1.25)
			failprog = -1
			var missing_endings = 0
			for ending in branches[hand_index].requires_endings:
				missing_endings += 1
				for branch in branches:
					if branch.action_string == ending:
						missing_endings -= 1
						break
			if missing_endings > 0 or randf() > branches[hand_index].success_chance:
				failprog = rand_range(25.0,85.0)
		if pin.a.released:
			choosest.goto(CHOOSING)
		
		if choosest.id == CHOICE_PROGRESS:
			
			if failprog > 0 and progress > failprog:
				$choices.get_child(hand_index).show_fail()
				choosest.goto(CHOOSING)
			elif progress < 100.0:
				progress += progspeed * delta
				if randf() < 0.01:
					progspeed *= 1 + randf()
				if randf() < 0.01:
					progspeed *= 1 - randf()*0.5
			else:
				var finished_branch : StoryBranch = branches[hand_index]
				branches.remove(hand_index)
				for new_branch in finished_branch.success_unlocks_branches:
					if new_branch == null: branches.clear()
					else: branches.append(new_branch)
				update_branches()
		else:
			progress *= 0.9
	else:
		$cursor.hide()

func get_index_pos(i) -> Vector2:
	var x = 0
	if i == hand_index:
		x += 10 + pow(progress/100,2)*100 * (2.0 - 0.150)
	return Vector2(x,i*10)
