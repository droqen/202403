extends Node

onready var bank = $"../bank"

var score = 0
var maxscore = 14

onready var labels = [$"../status_label",$"../status_label2"]

func _ready():
	randomize()
	for label in labels: label.text = ""
	call_deferred('spawn_cards', 10)
func spawn_cards(count):
	for i in range(count):
		yield(get_tree().create_timer(0.25 - 0.002 * i * i),"timeout")
		var card : RigidBody2D = bank.spawn("card(physical)", "cards", Vector2(rand_range(50,250),250)).setup()
		card.rotation = rand_range(-.25,.25) * PI
		card.angular_velocity = -card.rotation * rand_range(30,50)
		card.linear_velocity = Vector2(
			rand_range(-50,50) + 2.0*(150-card.position.x),
			rand_range(-100,-50)-0.2*card.position.y)
		$deal.pitch_scale = 1.0 + 0.1 * i
		$deal.play()
func insert_cards(cards):
	for i in range(len(cards)):
		yield(get_tree().create_timer(0.25 - 0.002 * i * i),"timeout")
#		var card : RigidBody2D = bank.spawn("card(physical)", "cards", Vector2(rand_range(50,250),250)).setup()
		var card = cards[i]
		card.position = Vector2(rand_range(50,250),250)
		card.rotation = rand_range(-.25,.25) * PI
		card.angular_velocity = -card.rotation * rand_range(30,50)
		card.linear_velocity = Vector2(
			rand_range(-50,50) + 2.0*(150-card.position.x),
			rand_range(-100,-50)-0.2*card.position.y)
		$deal.pitch_scale = 1.0 + 0.1 * i
		$deal.play()
func discard_cards_randomly(count):
	var cards_group = bank.get_group("cards")
	for i in range(count):
		yield(get_tree().create_timer(0.25 - 0.002 * i * i),"timeout")
		if cards_group.get_child_count() > 0:
			discard_card(cards_group.get_child(randi() % cards_group.get_child_count()), false)
func click_card(card):
	match card.id:
		0: pass # nothing happen
		1: call_deferred('spawn_cards', card.number)
		2: call_deferred('discard_cards_randomly', card.number)
		3:
			var cards = bank.get_group("cards").get_children()
			cards.shuffle()
			for i in range(len(cards)):
				if i < card.number:
					cards[i].dance()
				else:
					call_deferred('discard_card', cards[i], false)
		4:
			for card2 in bank.get_group("cards").get_children():
				var sum = card.number + card2.number
				call_deferred('discard_card', card2, false)
				if sum <= 13:
					bank.spawn("card(physical)", "cards", card2.position).setup(-1, sum)
		5:
			for card2 in bank.get_group("cards").get_children():
				if card2.number > card.number:
					call_deferred('discard_card', card2, false)
					bank.spawn("card(physical)", "cards", card2.position).setup(-1, card2.number)
		6:
			for card2 in bank.get_group("cards").get_children():
				if card2.number > card.number:
					call_deferred('discard_card', card2, false)
					bank.spawn("card(physical)", "cards", card2.position).setup(-1, randi()%int(max(1,card.number)))
	if card.number == score:
		score += 1
		for label in labels: label.text = "%d/%d"%[score,maxscore]
		if score == 14:
			$theme_win.play()
			get_tree().paused = true
			yield($theme_win,"finished")
			get_tree().paused = false
			for label in labels: label.text = "finish"
	elif score > 0 and score < 14:
		$theme_miniloss.play()
		get_tree().paused = true
		yield($theme_miniloss,"finished")
		get_tree().paused = false
		score = 0
		for label in labels: label.text = ""
	discard_card(card, true)
func discard_card(card : Node2D, nicely : bool):
	if nicely:
		$power.play()
	else:
		$trash.play()
	card.discard(nicely)
	bank.get_group("cards").remove_child(card)
	get_parent().add_child(card)
	
	if bank.get_group("cards").get_child_count() == 0:
		yield(get_tree().create_timer(1.0),"timeout")
		$theme_loss.play()
		get_tree().paused = true
		yield($theme_loss,"finished")
		get_tree().paused = false
		for label in labels: label.text = ""
		call_deferred('spawn_cards', 10)
		
