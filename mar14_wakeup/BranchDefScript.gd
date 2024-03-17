extends Node

static func GetStartingBranches(): 
	return [
		StoryBranch.new("Wake Up", "i don't wanna get up", 50, 0.85, GetPostWakeUpBranches()),
#		StoryBranch.new("Test", "rejected", 200, 0.00, []).require("*key*"),
	]
static func GetPostWakeUpBranches():
	return [
		Ending("*a nameless dread*"),
		StoryBranch.new("Remove Retainer", "", 120, 1.00, [
			StoryBranch.new("Brush Teeth", "", 120, 1.00, [
				StoryBranch.new("Have Breakfast", "can't stomach the idea", 100, 0.50, [Ending("*had breakfast*")])
			]),
		]),
		StoryBranch.new("Look In Mirror", "something behind me?", 120, 0.50, [Ending("*nothing in the mirror*")]),
		StoryBranch.new("Gaze Out Window", "afraid to be noticed", 120, 0.25, [
			StoryBranch.new("Open Front Door", "weak, hungry", 90, 1.00, GetGoOutsideBranches(), ["*had breakfast*"])
		]),
	]
static func GetGoOutsideBranches():
	return [
		StoryBranch.new("Go to School", "too far to walk", 90, 1.00, GetSchoolBranches()).require("*got the car*"),
		StoryBranch.new("Go to Garage", "garage door is a bit jammed", 120, 0.40, [
				StoryBranch.new("Drive Car", "need my keys...", 120, 1.00, 
				[Ending("*got the car*")]
			).require("*found car keys*")
		]),
		StoryBranch.new("Go to Shopping District", "i don't need anything", 80, 0.00, []),
		StoryBranch.new("Go to Park", "", 90, 1.00, [
			StoryBranch.new("Stroll around the Park", "the flowers are dead", 50, 0.75, [
				StoryBranch.new("Feed the Geese", "", 50, 1.00, []),
				StoryBranch.new("Explore Dead Bushes", "a sad sight", 50, 0.75, [Ending("*found car keys*")]),
				StoryBranch.new("Explore Winding Path", "hill is steep", 50, 0.75, []),
			])
		]),
		StoryBranch.new("Go Home", "i don't remember the way", 70, 0.00, []),
		StoryBranch.new("Leave the City", "not without Gordon", 90, 1.00, [
			null,
			StoryBranch.new("Keep Driving", "", 100, 1.00, [
				StoryBranch.new("Keep Driving", "", 50, 1.00, [
					StoryBranch.new("Keep Driving", "", 25, 1.00, [
						
					])
				])
			])
		]).require("*Gordon!*"),
	]
static func GetSchoolBranches():
	return [
		StoryBranch.new("Find Gordon", "cant find Gordon... keep looking", 60, 0.20, [Ending("*Gordon!*")])
	]
static func Ending(endingname):
	return StoryBranch.new(endingname, endingname, 50, 0.00, [])
